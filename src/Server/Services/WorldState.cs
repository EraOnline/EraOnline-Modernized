using System.Collections.Concurrent;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using EraOnline.Shared.Constants;
using EraOnline.Shared.Models;

namespace EraOnline.Server.Services;

/// <summary>
/// Holds all live game state in memory. Replaces VB6 UserList(), MapData(), etc.
/// Registered as singleton. All access is through this service.
/// </summary>
public class WorldState
{
    private readonly GameDataService _gameData;
    private readonly ILogger<WorldState> _logger;
    private readonly string _charPath;

    // Online players indexed by connection ID
    private readonly ConcurrentDictionary<string, PlayerState> _playersByConnection = new();

    // Online players indexed by char index (for broadcasting)
    private readonly ConcurrentDictionary<int, PlayerState> _playersByCharIndex = new();

    // Next available char index (VB6: NextOpenCharIndex)
    private int _nextCharIndex = 1;

    // Map tile occupancy: map -> (x,y) -> charIndex. Prevents two characters on same tile.
    // VB6: MapData(map, x, y).userindex
    private readonly ConcurrentDictionary<int, ConcurrentDictionary<(int x, int y), int>> _mapOccupancy = new();

    public WorldState(GameDataService gameData, IConfiguration config, ILogger<WorldState> logger)
    {
        _gameData = gameData;
        _logger = logger;
        _charPath = config.GetValue<string>("CharacterPath") ?? Path.Combine(Directory.GetCurrentDirectory(), "characters");
        Directory.CreateDirectory(_charPath);
    }

    // --- Character Persistence ---

    private string CharFilePath(string name) =>
        Path.Combine(_charPath, name.ToUpperInvariant() + ".json");

    public bool CharacterExists(string name) =>
        File.Exists(CharFilePath(name));

    public async Task<CharacterData?> LoadCharacter(string name)
    {
        var path = CharFilePath(name);
        if (!File.Exists(path)) return null;
        await using var stream = File.OpenRead(path);
        return await JsonSerializer.DeserializeAsync<CharacterData>(stream);
    }

    public async Task SaveCharacter(CharacterData character)
    {
        var path = CharFilePath(character.Name);
        await using var stream = File.Create(path);
        await JsonSerializer.SerializeAsync(stream, character, new JsonSerializerOptions { WriteIndented = true });
    }

    public static string HashPassword(string password)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
        return Convert.ToHexStringLower(bytes);
    }

    // --- Head Assignment (VB6: ConnectNewUser random head per race/gender) ---

    public static int RandomHead(string race, string gender)
    {
        return (race, gender) switch
        {
            ("Human", "Male") => Random.Shared.Next(6, 16),
            ("Human", "Female") => Random.Shared.Next(16, 26),
            ("Haaki", "Male") => Random.Shared.Next(26, 36),
            ("Haaki", "Female") => Random.Shared.Next(36, 46),
            ("Wood Elf", "Male") => Random.Shared.Next(46, 56),
            ("Wood Elf", "Female") => Random.Shared.Next(56, 66),
            ("Dark Elf", "Male") => Random.Shared.Next(66, 75),
            ("Dark Elf", "Female") => Random.Shared.Next(75, 85),
            _ => Random.Shared.Next(6, 16) // default to human male
        };
    }

    // --- Starting Position ---

    public (int map, int x, int y) GetStartingPosition(string? race = null)
    {
        // Default to Castlefall for now (most popular starting city)
        var city = _gameData.Config.StartingCities.FirstOrDefault(c => c.Name == "Castlefall")
                   ?? _gameData.Config.StartingCities.FirstOrDefault();
        if (city != null)
            return (city.Map, city.X, city.Y);
        return (81, 59, 41); // hardcoded fallback
    }

    // --- Player Connection ---

    public int AllocateCharIndex()
    {
        return Interlocked.Increment(ref _nextCharIndex);
    }

    public PlayerState AddPlayer(string connectionId, CharacterData character, int charIndex, int map, int x, int y)
    {
        var player = new PlayerState
        {
            ConnectionId = connectionId,
            Character = character,
            CharIndex = charIndex,
            Map = map,
            X = x,
            Y = y,
            Heading = (int)Direction.South
        };

        _playersByConnection[connectionId] = player;
        _playersByCharIndex[charIndex] = player;

        // Occupy tile
        SetTileOccupant(map, x, y, charIndex);

        _logger.LogInformation("Player {Name} connected (charIndex={CharIndex}, map={Map}, pos=({X},{Y}))",
            character.Name, charIndex, map, x, y);

        return player;
    }

    public PlayerState? RemovePlayer(string connectionId)
    {
        if (!_playersByConnection.TryRemove(connectionId, out var player))
            return null;

        _playersByCharIndex.TryRemove(player.CharIndex, out _);
        ClearTileOccupant(player.Map, player.X, player.Y, player.CharIndex);

        _logger.LogInformation("Player {Name} disconnected", player.Character.Name);
        return player;
    }

    public PlayerState? GetPlayer(string connectionId) =>
        _playersByConnection.GetValueOrDefault(connectionId);

    public PlayerState? GetPlayerByCharIndex(int charIndex) =>
        _playersByCharIndex.GetValueOrDefault(charIndex);

    public IEnumerable<PlayerState> GetPlayersOnMap(int map) =>
        _playersByConnection.Values.Where(p => p.Map == map);

    public bool IsNameOnline(string name) =>
        _playersByConnection.Values.Any(p => p.Character.Name.Equals(name, StringComparison.OrdinalIgnoreCase));

    // --- Tile Occupancy ---

    private ConcurrentDictionary<(int, int), int> GetMapOccupancy(int map) =>
        _mapOccupancy.GetOrAdd(map, _ => new());

    private void SetTileOccupant(int map, int x, int y, int charIndex) =>
        GetMapOccupancy(map)[(x, y)] = charIndex;

    private void ClearTileOccupant(int map, int x, int y, int expectedCharIndex)
    {
        var occ = GetMapOccupancy(map);
        // Only clear if it's still us (avoid race conditions)
        occ.TryRemove(new KeyValuePair<(int, int), int>((x, y), expectedCharIndex));
    }

    public bool IsTileBlocked(int map, int x, int y)
    {
        if (x < 1 || x > GameConstants.MapWidth || y < 1 || y > GameConstants.MapHeight)
            return true;

        // Check map blocked tiles
        if (_gameData.Maps.TryGetValue(map, out var mapDef))
        {
            var idx = MapDef.TileIndex(x, y);
            if (idx >= 0 && idx < mapDef.Tiles.Blocked.Length && mapDef.Tiles.Blocked[idx] == 1)
                return true;
        }

        // Check player occupancy
        var occ = GetMapOccupancy(map);
        if (occ.ContainsKey((x, y)))
            return true;

        return false;
    }

    /// <summary>
    /// Move a player to a new position. Returns true if the move was valid.
    /// VB6: MoveUserChar (GameLogic.bas:2607)
    /// </summary>
    public bool MovePlayer(PlayerState player, Direction heading)
    {
        var (dx, dy) = heading switch
        {
            Direction.North => (0, -1),
            Direction.East => (1, 0),
            Direction.South => (0, 1),
            Direction.West => (-1, 0),
            _ => (0, 0)
        };

        int newX = player.X + dx;
        int newY = player.Y + dy;

        if (IsTileBlocked(player.Map, newX, newY))
            return false;

        // Update occupancy
        ClearTileOccupant(player.Map, player.X, player.Y, player.CharIndex);
        player.X = newX;
        player.Y = newY;
        player.Heading = (int)heading;
        SetTileOccupant(player.Map, newX, newY, player.CharIndex);

        return true;
    }
}

/// <summary>Live state for an online player. VB6: UserList(userindex).</summary>
public class PlayerState
{
    public required string ConnectionId { get; init; }
    public required CharacterData Character { get; set; }
    public int CharIndex { get; init; }
    public int Map { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int Heading { get; set; }
}

/// <summary>
/// Persisted character data. VB6: .chr file contents.
/// Simplified for Phase 3 - stats/inventory/skills added in Phase 4.
/// </summary>
public class CharacterData
{
    public string Name { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string Race { get; set; } = "Human";
    public string Gender { get; set; } = "Male";
    public int Body { get; set; } = 1;
    public int Head { get; set; } = 6;
    public int LastMap { get; set; }
    public int LastX { get; set; }
    public int LastY { get; set; }
}
