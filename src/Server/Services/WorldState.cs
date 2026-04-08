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

    // NPC tile occupancy: map -> (x,y) -> npcIndex. Separate from player occupancy.
    // VB6: MapData(map, x, y).NpcIndex
    private readonly ConcurrentDictionary<int, ConcurrentDictionary<(int x, int y), int>> _npcOccupancy = new();

    // All live NPC instances indexed by npcIndex (1-based)
    private readonly ConcurrentDictionary<int, NpcState> _npcs = new();

    // Per-map NPC lists for efficient iteration during AI tick
    private readonly ConcurrentDictionary<int, List<NpcState>> _npcsByMap = new();

    // Next NPC index counter
    private int _nextNpcIndex = 1;

    // VB6: MapData(map, x, y).ObjInfo — ground items, one item per tile
    private readonly ConcurrentDictionary<int, ConcurrentDictionary<(int x, int y), GroundItem>> _groundItems = new();

    private readonly string _groundItemPath;

    public WorldState(GameDataService gameData, IConfiguration config, ILogger<WorldState> logger)
    {
        _gameData = gameData;
        _logger = logger;
        _charPath = config.GetValue<string>("CharacterPath") ?? Path.Combine(Directory.GetCurrentDirectory(), "characters");
        _groundItemPath = config.GetValue<string>("GroundItemPath") ?? Path.Combine(Directory.GetCurrentDirectory(), "grounditems");
        Directory.CreateDirectory(_charPath);
        Directory.CreateDirectory(_groundItemPath);
        LoadAllGroundItems();
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
        var character = await JsonSerializer.DeserializeAsync<CharacterData>(stream);
        if (character != null)
        {
            // Ensure inventory array is initialized (handles old save files)
            if (character.Inventory == null || character.Inventory.Length < 20)
            {
                var old = character.Inventory ?? [];
                character.Inventory = new InventorySlot[20];
                Array.Copy(old, character.Inventory, Math.Min(old.Length, 20));
            }
            for (int i = 0; i < 20; i++)
                character.Inventory[i] ??= new InventorySlot();
        }
        return character;
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

    public PlayerState? GetPlayerByName(string name) =>
        _playersByConnection.Values.FirstOrDefault(p => p.Character.Name.Equals(name, StringComparison.OrdinalIgnoreCase));

    public IEnumerable<PlayerState> GetAllOnlinePlayers() =>
        _playersByConnection.Values;

    public int GetOnlineCount() =>
        _playersByConnection.Count;

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

        // Check NPC occupancy
        if (IsNpcOnTile(map, x, y))
            return true;

        return false;
    }

    // --- Ground Items (VB6: MapData(map,x,y).ObjInfo) ---
    // Write-through persistence: saved to grounditems/map-NNN.json on every change.

    private ConcurrentDictionary<(int, int), GroundItem> GetMapGroundItems(int map) =>
        _groundItems.GetOrAdd(map, _ => new());

    /// <summary>Place an item on the ground. Returns false if tile already has an item.</summary>
    public bool PlaceGroundItem(int map, int x, int y, int objIndex, int amount)
    {
        var items = GetMapGroundItems(map);
        if (!items.TryAdd((x, y), new GroundItem { ObjIndex = objIndex, Amount = amount }))
            return false;
        SaveMapGroundItems(map);
        return true;
    }

    /// <summary>Pick up the item on a tile. Returns null if nothing there.</summary>
    public GroundItem? PickupGroundItem(int map, int x, int y)
    {
        var items = GetMapGroundItems(map);
        if (!items.TryRemove((x, y), out var item))
            return null;
        SaveMapGroundItems(map);
        return item;
    }

    /// <summary>Get the item on a tile without removing it (for inspection).</summary>
    public GroundItem? GetGroundItem(int map, int x, int y)
    {
        var items = GetMapGroundItems(map);
        items.TryGetValue((x, y), out var item);
        return item;
    }

    /// <summary>Get all ground items on a map (for sending to newly arrived players).</summary>
    public IEnumerable<(int x, int y, GroundItem item)> GetAllGroundItems(int map)
    {
        var items = GetMapGroundItems(map);
        foreach (var kvp in items)
            yield return (kvp.Key.Item1, kvp.Key.Item2, kvp.Value);
    }

    private string GroundItemFilePath(int map) =>
        Path.Combine(_groundItemPath, $"map-{map:D3}.json");

    /// <summary>Write-through: save all ground items for one map to disk.</summary>
    private void SaveMapGroundItems(int map)
    {
        var items = GetMapGroundItems(map);
        var path = GroundItemFilePath(map);

        if (items.IsEmpty)
        {
            // No items left — delete the file
            if (File.Exists(path)) File.Delete(path);
            return;
        }

        // Sparse format: array of [x, y, objIndex, amount]
        var entries = items.Select(kvp => new[] { kvp.Key.Item1, kvp.Key.Item2, kvp.Value.ObjIndex, kvp.Value.Amount }).ToList();
        File.WriteAllText(path, JsonSerializer.Serialize(entries));
    }

    /// <summary>Load all ground item files on startup.</summary>
    private void LoadAllGroundItems()
    {
        if (!Directory.Exists(_groundItemPath)) return;

        var files = Directory.GetFiles(_groundItemPath, "map-*.json");
        int totalItems = 0;

        foreach (var file in files)
        {
            var name = Path.GetFileNameWithoutExtension(file); // "map-081"
            if (!int.TryParse(name.AsSpan(4), out var mapId)) continue;

            try
            {
                var json = File.ReadAllText(file);
                var entries = JsonSerializer.Deserialize<List<int[]>>(json);
                if (entries == null) continue;

                var items = GetMapGroundItems(mapId);
                foreach (var entry in entries)
                {
                    if (entry.Length >= 4)
                    {
                        items[(entry[0], entry[1])] = new GroundItem { ObjIndex = entry[2], Amount = entry[3] };
                        totalItems++;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning("Failed to load ground items from {File}: {Error}", file, ex.Message);
            }
        }

        if (totalItems > 0)
            _logger.LogInformation("Loaded {Count} ground items from {Files} map files", totalItems, files.Length);
    }

    // --- NPC System (VB6: NPCList, OpenNPC, NPCAI, MoveNPCChar) ---

    /// <summary>Spawn all NPCs from map data. Called once at server startup.</summary>
    public void SpawnAllNpcs()
    {
        int totalSpawned = 0;
        foreach (var (mapId, mapDef) in _gameData.Maps)
        {
            foreach (var spawn in mapDef.NpcSpawns)
            {
                int x = spawn[0], y = spawn[1], templateId = spawn[2];
                var template = _gameData.Npcs.FirstOrDefault(n => n.Id == templateId);
                if (template == null) continue;

                var npc = SpawnNpc(template, mapId, x, y);
                if (npc != null) totalSpawned++;
            }
        }
        _logger.LogInformation("Spawned {Count} live NPCs across {Maps} maps", totalSpawned, _npcsByMap.Count);
    }

    /// <summary>Create a live NPC instance from a template. VB6: OpenNPC.</summary>
    private NpcState? SpawnNpc(NpcDef template, int map, int x, int y)
    {
        var npcIndex = Interlocked.Increment(ref _nextNpcIndex);
        var charIndex = AllocateCharIndex();

        var npc = new NpcState
        {
            NpcIndex = npcIndex,
            CharIndex = charIndex,
            TemplateId = template.Id,
            Name = template.Name,
            Map = map,
            X = x,
            Y = y,
            SpawnMap = map,
            Heading = template.Heading > 0 ? template.Heading : (int)Direction.South,
            Body = template.Body > 0 ? template.Body : 1,
            Head = template.Head > 0 ? template.Head : 0,
            WeaponAnim = 2, // VB6: default invisible
            ShieldAnim = 2,
            CurrentHp = template.MaxHp,
            MaxHp = template.MaxHp,
            MinHit = template.MinHit,
            MaxHit = template.MaxHit,
            Def = template.Def,
            Movement = template.Movement,
            OriginalMovement = template.Movement,
            Hostile = template.Hostile == 1,
            OriginalHostile = template.Hostile == 1,
            Guard = template.Guard,
            Sound = template.Sound,
            GiveExp = template.GiveExp,
            GiveGold = template.GiveGold,
            DeathObj = template.DeathObj,
            LootChance = template.LootChance > 0 ? template.LootChance : 1,
            Level = template.Level,
            Inventory = template.Inventory ?? [],
        };

        _npcs[npcIndex] = npc;

        // Add to per-map list
        var mapList = _npcsByMap.GetOrAdd(map, _ => new List<NpcState>());
        lock (mapList) { mapList.Add(npc); }

        // Occupy tile
        SetNpcTileOccupant(map, x, y, npcIndex);

        return npc;
    }

    // --- NPC Tile Occupancy ---

    private ConcurrentDictionary<(int, int), int> GetNpcMapOccupancy(int map) =>
        _npcOccupancy.GetOrAdd(map, _ => new());

    private void SetNpcTileOccupant(int map, int x, int y, int npcIndex) =>
        GetNpcMapOccupancy(map)[(x, y)] = npcIndex;

    private void ClearNpcTileOccupant(int map, int x, int y, int expectedNpcIndex)
    {
        var occ = GetNpcMapOccupancy(map);
        occ.TryRemove(new KeyValuePair<(int, int), int>((x, y), expectedNpcIndex));
    }

    public bool IsNpcOnTile(int map, int x, int y) =>
        GetNpcMapOccupancy(map).ContainsKey((x, y));

    public NpcState? GetNpcOnTile(int map, int x, int y)
    {
        if (GetNpcMapOccupancy(map).TryGetValue((x, y), out var npcIndex))
            return _npcs.GetValueOrDefault(npcIndex);
        return null;
    }

    public NpcState? GetNpcByIndex(int npcIndex) =>
        _npcs.GetValueOrDefault(npcIndex);

    public NpcState? GetNpcByCharIndex(int charIndex) =>
        _npcs.Values.FirstOrDefault(n => n.CharIndex == charIndex);

    /// <summary>Get all live NPCs on a map (for sending to players entering the map).</summary>
    public IReadOnlyList<NpcState> GetNpcsOnMap(int map)
    {
        if (_npcsByMap.TryGetValue(map, out var list))
            lock (list) { return list.ToList(); }
        return [];
    }

    /// <summary>Count players on a map. VB6: MapInfo(map).NumUsers</summary>
    public int GetPlayerCountOnMap(int map) =>
        _playersByConnection.Values.Count(p => p.Map == map);

    // --- NPC Movement (VB6: MoveNPCChar) ---

    /// <summary>
    /// Move an NPC one tile in a direction. Returns true if the move was valid.
    /// VB6: MoveNPCChar (GameLogic.bas:2651)
    /// </summary>
    public bool MoveNpc(NpcState npc, Direction heading)
    {
        var (dx, dy) = heading switch
        {
            Direction.North => (0, -1),
            Direction.East => (1, 0),
            Direction.South => (0, 1),
            Direction.West => (-1, 0),
            _ => (0, 0)
        };

        int newX = npc.X + dx;
        int newY = npc.Y + dy;

        // VB6: LegalPos check — bounds, blocked tiles, player occupancy, NPC occupancy
        if (!IsNpcLegalPos(npc.Map, newX, newY, npc.NpcIndex))
            return false;

        // Update occupancy
        ClearNpcTileOccupant(npc.Map, npc.X, npc.Y, npc.NpcIndex);
        npc.X = newX;
        npc.Y = newY;
        npc.Heading = (int)heading;
        SetNpcTileOccupant(npc.Map, newX, newY, npc.NpcIndex);

        return true;
    }

    /// <summary>
    /// Check if a position is legal for an NPC to move to.
    /// VB6: LegalPos (GameLogic.bas:2719) — checks bounds, blocked, player+NPC occupancy.
    /// </summary>
    public bool IsNpcLegalPos(int map, int x, int y, int excludeNpcIndex = 0)
    {
        if (x < 1 || x > GameConstants.MapWidth || y < 1 || y > GameConstants.MapHeight)
            return false;

        // Check blocked tiles
        if (_gameData.Maps.TryGetValue(map, out var mapDef))
        {
            var idx = MapDef.TileIndex(x, y);
            if (idx >= 0 && idx < mapDef.Tiles.Blocked.Length && mapDef.Tiles.Blocked[idx] == 1)
                return false;
        }

        // Check player occupancy
        if (GetMapOccupancy(map).ContainsKey((x, y)))
            return false;

        // Check NPC occupancy (excluding self)
        var npcOcc = GetNpcMapOccupancy(map);
        if (npcOcc.TryGetValue((x, y), out var occupant) && occupant != excludeNpcIndex)
            return false;

        return true;
    }

    /// <summary>
    /// Warp an NPC to a new position (used for death respawn).
    /// VB6: WarpNPCChar (GameLogic.bas:3101)
    /// </summary>
    public void WarpNpc(NpcState npc, int map, int x, int y)
    {
        ClearNpcTileOccupant(npc.Map, npc.X, npc.Y, npc.NpcIndex);
        npc.Map = map;
        npc.X = x;
        npc.Y = y;
        SetNpcTileOccupant(map, x, y, npc.NpcIndex);
    }

    /// <summary>
    /// Find direction from source to target position.
    /// VB6: FindDirection (GameLogic.bas:4140) — faithful port including diagonal bias.
    /// </summary>
    public static Direction FindDirection(int srcX, int srcY, int tgtX, int tgtY)
    {
        int dx = srcX - tgtX;  // positive = target is west
        int dy = srcY - tgtY;  // positive = target is north
        int sx = Math.Sign(dx);
        int sy = Math.Sign(dy);

        // VB6's exact diagonal resolution:
        // NE (sx=-1, sy=1) → NORTH
        // NW (sx=1, sy=1) → WEST
        // SW (sx=1, sy=-1) → WEST
        // SE (sx=-1, sy=-1) → SOUTH
        if (sx == -1 && sy == 1) return Direction.North;
        if (sx == 1 && sy == 1) return Direction.West;
        if (sx == 1 && sy == -1) return Direction.West;
        if (sx == -1 && sy == -1) return Direction.South;

        // Cardinals
        if (sx == 0 && sy == -1) return Direction.South;
        if (sx == 0 && sy == 1) return Direction.North;
        if (sx == 1 && sy == 0) return Direction.West;
        if (sx == -1 && sy == 0) return Direction.East;

        return Direction.South; // same spot fallback
    }

    /// <summary>
    /// Warp a player to a new map and position. Updates occupancy.
    /// VB6: WarpUserChar (GameLogic.bas:2982)
    /// </summary>
    public void WarpPlayer(PlayerState player, int newMap, int newX, int newY)
    {
        ClearTileOccupant(player.Map, player.X, player.Y, player.CharIndex);
        player.Map = newMap;
        player.X = newX;
        player.Y = newY;
        SetTileOccupant(newMap, newX, newY, player.CharIndex);
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

    /// <summary>VB6: Flags.status = 1 means dead/ghost</summary>
    public bool IsDead { get; set; }

    // Equipment slot indices in inventory (-1 = nothing equipped)
    public int WeaponEqpSlot { get; set; } = -1;
    public int ArmourEqpSlot { get; set; } = -1;
    public int ShieldEqpSlot { get; set; } = -1;
    public int HeadEqpSlot { get; set; } = -1;

    /// <summary>VB6: UserList.NpcIndex / NPCtarget — currently targeted NPC index</summary>
    public int TargetNpcIndex { get; set; }

    /// <summary>VB6: UserList.UserTargetIndex — currently targeted player char index</summary>
    public int TargetPlayerCharIndex { get; set; }
}

/// <summary>
/// Persisted character data. VB6: .chr file contents ([INIT], [STATS], [FLAGS] sections).
/// </summary>
public class CharacterData
{
    public string Name { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string Race { get; set; } = "Human";
    public string Gender { get; set; } = "Male";
    public int Body { get; set; } = 1;
    public int Head { get; set; } = 6;
    public string? Description { get; set; }
    public int LastMap { get; set; }
    public int LastX { get; set; }
    public int LastY { get; set; }

    // VB6: [INVENTORY] section — 20 slots, 1-indexed in VB6, 0-indexed here
    public InventorySlot[] Inventory { get; set; } = new InventorySlot[20];

    // VB6: Equipment tracking — which inventory slot holds each equipped type
    public int WeaponEqpSlot { get; set; } = -1;
    public int ArmourEqpSlot { get; set; } = -1;
    public int ShieldEqpSlot { get; set; } = -1;
    public int HeadEqpSlot { get; set; } = -1;

    // VB6: [STATS] section
    public int MaxHp { get; set; } = 30;
    public int CurrentHp { get; set; } = 30;
    public int MaxSta { get; set; } = 5;
    public int CurrentSta { get; set; } = 5;
    public int MaxMan { get; set; } = 0;
    public int CurrentMan { get; set; } = 0;
    public int Gold { get; set; } = 0;
    public int Exp { get; set; } = 0;
    public int Elu { get; set; } = 300;       // experience to level up
    public int Level { get; set; } = 1;        // hidden from player
    public int MinHit { get; set; } = 2;
    public int MaxHit { get; set; } = 4;
    public int Def { get; set; } = 0;
    public int Food { get; set; } = 0;
    public int Drink { get; set; } = 0;
    public int TrainingPoints { get; set; } = 0;

    // VB6: [INIT] section — class, magic school
    public string Class { get; set; } = "Warrior";
    public string MagicSchool { get; set; } = "";

    // VB6: [FLAGS] section — 3 specialized skill names (can exceed 50)
    public string SpecSkill1 { get; set; } = "";
    public string SpecSkill2 { get; set; } = "";
    public string SpecSkill3 { get; set; } = "";

    // VB6: [SKILLS] section — 28 skills, 1-indexed (index 0 unused)
    public int[] Skills { get; set; } = new int[SkillInfo.SkillCount + 1];

    // VB6: [Community] section
    public int BankGold { get; set; } = 0;
    public int NobleRep { get; set; } = 0;
    public int UnderRep { get; set; } = 0;
    public int CommonRep { get; set; } = 0;
    public int OverallRep { get; set; } = 500;
    public string RepRank { get; set; } = "Unknown";
    public int Criminal { get; set; } = 0;
    public long CriminalCount { get; set; } = 0;

    /// <summary>Check if a skill name is one of this character's 3 specialized skills.</summary>
    public bool IsSpecializedSkill(string skillName) =>
        string.Equals(SpecSkill1, skillName, StringComparison.OrdinalIgnoreCase) ||
        string.Equals(SpecSkill2, skillName, StringComparison.OrdinalIgnoreCase) ||
        string.Equals(SpecSkill3, skillName, StringComparison.OrdinalIgnoreCase);

    /// <summary>Check if a skill index is one of this character's 3 specialized skills.</summary>
    public bool IsSpecializedSkill(int skillIndex)
    {
        if (skillIndex < 1 || skillIndex > SkillInfo.SkillCount) return false;
        return IsSpecializedSkill(SkillInfo.Names[skillIndex]);
    }

    /// <summary>
    /// Find the highest skill and update class accordingly. VB6: CheckClass in Checks.bas.
    /// </summary>
    public void CheckClass()
    {
        int highestIndex = -1;
        int highestValue = 0;
        bool tied = false;

        for (int i = 1; i <= SkillInfo.SkillCount; i++)
        {
            if (Skills[i] > highestValue)
            {
                highestValue = Skills[i];
                highestIndex = i;
                tied = false;
            }
            else if (Skills[i] == highestValue && highestValue > 0)
            {
                tied = true;
            }
        }

        // VB6 uses strict "greater than ALL others" — ties don't trigger a change
        if (tied || highestIndex < 0) return;
        if (!SkillInfo.SkillToClass.TryGetValue(highestIndex, out var newClass)) return;
        if (Class == newClass) return;

        Class = newClass;
    }

    /// <summary>Initialize default starting inventory for a new character. VB6: ConnectNewUser.</summary>
    public void InitStartingInventory()
    {
        Inventory = new InventorySlot[20];
        for (int i = 0; i < 20; i++) Inventory[i] = new InventorySlot();

        // VB6: slot 2 = brown pants & green shirt (obj 145, equipped)
        Inventory[1] = new InventorySlot { ObjIndex = 145, Amount = 1, Equipped = true };
        ArmourEqpSlot = 1;
        // VB6: slot 3 = rusty dagger (obj 33)
        Inventory[2] = new InventorySlot { ObjIndex = 33, Amount = 1 };
        // VB6: slot 4 = 5 water flasks (obj 22)
        Inventory[3] = new InventorySlot { ObjIndex = 22, Amount = 5 };
        // VB6: slot 5 = 5 breads (obj 95)
        Inventory[4] = new InventorySlot { ObjIndex = 95, Amount = 5 };
    }
}

/// <summary>VB6: UserOBJ type — one inventory slot.</summary>
public class InventorySlot
{
    public int ObjIndex { get; set; }
    public int Amount { get; set; }
    public bool Equipped { get; set; }
}

/// <summary>VB6: MapData(map, x, y).ObjInfo — an item on the ground.</summary>
public class GroundItem
{
    public int ObjIndex { get; set; }
    public int Amount { get; set; }
}

/// <summary>
/// Live NPC instance in the world. VB6: NPCList(npcindex).
/// Each map NPC spawn becomes one NpcState at server startup.
/// </summary>
public class NpcState
{
    public int NpcIndex { get; init; }         // unique runtime index (1-based like VB6)
    public int CharIndex { get; init; }        // unique char index for MakeChar (positive, allocated)
    public int TemplateId { get; init; }       // NPC.dat ID (for looking up static data)
    public string Name { get; set; } = "";
    public int Map { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int SpawnMap { get; init; }         // original spawn map (for respawn)
    public int Heading { get; set; } = (int)Direction.South;

    // Appearance
    public int Body { get; set; }
    public int Head { get; set; }
    public int WeaponAnim { get; set; } = 2;   // 2 = invisible/none
    public int ShieldAnim { get; set; } = 2;

    // Stats (runtime — reset on death)
    public int CurrentHp { get; set; }
    public int MaxHp { get; set; }
    public int MinHit { get; set; }
    public int MaxHit { get; set; }
    public int Def { get; set; }

    // Flags
    public int Movement { get; set; }          // VB6: NPCList.Movement (1-8)
    public int OriginalMovement { get; set; }  // restore after combat if was standing/random
    public bool Hostile { get; set; }          // VB6: NPCList.Hostile
    public bool OriginalHostile { get; set; }  // restore after combat
    public int Guard { get; set; }             // VB6: NPCList.Guard (0=none, 1=normal, 2=chaotic)
    public bool Active { get; set; } = true;   // VB6: Flags.NPCActive
    public bool CanAttack { get; set; } = true; // reset by 4000ms timer
    public int Target { get; set; }            // userindex of target player (0=none)
    public int AttackedBy { get; set; }        // userindex of player who attacked first (0=none)
    public int Sound { get; set; }             // death/attack sound

    // NPC data for loot/rewards
    public int GiveExp { get; set; }
    public long GiveGold { get; set; }
    public int DeathObj { get; set; }
    public int LootChance { get; set; }
    public int Level { get; set; }
    public NpcInvSlot[] Inventory { get; set; } = [];
}
