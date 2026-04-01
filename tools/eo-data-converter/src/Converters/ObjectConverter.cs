namespace EoDataConverter.Converters;

public static class ObjectConverter
{
    public static List<ObjRecord> Convert(string path)
    {
        var ini = IniParser.Load(path);
        int count = ini.GetInt("INIT", "NumOBJs");
        var result = new List<ObjRecord>();

        for (int i = 1; i <= count; i++)
        {
            var sec = $"OBJ{i}";
            var name = ini.GetVar(sec, "Name");
            if (string.IsNullOrEmpty(name)) continue;

            var forbids = new[] { "Classforbid1", "Classforbid2", "Classforbid3", "Classforbid4", "Classforbid5", "Classforbid6", "Classforbid7" }
                .Select(k => ini.GetVar(sec, k))
                .Where(v => !string.IsNullOrEmpty(v))
                .ToArray();

            result.Add(new ObjRecord
            {
                Id = i,
                Name = name,
                ObjType = ini.GetInt(sec, "ObjType"),
                GrhIndex = ini.GetInt(sec, "GrhIndex"),
                Category = ini.GetVar(sec, "Category"),
                MinHp = ini.GetInt(sec, "MinHP"),
                MaxHp = ini.GetInt(sec, "MaxHP"),
                MinHit = ini.GetInt(sec, "MinHIT"),
                MaxHit = ini.GetInt(sec, "MaxHIT"),
                Def = ini.GetInt(sec, "DEF"),
                Pickable = ini.GetInt(sec, "Pickable"),
                ClothingType = ini.GetInt(sec, "ClothingType"),
                HandleRain = ini.GetInt(sec, "TakeRain"),
                SpellType = ini.GetInt(sec, "SPELLTYPE"),
                Value = ini.GetVar(sec, "VALUE"),
                MakeItem = ini.GetInt(sec, "Makeitem"),
                NeedPlanks = ini.GetInt(sec, "NeedPlanks"),
                NeedSteel = ini.GetInt(sec, "NeedSteel"),
                NeedFoldedCloth = ini.GetInt(sec, "NeedFoldedCloth"),
                WeaponAnim = ini.GetInt(sec, "WeaponAnim"),
                ShieldAnim = ini.GetInt(sec, "ShieldAnim"),
                Skill = ini.GetInt(sec, "Skill"),
                Sellable = ini.GetInt(sec, "Sellable"),
                Level = ini.GetLong(sec, "LEVEL"),
                Food = ini.GetInt(sec, "Food"),
                ClassForbid = forbids
            });
        }
        return result;
    }
}
