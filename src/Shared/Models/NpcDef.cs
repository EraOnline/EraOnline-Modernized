using System.Text.Json.Serialization;

namespace EraOnline.Shared.Models;

/// <summary>
/// Static NPC template definition loaded from npcs.json.
/// VB6: NPC type in Declarations.bas (27 fields) + data from NPC.dat/NPC2.dat.
/// </summary>
public class NpcDef
{
    [JsonPropertyName("id")] public int Id { get; set; }
    [JsonPropertyName("name")] public string Name { get; set; } = "";
    [JsonPropertyName("desc")] public string Desc { get; set; } = "";
    [JsonPropertyName("movement")] public int Movement { get; set; }
    [JsonPropertyName("body")] public int Body { get; set; }
    [JsonPropertyName("head")] public int Head { get; set; }
    [JsonPropertyName("heading")] public int Heading { get; set; }
    [JsonPropertyName("attackable")] public int Attackable { get; set; }
    [JsonPropertyName("hostile")] public int Hostile { get; set; }
    [JsonPropertyName("guard")] public int Guard { get; set; }
    [JsonPropertyName("npcType")] public int NpcType { get; set; }
    [JsonPropertyName("level")] public int Level { get; set; }
    [JsonPropertyName("lootChance")] public int LootChance { get; set; }
    [JsonPropertyName("giveExp")] public int GiveExp { get; set; }
    [JsonPropertyName("giveGold")] public long GiveGold { get; set; }
    [JsonPropertyName("deathObj")] public int DeathObj { get; set; }
    [JsonPropertyName("tameable")] public int Tameable { get; set; }
    [JsonPropertyName("tradeable")] public int Tradeable { get; set; }
    [JsonPropertyName("gold")] public long Gold { get; set; }
    [JsonPropertyName("skillNeeded")] public string SkillNeeded { get; set; } = "";
    [JsonPropertyName("sound")] public int Sound { get; set; }
    [JsonPropertyName("maxHp")] public int MaxHp { get; set; }
    [JsonPropertyName("minHit")] public int MinHit { get; set; }
    [JsonPropertyName("maxHit")] public int MaxHit { get; set; }
    [JsonPropertyName("def")] public int Def { get; set; }
    [JsonPropertyName("categories")] public string[] Categories { get; set; } = [];
    [JsonPropertyName("inventory")] public NpcInvSlot[] Inventory { get; set; } = [];
}

public class NpcInvSlot
{
    [JsonPropertyName("objIndex")] public int ObjIndex { get; set; }
    [JsonPropertyName("amount")] public int Amount { get; set; }
}
