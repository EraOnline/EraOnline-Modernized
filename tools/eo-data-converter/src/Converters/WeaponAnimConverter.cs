namespace EoDataConverter.Converters;

public static class WeaponAnimConverter
{
    public static List<AnimRecord> Convert(string path)
    {
        var ini = IniParser.Load(path);
        int count = ini.GetInt("INIT", "NumWeaponAnims");
        var result = new List<AnimRecord>();

        for (int i = 1; i <= count; i++)
        {
            var sec = $"WeaponAnim{i}";
            var w1 = ini.GetInt(sec, "WeaponWalk1");
            if (w1 == 0) continue;

            result.Add(new AnimRecord
            {
                Id = i,
                Walk = [w1, ini.GetInt(sec, "WeaponWalk2"), ini.GetInt(sec, "WeaponWalk3"), ini.GetInt(sec, "WeaponWalk4")]
            });
        }
        return result;
    }
}
