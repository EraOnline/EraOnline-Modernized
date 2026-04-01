namespace EoDataConverter.Converters;

public static class HeadConverter
{
    public static List<HeadRecord> Convert(string path)
    {
        var ini = IniParser.Load(path);
        int count = ini.GetInt("INIT", "NumHeads");
        var result = new List<HeadRecord>();

        for (int i = 1; i <= count; i++)
        {
            var sec = $"Head{i}";
            var h1 = ini.GetInt(sec, "Head1");
            if (h1 == 0) continue; // skip empty entries

            result.Add(new HeadRecord
            {
                Id = i,
                Grh = [h1, ini.GetInt(sec, "Head2"), ini.GetInt(sec, "Head3"), ini.GetInt(sec, "Head4")]
            });
        }
        return result;
    }
}
