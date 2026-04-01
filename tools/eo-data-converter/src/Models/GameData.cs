namespace EoDataConverter;

public record ObjRecord
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public int ObjType { get; init; }
    public int GrhIndex { get; init; }
    public string Category { get; init; } = "";
    public int MinHp { get; init; }
    public int MaxHp { get; init; }
    public int MinHit { get; init; }
    public int MaxHit { get; init; }
    public int Def { get; init; }
    public int Pickable { get; init; }
    public int ClothingType { get; init; }
    public int HandleRain { get; init; }
    public int SpellType { get; init; }
    public string Value { get; init; } = "";
    public int MakeItem { get; init; }
    public int NeedPlanks { get; init; }
    public int NeedSteel { get; init; }
    public int NeedFoldedCloth { get; init; }
    public int WeaponAnim { get; init; }
    public int ShieldAnim { get; init; }
    public int Skill { get; init; }
    public int Sellable { get; init; }
    public long Level { get; init; }
    public int Food { get; init; }
    public string[] ClassForbid { get; init; } = [];
}

public record NpcRecord
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public string Desc { get; init; } = "";
    public int Movement { get; init; }
    public int Body { get; init; }
    public int Head { get; init; }
    public int Heading { get; init; }
    public int Attackable { get; init; }
    public int Hostile { get; init; }
    public int Guard { get; init; }
    public int NpcType { get; init; }
    public int Level { get; init; }
    public int LootChance { get; init; }
    public int GiveExp { get; init; }
    public long GiveGold { get; init; }
    public int DeathObj { get; init; }
    public int Tameable { get; init; }
    public int Tradeable { get; init; }
    public string SkillNeeded { get; init; } = "";
    public int Sound { get; init; }
    public int MaxHp { get; init; }
    public int MinHit { get; init; }
    public int MaxHit { get; init; }
    public int Def { get; init; }
    public string[] Categories { get; init; } = [];
    public NpcInvSlot[] Inventory { get; init; } = [];
}

public record NpcInvSlot
{
    public int ObjIndex { get; init; }
    public int Amount { get; init; }
}

public record SpellRecord
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public string Desc { get; init; } = "";
    public string CasterMessage { get; init; } = "";
    public string TargetMessage { get; init; } = "";
    public string[] Schools { get; init; } = [];
    public int GrhEffect { get; init; }
    public int GrhIndex { get; init; }
    public int GrhIcon { get; init; }
    public int Sound { get; init; }
    public int NeedsMana { get; init; }
    public int GiveHp { get; init; }
    public int GiveMan { get; init; }
    public int GiveFat { get; init; }
    public int GiveMoney { get; init; }
    public int GiveFood { get; init; }
    public int GiveDrink { get; init; }
    public int GiveExp { get; init; }
    public int HealHp { get; init; }
    public int HealMan { get; init; }
    public int HealFat { get; init; }
    public int DamageHp { get; init; }
    public int DamageMan { get; init; }
    public int DamageFat { get; init; }
    public int Invisibility { get; init; }
    public int CreateObj { get; init; }
    public int SummonCreature { get; init; }
    public int Paralyze { get; init; }
    public int Destruction { get; init; }
    public int Resurrection { get; init; }
}

public record ConfigData
{
    public int Port { get; init; }
    public int MaxUsers { get; init; }
    public string ClientVersion { get; init; } = "";
    public int IdleLimit { get; init; }
    public string Season { get; init; } = "";
    public int Era { get; init; }
    public int Year { get; init; }
    public List<StartingCity> StartingCities { get; init; } = [];
    public List<string> Gms { get; init; } = [];
}

public record StartingCity
{
    public string Name { get; init; } = "";
    public int Map { get; init; }
    public int X { get; init; }
    public int Y { get; init; }
}

public record GossipEntry
{
    public int Id { get; init; }
    public string Text { get; init; } = "";
}

public record QuestRecord
{
    public int Id { get; init; }
    public int Type { get; init; }
    public int Item { get; init; }
    public string Sender { get; init; } = "";
    public string Receiver { get; init; } = "";
    public int RewardItem { get; init; }
    public int RewardExp { get; init; }
    public int RewardGold { get; init; }
}

public record HeadRecord
{
    public int Id { get; init; }
    public int[] Grh { get; init; } = []; // 4 directions: N, E, S, W
}

public record BodyRecord
{
    public int Id { get; init; }
    public int[] Walk { get; init; } = []; // 4 directions: N, E, S, W
    public int HeadOffsetX { get; init; }
    public int HeadOffsetY { get; init; }
}

public record AnimRecord
{
    public int Id { get; init; }
    public int[] Walk { get; init; } = []; // 4 directions
}

public record GrhData
{
    public int NumFiles { get; init; }
    public Dictionary<int, GrhEntry> Entries { get; init; } = [];
}

public record GrhEntry
{
    public int? File { get; init; }
    public int? X { get; init; }
    public int? Y { get; init; }
    public int? W { get; init; }
    public int? H { get; init; }
    public int[]? Frames { get; init; }
    public int? Speed { get; init; }
}

public record MapData
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public string Music { get; init; } = "";
    public bool PkFreeZone { get; init; }
    public int[]? StartPos { get; init; }
    public Dictionary<string, int> Exits { get; init; } = [];
    public MapTiles Tiles { get; init; } = new();
    public List<int[]> TileExits { get; init; } = [];
    public List<int[]> NpcSpawns { get; init; } = [];
}

public record MapTiles
{
    public int[] Blocked { get; init; } = [];
    public int[] Layer1 { get; init; } = [];
    public int[] Layer2 { get; init; } = [];
    public int[] Layer3 { get; init; } = [];
}
