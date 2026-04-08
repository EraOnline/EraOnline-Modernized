using EraOnline.Shared.Constants;

namespace EraOnline.Server.Services;

/// <summary>
/// Starting skill templates per class. VB6: GiveSkills in GameLogic.bas.
/// Each class defines starting values for all 28 skills, plus starting stats
/// (HP, Mana, HIT), magic school, starting spells, and extra inventory items.
/// </summary>
public static class ClassTemplates
{
    /// <summary>Classes available per race. VB6: Form5.frx combo box data.</summary>
    public static readonly Dictionary<string, string[]> ClassesByRace = new()
    {
        ["Human"] = new[] {
            "Warrior", "Healer", "Thief", "Paladin", "Bandit", "Woodworker",
            "BlackSmith", "Tailor", "Fisher", "Animal Tamer", "Merchant", "Bard",
            "Pirate", "Miner", "Cook", "Cleric", "Wizard", "Druid", "Enchanter"
        },
        ["Wood Elf"] = new[] {
            "Warrior", "Healer", "Thief", "Paladin", "Bandit", "Woodworker",
            "BlackSmith", "Tailor", "Fisher", "Animal Tamer", "Merchant", "Bard",
            "Miner", "Cook", "Cleric", "Druid", "Enchanter"
        },
        ["Haaki"] = new[] {
            "Warrior", "Thief", "Bandit", "BlackSmith", "Tailor", "Animal Tamer",
            "Merchant", "Bard", "Miner", "Cook", "Cleric", "Wizard", "Druid"
        },
        ["Dark Elf"] = new[] {
            "Warrior", "Thief", "Bandit", "Woodworker", "BlackSmith", "Tailor",
            "Merchant", "Miner", "Cook", "Assasin", "Wizard", "Enchanter"
        },
    };

    public static ClassTemplate? Get(string className) =>
        Templates.GetValueOrDefault(className);

    private static readonly Dictionary<string, ClassTemplate> Templates = new()
    {
        ["Warrior"] = new()
        {
            Skills = SkillArray(tactics: 8, swordmanship: 12, parrying: 9, religionLore: 1, backstabbing: 2, surviving: 5, streetwise: 2),
            MaxHp = 50, MaxMan = 0, MinHit = 4, MaxHit = 5,
        },
        ["Druid"] = new()
        {
            Skills = SkillArray(tactics: 2, merchant: 4, hiding: 4, magery: 12, stealth: 3, animalTaming: 15, religionLore: 4, backstabbing: 2, healing: 7, etiquette: 11, streetwise: 2, meditating: 13),
            MaxHp = 30, MaxMan = 190, MinHit = 2, MaxHit = 4,
            MagicSchool = "Nature", StartingSpells = new[] { 1, 2, 5 },
        },
        ["Healer"] = new()
        {
            Skills = SkillArray(cooking: 8, musicianship: 2, poisoning: 2, religionLore: 3, healing: 12, etiquette: 4, streetwise: 1, meditating: 5),
            MaxHp = 30, MaxMan = 100, MinHit = 2, MaxHit = 4,
            MagicSchool = "Nature", StartingSpells = new[] { 1, 2, 5 },
        },
        ["Cleric"] = new()
        {
            Skills = SkillArray(musicianship: 2, tailoring: 4, tactics: 8, disguise: 1, merchant: 3, hiding: 2, religionLore: 14, healing: 4, etiquette: 10, streetwise: 3, meditating: 4),
            MaxHp = 30, MaxMan = 120, MinHit = 2, MaxHit = 4,
            MagicSchool = "Nature", StartingSpells = new[] { 2 },
        },
        ["Thief"] = new()
        {
            Skills = SkillArray(musicianship: 2, tactics: 3, merchant: 4, lockpicking: 12, pickpocket: 14, stealth: 7, backstabbing: 5, surviving: 2, streetwise: 10),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
        },
        ["Paladin"] = new()
        {
            Skills = SkillArray(musicianship: 3, tailoring: 2, tactics: 7, merchant: 4, swordmanship: 16, parrying: 11, religionLore: 4, healing: 2, surviving: 1, etiquette: 20),
            MaxHp = 40, MaxMan = 110, MinHit = 3, MaxHit = 4,
            MagicSchool = "Enchanting", StartingSpells = new[] { 1, 4 },
        },
        ["Bandit"] = new()
        {
            Skills = SkillArray(cooking: 3, musicianship: 1, tactics: 2, hiding: 13, pickpocket: 2, stealth: 8, swordmanship: 5, parrying: 3, backstabbing: 6, surviving: 5, archery: 3),
            MaxHp = 30, MaxMan = 0, MinHit = 4, MaxHit = 4,
        },
        ["Woodworker"] = new()
        {
            Skills = SkillArray(cooking: 3, carpentry: 20, lumberjacking: 20, merchant: 2, swordmanship: 3, fishing: 3, surviving: 5, archery: 5),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
            ExtraItems = new[] { (7, 1), (128, 1), (255, 1), (257, 1) }, // lumberjack axe, saw, drawings
        },
        ["BlackSmith"] = new()
        {
            Skills = SkillArray(tactics: 2, blacksmithing: 19, swordmanship: 5, parrying: 5, mining: 7, streetwise: 7),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
            ExtraItems = new[] { (125, 5), (126, 1), (127, 1), (258, 1) }, // ore, hammer, drawings
        },
        ["Tailor"] = new()
        {
            Skills = SkillArray(cooking: 3, musicianship: 4, tailoring: 20, disguise: 2, merchant: 9, etiquette: 4, streetwise: 5),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
            ExtraItems = new[] { (123, 5), (124, 1), (259, 1) }, // cloth, sewing kit, drawing
        },
        ["Fisher"] = new()
        {
            Skills = SkillArray(cooking: 5, surviving: 10, fishing: 20, merchant: 3),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
            ExtraItems = new[] { (121, 1) }, // fishing rod
        },
        ["Animal Tamer"] = new()
        {
            Skills = SkillArray(animalTaming: 20, surviving: 10, healing: 5),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
        },
        ["Merchant"] = new()
        {
            Skills = SkillArray(merchant: 22, etiquette: 10, streetwise: 12),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
        },
        ["Bard"] = new()
        {
            Skills = SkillArray(musicianship: 20, merchant: 10, etiquette: 10, streetwise: 5),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
        },
        ["Miner"] = new()
        {
            Skills = SkillArray(blacksmithing: 5, mining: 20, swordmanship: 3, surviving: 5, streetwise: 5),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
            ExtraItems = new[] { (130, 1) }, // pickaxe
        },
        ["Pirate"] = new()
        {
            Skills = SkillArray(cooking: 3, tactics: 2, merchant: 3, swordmanship: 10, parrying: 5, backstabbing: 5, surviving: 5),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
        },
        ["Cook"] = new()
        {
            Skills = SkillArray(cooking: 20, disguise: 20, merchant: 5),
            MaxHp = 30, MaxMan = 0, MinHit = 2, MaxHit = 4,
        },
        ["Assasin"] = new()
        {
            Skills = SkillArray(tactics: 5, hiding: 10, stealth: 8, swordmanship: 5, parrying: 3, backstabbing: 12, merchant: 2),
            MaxHp = 30, MaxMan = 0, MinHit = 4, MaxHit = 5,
        },
        ["Wizard"] = new()
        {
            Skills = SkillArray(magery: 15, meditating: 15, hiding: 5),
            MaxHp = 30, MaxMan = 200, MinHit = 2, MaxHit = 4,
            MagicSchool = "Destruction", StartingSpells = new[] { 3, 7, 8 },
        },
        ["Enchanter"] = new()
        {
            Skills = SkillArray(magery: 12, meditating: 12, merchant: 5, etiquette: 5),
            MaxHp = 30, MaxMan = 180, MinHit = 2, MaxHit = 4,
            MagicSchool = "Enchanting", StartingSpells = new[] { 1, 4, 6 },
        },
    };

    /// <summary>Helper to build a 29-element skill array (index 0 unused) from named params.</summary>
    private static int[] SkillArray(
        int cooking = 0, int musicianship = 0, int tailoring = 0, int carpentry = 0,
        int lumberjacking = 0, int tactics = 0, int disguise = 0, int merchant = 0,
        int blacksmithing = 0, int hiding = 0, int magery = 0, int lockpicking = 0,
        int pickpocket = 0, int stealth = 0, int poisoning = 0, int swordmanship = 0,
        int parrying = 0, int animalTaming = 0, int religionLore = 0, int fishing = 0,
        int mining = 0, int backstabbing = 0, int healing = 0, int surviving = 0,
        int etiquette = 0, int streetwise = 0, int meditating = 0, int archery = 0)
    {
        return new[]
        {
            0, // index 0 unused
            cooking, musicianship, tailoring, carpentry, lumberjacking,
            tactics, disguise, merchant, blacksmithing, hiding,
            magery, lockpicking, pickpocket, stealth, poisoning,
            swordmanship, parrying, animalTaming, religionLore, fishing,
            mining, backstabbing, healing, surviving, etiquette,
            streetwise, meditating, archery
        };
    }
}

public class ClassTemplate
{
    public int[] Skills { get; init; } = new int[SkillInfo.SkillCount + 1];
    public int MaxHp { get; init; } = 30;
    public int MaxMan { get; init; } = 0;
    public int MinHit { get; init; } = 2;
    public int MaxHit { get; init; } = 4;
    public string MagicSchool { get; init; } = "";
    public int[]? StartingSpells { get; init; }
    /// <summary>Extra starting items as (objIndex, amount) tuples beyond the default set.</summary>
    public (int ObjIndex, int Amount)[]? ExtraItems { get; init; }
}
