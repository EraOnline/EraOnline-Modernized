using EraOnline.Shared.Constants;

namespace EraOnline.Shared.Protocol;

/// <summary>
/// SignalR protocol message types. Replace the VB6 text-based TCP protocol.
/// Naming follows VB6 message prefixes where applicable.
/// </summary>

// --- Client -> Server ---

public record LoginRequest(string Name, string Password);

public record CreateCharacterRequest(
    string Name, string Password, string Race, string Gender,
    string? Class = null, string? SpecSkill1 = null, string? SpecSkill2 = null, string? SpecSkill3 = null);

// --- Server -> Client ---

public record LoginResponse(bool Success, string? ErrorMessage = null);

/// <summary>VB6: MAC - Make a character on the client (body,head,heading,charIndex,x,y,weapon,shield,name)</summary>
public record MakeCharMessage(
    int CharIndex,
    string Name,
    int Body,
    int Head,
    int Heading,
    int X,
    int Y,
    int WeaponAnim,
    int ShieldAnim,
    bool IsCriminal = false);

/// <summary>VB6: ERC - Erase a character from the client</summary>
public record EraseCharMessage(int CharIndex);

/// <summary>VB6: MOC - Move a character (charIndex, newX, newY, heading)</summary>
public record MoveCharMessage(int CharIndex, int X, int Y, int Heading);

/// <summary>VB6: SUP - Set the local player's authoritative position</summary>
public record SetPositionMessage(int X, int Y);

/// <summary>VB6: SCM + map data sent on zone entry</summary>
public record MapLoadMessage(int MapId);

/// <summary>VB6: SUC - Tell the client which char index is theirs</summary>
public record SetCharIndexMessage(int CharIndex);

/// <summary>VB6: @ - Chat/info message with font type</summary>
public record ChatMessage(string Text, FontType Font);

/// <summary>
/// VB6: SST - Full stats update. Sent on login and whenever stats change.
/// VB6 format: "SST" & HP,MaxHP,MAN,MaxMAN,STA,MaxSTA,GLD,EXP,ELU,Food,Drink,MinHIT,MaxHIT,DEF,PracticePoints
/// </summary>
public record StatsMessage(
    int Hp, int MaxHp,
    int Man, int MaxMan,
    int Sta, int MaxSta,
    int Gold,
    int Exp, int Elu,
    int Food, int Drink,
    int MinHit, int MaxHit,
    int Def,
    int TrainingPoints,
    string Class = "",
    string RepRank = "",
    int[]? Skills = null,
    int Criminal = 0,
    long CriminalCount = 0);

/// <summary>VB6: TGT - Set target name in the target bar</summary>
public record TargetMessage(string Text);

/// <summary>VB6: SIS - Set inventory slot (sent per-slot on login and on changes)</summary>
public record InventorySlotMessage(
    int Slot,
    int ObjIndex,
    string Name,
    int Amount,
    bool Equipped,
    int GrhIndex,
    int Value);

/// <summary>VB6: MOB - Place/show an object on the ground at a tile</summary>
public record MakeObjMessage(int GrhIndex, int X, int Y);

/// <summary>VB6: EOB - Remove an object from the ground at a tile</summary>
public record EraseObjMessage(int X, int Y);

/// <summary>VB6: PLM - Play zone music (music number + loop flag)</summary>
public record PlayMusicMessage(int MusicNumber, bool Loop);

/// <summary>VB6: PLW - Play sound effect</summary>
public record PlaySoundMessage(int SoundId);

/// <summary>VB6: PL3 - Play voiceover MP3</summary>
public record PlayVoiceMessage(int Id);

/// <summary>VB6: NIS - NPC inventory slot for trade window</summary>
public record NpcInvSlotMessage(
    int Slot,
    int ObjIndex,
    string Name,
    int Amount,
    int GrhIndex,
    int Value,
    long Level);

/// <summary>Sent to client to open the trade window with the NPC's name</summary>
public record TradeOpenMessage(string NpcName, NpcInvSlotMessage[] NpcInventory);

/// <summary>VB6: DOS — start crafting progress bar</summary>
public record CraftStartMessage(int JobType, int DurationMs);
