using System.Text.Json;
using SkiaSharp;

namespace EraOnline.Client.CLI.Rendering;

/// <summary>
/// Loads sprite sheets and GRH definitions for headless rendering.
/// Port of the JS renderer's data loading (renderer.js init/loadSpriteSheet).
/// </summary>
public class SpriteLoader : IDisposable
{
    private readonly string _dataPath;
    private readonly Dictionary<int, SKBitmap> _spriteSheets = new();
    private Dictionary<string, GrhEntry> _grhEntries = new();
    private Dictionary<int, BodyDef> _bodyDefs = new();
    private Dictionary<int, HeadDef> _headDefs = new();
    private Dictionary<int, AnimDef> _weaponAnimDefs = new();
    private Dictionary<int, AnimDef> _shieldAnimDefs = new();

    public SpriteLoader(string dataPath)
    {
        _dataPath = dataPath;
    }

    public void LoadAll()
    {
        LoadGrhEntries();
        LoadBodies();
        LoadHeads();
        LoadWeaponAnims();
        LoadShieldAnims();
    }

    // --- GRH entries ---

    private void LoadGrhEntries()
    {
        var path = Path.Combine(_dataPath, "grh.json");
        if (!File.Exists(path)) return;
        var json = File.ReadAllText(path);
        using var doc = JsonDocument.Parse(json);
        var entries = doc.RootElement.GetProperty("entries");
        foreach (var prop in entries.EnumerateObject())
        {
            var entry = new GrhEntry { Index = int.Parse(prop.Name) };
            if (prop.Value.TryGetProperty("file", out var fileProp))
            {
                entry.File = fileProp.GetInt32();
                entry.X = prop.Value.GetProperty("x").GetInt32();
                entry.Y = prop.Value.GetProperty("y").GetInt32();
                entry.W = prop.Value.GetProperty("w").GetInt32();
                entry.H = prop.Value.GetProperty("h").GetInt32();
            }
            if (prop.Value.TryGetProperty("frames", out var framesProp))
            {
                entry.Frames = framesProp.EnumerateArray().Select(f => f.GetInt32()).ToArray();
                entry.Speed = prop.Value.GetProperty("speed").GetInt32();
            }
            _grhEntries[prop.Name] = entry;
        }
    }

    public GrhEntry? ResolveGrh(int grhIndex)
    {
        if (!_grhEntries.TryGetValue(grhIndex.ToString(), out var entry)) return null;
        // If animated, return first frame
        if (entry.Frames is { Length: > 0 })
        {
            return _grhEntries.GetValueOrDefault(entry.Frames[0].ToString());
        }
        return entry;
    }

    // --- Body/Head/Weapon/Shield defs ---

    private void LoadBodies()
    {
        var path = Path.Combine(_dataPath, "bodies.json");
        if (!File.Exists(path)) return;
        var json = File.ReadAllText(path);
        var items = JsonSerializer.Deserialize<BodyDef[]>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        if (items != null)
            foreach (var b in items) _bodyDefs[b.Id] = b;
    }

    private void LoadHeads()
    {
        var path = Path.Combine(_dataPath, "heads.json");
        if (!File.Exists(path)) return;
        var json = File.ReadAllText(path);
        var items = JsonSerializer.Deserialize<HeadDef[]>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        if (items != null)
            foreach (var h in items) _headDefs[h.Id] = h;
    }

    private void LoadWeaponAnims()
    {
        var path = Path.Combine(_dataPath, "weapon-anims.json");
        if (!File.Exists(path)) return;
        var json = File.ReadAllText(path);
        var items = JsonSerializer.Deserialize<AnimDef[]>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        if (items != null)
            foreach (var a in items) _weaponAnimDefs[a.Id] = a;
    }

    private void LoadShieldAnims()
    {
        var path = Path.Combine(_dataPath, "shield-anims.json");
        if (!File.Exists(path)) return;
        var json = File.ReadAllText(path);
        var items = JsonSerializer.Deserialize<AnimDef[]>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        if (items != null)
            foreach (var a in items) _shieldAnimDefs[a.Id] = a;
    }

    // --- Sprite sheet loading ---

    public SKBitmap? GetSpriteSheet(int fileNum)
    {
        if (_spriteSheets.TryGetValue(fileNum, out var cached)) return cached;

        var path = Path.Combine(_dataPath, "grh", $"grh{fileNum}.png");
        if (!File.Exists(path)) return null;

        var bitmap = SKBitmap.Decode(path);
        if (bitmap != null) _spriteSheets[fileNum] = bitmap;
        return bitmap;
    }

    public BodyDef? GetBody(int id) => _bodyDefs.GetValueOrDefault(id);
    public HeadDef? GetHead(int id) => _headDefs.GetValueOrDefault(id);
    public AnimDef? GetWeaponAnim(int id) => _weaponAnimDefs.GetValueOrDefault(id);
    public AnimDef? GetShieldAnim(int id) => _shieldAnimDefs.GetValueOrDefault(id);

    public void Dispose()
    {
        foreach (var bitmap in _spriteSheets.Values)
            bitmap.Dispose();
        _spriteSheets.Clear();
    }
}

public class GrhEntry
{
    public int Index { get; set; }
    public int File { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int W { get; set; }
    public int H { get; set; }
    public int[]? Frames { get; set; }
    public int Speed { get; set; }
}

public class BodyDef
{
    public int Id { get; set; }
    public int[] Walk { get; set; } = Array.Empty<int>(); // 4 entries: N,E,S,W
    public int HeadOffsetX { get; set; }
    public int HeadOffsetY { get; set; }
}

public class HeadDef
{
    public int Id { get; set; }
    public int[] Grh { get; set; } = Array.Empty<int>(); // 4 entries: N,E,S,W
}

public class AnimDef
{
    public int Id { get; set; }
    public int[] Walk { get; set; } = Array.Empty<int>(); // 4 entries: N,E,S,W
}
