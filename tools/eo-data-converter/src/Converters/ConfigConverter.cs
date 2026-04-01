namespace EoDataConverter.Converters;

public static class ConfigConverter
{
    public static ConfigData Convert(string path)
    {
        var ini = IniParser.Load(path);

        var cities = new List<StartingCity>();
        var cityDefs = new (string name, string key)[]
        {
            ("Bernvillage", "Bernvillage"),
            ("Castlefall", "CastleFall"),
            ("Angelmoor", "AngelMoor"),
            ("Gorth", "Gorth"),
            ("Jemhoo", "Jemhoo"),
            ("Denc", "Denc"),
            ("Valen", "Valen"),
            ("Valentfall", "ValenFall"),
            ("Molg", "Molg"),
            ("Ug", "Ug")
        };

        foreach (var (name, key) in cityDefs)
        {
            var val = ini.GetVar("INIT", key);
            if (string.IsNullOrEmpty(val)) continue;
            var parts = val.Split('-');
            if (parts.Length == 3 && int.TryParse(parts[0], out var map) && int.TryParse(parts[1], out var x) && int.TryParse(parts[2], out var y))
                cities.Add(new StartingCity { Name = name, Map = map, X = x, Y = y });
        }

        var gms = new List<string>();
        int numGms = ini.GetInt("INIT", "NumWizs");
        for (int i = 1; i <= numGms; i++)
        {
            var gm = ini.GetVar("WizList", $"wiz{i}");
            if (!string.IsNullOrEmpty(gm)) gms.Add(gm);
        }

        return new ConfigData
        {
            Port = ini.GetInt("INIT", "StartPort", 7777),
            MaxUsers = ini.GetInt("INIT", "MaxUsers", 1000),
            ClientVersion = ini.GetVar("INIT", "ClientVersion"),
            IdleLimit = ini.GetInt("INIT", "IdleLimit"),
            Season = ini.GetVar("INIT", "Season"),
            Era = ini.GetInt("INIT", "Era"),
            Year = ini.GetInt("INIT", "Year"),
            StartingCities = cities,
            Gms = gms
        };
    }
}
