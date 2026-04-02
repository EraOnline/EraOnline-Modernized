using System.Text.Json.Serialization;

namespace EraOnline.Shared.Models;

/// <summary>
/// Map definition loaded from maps/map-NNN.json.
/// VB6: MapBlock + MapInfo types, loaded from .map/.inf/.dat files.
/// Tile arrays are 10,000 elements indexed by (y-1)*100 + (x-1).
/// </summary>
public class MapDef
{
    [JsonPropertyName("id")] public int Id { get; set; }
    [JsonPropertyName("name")] public string Name { get; set; } = "";
    [JsonPropertyName("music")] public string Music { get; set; } = "";
    [JsonPropertyName("pkFreeZone")] public bool PkFreeZone { get; set; }
    [JsonPropertyName("startPos")] public int[]? StartPos { get; set; }
    [JsonPropertyName("exits")] public Dictionary<string, int> Exits { get; set; } = [];
    [JsonPropertyName("tiles")] public MapTileLayers Tiles { get; set; } = new();
    [JsonPropertyName("tileExits")] public List<int[]> TileExits { get; set; } = [];
    [JsonPropertyName("npcSpawns")] public List<int[]> NpcSpawns { get; set; } = [];

    /// <summary>Get tile array index from 1-based map coordinates.</summary>
    public static int TileIndex(int x, int y) => (y - 1) * 100 + (x - 1);
}

public class MapTileLayers
{
    [JsonPropertyName("blocked")] public int[] Blocked { get; set; } = [];
    [JsonPropertyName("layer1")] public int[] Layer1 { get; set; } = [];
    [JsonPropertyName("layer2")] public int[] Layer2 { get; set; } = [];
    [JsonPropertyName("layer3")] public int[] Layer3 { get; set; } = [];
}
