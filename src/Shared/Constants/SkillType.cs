namespace EraOnline.Shared.Constants;

/// <summary>VB6: Skills 1-28, referenced as Skill1..Skill28 in UserStats</summary>
public enum SkillType
{
    Cooking = 1,
    Musicianship = 2,
    Tailoring = 3,
    Carpentry = 4,
    Lumberjacking = 5,
    Tactics = 6,
    Disguise = 7,
    Merchant = 8,
    Blacksmithing = 9,
    Hiding = 10,
    Magery = 11,
    Lockpicking = 12,
    Pickpocket = 13,
    Stealth = 14,
    Poisoning = 15,
    Swordmanship = 16,
    Parrying = 17,
    AnimalTaming = 18,
    RegionLore = 19,
    Fishing = 20,
    Mining = 21,
    Backstabbing = 22,
    Healing = 23,
    Surviving = 24,
    Etiquette = 25,
    Streetwise = 26,
    Meditating = 27,
    Archery = 28
}

public static class SkillInfo
{
    public const int SkillCount = 28;

    /// <summary>Skill names as they appear in the original game (matching VB6 SpecSkill strings)</summary>
    public static readonly string[] Names = new string[SkillCount + 1]
    {
        "",             // 0 = unused (1-indexed)
        "Cooking",      // 1
        "Musicanship",  // 2 - original spelling
        "Tailoring",    // 3
        "Carpenting",   // 4 - original spelling
        "Lumberjacking",// 5
        "Tactics",      // 6
        "Disguise",     // 7
        "Merchant",     // 8
        "Blacksmithing",// 9
        "Hiding",       // 10
        "Magery",       // 11
        "Lockpicking",  // 12
        "Pickpocket",   // 13
        "Stealth",      // 14
        "Poisoning",    // 15
        "Swordmanship", // 16
        "Parrying",     // 17
        "Animal Taming",// 18
        "Religion Lore",// 19
        "Fishing",      // 20
        "Mining",       // 21
        "Backstabbing", // 22
        "Healing",      // 23
        "Surviving",    // 24
        "Etiquette",    // 25
        "Streetwise",   // 26
        "Meditating",   // 27
        "Archery"       // 28
    };

    /// <summary>
    /// Per-level skill cap for use-based auto-raise. VB6: LevelSkill(1..50).LevelValue.
    /// Index = player level (1-50), value = max skill reachable at that level.
    /// </summary>
    public static readonly int[] LevelCap = new int[51]
    {
        0,   // 0 = unused
        3, 5, 7, 10, 13,       // levels 1-5
        15, 17, 20, 23, 25,    // levels 6-10
        27, 30, 33, 35, 37,    // levels 11-15
        40, 43, 45, 47, 50,    // levels 16-20
        53, 55, 57, 60, 63,    // levels 21-25
        65, 67, 70, 73, 75,    // levels 26-30
        77, 80, 83, 85, 87,    // levels 31-35
        90, 93, 95, 97, 100,   // levels 36-40
        100, 100, 100, 100, 100, // levels 41-45
        100, 100, 100, 100, 100  // levels 46-50
    };

    /// <summary>
    /// Mapping from highest skill to class name. VB6: CheckClass in Checks.bas.
    /// Skills not listed here don't trigger a class change when they're highest.
    /// </summary>
    public static readonly Dictionary<int, string> SkillToClass = new()
    {
        [1] = "Cook",           // Cooking
        [2] = "Bard",           // Musicianship
        [3] = "Tailor",         // Tailoring
        [4] = "Woodworker",     // Carpentry
        [5] = "Woodworker",     // Lumberjacking
        [8] = "Merchant",       // Merchant
        [9] = "Blacksmith",     // Blacksmithing
        [11] = "Mage",          // Magery
        [12] = "Thief",         // Lockpicking
        [13] = "Thief",         // Pickpocket
        [16] = "Warrior",       // Swordmanship
        [17] = "Warrior",       // Parrying
        [18] = "Animal Tamer",  // Animal Taming
        [19] = "Cleric",        // Religion Lore
        [21] = "Miner",         // Mining
        [23] = "Healer",        // Healing
        [28] = "Archer",        // Archery
    };
}
