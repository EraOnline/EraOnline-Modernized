namespace EoDataConverter.Converters;

public static class GossipConverter
{
    public static List<GossipEntry> Convert(string path)
    {
        var ini = IniParser.Load(path);
        int count = ini.GetInt("INIT", "NumGOSSIPs");
        var result = new List<GossipEntry>();

        for (int i = 1; i <= count; i++)
        {
            var text = ini.GetVar($"GOSSIP{i}", "Gossip");
            if (!string.IsNullOrEmpty(text))
                result.Add(new GossipEntry { Id = i, Text = text });
        }
        return result;
    }
}
