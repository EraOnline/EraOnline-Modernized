using SkiaSharp;

namespace EoDataConverter.Converters;

/// <summary>
/// Converts VB6 BMP sprite sheets to PNG with transparency.
/// The original game uses DirectDraw color key blitting where black (0,0,0) = transparent.
/// We convert black pixels to alpha=0 in the output PNG.
/// </summary>
public static class SpriteConverter
{
    public static int Convert(string sourceDir, string outputDir)
    {
        Directory.CreateDirectory(outputDir);
        int converted = 0;

        // Find all GRH BMP files (mixed case: Grh1.bmp, GRH87.BMP, etc.)
        var bmpFiles = Directory.GetFiles(sourceDir, "*.bmp", SearchOption.TopDirectoryOnly)
            .Concat(Directory.GetFiles(sourceDir, "*.BMP", SearchOption.TopDirectoryOnly))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .Where(f =>
            {
                var name = Path.GetFileNameWithoutExtension(f).ToLowerInvariant();
                return name.StartsWith("grh") && int.TryParse(name[3..], out _);
            })
            .OrderBy(f =>
            {
                var name = Path.GetFileNameWithoutExtension(f).ToLowerInvariant();
                return int.Parse(name[3..]);
            });

        foreach (var bmpPath in bmpFiles)
        {
            var name = Path.GetFileNameWithoutExtension(bmpPath).ToLowerInvariant();
            var pngPath = Path.Combine(outputDir, name + ".png");

            try
            {
                using var bmp = SKBitmap.Decode(bmpPath);
                if (bmp == null)
                {
                    Console.Error.WriteLine($"  Warning: Failed to decode {bmpPath}");
                    continue;
                }

                // Convert black pixels to transparent
                var pixels = bmp.Pixels;
                for (int i = 0; i < pixels.Length; i++)
                {
                    var p = pixels[i];
                    if (p.Red == 0 && p.Green == 0 && p.Blue == 0)
                    {
                        pixels[i] = SKColor.Empty; // fully transparent
                    }
                }

                using var output = new SKBitmap(bmp.Width, bmp.Height, SKColorType.Rgba8888, SKAlphaType.Premul);
                output.Pixels = pixels;

                using var image = SKImage.FromBitmap(output);
                using var data = image.Encode(SKEncodedImageFormat.Png, 100);
                using var stream = File.OpenWrite(pngPath);
                data.SaveTo(stream);

                converted++;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"  Warning: Error converting {bmpPath}: {ex.Message}");
            }
        }

        return converted;
    }
}
