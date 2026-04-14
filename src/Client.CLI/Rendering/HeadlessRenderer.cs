using System.Text.Json;
using EraOnline.Client.CLI.Session;
using SkiaSharp;

namespace EraOnline.Client.CLI.Rendering;

/// <summary>
/// Headless 3-pass renderer that produces PNG screenshots.
/// Faithful port of the JS renderer (renderer.js render function).
///
/// Pass 1: Ground tiles (layer1) — opaque blit
/// Pass 2: Characters + ground objects — drawn to offscreen canvas
/// Pass 3: Fringe (layer2 + layer3/weather) — drawn to offscreen canvas with alpha reveal
/// Composite: characters behind, fringe on top (with hole revealing characters)
/// </summary>
public class HeadlessRenderer : IDisposable
{
    private const int TileSize = 32;
    private const int ViewportW = 40;
    private const int ViewportH = 22;
    private const int ScreenBuffer = 2;
    private const int FringeOverscan = 8; // extra tiles for large multi-tile sprites
    private const float RevealRadiusPx = 3.2f * TileSize;
    private const float RevealAlpha = 0.6f;

    private readonly SpriteLoader _sprites;
    private readonly string _dataPath;

    // Map tile data (loaded per map)
    private int _currentMapId;
    private int[]? _layer1;
    private int[]? _layer2;
    private int[]? _layer3;

    public HeadlessRenderer(SpriteLoader sprites, string dataPath)
    {
        _sprites = sprites;
        _dataPath = dataPath;
    }

    /// <summary>
    /// Render the current viewport to a PNG file.
    /// Returns the file path of the saved screenshot.
    /// </summary>
    public string RenderScreenshot(GameState state, string outputDir, float scale = 1.5f)
    {
        // Ensure map data is loaded
        LoadMapIfNeeded(state.Map);

        if (_layer1 == null) return "(no map data)";

        // Render at native resolution, then scale up the output
        int canvasW = ViewportW * TileSize;
        int canvasH = ViewportH * TileSize;

        using var mainBitmap = new SKBitmap(canvasW, canvasH);
        using var mainCanvas = new SKCanvas(mainBitmap);
        using var charBitmap = new SKBitmap(canvasW, canvasH);
        using var charCanvas = new SKCanvas(charBitmap);
        using var fringeBitmap = new SKBitmap(canvasW, canvasH);
        using var fringeCanvas = new SKCanvas(fringeBitmap);

        mainCanvas.Clear(SKColors.Black);
        charCanvas.Clear(SKColors.Transparent);
        fringeCanvas.Clear(SKColors.Transparent);

        int camX = state.X;
        int camY = state.Y;
        int halfW = ViewportW / 2;
        int halfH = ViewportH / 2;
        int minX = camX - halfW - ScreenBuffer;
        int maxX = camX + halfW + ScreenBuffer;
        int minY = camY - halfH - ScreenBuffer;
        int maxY = camY + halfH + ScreenBuffer;

        // Pass 1: Ground layer (onto main canvas)
        for (int y = minY; y <= maxY; y++)
        {
            for (int x = minX; x <= maxX; x++)
            {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                int idx = (y - 1) * 100 + (x - 1);
                int grhIndex = _layer1[idx];
                if (grhIndex > 0)
                {
                    int sx = x - (camX - halfW);
                    int sy = y - (camY - halfH);
                    DrawGrh(mainCanvas, grhIndex, sx * TileSize, sy * TileSize, false);
                }
            }
        }

        // Pass 2a: Characters + ground objects (onto char canvas)
        for (int y = minY; y <= maxY; y++)
        {
            for (int x = minX; x <= maxX; x++)
            {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                int sx = x - (camX - halfW);
                int sy = y - (camY - halfH);
                int px = sx * TileSize;
                int py = sy * TileSize;

                // Ground objects
                if (state.GroundObjects.TryGetValue($"{x},{y}", out int objGrh) && objGrh > 0)
                {
                    DrawGrh(charCanvas, objGrh, px, py, true);
                }

                // Characters at this tile
                foreach (var ch in state.Characters.Values)
                {
                    if (ch.X == x && ch.Y == y)
                    {
                        DrawCharacter(charCanvas, ch, px, py);
                    }
                }
            }
        }

        // Pass 2b: Fringe layer (layer2 + layer3 weather) onto fringe canvas
        // Use wider scan range to catch large multi-tile sprites (buildings, trees)
        int fMinX = camX - halfW - FringeOverscan;
        int fMaxX = camX + halfW + FringeOverscan;
        int fMinY = camY - halfH - FringeOverscan;
        int fMaxY = camY + halfH + FringeOverscan;

        for (int y = fMinY; y <= fMaxY; y++)
        {
            for (int x = fMinX; x <= fMaxX; x++)
            {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                int idx = (y - 1) * 100 + (x - 1);
                int sx = x - (camX - halfW);
                int sy = y - (camY - halfH);
                int px = sx * TileSize;
                int py = sy * TileSize;

                if (_layer2 != null)
                {
                    int grh2 = _layer2[idx];
                    if (grh2 > 0)
                        DrawGrh(fringeCanvas, grh2, px, py, true);
                }

                if (state.IsRaining && _layer3 != null)
                {
                    int grh3 = _layer3[idx];
                    if (grh3 > 0)
                        DrawGrh(fringeCanvas, grh3, px, py, true);
                }
            }
        }

        // Pass 2c: Alpha reveal around player in fringe
        int meSx = camX - (camX - halfW);
        int meSy = camY - (camY - halfH);
        float mePx = meSx * TileSize + TileSize / 2f;
        float mePy = meSy * TileSize + TileSize / 2f;

        using (var revealPaint = new SKPaint())
        {
            revealPaint.BlendMode = SKBlendMode.DstOut;
            revealPaint.Shader = SKShader.CreateRadialGradient(
                new SKPoint(mePx, mePy),
                RevealRadiusPx,
                new[] { new SKColor(0, 0, 0, (byte)(RevealAlpha * 255)), SKColors.Transparent },
                new[] { 0f, 1f },
                SKShaderTileMode.Clamp);
            fringeCanvas.DrawRect(
                mePx - RevealRadiusPx, mePy - RevealRadiusPx,
                RevealRadiusPx * 2, RevealRadiusPx * 2,
                revealPaint);
        }

        // Composite: characters first (behind), then fringe on top
        mainCanvas.DrawBitmap(charBitmap, 0, 0);
        mainCanvas.DrawBitmap(fringeBitmap, 0, 0);

        // Clip to viewport (remove overdraw from screen buffer)
        // Actually we're already only rendering the viewport size, but with buffer
        // Let me just save what we have — the buffer tiles extend beyond canvas bounds
        // and get clipped naturally by the canvas dimensions.

        // Scale up for better visibility
        Directory.CreateDirectory(outputDir);
        var filename = $"{DateTime.Now:yyyyMMdd-HHmmss}.png";
        var filePath = Path.Combine(outputDir, filename);

        int scaledW = (int)(canvasW * scale);
        int scaledH = (int)(canvasH * scale);
        using var scaledBitmap = new SKBitmap(scaledW, scaledH);
        using var scaledCanvas = new SKCanvas(scaledBitmap);
        scaledCanvas.Scale(scale);
        scaledCanvas.DrawBitmap(mainBitmap, 0, 0);

        using var image = SKImage.FromBitmap(scaledBitmap);
        using var data = image.Encode(SKEncodedImageFormat.Png, 100);
        using var stream = File.OpenWrite(filePath);
        data.SaveTo(stream);

        return filePath;
    }

    /// <summary>
    /// Render the entire 100x100 map to a PNG at 1x scale (3200x3200 pixels).
    /// Used for bird's-eye spatial planning when first visiting a map.
    /// </summary>
    public string RenderFullMap(int mapId, GameState state, string outputDir)
    {
        LoadMapIfNeeded(mapId);
        if (_layer1 == null) return "(no map data)";

        int mapW = 100 * TileSize; // 3200
        int mapH = 100 * TileSize; // 3200

        using var mainBitmap = new SKBitmap(mapW, mapH);
        using var mainCanvas = new SKCanvas(mainBitmap);
        using var charBitmap = new SKBitmap(mapW, mapH);
        using var charCanvas = new SKCanvas(charBitmap);
        using var fringeBitmap = new SKBitmap(mapW, mapH);
        using var fringeCanvas = new SKCanvas(fringeBitmap);

        mainCanvas.Clear(SKColors.Black);
        charCanvas.Clear(SKColors.Transparent);
        fringeCanvas.Clear(SKColors.Transparent);

        // Pass 1: Ground
        for (int y = 1; y <= 100; y++)
            for (int x = 1; x <= 100; x++)
            {
                int idx = (y - 1) * 100 + (x - 1);
                int grhIndex = _layer1[idx];
                if (grhIndex > 0)
                    DrawGrh(mainCanvas, grhIndex, (x - 1) * TileSize, (y - 1) * TileSize, false);
            }

        // Pass 2a: Characters + ground objects
        foreach (var ch in state.Characters.Values)
        {
            int px = (ch.X - 1) * TileSize;
            int py = (ch.Y - 1) * TileSize;
            DrawCharacter(charCanvas, ch, px, py);
        }
        foreach (var (key, grhIdx) in state.GroundObjects)
        {
            var parts = key.Split(',');
            if (parts.Length == 2 && int.TryParse(parts[0], out int ox) && int.TryParse(parts[1], out int oy))
                DrawGrh(charCanvas, grhIdx, (ox - 1) * TileSize, (oy - 1) * TileSize, true);
        }

        // Pass 2b: Fringe
        for (int y = 1; y <= 100; y++)
            for (int x = 1; x <= 100; x++)
            {
                int idx = (y - 1) * 100 + (x - 1);
                if (_layer2 != null)
                {
                    int grh2 = _layer2[idx];
                    if (grh2 > 0)
                        DrawGrh(fringeCanvas, grh2, (x - 1) * TileSize, (y - 1) * TileSize, true);
                }
            }

        // Composite
        mainCanvas.DrawBitmap(charBitmap, 0, 0);
        mainCanvas.DrawBitmap(fringeBitmap, 0, 0);

        // Mark player position with a red circle
        using var markerPaint = new SKPaint { Color = SKColors.Red, Style = SKPaintStyle.Stroke, StrokeWidth = 3 };
        mainCanvas.DrawCircle((state.X - 1) * TileSize + TileSize / 2, (state.Y - 1) * TileSize + TileSize / 2, TileSize, markerPaint);

        // Save
        Directory.CreateDirectory(outputDir);
        var filename = $"map-{mapId:D3}-full.png";
        var filePath = Path.Combine(outputDir, filename);

        using var image = SKImage.FromBitmap(mainBitmap);
        using var data = image.Encode(SKEncodedImageFormat.Png, 90);
        using var stream = File.OpenWrite(filePath);
        data.SaveTo(stream);

        return filePath;
    }

    /// <summary>
    /// Render a viewport-sized area centered on arbitrary coordinates with a red marker.
    /// Used for probing/inspecting specific areas of the map.
    /// </summary>
    public string RenderProbe(int mapId, int centerX, int centerY, GameState state, string outputDir, float scale = 1.5f)
    {
        LoadMapIfNeeded(mapId);
        if (_layer1 == null) return "(no map data)";

        int canvasW = ViewportW * TileSize;
        int canvasH = ViewportH * TileSize;

        using var mainBitmap = new SKBitmap(canvasW, canvasH);
        using var mainCanvas = new SKCanvas(mainBitmap);
        using var charBitmap = new SKBitmap(canvasW, canvasH);
        using var charCanvas = new SKCanvas(charBitmap);
        using var fringeBitmap = new SKBitmap(canvasW, canvasH);
        using var fringeCanvas = new SKCanvas(fringeBitmap);

        mainCanvas.Clear(SKColors.Black);
        charCanvas.Clear(SKColors.Transparent);
        fringeCanvas.Clear(SKColors.Transparent);

        int halfW = ViewportW / 2;
        int halfH = ViewportH / 2;

        // Ground
        for (int y = centerY - halfH - ScreenBuffer; y <= centerY + halfH + ScreenBuffer; y++)
            for (int x = centerX - halfW - ScreenBuffer; x <= centerX + halfW + ScreenBuffer; x++)
            {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                int idx = (y - 1) * 100 + (x - 1);
                int grhIndex = _layer1[idx];
                if (grhIndex > 0)
                {
                    int sx = x - (centerX - halfW);
                    int sy = y - (centerY - halfH);
                    DrawGrh(mainCanvas, grhIndex, sx * TileSize, sy * TileSize, false);
                }
            }

        // Characters + ground objects in view
        for (int y = centerY - halfH - ScreenBuffer; y <= centerY + halfH + ScreenBuffer; y++)
            for (int x = centerX - halfW - ScreenBuffer; x <= centerX + halfW + ScreenBuffer; x++)
            {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                int sx = x - (centerX - halfW);
                int sy = y - (centerY - halfH);
                int px = sx * TileSize;
                int py = sy * TileSize;

                if (state.GroundObjects.TryGetValue($"{x},{y}", out int objGrh) && objGrh > 0)
                    DrawGrh(charCanvas, objGrh, px, py, true);
                foreach (var ch in state.Characters.Values)
                    if (ch.X == x && ch.Y == y)
                        DrawCharacter(charCanvas, ch, px, py);
            }

        // Fringe with overscan
        for (int y = centerY - halfH - FringeOverscan; y <= centerY + halfH + FringeOverscan; y++)
            for (int x = centerX - halfW - FringeOverscan; x <= centerX + halfW + FringeOverscan; x++)
            {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                int idx = (y - 1) * 100 + (x - 1);
                int sx = x - (centerX - halfW);
                int sy = y - (centerY - halfH);
                if (_layer2 != null)
                {
                    int grh2 = _layer2[idx];
                    if (grh2 > 0) DrawGrh(fringeCanvas, grh2, sx * TileSize, sy * TileSize, true);
                }
            }

        // Composite
        mainCanvas.DrawBitmap(charBitmap, 0, 0);
        mainCanvas.DrawBitmap(fringeBitmap, 0, 0);

        // Red dot at the probe center
        using var markerPaint = new SKPaint { Color = SKColors.Red, Style = SKPaintStyle.Fill };
        int dotX = halfW * TileSize + TileSize / 2;
        int dotY = halfH * TileSize + TileSize / 2;
        mainCanvas.DrawCircle(dotX, dotY, 6, markerPaint);
        using var outlinePaint = new SKPaint { Color = SKColors.White, Style = SKPaintStyle.Stroke, StrokeWidth = 2 };
        mainCanvas.DrawCircle(dotX, dotY, 6, outlinePaint);

        // Scale and save
        Directory.CreateDirectory(outputDir);
        var filename = $"probe-{centerX}-{centerY}.png";
        var filePath = Path.Combine(outputDir, filename);

        int scaledW = (int)(canvasW * scale);
        int scaledH = (int)(canvasH * scale);
        using var scaledBitmap = new SKBitmap(scaledW, scaledH);
        using var scaledCanvas = new SKCanvas(scaledBitmap);
        scaledCanvas.Scale(scale);
        scaledCanvas.DrawBitmap(mainBitmap, 0, 0);

        using var image = SKImage.FromBitmap(scaledBitmap);
        using var data = image.Encode(SKEncodedImageFormat.Png, 100);
        using var stream = File.OpenWrite(filePath);
        data.SaveTo(stream);

        return filePath;
    }

    private void DrawGrh(SKCanvas canvas, int grhIndex, int px, int py, bool center)
    {
        var sprite = _sprites.ResolveGrh(grhIndex);
        if (sprite == null || sprite.File <= 0) return;

        var sheet = _sprites.GetSpriteSheet(sprite.File);
        if (sheet == null) return;

        int dx = px, dy = py;
        if (center)
        {
            // VB6 uses float division: TileWidth = pixelWidth / TileSizeX
            // JS also uses float: sprite.w / TILE_SIZE
            // Must use float here too — integer division truncates sub-tile sprites to 0
            float tw = (float)sprite.W / TileSize;
            float th = (float)sprite.H / TileSize;
            if (Math.Abs(tw - 1f) > 0.001f) dx -= (int)(tw * 16) - 16;
            if (Math.Abs(th - 1f) > 0.001f) dy -= (int)(th * 32) - 32;
        }

        var srcRect = new SKRect(sprite.X, sprite.Y, sprite.X + sprite.W, sprite.Y + sprite.H);
        var dstRect = new SKRect(dx, dy, dx + sprite.W, dy + sprite.H);
        canvas.DrawBitmap(sheet, srcRect, dstRect);
    }

    private void DrawCharacter(SKCanvas canvas, CharacterInfo ch, int screenX, int screenY)
    {
        int hi = (ch.Heading > 0 ? ch.Heading : 3) - 1; // heading 1-4 -> index 0-3

        var body = _sprites.GetBody(ch.Body);
        var head = _sprites.GetHead(ch.Head);
        var weapon = _sprites.GetWeaponAnim(ch.WeaponAnim);
        var shield = _sprites.GetShieldAnim(ch.ShieldAnim);

        // Head (drawn first, behind body — matching JS order)
        if (head?.Grh is { Length: > 0 } && hi < head.Grh.Length)
        {
            int headOffX = body?.HeadOffsetX ?? 0;
            int headOffY = body?.HeadOffsetY ?? 0;
            DrawGrh(canvas, head.Grh[hi], screenX + headOffX, screenY + headOffY, true);
        }

        // Body
        if (body?.Walk is { Length: > 0 } && hi < body.Walk.Length)
        {
            DrawGrh(canvas, body.Walk[hi], screenX, screenY, true);
        }

        // Shield
        if (shield?.Walk is { Length: > 0 } && hi < shield.Walk.Length)
        {
            DrawGrh(canvas, shield.Walk[hi], screenX, screenY, true);
        }

        // Weapon
        if (weapon?.Walk is { Length: > 0 } && hi < weapon.Walk.Length)
        {
            DrawGrh(canvas, weapon.Walk[hi], screenX, screenY, true);
        }
    }

    private void LoadMapIfNeeded(int mapId)
    {
        if (mapId == _currentMapId && _layer1 != null) return;

        var padded = mapId.ToString().PadLeft(3, '0');
        var path = Path.Combine(_dataPath, "maps", $"map-{padded}.json");
        if (!File.Exists(path))
        {
            _layer1 = null;
            _layer2 = null;
            _layer3 = null;
            return;
        }

        var json = File.ReadAllText(path);
        using var doc = JsonDocument.Parse(json);
        var tiles = doc.RootElement.GetProperty("tiles");

        _layer1 = ReadTileLayer(tiles, "layer1");
        _layer2 = ReadTileLayer(tiles, "layer2");
        _layer3 = ReadTileLayer(tiles, "layer3");
        _currentMapId = mapId;
    }

    private static int[]? ReadTileLayer(JsonElement tiles, string name)
    {
        if (!tiles.TryGetProperty(name, out var layer)) return null;
        return layer.EnumerateArray().Select(e => e.GetInt32()).ToArray();
    }

    public void Dispose()
    {
        // SpriteLoader handles its own disposal
    }
}
