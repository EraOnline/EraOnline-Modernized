namespace EoDataConverter.Converters;

public static class QuestConverter
{
    public static List<QuestRecord> Convert(string path)
    {
        var ini = IniParser.Load(path);
        int count = ini.GetInt("INIT", "NumQUESTs");
        var result = new List<QuestRecord>();

        for (int i = 1; i <= count; i++)
        {
            var sec = $"QUEST{i}";
            result.Add(new QuestRecord
            {
                Id = i,
                Type = ini.GetInt(sec, "Type"),
                Item = ini.GetInt(sec, "Item"),
                Sender = ini.GetVar(sec, "Sender"),
                Receiver = ini.GetVar(sec, "Reciver"), // original typo
                RewardItem = ini.GetInt(sec, "RewardItem"),
                RewardExp = ini.GetInt(sec, "RewardExp"),
                RewardGold = ini.GetInt(sec, "RewardGold")
            });
        }
        return result;
    }
}
