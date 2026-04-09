namespace EoDataConverter.Converters;

public static class NpcConverter
{
    public static List<NpcRecord> Convert(string npcPath, string npc2Path)
    {
        var ini1 = IniParser.Load(npcPath);
        var ini2 = IniParser.Load(npc2Path);
        int count = ini1.GetInt("INIT", "NumNPCs");
        var result = new List<NpcRecord>();

        for (int i = 1; i <= count; i++)
        {
            // NPC.dat for < 500, NPC2.dat for >= 500
            var ini = i < 500 ? ini1 : ini2;
            var sec = $"NPC{i}";
            var name = ini.GetVar(sec, "Name");
            if (string.IsNullOrEmpty(name)) continue;

            var categories = new[] { "Category1", "Category2", "Category3", "Category4", "Category5" }
                .Select(k => ini.GetVar(sec, k))
                .Where(v => !string.IsNullOrEmpty(v))
                .ToArray();

            var inventory = new List<NpcInvSlot>();
            for (int s = 1; s <= 40; s++)
            {
                // VB6 format: Obj1=ObjIndex-Amount-Equipped (e.g. "6-1-0")
                var objStr = ini.GetVar(sec, $"Obj{s}");
                if (string.IsNullOrEmpty(objStr)) continue;
                var parts = objStr.Split('-');
                int objIdx = parts.Length > 0 && int.TryParse(parts[0], out var idx) ? idx : 0;
                int amount = parts.Length > 1 && int.TryParse(parts[1], out var amt) ? amt : 1;
                if (objIdx > 0)
                    inventory.Add(new NpcInvSlot { ObjIndex = objIdx, Amount = amount });
            }

            result.Add(new NpcRecord
            {
                Id = i,
                Name = name,
                Desc = ini.GetVar(sec, "Desc"),
                Movement = ini.GetInt(sec, "Movement"),
                Body = ini.GetInt(sec, "Body"),
                Head = ini.GetInt(sec, "Head"),
                Heading = ini.GetInt(sec, "Heading"),
                Attackable = ini.GetInt(sec, "Attackable"),
                Hostile = ini.GetInt(sec, "Hostile"),
                Guard = ini.GetInt(sec, "Guard"),
                NpcType = ini.GetInt(sec, "NPCtype"),
                Level = ini.GetInt(sec, "Level"),
                LootChance = ini.GetInt(sec, "LootChance"),
                GiveExp = ini.GetInt(sec, "GiveEXP"),
                GiveGold = ini.GetLong(sec, "GiveGLD"),
                DeathObj = ini.GetInt(sec, "DeathObj"),
                Tameable = ini.GetInt(sec, "Tameable"),
                Tradeable = ini.GetInt(sec, "Tradeable"),
                Gold = ini.GetLong(sec, "Gold"),
                SkillNeeded = ini.GetVar(sec, "SkillNeeded"),
                Sound = ini.GetInt(sec, "Sound"),
                MaxHp = ini.GetInt(sec, "MaxHP"),
                MinHit = ini.GetInt(sec, "MinHIT"),
                MaxHit = ini.GetInt(sec, "MaxHIT"),
                Def = ini.GetInt(sec, "DEF"),
                Categories = categories,
                Inventory = inventory.ToArray()
            });
        }
        return result;
    }
}
