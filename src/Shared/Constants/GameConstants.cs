namespace EraOnline.Shared.Constants;

/// <summary>VB6: Various constants from Declarations.bas and Declares.bas</summary>
public static class GameConstants
{
    // Map dimensions
    public const int MapWidth = 100;
    public const int MapHeight = 100;
    public const int TileSize = 32;
    public const int ViewportWidth = 20;  // tiles
    public const int ViewportHeight = 11; // tiles
    public const int ViewportOffsetX = 80; // pixels from window edge
    public const int ViewportOffsetY = 80;

    // Stat caps
    public const int MaxLevel = 50;
    public const int MaxHp = 9999;
    public const int MaxStamina = 9999;
    public const int MaxMana = 9999;
    public const int MaxHit = 9999;
    public const int MaxDef = 9999;

    // Inventory
    public const int MaxInventorySlots = 20;
    public const int MaxInventoryStack = 999_999_999;
    public const int MaxNpcInventorySlots = 40;
    public const int MaxSpellSlots = 50;

    // Timing (milliseconds)
    public const int GameTickInterval = 50;      // Server main loop
    public const int NpcAttackInterval = 4000;    // NPC attack cadence
    public const int PlayerAttackInterval = 4000; // Player attack cadence
    public const int CriminalTickInterval = 60000;
    public const int CampfireHealInterval = 10000;
    public const int MeditateInterval = 10000;
    public const int EatDrinkInterval = 15000;
    public const int SkillProgressInterval = 5000;

    // Character creation defaults
    public const int StartingHp = 30;
    public const int StartingStamina = 5;
    public const int StartingMinHit = 2;
    public const int StartingMaxHit = 4;
    public const int StartingExpToLevel = 300;
    public const int StartingOverallRep = 500;
}

/// <summary>VB6: SendData routing constants (ToIndex, ToAll, etc.)</summary>
public enum SendRoute
{
    ToIndex = 0,
    ToAll = 1,
    ToMap = 2,
    ToPCArea = 3,
    ToNone = 4,
    ToAllButIndex = 5,
    ToMapButIndex = 6,
    ToGM = 7
}

/// <summary>VB6: FONTTYPE_* constants - chat message styling</summary>
public enum FontType
{
    Talk,     // white, normal
    Fight,    // red, bold
    Warning,  // red, bold italic
    Info,     // green
    SkillInfo // blue
}

/// <summary>VB6: NPC Movement types from NPCAI function</summary>
public enum NpcMovement
{
    Stand = 1,
    RandomWalk = 2,
    HostileChase = 3,
    GuardPatrol = 4,
    BeggarFollow = 5,
    TamedFollow = 6,
    ShortRangeHostile = 7,
    ChaoticGuardPatrol = 8
}

/// <summary>VB6: NPC Guard types</summary>
public enum GuardType : byte
{
    None = 0,
    Normal = 1,   // attacks criminals only
    Chaotic = 2   // attacks humans, wood elves, and criminals
}
