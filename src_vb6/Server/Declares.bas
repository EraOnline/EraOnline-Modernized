Attribute VB_Name = "Declares"
Option Explicit



'********** Public CONSTANTS ***********

'Constants for Headings
Public Const NORTH = 1
Public Const EAST = 2
Public Const SOUTH = 3
Public Const WEST = 4

'Map sizes
Public Const XMaxMapSize = 100
Public Const XMinMapSize = 1
Public Const YMaxMapSize = 100
Public Const YMinMapSize = 1

'Tile size in pixels
Public Const TileSizeX = 32
Public Const TileSizeY = 32

'Window size in tiles
Public Const XWindow = 20
Public Const YWindow = 11

'Sound constants
Public Const SOUND_BUMP = 1
Public Const SOUND_SWING = 2
Public Const SOUND_WARP = 3
Public Const SOUND_PAPER = 4
Public Const SOUND_DRAGFISH = 5
Public Const SOUND_FISHINGPOLE = 6
Public Const SOUND_BURN = 7
Public Const SOUND_COINS = 8
Public Const SOUND_NIGHTLOOP = 9
Public Const SOUND_FIREBALL = 10
Public Const SOUND_FIREBALL2 = 11
Public Const SOUND_FOLDCLOTHING = 12
Public Const SOUND_FORRESTLOOP = 13
Public Const SOUND_FORRESTLOOP2 = 14
Public Const SOUND_FEMALESCREAM = 15
Public Const SOUND_SPELLEFFECT1 = 16
Public Const SOUND_HAMMERING = 17
Public Const SOUND_LIGHTNING = 18
Public Const SOUND_LOCKPICKING = 19
Public Const SOUND_MALEHURT = 20
Public Const SOUND_MALEHURT2 = 21
Public Const SOUND_MEDOWLOOP = 22
Public Const SOUND_METALHIT = 23
Public Const SOUND_SPELLEFFECT2 = 24
Public Const SOUND_SAILING = 25
Public Const SOUND_SAW = 26
Public Const SOUND_SHORE = 27
Public Const SOUND_SMITHING = 28
Public Const SOUND_SPELLEFFECT3 = 29
Public Const SOUND_SPELLEFFECT4 = 30
Public Const SOUND_SPELLEFFECT5 = 31
Public Const SOUND_STREAM = 32
Public Const SOUND_SWAMPLOOP = 33
Public Const SOUND_SWORDSWING = 34
Public Const SOUND_SWORDHIT = 35
Public Const SOUND_SWORDHIT2 = 36
Public Const SOUND_WINDLOOP = 37
Public Const SOUND_STORMLOOP = 38
Public Const SOUND_SPELLEFFECT6 = 39
Public Const SOUND_CHOPPING = 40
Public Const SOUND_MEDIVAL = 41
Public Const SOUND_CHORUS = 42
Public Const SOUND_THUNDER = 43
Public Const SOUND_BIRDS = 44

'Animal & Monster Sounds
Public Const SOUND_SNAKE = 45
Public Const SOUND_SHEEP = 46
Public Const SOUND_MONSTER1 = 47
Public Const SOUND_MONSTER2 = 48
Public Const SOUND_COW = 49
Public Const SOUND_COW2 = 50
Public Const SOUND_GREMLIN = 51
Public Const SOUND_HORSE = 52
Public Const SOUND_WOLF = 53
Public Const SOUND_CHICKEN = 54
Public Const SOUND_ROAR = 55
Public Const SOUND_LAUGHEVIL = 56
Public Const SOUND_HEART = 57
Public Const SOUND_CLICK = 58
Public Const SOUND_BIRDS2 = 59
Public Const SOUND_BEE = 60


'Spell constants
Public Const MAX_SPELL_SPELLS = 99
Public Const MAX_SPELL_SLOTS = 50

'Object constants
Public Const MAX_INVENTORY_OBJS = 999999999
Public Const MAX_INVENTORY_SLOTS = 20

'Npc OBJECT constants
Public Const MAX_NPCINVENTORY_OBJS = 99
Public Const MAX_NPCINVENTORY_SLOTS = 40


Public Const OBJTYPE_USEONCE = 1
Public Const OBJTYPE_WEAPON = 2
Public Const OBJTYPE_ARMOUR = 3
Public Const OBJTYPE_MSGBOARD = 4
Public Const OBJTYPE_PRIESTNOTE = 5
Public Const OBJTYPE_Food = 6
Public Const OBJTYPE_Drink = 7
Public Const OBJTYPE_HARP = 8
Public Const OBJTYPE_BAGPIPE = 9
Public Const OBJTYPE_GUITAR = 10
Public Const OBJTYPE_DRUM = 11
Public Const OBJTYPE_NECKLACE = 12
Public Const OBJTYPE_RING = 13
Public Const OBJTYPE_HELMET = 14
Public Const OBJTYPE_CLOTHING = 15
Public Const OBJTYPE_FISHINGROD = 16
Public Const OBJTYPE_LUMBERJACKAXE = 17
Public Const OBJTYPE_ARROW = 18
Public Const OBJTYPE_KEY = 19
Public Const OBJTYPE_LOG = 20
Public Const OBJTYPE_CAMPFIRE = 21
Public Const OBJTYPE_SAW = 22
'The spells
Public Const OBJTYPE_SPELL = 23
'End Spells
Public Const OBJTYPE_SHIELD = 24
Public Const OBJTYPE_CARPENTRYDRAWING = 25
Public Const OBJTYPE_BLACKSMITHINGDRAWING = 26
Public Const OBJTYPE_TAILORDRAWING = 27
Public Const OBJTYPE_SEWINGKIT = 28
Public Const OBJTYPE_CLOTH = 29
Public Const OBJTYPE_FOLDEDCLOTH = 30
Public Const OBJTYPE_STEEL = 31
Public Const OBJTYPE_ORE = 32
Public Const OBJTYPE_HAMMER = 33
Public Const OBJTYPE_PLANKS = 35
Public Const OBJTYPE_EMPTYBOWL = 36
Public Const OBJTYPE_BOWLOFWATER = 37
Public Const OBJTYPE_ROASTEDMEAT = 38
Public Const OBJTYPE_MEAT = 39
Public Const OBJTYPE_CORPSE = 40
Public Const OBJTYPE_GOLD = 41
Public Const OBJTYPE_FURNITURE = 42
Public Const OBJTYPE_HOUSEDEED = 43
Public Const OBJTYPE_SHOES = 44
Public Const OBJTYPE_BANDAGE = 45
Public Const OBJTYPE_MERCHANTBOOTH = 46
Public Const OBJTYPE_SIGN = 47
Public Const OBJTYPE_PICKAXE = 48

'Text type constants
Public Const FONTTYPE_TALK = "~255~255~255~0"
Public Const FONTTYPE_FIGHT = "~255~0~0~1~0"
Public Const FONTTYPE_WARNING = "~255~0~0~1~1"
Public Const FONTTYPE_INFO = "~0~255~0~0"
Public Const FONTTYPE_SKILLINFO = "~0~0~255~0"

'Stat constants
Public Const STAT_MAXELV = 50
Public Const STAT_MAXHP = 9999
Public Const STAT_MAXSTA = 9999
Public Const STAT_MAXMAN = 9999
Public Const STAT_MAXHIT = 9999
Public Const STAT_MAXDEF = 9999

'********** Public TYPES ***********

Type Position
    X As Integer
    Y As Integer
End Type

Type WorldPos
    map As Integer
    X As Integer
    Y As Integer
End Type

'Holds data for a user or NPC character
Type Char
    CharIndex As Integer
    Head As Integer
    Body As Integer
    WeaponAnim As Integer
    ShieldAnim As Integer
    Heading As Byte
End Type

Public Type GMQUEData
    userindex As Integer
    Helpmsg As String
    Time As String
    Date As String
    Name As String
End Type

'** POSTING TYPES **
Public Type PostData
    subject As String
    Post As String
    Author As String
End Type

'** Object types **
Public Type ObjData
    Name As String
    ObjType As Integer
    Grhindex As Integer
    MinHP As Integer
    MaxHP As Integer
    MinHIT As Integer
    MaxHIT As Integer
    DEF As Integer
    Pickable As Integer
    ClothingType As Integer
    HandleRain As Integer
    SpellType As Integer
    Value As String
    MakeItem As Integer
    NeedPlanks As Integer
    NeedSteel As Integer
    NeedFoldedCloth As Integer
    WeaponAnim As Integer
    ShieldAnim As Integer
    skill As Integer
    Sellable As Integer
    Level As Long
    Food As Integer
    Category As String
    
    ClassForbid1 As String
    ClassForbid2 As String
    ClassForbid3 As String
    ClassForbid4 As String
    ClassForbid5 As String
    ClassForbid6 As String
    ClassForbid7 As String
    
    
End Type

Public Type obj
    ObjIndex As Integer
    Amount As Integer
End Type

Public Type SpellObj
    SpellIndex As Integer
End Type

'** Spell types **
Public Type SpellData
    Name As String
    Desc As String
    GrhEffect As Integer
    Grhindex As Integer
    GrhIcon As Integer
    Sound As Integer
    NeedsMana As Integer
    GiveHp As Integer
    GiveMan As Integer
    GiveFat As Integer
    GiveMoney As Integer
    GiveFood As Integer
    GiveDrink As Integer
    GiveEXP As Integer
    HealHP As Integer
    HealMan As Integer
    HealFat As Integer
    DamageHp As Integer
    DamageMan As Integer
    DamageFat As Integer
    Invisibility As Integer
    CreateObj As Integer
    Teleport As Integer
    SummonCreature As Integer
    Paralyze As Integer
    CasterMessage As String
    TargetMessage As String
    Destruction As Integer
    Ressurection As Integer
    School1 As String
    School2 As String
    School3 As String
    
    
End Type



'** User Types **
'Stats for a user
Type UserStats
    GLD As Long
    BANKGLD As Long
    Drink As Long
    Food As Long
    PracticePoints As Long
    MET As Integer
    MaxHP As Integer
    MinHP As Integer
    FIT As Integer
    MaxSTA As Integer
    MinSTA As Integer
    MaxMAN As Integer
    MinMAN As Integer
    MaxHIT As Integer
    MinHIT As Integer
    DEF As Integer
    EXP As Long
    ELV As Long
    ELU As Long
    OwnAnimal As Integer
    AnimalIndex As Integer
    
    LastPray As String
    
    Anchor As Integer
    Telemap As Integer
    TeleX As Integer
    TeleY As Integer

    Skill1 As Long
    Skill2 As Long
    Skill3 As Long
    Skill4 As Long
    Skill5 As Long
    Skill6 As Long
    Skill7 As Long
    Skill8 As Long
    Skill9 As Long
    Skill10 As Long
    Skill11 As Long
    Skill12 As Long
    Skill13 As Long
    Skill14 As Long
    Skill15 As Long
    Skill16 As Long
    Skill17 As Long
    Skill18 As Long
    Skill19 As Long
    Skill20 As Long
    Skill21 As Long
    Skill22 As Long
    Skill23 As Long
    Skill24 As Long
    Skill25 As Long
    Skill26 As Long
    Skill27 As Long
    Skill28 As Long
    

End Type

'Flags for a user
Type UserFlags
    UserLogged As Byte 'is the user logged in
    status As Integer
    Criminal As Integer
    Battlemode As Integer
    Duel As Integer
    Attack As Integer
    NpcAttack As Integer
    Pickpocket As Integer
    Giving As Integer
    Strike As Integer
    Meditate As Integer
    StartHead As Integer
    Hiding As Integer
    StartName As String
    LastExp As Integer
    Working As Integer
    whatjob As Integer
    SkillFinished As Integer
    LastSlot As Byte
    CriminalCount As Long
    YourID As Long
    Locks As Integer
    Sign As Long
    
    SpecSkill1 As String
    SpecSkill2 As String
    SpecSkill3 As String
    
    Immortal As Integer
    Morphed As Integer
    
    
End Type


'User Throwaway Variables
Type UserThrow
    MakeItem As Integer
    NeedPlanks As Integer
    NeedFoldedCloth As Integer
    NeedSteel As Integer
    skill As Integer
    
    Donategold As Integer
    
End Type

'Community standings for a user
Type UserCommunity
    NobleRep As Long
    UnderRep As Long
    CommonRep As Long
    BendarrRep As Long
    VeegaRep As Long
    ZeendicRep As Long
    GriigoRep As Long
    HyliiosRep As Long
    OverallRep As Long
    
    RepRank As String
    
End Type

Type UserCounters
    IdleCount As Long
End Type

Type UserSpell
    SpellIndex As Integer
End Type

Type UserOBJ
    ObjIndex As Integer
    Amount As Integer
    Equipped As Byte
End Type

Type NPCOBJ
    ObjIndex As Integer
    Amount As Integer
    Equipped As Byte
End Type

'Holds data for a user
Type User
    Name As String
    Town As String
    class As String
    Race As String
    modName As String
    Password As String
    theid As Long
    Gender As String
    Email As String
    Char As Char 'Defines users looks
    Desc As String
    NPCtarget As Integer
    OBJtarget As Integer
    Npcindex As Integer
    PlayerIndex As Integer
    UserTargetIndex As Integer
    MagicSchool As String
    
    Clan As String
    ClanRank As String
    ClanMember As Long
    Invite As String
    
    Pos As WorldPos 'Current User Postion
    
    IP As String 'User Ip
    ConnID As Integer 'Connection ID
    RDBuffer As String 'Broken Line Buffer

    Object(1 To MAX_INVENTORY_SLOTS) As UserOBJ

    SpellObj(1 To MAX_SPELL_SLOTS) As UserSpell
    WeaponEqpObjIndex As Integer
    WeaponEqpSlot As Byte
    ArmourEqpObjIndex As Integer
    ArmourEqpSlot As Byte
    ClothingEqpObjindex As Integer
    ClothingEqpSlot As Byte
    HEADEqpObjindex As Integer
    HEADEqpSlot As Byte
    SHIELDEqpObjindex As Integer
    SHIELDEqpSlot As Byte
    
    Counters As UserCounters
    Stats As UserStats
    Flags As UserFlags
    Throw As UserThrow
    Community As UserCommunity
End Type

'** NPC Types **
Type NPCStats
    MaxHP As Integer
    MinHP As Integer
    MaxHIT As Integer
    MinHIT As Integer
    DEF As Integer
End Type

Type NPCFlags
    NPCActive As Byte 'is the user logged in
    UseAINow As Integer
    Sound As Integer
    Attacking As Integer
    AttackedBy As Integer
    Category1 As String
    Category2 As String
    Category3 As String
    Category4 As String
    Category5 As String
End Type

Type LevelSkill

LevelValue As Integer

End Type


Type NPC
    Name As String
    Char As Char 'Defines users looks
    Desc As String
    
    Object(1 To MAX_NPCINVENTORY_SLOTS) As NPCOBJ
    
    Pos As WorldPos 'Current User Postion
    
    Hail As String
    
    Movement As Integer
    Attackable As Byte
    Hostile As Byte
    Guard As Byte
    NPCtype As Integer
    Level As Integer
    LootChance As Integer
    
    GiveEXP As Integer
    GiveGLD As Long
    
    DeathObj As Integer
    
    Tameable As Integer
    Tradeable As Integer
    Tamed As Integer
    Owner As Integer
    CanAttack As Integer
    Gold As String
    Target As Long
    Stats As NPCStats
    Flags As NPCFlags
    NpcNumber As Integer
    SkillNeeded As String
    
End Type



'** Map Types **

Type MapUserData
    UsersOnMap As Long
  End Type

'Tile Data
Type MapBlock
    Blocked As Byte
    userindex As Integer
    Npcindex As Integer
    ObjInfo As obj
    TileExit As WorldPos
    Locked As Long
    Sign As Integer
    SignOwner As Long
   End Type
    
'Map info
Type MapInfo
    NumUsers As Integer
    Music As String
    Name As String
    StartPos As WorldPos
    NorthExit As Integer
    SouthExit As Integer
    WestExit As Integer
    EastExit As Integer
    UsersOnMap As Integer
    PKFREEZONE As Integer
    Moderated As Integer
End Type

'********** Public VARS ***********

Public ENDL As String
Public ENDC As String

'Paths
Public IniPath As String
Public MapPath As String
Public CharPath As String
Public ClanPath As String

'Where the map borders are.. Set during load
Public MinXBorder As Byte
Public MaxXBorder As Byte
Public MinYBorder As Byte
Public MaxYBorder As Byte


Public CastleFallStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)
Public AngelmoorStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)
Public GorthStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)
Public BernVillageStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)
Public JemhooStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)
Public DencStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)
Public ValenStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)
Public ValenfallStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)
Public MolgStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)
Public UgStartPos As WorldPos 'Starting Pos (Loaded from Server.ini)

'Weather
Public Raining As Integer
Public Snowing As Integer
Public WillRain As Integer
Public WillStopRain As Integer

'Diverse

Public NPCCANATTACK As Integer

Public NumUsers As Integer 'current Number of Users
Public LastUser As Integer 'current Last User index
Public LastChar As Integer
Public NumChars As Integer
Public LastNPC As Integer
Public NumNPCs As Integer
Public NumMaps As Integer
Public NumObjDatas As Integer
Public NumPostDatas As Integer
Public NumSPELLDatas As Integer

Public ServerLogin As Integer
Public ClientVersion As String

Public AllowMultiLogins As Byte
Public IdleLimit As Integer
Public MaxUsers As Integer
Public HideMe As Byte
Public MessageboardNews As String

'********** Public ARRAYS ***********
Public UserList() As User 'Holds data for each user
Public NPCList(1 To 10000) As NPC 'Holds data for each NPC
Public MapData() As MapBlock
Public MapInfo() As MapInfo
Public CharList(1 To 10000) As Integer
Public ObjData() As ObjData
Public SpellData() As SpellData
Public PostData() As PostData
Public GMQUEData() As GMQUEData
Public LevelSkill(1 To 50) As LevelSkill

'********** EXTERNAL FUNCTIONS ***********
'APIs to write and read inis
Declare Function writeprivateprofilestring Lib "Kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationname As String, ByVal lpKeyname As Any, ByVal lpString As String, ByVal lpfilename As String) As Long
Declare Function getprivateprofilestring Lib "Kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationname As String, ByVal lpKeyname As Any, ByVal lpdefault As String, ByVal lpreturnedstring As String, ByVal nsize As Long, ByVal lpfilename As String) As Long
