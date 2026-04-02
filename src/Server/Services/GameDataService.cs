using System.Text.Json;
using EraOnline.Shared.Models;

namespace EraOnline.Server.Services;

/// <summary>
/// Loads all game data from the converted JSON files at startup.
/// Registered as a singleton - all game data is read-only after loading.
/// </summary>
public class GameDataService
{
    private readonly string _dataPath;
    private readonly ILogger<GameDataService> _logger;

    public IReadOnlyList<ObjectDef> Objects { get; private set; } = [];
    public IReadOnlyList<NpcDef> Npcs { get; private set; } = [];
    public IReadOnlyList<SpellDef> Spells { get; private set; } = [];
    public IReadOnlyDictionary<int, MapDef> Maps { get; private set; } = new Dictionary<int, MapDef>();
    public GrhDataSet Grh { get; private set; } = new();
    public IReadOnlyList<HeadDef> Heads { get; private set; } = [];
    public IReadOnlyList<BodyDef> Bodies { get; private set; } = [];
    public IReadOnlyList<AnimDef> ShieldAnims { get; private set; } = [];
    public IReadOnlyList<AnimDef> WeaponAnims { get; private set; } = [];
    public ServerConfig Config { get; private set; } = new();
    public IReadOnlyList<GossipEntry> Gossip { get; private set; } = [];
    public IReadOnlyList<QuestDef> Quests { get; private set; } = [];

    public GameDataService(IConfiguration configuration, IWebHostEnvironment env, ILogger<GameDataService> logger)
    {
        // Read from Client.Web/wwwroot/data/ (same directory the browser fetches from)
        _dataPath = configuration.GetValue<string>("GameDataPath")
            ?? Path.Combine(env.WebRootPath ?? "", "data");
        _logger = logger;
    }

    public async Task LoadAllAsync()
    {
        _logger.LogInformation("Loading game data from {Path}", Path.GetFullPath(_dataPath));

        Objects = await LoadJsonAsync<List<ObjectDef>>("objects.json") ?? [];
        Npcs = await LoadJsonAsync<List<NpcDef>>("npcs.json") ?? [];
        Spells = await LoadJsonAsync<List<SpellDef>>("spells.json") ?? [];
        Grh = await LoadJsonAsync<GrhDataSet>("grh.json") ?? new();
        Heads = await LoadJsonAsync<List<HeadDef>>("heads.json") ?? [];
        Bodies = await LoadJsonAsync<List<BodyDef>>("bodies.json") ?? [];
        ShieldAnims = await LoadJsonAsync<List<AnimDef>>("shield-anims.json") ?? [];
        WeaponAnims = await LoadJsonAsync<List<AnimDef>>("weapon-anims.json") ?? [];
        Config = await LoadJsonAsync<ServerConfig>("config.json") ?? new();
        Gossip = await LoadJsonAsync<List<GossipEntry>>("gossip.json") ?? [];
        Quests = await LoadJsonAsync<List<QuestDef>>("quests.json") ?? [];

        // Load maps
        var maps = new Dictionary<int, MapDef>();
        var mapsDir = Path.Combine(_dataPath, "maps");
        if (Directory.Exists(mapsDir))
        {
            foreach (var file in Directory.GetFiles(mapsDir, "map-*.json"))
            {
                var map = await LoadJsonFileAsync<MapDef>(file);
                if (map != null)
                    maps[map.Id] = map;
            }
        }
        Maps = maps;

        LogSummary();
    }

    private void LogSummary()
    {
        _logger.LogInformation("Game data loaded successfully:");
        _logger.LogInformation("  Objects: {Count}", Objects.Count);
        _logger.LogInformation("  NPCs: {Count}", Npcs.Count);
        _logger.LogInformation("  Spells: {Count}", Spells.Count);
        _logger.LogInformation("  Maps: {Count}", Maps.Count);
        _logger.LogInformation("  Sprite definitions: {Count}", Grh.Entries.Count);
        _logger.LogInformation("  Heads: {Count}, Bodies: {Count}", Heads.Count, Bodies.Count);
        _logger.LogInformation("  Shield anims: {Count}, Weapon anims: {Count}", ShieldAnims.Count, WeaponAnims.Count);
        _logger.LogInformation("  Starting cities: {Count}, GMs: {Count}", Config.StartingCities.Count, Config.Gms.Count);
        _logger.LogInformation("  Gossip: {Count}, Quests: {Count}", Gossip.Count, Quests.Count);

        int totalNpcSpawns = Maps.Values.Sum(m => m.NpcSpawns.Count);
        int totalTileExits = Maps.Values.Sum(m => m.TileExits.Count);
        _logger.LogInformation("  Total NPC spawns across all maps: {Count}", totalNpcSpawns);
        _logger.LogInformation("  Total tile exits across all maps: {Count}", totalTileExits);
    }

    private async Task<T?> LoadJsonAsync<T>(string filename)
    {
        return await LoadJsonFileAsync<T>(Path.Combine(_dataPath, filename));
    }

    private async Task<T?> LoadJsonFileAsync<T>(string path)
    {
        if (!File.Exists(path))
        {
            _logger.LogWarning("Data file not found: {Path}", path);
            return default;
        }

        await using var stream = File.OpenRead(path);
        return await JsonSerializer.DeserializeAsync<T>(stream);
    }
}
