namespace EoDataConverter.Converters;

public static class MapConverter
{
    private const int MapWidth = 100;
    private const int MapHeight = 100;
    private const int TileCount = MapWidth * MapHeight;
    private const int MapBytesPerTile = 7;  // Blocked(1) + 3 GrhIndex(2 each)
    private const int InfBytesPerTile = 12; // TileExit(6) + NpcIndex(2) + Padding(4)

    public static MapData Convert(int mapId, string mapFile, string infFile, string datFile)
    {
        var blocked = new int[TileCount];
        var layer1 = new int[TileCount];
        var layer2 = new int[TileCount];
        var layer3 = new int[TileCount];
        var tileExits = new List<int[]>();
        var npcSpawns = new List<int[]>();

        // Parse .map file (7 bytes/tile)
        var mapData = File.ReadAllBytes(mapFile);
        for (int i = 0; i < TileCount; i++)
        {
            int offset = i * MapBytesPerTile;
            blocked[i] = mapData[offset];
            layer1[i] = BitConverter.ToInt16(mapData, offset + 1);
            layer2[i] = BitConverter.ToInt16(mapData, offset + 3);
            layer3[i] = BitConverter.ToInt16(mapData, offset + 5);
        }

        // Parse .inf file (12 bytes/tile, file may be larger due to trailing space)
        if (File.Exists(infFile))
        {
            var infData = File.ReadAllBytes(infFile);
            for (int i = 0; i < TileCount; i++)
            {
                int offset = i * InfBytesPerTile;
                if (offset + InfBytesPerTile > infData.Length) break;

                int exitMap = BitConverter.ToInt16(infData, offset);
                int exitX = BitConverter.ToInt16(infData, offset + 2);
                int exitY = BitConverter.ToInt16(infData, offset + 4);
                int npcIndex = BitConverter.ToInt16(infData, offset + 6);
                // bytes 8-11 are padding (always 0)

                int x = (i % MapWidth) + 1;
                int y = (i / MapWidth) + 1;

                if (exitMap > 0)
                    tileExits.Add([x, y, exitMap, exitX, exitY]);
                if (npcIndex > 0)
                    npcSpawns.Add([x, y, npcIndex]);
            }
        }

        // Parse .dat file (INI metadata)
        string name = "";
        string music = "";
        bool pkFreeZone = false;
        int[]? startPos = null;
        var exits = new Dictionary<string, int>();

        if (File.Exists(datFile))
        {
            var ini = IniParser.Load(datFile);
            var sec = $"Map{mapId}";
            name = ini.GetVar(sec, "Name");
            music = ini.GetVar(sec, "MusicNum");
            pkFreeZone = ini.GetVar(sec, "PKFREEZONE") == "1";

            var sp = ini.GetVar(sec, "StartPos");
            if (!string.IsNullOrEmpty(sp))
            {
                var parts = sp.Split('-');
                if (parts.Length == 3)
                    startPos = [int.Parse(parts[0]), int.Parse(parts[1]), int.Parse(parts[2])];
            }

            int n = ini.GetInt(sec, "NorthExit");
            int s = ini.GetInt(sec, "SouthExit");
            int w = ini.GetInt(sec, "WestExit");
            int e = ini.GetInt(sec, "EastExit");
            if (n > 0) exits["north"] = n;
            if (s > 0) exits["south"] = s;
            if (w > 0) exits["west"] = w;
            if (e > 0) exits["east"] = e;
        }

        return new MapData
        {
            Id = mapId,
            Name = name,
            Music = music,
            PkFreeZone = pkFreeZone,
            StartPos = startPos,
            Exits = exits,
            Tiles = new MapTiles
            {
                Blocked = blocked,
                Layer1 = layer1,
                Layer2 = layer2,
                Layer3 = layer3
            },
            TileExits = tileExits,
            NpcSpawns = npcSpawns
        };
    }
}
