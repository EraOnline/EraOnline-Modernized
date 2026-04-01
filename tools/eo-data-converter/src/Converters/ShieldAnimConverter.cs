namespace EoDataConverter.Converters;

public static class ShieldAnimConverter
{
    public static List<AnimRecord> Convert(string path)
    {
        var ini = IniParser.Load(path);
        int count = ini.GetInt("INIT", "NumShieldAnims");
        var result = new List<AnimRecord>();

        for (int i = 1; i <= count; i++)
        {
            var sec = $"ShieldAnim{i}";
            var w1 = ini.GetInt(sec, "ShieldWalk1");
            if (w1 == 0) continue;

            result.Add(new AnimRecord
            {
                Id = i,
                Walk = [w1, ini.GetInt(sec, "ShieldWalk2"), ini.GetInt(sec, "ShieldWalk3"), ini.GetInt(sec, "ShieldWalk4")]
            });
        }
        return result;
    }
}
