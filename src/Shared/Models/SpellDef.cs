using System.Text.Json.Serialization;

namespace EraOnline.Shared.Models;

/// <summary>
/// Static spell definition loaded from spells.json.
/// VB6: SpellData type in Declarations.bas (32 fields).
/// </summary>
public class SpellDef
{
    [JsonPropertyName("id")] public int Id { get; set; }
    [JsonPropertyName("name")] public string Name { get; set; } = "";
    [JsonPropertyName("desc")] public string Desc { get; set; } = "";
    [JsonPropertyName("casterMessage")] public string CasterMessage { get; set; } = "";
    [JsonPropertyName("targetMessage")] public string TargetMessage { get; set; } = "";
    [JsonPropertyName("schools")] public string[] Schools { get; set; } = [];
    [JsonPropertyName("grhEffect")] public int GrhEffect { get; set; }
    [JsonPropertyName("grhIndex")] public int GrhIndex { get; set; }
    [JsonPropertyName("grhIcon")] public int GrhIcon { get; set; }
    [JsonPropertyName("sound")] public int Sound { get; set; }
    [JsonPropertyName("needsMana")] public int NeedsMana { get; set; }
    [JsonPropertyName("giveHp")] public int GiveHp { get; set; }
    [JsonPropertyName("giveMan")] public int GiveMana { get; set; }
    [JsonPropertyName("giveFat")] public int GiveStamina { get; set; }
    [JsonPropertyName("giveMoney")] public int GiveMoney { get; set; }
    [JsonPropertyName("giveFood")] public int GiveFood { get; set; }
    [JsonPropertyName("giveDrink")] public int GiveDrink { get; set; }
    [JsonPropertyName("giveExp")] public int GiveExp { get; set; }
    [JsonPropertyName("healHp")] public int HealHp { get; set; }
    [JsonPropertyName("healMan")] public int HealMana { get; set; }
    [JsonPropertyName("healFat")] public int HealStamina { get; set; }
    [JsonPropertyName("damageHp")] public int DamageHp { get; set; }
    [JsonPropertyName("damageMan")] public int DamageMana { get; set; }
    [JsonPropertyName("damageFat")] public int DamageStamina { get; set; }
    [JsonPropertyName("invisibility")] public int Invisibility { get; set; }
    [JsonPropertyName("createObj")] public int CreateObj { get; set; }
    [JsonPropertyName("summonCreature")] public int SummonCreature { get; set; }
    [JsonPropertyName("paralyze")] public int Paralyze { get; set; }
    [JsonPropertyName("teleport")] public int Teleport { get; set; }
    [JsonPropertyName("destruction")] public int Destruction { get; set; }
    [JsonPropertyName("resurrection")] public int Resurrection { get; set; }
}
