using System.Text.Json;
using System.Text.Json.Serialization;
using EoDataConverter;
using EoDataConverter.Converters;

var sourcePath = args.Length > 0 ? args[0] : Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "src_vb6"));
var outputPath = args.Length > 1 ? args[1] : Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "data"));

if (!Directory.Exists(sourcePath))
{
    Console.Error.WriteLine($"Source path not found: {sourcePath}");
    return 1;
}

Directory.CreateDirectory(outputPath);
Directory.CreateDirectory(Path.Combine(outputPath, "maps"));

var jsonOptions = new JsonSerializerOptions
{
    WriteIndented = true,
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
};

// Maps use compact JSON - tile arrays don't benefit from indentation
var mapJsonOptions = new JsonSerializerOptions
{
    WriteIndented = false,
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
};

var serverPath = Path.Combine(sourcePath, "Server");
var clientPath = Path.Combine(sourcePath, "Client");
var mapsPath = Path.Combine(serverPath, "Maps");

Console.WriteLine($"Source: {sourcePath}");
Console.WriteLine($"Output: {outputPath}");
Console.WriteLine();

var warnings = new List<string>();
int totalFiles = 0;

// --- INI-format data files ---

var objects = ObjectConverter.Convert(Path.Combine(serverPath, "OBJ.dat"));
WriteJson("objects.json", objects);
Console.WriteLine($"  objects.json: {objects.Count} items");

var npcs = NpcConverter.Convert(Path.Combine(serverPath, "NPC.dat"), Path.Combine(serverPath, "NPC2.dat"));
WriteJson("npcs.json", npcs);
Console.WriteLine($"  npcs.json: {npcs.Count} NPCs");

var spells = SpellConverter.Convert(Path.Combine(serverPath, "Spells.dat"));
WriteJson("spells.json", spells);
Console.WriteLine($"  spells.json: {spells.Count} spells");

var config = ConfigConverter.Convert(Path.Combine(serverPath, "Server.ini"));
WriteJson("config.json", config);
Console.WriteLine($"  config.json: {config.StartingCities.Count} cities, {config.Gms.Count} GMs");

var gossip = GossipConverter.Convert(Path.Combine(serverPath, "gossip.txt"));
WriteJson("gossip.json", gossip);
Console.WriteLine($"  gossip.json: {gossip.Count} entries");

var quests = QuestConverter.Convert(Path.Combine(serverPath, "quests.txt"));
WriteJson("quests.json", quests);
Console.WriteLine($"  quests.json: {quests.Count} quests");

var heads = HeadConverter.Convert(Path.Combine(clientPath, "Head.dat"));
WriteJson("heads.json", heads);
Console.WriteLine($"  heads.json: {heads.Count} heads");

var bodies = BodyConverter.Convert(Path.Combine(clientPath, "Body.dat"));
WriteJson("bodies.json", bodies);
Console.WriteLine($"  bodies.json: {bodies.Count} bodies");

var shieldAnims = ShieldAnimConverter.Convert(Path.Combine(clientPath, "shanim.dat"));
WriteJson("shield-anims.json", shieldAnims);
Console.WriteLine($"  shield-anims.json: {shieldAnims.Count} shield anims");

var weaponAnims = WeaponAnimConverter.Convert(Path.Combine(clientPath, "wpanim.dat"));
WriteJson("weapon-anims.json", weaponAnims);
Console.WriteLine($"  weapon-anims.json: {weaponAnims.Count} weapon anims");

// --- Binary data files ---

var grh = GrhConverter.Convert(Path.Combine(clientPath, "Grh.dat"), Path.Combine(clientPath, "Grh.ini"));
WriteJson("grh.json", grh);
Console.WriteLine($"  grh.json: {grh.Entries.Count} sprite defs, {grh.NumFiles} sprite sheets");

// --- Sprite sheet conversion (BMP -> PNG with transparency) ---
Console.WriteLine();
var grhDir = Path.Combine(clientPath, "Grh");
var spriteOutputDir = Path.Combine(outputPath, "grh");
int spritesConverted = SpriteConverter.Convert(grhDir, spriteOutputDir);
Console.WriteLine($"  grh/: {spritesConverted} sprite sheets converted (BMP -> PNG)");

// --- Map files ---
Console.WriteLine();
var mapIndex = IniParser.Load(Path.Combine(mapsPath, "Map.dat"));
int numMaps = mapIndex.GetInt("INIT", "NumMaps");
int mapsConverted = 0;
int totalNpcSpawns = 0;
int totalTileExits = 0;

for (int m = 1; m <= numMaps; m++)
{
    var mapFile = Path.Combine(mapsPath, $"Map{m}.map");
    var infFile = Path.Combine(mapsPath, $"Map{m}.inf");
    var datFile = Path.Combine(mapsPath, $"Map{m}.dat");

    if (!File.Exists(mapFile))
    {
        warnings.Add($"Map {m}: .map file missing");
        continue;
    }

    var map = MapConverter.Convert(m, mapFile, infFile, datFile);
    var mapOutputFile = Path.Combine(outputPath, "maps", $"map-{m:D3}.json");
    File.WriteAllText(mapOutputFile, JsonSerializer.Serialize(map, mapJsonOptions));
    totalFiles++;
    mapsConverted++;
    totalNpcSpawns += map.NpcSpawns.Count;
    totalTileExits += map.TileExits.Count;
}

Console.WriteLine($"  maps/: {mapsConverted} maps, {totalNpcSpawns} NPC spawns, {totalTileExits} tile exits");

// --- Cross-validation ---
Console.WriteLine();
Console.WriteLine("Cross-validation:");

// Validate NPC spawn templates reference valid NPC numbers
var maxNpcNum = npcs.Max(n => n.Id);
foreach (var mapFile in Directory.GetFiles(Path.Combine(outputPath, "maps"), "map-*.json"))
{
    var map = JsonSerializer.Deserialize<MapData>(File.ReadAllText(mapFile), jsonOptions)!;
    foreach (var spawn in map.NpcSpawns)
    {
        if (spawn[2] > maxNpcNum)
            warnings.Add($"Map {map.Id}: NPC spawn template {spawn[2]} at ({spawn[0]},{spawn[1]}) exceeds max NPC {maxNpcNum}");
    }
}

// Validate object GRH indices exist
var grhIds = grh.Entries.Keys.ToHashSet();
int missingGrh = 0;
foreach (var obj in objects)
{
    if (obj.GrhIndex > 0 && !grhIds.Contains(obj.GrhIndex))
    {
        missingGrh++;
        if (missingGrh <= 5)
            warnings.Add($"Object '{obj.Name}' (id={obj.Id}): GrhIndex {obj.GrhIndex} not found in grh.json");
    }
}

// Validate animation frame references
int badFrames = 0;
foreach (var (id, entry) in grh.Entries)
{
    if (entry.Frames != null)
    {
        foreach (var frame in entry.Frames)
        {
            if (!grhIds.Contains(frame))
            {
                badFrames++;
                if (badFrames <= 5)
                    warnings.Add($"Grh[{id}]: animation frame {frame} not found");
            }
        }
    }
}

if (warnings.Count == 0)
{
    Console.WriteLine("  All checks passed.");
}
else
{
    Console.WriteLine($"  {warnings.Count} warnings:");
    foreach (var w in warnings.Take(20))
        Console.WriteLine($"    - {w}");
    if (warnings.Count > 20)
        Console.WriteLine($"    ... and {warnings.Count - 20} more");
}

Console.WriteLine();
Console.WriteLine($"Done. {totalFiles} files written to {outputPath}");
return 0;

void WriteJson<T>(string filename, T data)
{
    File.WriteAllText(Path.Combine(outputPath, filename), JsonSerializer.Serialize(data, jsonOptions));
    totalFiles++;
}
