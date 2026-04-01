namespace EoDataConverter.Converters;

public static class BodyConverter
{
    public static List<BodyRecord> Convert(string path)
    {
        var ini = IniParser.Load(path);
        int count = ini.GetInt("INIT", "NumBodies");
        var result = new List<BodyRecord>();

        for (int i = 1; i <= count; i++)
        {
            var sec = $"Body{i}";
            var w1 = ini.GetInt(sec, "Walk1");
            if (w1 == 0) continue;

            result.Add(new BodyRecord
            {
                Id = i,
                Walk = [w1, ini.GetInt(sec, "Walk2"), ini.GetInt(sec, "Walk3"), ini.GetInt(sec, "Walk4")],
                HeadOffsetX = ini.GetInt(sec, "HeadoffsetX"),
                HeadOffsetY = ini.GetInt(sec, "HeadoffsetY")
            });
        }
        return result;
    }
}
