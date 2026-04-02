using System.Text.Json.Serialization;
using EraOnline.Shared.Constants;

namespace EraOnline.Shared.Models;

/// <summary>
/// Static object/item definition loaded from objects.json.
/// VB6: ObjData type in Declarations.bas (31 fields).
/// </summary>
public class ObjectDef
{
    [JsonPropertyName("id")] public int Id { get; set; }
    [JsonPropertyName("name")] public string Name { get; set; } = "";
    [JsonPropertyName("objType")] public int ObjType { get; set; }
    [JsonPropertyName("grhIndex")] public int GrhIndex { get; set; }
    [JsonPropertyName("category")] public string Category { get; set; } = "";
    [JsonPropertyName("minHp")] public int MinHp { get; set; }
    [JsonPropertyName("maxHp")] public int MaxHp { get; set; }
    [JsonPropertyName("minHit")] public int MinHit { get; set; }
    [JsonPropertyName("maxHit")] public int MaxHit { get; set; }
    [JsonPropertyName("def")] public int Def { get; set; }
    [JsonPropertyName("pickable")] public int Pickable { get; set; }
    [JsonPropertyName("clothingType")] public int ClothingType { get; set; }
    [JsonPropertyName("handleRain")] public int HandleRain { get; set; }
    [JsonPropertyName("spellType")] public int SpellType { get; set; }
    [JsonPropertyName("value")] public string Value { get; set; } = "";
    [JsonPropertyName("makeItem")] public int MakeItem { get; set; }
    [JsonPropertyName("needPlanks")] public int NeedPlanks { get; set; }
    [JsonPropertyName("needSteel")] public int NeedSteel { get; set; }
    [JsonPropertyName("needFoldedCloth")] public int NeedFoldedCloth { get; set; }
    [JsonPropertyName("weaponAnim")] public int WeaponAnim { get; set; }
    [JsonPropertyName("shieldAnim")] public int ShieldAnim { get; set; }
    [JsonPropertyName("skill")] public int Skill { get; set; }
    [JsonPropertyName("sellable")] public int Sellable { get; set; }
    [JsonPropertyName("level")] public long Level { get; set; }
    [JsonPropertyName("food")] public int Food { get; set; }
    [JsonPropertyName("classForbid")] public string[] ClassForbid { get; set; } = [];

    [JsonIgnore] public ObjectType Type => (ObjectType)ObjType;
}
