using System.Text.Json.Serialization;

namespace EraOnline.Shared.Models;

/// <summary>
/// Sprite atlas data loaded from grh.json.
/// VB6: GrhData type in Client/Declares.bas, loaded from Grh.dat binary.
/// </summary>
public class GrhDataSet
{
    [JsonPropertyName("numFiles")] public int NumFiles { get; set; }
    [JsonPropertyName("entries")] public Dictionary<string, GrhEntry> Entries { get; set; } = [];
}

/// <summary>
/// Single sprite or animation definition.
/// If Frames is set, this is an animation (references other GrhEntry indices).
/// Otherwise, File/X/Y/W/H define a rectangle in a sprite sheet.
/// </summary>
public class GrhEntry
{
    [JsonPropertyName("file")] public int? File { get; set; }
    [JsonPropertyName("x")] public int? X { get; set; }
    [JsonPropertyName("y")] public int? Y { get; set; }
    [JsonPropertyName("w")] public int? W { get; set; }
    [JsonPropertyName("h")] public int? H { get; set; }
    [JsonPropertyName("frames")] public int[]? Frames { get; set; }
    [JsonPropertyName("speed")] public int? Speed { get; set; }

    [JsonIgnore] public bool IsAnimation => Frames != null;
}

/// <summary>
/// Head sprite definition loaded from heads.json.
/// VB6: HeadData type - 4 directional GRH indices (N, E, S, W).
/// </summary>
public class HeadDef
{
    [JsonPropertyName("id")] public int Id { get; set; }
    [JsonPropertyName("grh")] public int[] Grh { get; set; } = []; // [N, E, S, W]
}

/// <summary>
/// Body sprite definition loaded from bodies.json.
/// VB6: BodyData type - 4 directional walk animations + head offset.
/// </summary>
public class BodyDef
{
    [JsonPropertyName("id")] public int Id { get; set; }
    [JsonPropertyName("walk")] public int[] Walk { get; set; } = []; // [N, E, S, W]
    [JsonPropertyName("headOffsetX")] public int HeadOffsetX { get; set; }
    [JsonPropertyName("headOffsetY")] public int HeadOffsetY { get; set; }
}

/// <summary>
/// Weapon or shield animation definition loaded from weapon-anims.json / shield-anims.json.
/// VB6: WeaponAnimData / ShieldAnimData types.
/// </summary>
public class AnimDef
{
    [JsonPropertyName("id")] public int Id { get; set; }
    [JsonPropertyName("walk")] public int[] Walk { get; set; } = []; // [N, E, S, W]
}
