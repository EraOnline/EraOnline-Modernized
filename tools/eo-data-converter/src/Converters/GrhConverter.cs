namespace EoDataConverter.Converters;

public static class GrhConverter
{
    public static GrhData Convert(string grhDatPath, string grhIniPath)
    {
        var ini = IniParser.Load(grhIniPath);
        int numFiles = ini.GetInt("INIT", "NumGrhFiles");

        var data = File.ReadAllBytes(grhDatPath);
        var entries = new Dictionary<int, GrhEntry>();
        int offset = 10; // skip 5 x Int16 header

        while (offset + 2 <= data.Length)
        {
            int grhIndex = BitConverter.ToInt16(data, offset);
            offset += 2;
            if (grhIndex == 0) break;

            int numFrames = BitConverter.ToInt16(data, offset);
            offset += 2;

            if (numFrames > 1)
            {
                // Animation: N frame indices + speed
                var frames = new int[numFrames];
                for (int f = 0; f < numFrames; f++)
                {
                    frames[f] = BitConverter.ToInt16(data, offset);
                    offset += 2;
                }
                int speed = BitConverter.ToInt16(data, offset);
                offset += 2;

                entries[grhIndex] = new GrhEntry { Frames = frames, Speed = speed };
            }
            else
            {
                // Single sprite: fileNum, sX, sY, pixelWidth, pixelHeight
                int fileNum = BitConverter.ToInt16(data, offset); offset += 2;
                int sx = BitConverter.ToInt16(data, offset); offset += 2;
                int sy = BitConverter.ToInt16(data, offset); offset += 2;
                int pw = BitConverter.ToInt16(data, offset); offset += 2;
                int ph = BitConverter.ToInt16(data, offset); offset += 2;

                entries[grhIndex] = new GrhEntry { File = fileNum, X = sx, Y = sy, W = pw, H = ph };
            }
        }

        return new GrhData { NumFiles = numFiles, Entries = entries };
    }
}
