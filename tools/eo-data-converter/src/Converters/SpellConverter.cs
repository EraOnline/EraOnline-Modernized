namespace EoDataConverter.Converters;

public static class SpellConverter
{
    public static List<SpellRecord> Convert(string path)
    {
        var ini = IniParser.Load(path);
        int count = ini.GetInt("INIT", "NumSpells");
        var result = new List<SpellRecord>();

        for (int i = 1; i <= count; i++)
        {
            var sec = $"SPELL{i}";
            var name = ini.GetVar(sec, "Name");
            if (string.IsNullOrEmpty(name)) continue;

            var schools = new[] { "School1", "School2", "School3" }
                .Select(k => ini.GetVar(sec, k))
                .Where(v => !string.IsNullOrEmpty(v))
                .ToArray();

            result.Add(new SpellRecord
            {
                Id = i,
                Name = name,
                Desc = ini.GetVar(sec, "Desc"),
                CasterMessage = ini.GetVar(sec, "CasterMessage"),
                TargetMessage = ini.GetVar(sec, "TargetMessage"),
                Schools = schools,
                GrhEffect = ini.GetInt(sec, "GrhEffect"),
                GrhIndex = ini.GetInt(sec, "GrhIndex"),
                GrhIcon = ini.GetInt(sec, "GrhIcon"),
                Sound = ini.GetInt(sec, "Sound"),
                NeedsMana = ini.GetInt(sec, "NeedsMana"),
                GiveHp = ini.GetInt(sec, "GiveHP"),
                GiveMan = ini.GetInt(sec, "GiveMan"),
                GiveFat = ini.GetInt(sec, "GiveFat"),
                GiveMoney = ini.GetInt(sec, "GiveMoney"),
                GiveFood = ini.GetInt(sec, "GiveFood"),
                GiveDrink = ini.GetInt(sec, "GiveDrink"),
                GiveExp = ini.GetInt(sec, "GiveExp"),
                HealHp = ini.GetInt(sec, "HealHP"),
                HealMan = ini.GetInt(sec, "HealMan"),
                HealFat = ini.GetInt(sec, "HealFat"),
                DamageHp = ini.GetInt(sec, "DamageHP"),
                DamageMan = ini.GetInt(sec, "DamageMan"),
                DamageFat = ini.GetInt(sec, "DamageFat"),
                Invisibility = ini.GetInt(sec, "Invisibility"),
                CreateObj = ini.GetInt(sec, "CreateOBJ"),
                SummonCreature = ini.GetInt(sec, "SummonCreature"),
                Paralyze = ini.GetInt(sec, "Paralyze"),
                Destruction = ini.GetInt(sec, "Destruction"),
                Resurrection = ini.GetInt(sec, "Ressurection")
            });
        }
        return result;
    }
}
