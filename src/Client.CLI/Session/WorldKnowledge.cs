using System.Text.Json;
using System.Text.Json.Serialization;

namespace EraOnline.Client.CLI.Session;

/// <summary>
/// Per-character persistent knowledge about the world.
/// Updated as the character explores. Saved to knowledge.json.
/// </summary>
public class WorldKnowledge
{
    private readonly string _filePath;

    public Dictionary<int, MapKnowledge> Maps { get; set; } = new();

    // Well-known map names from Server.ini starting cities
    private static readonly Dictionary<int, string> KnownMapNames = new()
    {
        [81] = "Castlefall", [1] = "Bernvillage", [18] = "Angelmoor",
        [140] = "Gorth", [115] = "Jemhoo", [22] = "Denc",
        [155] = "Valen", [169] = "Valentfall", [206] = "Molg", [189] = "Ug",
    };

    public WorldKnowledge(string characterDataDir)
    {
        _filePath = Path.Combine(characterDataDir, "knowledge.json");
        Load();
    }

    /// <summary>Get or create knowledge for a map.</summary>
    public MapKnowledge GetMap(int mapId)
    {
        if (!Maps.TryGetValue(mapId, out var mk))
        {
            mk = new MapKnowledge { MapId = mapId };
            if (KnownMapNames.TryGetValue(mapId, out var name))
                mk.Name = name;
            Maps[mapId] = mk;
        }
        return mk;
    }

    /// <summary>
    /// Called when entering a map. Records visit, detects spaces from NPC data.
    /// </summary>
    public void OnMapEnter(int mapId, GameState state, string? dataPath)
    {
        var mk = GetMap(mapId);
        mk.VisitCount++;
        mk.LastVisit = DateTime.UtcNow;

        // Record edge exits from map data
        if (dataPath != null)
        {
            var padded = mapId.ToString().PadLeft(3, '0');
            var mapFile = Path.Combine(dataPath, "maps", $"map-{padded}.json");
            if (File.Exists(mapFile))
            {
                try
                {
                    using var doc = JsonDocument.Parse(File.ReadAllText(mapFile));
                    var root = doc.RootElement;

                    // Edge exits
                    if (root.TryGetProperty("exits", out var exits))
                    {
                        if (exits.TryGetProperty("north", out var n) && n.GetInt32() > 0) mk.Exits["north"] = n.GetInt32();
                        if (exits.TryGetProperty("south", out var s) && s.GetInt32() > 0) mk.Exits["south"] = s.GetInt32();
                        if (exits.TryGetProperty("east", out var e) && e.GetInt32() > 0) mk.Exits["east"] = e.GetInt32();
                        if (exits.TryGetProperty("west", out var w) && w.GetInt32() > 0) mk.Exits["west"] = w.GetInt32();
                    }

                    // Tile exits
                    if (root.TryGetProperty("tileExits", out var te))
                    {
                        foreach (var exit in te.EnumerateArray())
                        {
                            var arr = exit.EnumerateArray().Select(x => x.GetInt32()).ToArray();
                            if (arr.Length >= 3)
                            {
                                var destName = KnownMapNames.GetValueOrDefault(arr[2], $"Map {arr[2]}");
                                var spaceName = $"Exit to {destName}";
                                mk.AddSpaceIfNew(spaceName, arr[0], arr[1], "exit", true);
                            }
                        }
                    }

                    // Read blocked tile data for pathfinding
                    if (root.TryGetProperty("tiles", out var tiles) && tiles.TryGetProperty("blocked", out var blocked))
                    {
                        mk.BlockedTiles = blocked.EnumerateArray().Select(x => x.GetInt32()).ToArray();
                    }
                }
                catch { /* skip parse errors */ }
            }
        }

        // Auto-detect spaces from visible NPCs
        DetectSpacesFromNpcs(mk, state);

        Save();
    }

    private void DetectSpacesFromNpcs(MapKnowledge mk, GameState state)
    {
        // Load NPC definitions to get NPC types
        foreach (var ch in state.Characters.Values)
        {
            if (ch.IsMyChar) continue;
            // Use character name as space name (NPCs have descriptive names)
            var name = ch.Name;
            if (string.IsNullOrEmpty(name) || name.StartsWith("a ", StringComparison.OrdinalIgnoreCase))
            {
                // Skip generic hostile NPCs like "a snake", "a bat"
                // But keep named NPCs and service NPCs
                continue;
            }
            mk.AddSpaceIfNew(name, ch.X, ch.Y, "npc", true);
        }
    }

    public void Save()
    {
        try
        {
            var dir = Path.GetDirectoryName(_filePath);
            if (dir != null) Directory.CreateDirectory(dir);
            var json = JsonSerializer.Serialize(this, new JsonSerializerOptions
            {
                WriteIndented = true,
                DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
            });
            File.WriteAllText(_filePath, json);
        }
        catch { /* ignore save errors */ }
    }

    private void Load()
    {
        if (!File.Exists(_filePath)) return;
        try
        {
            var json = File.ReadAllText(_filePath);
            var loaded = JsonSerializer.Deserialize<WorldKnowledge>(json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            if (loaded?.Maps != null)
                Maps = loaded.Maps;
        }
        catch { /* start fresh on parse error */ }
    }

    // Parameterless constructor for deserialization
    public WorldKnowledge() { _filePath = ""; }
}

public class MapKnowledge
{
    public int MapId { get; set; }
    public string Name { get; set; } = "";
    public int VisitCount { get; set; }
    public DateTime? LastVisit { get; set; }
    public Dictionary<string, int> Exits { get; set; } = new(); // direction -> mapId
    public List<Space> Spaces { get; set; } = new();
    public int[]? BlockedTiles { get; set; } // 10000 entries, 0=passable, 1=blocked

    [JsonIgnore]
    public string DisplayName => !string.IsNullOrEmpty(Name) ? Name : $"Map {MapId}";

    public void AddSpaceIfNew(string name, int x, int y, string type, bool auto)
    {
        // Don't add if a space with this name already exists nearby
        if (Spaces.Any(s => s.Name.Equals(name, StringComparison.OrdinalIgnoreCase)
            && Math.Abs(s.X - x) <= 3 && Math.Abs(s.Y - y) <= 3))
            return;
        Spaces.Add(new Space { Name = name, X = x, Y = y, Type = type, Auto = auto });
    }
}

public class Space
{
    public string Name { get; set; } = "";
    public int X { get; set; }
    public int Y { get; set; }
    public string Type { get; set; } = ""; // "npc", "exit", "manual"
    public bool Auto { get; set; } // auto-detected vs manually defined
}
