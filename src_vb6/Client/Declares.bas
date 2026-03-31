Attribute VB_Name = "Declares"
Option Explicit

'********** CONSTANTS ***********

'Heading Constants
Global Const NORTH = 1
Global Const EAST = 2
Global Const SOUTH = 3
Global Const WEST = 4

'Map size in tiles
Global Const XMaxMapSize = 100
Global Const XMinMapSize = 1
Global Const YMaxMapSize = 100
Global Const YMinMapSize = 1

'How many tiles the engine "looks ahead"
'when drawing the screen

Global Const screenbuffer = 10

'Tile and Screen sizes
Global Const TileSizeX = 32
Global Const TileSizeY = 32


'Size of main view window in tiles
Global Const XWindow = 20
Global Const YWindow = 11

'Pixel offset from upperleft of main view window
'Use this to move view window around the screen
Public Const MainViewOffsetX = 80
Public Const MainViewOffsetY = 80

'Object constants
Public Const MAX_INVENTORY_OBJS = 999999999
Public Const MAX_INVENTORY_SLOTS = 20

'NPC Object constants
Public Const MAX_NPCINVENTORY_OBJS = 99
Public Const MAX_NPCINVENTORY_SLOTS = 40

'Spell constants
Public Const MAX_SPELL_SPELLS = 99
Public Const MAX_SPELL_SLOTS = 50

'Tailor constants
Public Const MAX_TAILOR_OBJS = 100
Public Const MAX_TAILOR_SLOTS = 100

'Posting constants
Public Const MAX_POSTS_POSTS = 999

'Gm Que Slots constants
Public Const MAX_HELPS_HELPS = 99999

'********** TYPES ***********

'Holds a local position
Type Position
    x As Integer
    y As Integer
End Type

'Holds a world position
Type WorldPos
    map As Integer
    x As Integer
    y As Integer
End Type

'Holds data about where a bmp can be found,
'How big it is and animation info
Public Type GrhData
    sX As Integer
    sY As Integer
    FileNum As Integer
    pixelWidth As Integer
    pixelHeight As Integer
    TileWidth As Single
    TileHeight As Single
    
    NumFrames As Integer
    Frames(1 To 16) As Integer
    Speed As Integer
End Type

'Points to a grhData and keeps animation info
Type Grh
    GrhIndex As Integer
    FrameCounter As Byte
    SpeedCounter As Byte
    Started As Byte
End Type

'Bodies list
Type BodyData
    Walk(1 To 4) As Grh
    HeadOffset As Position
End Type

'Weapon anims list
Type WeaponAnimData
    WeaponWalk(1 To 4) As Grh
End Type

'Shield anims list
Type ShieldAnimData
    ShieldWalk(1 To 4) As Grh
End Type

'Heads list
Type HeadData
    head(1 To 4) As Grh
End Type

'Hold info about a character
Type Char
    Active As Byte
    Heading As Byte
    Pos As Position

    body As BodyData
    weaponanim As WeaponAnimData
    shieldanim As ShieldAnimData
    head As HeadData

    Moving As Byte
    MoveOffset As Position
End Type

'User's inventory
Type inventory
    ObjIndex As Integer
    Name As String
    GrhIndex As Integer
    Amount As Integer
    equipped As Byte
    value As Long
End Type

'NPC's inventory
Type NPCinventory
    ObjIndex As Integer
    Name As String
    GrhIndex As Integer
    Amount As Integer
    equipped As Byte
    value As Long
    level As Long
End Type

'User's spell book
Type spellbook
    SpellIndex As Integer
    Name As String
    GrhIndex As Integer
    desc As String
    NeedsMana As Integer
        'Not used
        Amount As Integer
        equipped As Byte
End Type

Type GmQueSlots
    userindex As Integer
    helpmsg As String
    Time As String
    Date As String
    Name As String
End Type

'Messageboard postings
Type Postings
    Subject As String
    Post As String
    Author As String
End Type

'Tailor Object List
Type Tailorlist
    Tailorindex As Integer
    Name As Integer
    GrhIndex As Integer
    NeedFoldedCloth As Integer
End Type

'User's Carpentry form
Type Carpentry
    CarpentryObjIndex As Integer
    Name As String
    GrhIndex As Integer
    desc As String
    Needplanks As Integer
End Type


'Holds info about each tile position
Type MapBlock
    graphic(1 To 3) As Grh
    CharIndex As Integer
    ObjGrh As Grh
    Blocked As Byte
End Type

'Hold info about each map
Type MapInfo
    Music As String
    Name As String
End Type

'Bitmap header
Type BITMAPFILEHEADER
        bfType As Integer
        bfSize As Long
        bfReserved1 As Integer
        bfReserved2 As Integer
        bfOffBits As Long
End Type

'Bitmap info header
Type BITMAPINFOHEADER
        biSize As Long
        biWidth As Long
        biHeight As Long
        biPlanes As Integer
        biBitCount As Integer
        biCompression As Long
        biSizeImage As Long
        biXPelsPerMeter As Long
        biYPelsPerMeter As Long
        biClrUsed As Long
        biClrImportant As Long
End Type


'********** GLOBAL VARS ***********

'Paths
Global GrhPath As String
Global IniPath As String

'Createchar
Global CreateRace As String
Global CreateGender As String
Global CreateSpecSkill1 As String
Global CreateSpecSkill2 As String
Global CreateSpecSkill3 As String
Global CreateClass As String
Global CreateHome As String
Global CreateVersion As String

'Other
Global Dead As Integer


'Where the map borders are.. Set during load
Global MinXBorder As Byte
Global MaxXBorder As Byte
Global MinYBorder As Byte
Global MaxYBorder As Byte

'DD Surface Rectangles
Public MainViewRect As RECT
Public MainViewWidth As Integer
Public MainViewHeight As Integer
Public BackBufferRect As RECT

'User status vars
Global CurMap As Integer 'Current map loaded
Global userindex As Integer
Global UserCharIndex As Integer
Global UserInventory(1 To MAX_INVENTORY_SLOTS) As inventory
Global NPCinventory(1 To MAX_NPCINVENTORY_SLOTS) As NPCinventory
Global UserSpellBook(1 To MAX_SPELL_SLOTS) As spellbook
Global Messageboard(1 To MAX_POSTS_POSTS) As Postings
Global GmHelps(1 To MAX_HELPS_HELPS) As GmQueSlots
Global UserTailorList(1 To MAX_TAILOR_SLOTS) As Tailorlist
Global UserMoving As Byte
Global UserPos As Position 'Holds current user pos
Global AddtoUserPos As Position 'For moving user
Global UserName As String
Global UserPassword As String
Global UserBody As Integer
Global UserWeaponAnim As Integer
Global UserShieldAnim As Integer
Global UserRace As String
Global UserHead As Integer
Global UserTown As String
Global UserClass As String
Global UserMaxHP As Integer
Global UserMinHP As Integer
Global UserMaxMAN As Integer
Global UserMinMAN As Integer
Global UserMaxSTA As Integer
Global UserMinSTA As Integer
Global UserGLD As Long
Global UserBankGld As Long
Global UserFood As Long
Global UserPracticePoints As Long
Global UserDrink As Long
Global UserHiding As Integer
Global UserPickPocketing As Integer
Global UserDisguising As Integer
Global UserMeditating As Integer
Global UserGender As String
Global UserMail As String
Global UserVersion As String
Global UserCriminal As Integer
Global CriminalCount As Long
Global CriminalCount2 As Long


Global UserSkill1 As Long
Global UserSkill2 As Long
Global UserSkill3 As Long
Global UserSkill4 As Long
Global UserSkill5 As Long
Global UserSkill6 As Long
Global UserSkill7 As Long
Global UserSkill8 As Long
Global UserSkill9 As Long
Global UserSkill10 As Long
Global UserSkill11 As Long
Global UserSkill12 As Long
Global UserSkill13 As Long
Global UserSkill14 As Long
Global UserSkill15 As Long
Global UserSkill16 As Long
Global UserSkill17 As Long
Global UserSkill18 As Long
Global UserSkill19 As Long
Global UserSkill20 As Long
Global UserSkill21 As Long
Global UserSkill22 As Long
Global UserSkill23 As Long
Global UserSkill24 As Long
Global UserSkill25 As Long
Global UserSkill26 As Long
Global UserSkill27 As Long
Global UserSkill28 As Long

Global SpecSkill1 As String
Global SpecSkill2 As String
Global SpecSkill3 As String

Global UserCanAttack As Integer

Global UserBetaPass As String
Global Userid As Long

Global UserLvl As Integer
Global UserPort As Integer
Global UserServerIP As String

'Tutorial stuff
Global tutorial As Integer

'Skill stuff
Global SkillTime As Integer
Global WhatJob As Integer
Global Working As Integer

'Diverse
Global musicon As Integer
Global MusicOnOff As Integer

'Allow Click
Global AllowClick As Integer


'Server stuff
Global RequestPosTimer As Integer 'Used in main loop
Global stxtbuffer As String 'Holds temp raw data from server
Global SendNewChar As Boolean 'Used during login
Global Connected As Boolean 'True when connected to server
Global ErasingChar As Boolean 'Used during login

'Strinf contants
Global ENDC As String 'Endline character for talking with server
Global ENDL As String 'Holds the Endline character for textboxes

'Engine control
Global prgRun As Boolean 'When true the program ends
Global EngineRun As Boolean 'When true the engine runs

'For getting screen resolution
Global DisplayBits As Integer
Global DisplayHeight As Integer
Global DisplayWidth As Integer
Global hdccaps As Integer
Global hdesktopwnd As Integer

'Sound stuff
Public CurMidi As String 'Keeps current MIDI file
Public LoopMidi As Byte 'If 1 current MIDI is looped

'FPS counter
Global FramesPerSec As Integer
Global FramesPerSecCounter As Integer

'Address to game server
Global Address As String

'Diverse
Public CurrentGrh As Grh
Global Voices As Integer

'Totals
Global NumMaps As Integer 'Number of maps
Global NumBodies As Integer
Global NumWeaponAnims As Integer
Global NumShieldAnims As Integer
Global NumHeads As Integer
Global NumGrhFiles As Integer 'Number of bmps
Global NumGrhs As Integer 'Number of Grhs
Global NumChars As Integer
Global LastChar As Integer

'Weather
Global Raining As Integer

'********** Direct X ***********
Public DirectDraw As IDirectDraw4

Public PrimarySurface As IDirectDrawSurface4
Public PrimaryClipper As IDirectDrawClipper
Public BackBufferSurface As IDirectDrawSurface4
Public SurfaceDB() As IDirectDrawSurface4

'Directory stuff

Global Const gintMAX_SIZE% = 255                        'Maximum buffer size
Global Const gintMAX_PATH_LEN% = 260                    ' Maximum allowed path length including path, filename,
Global gstrWinSysDir As String
Global Const gstrNULL$ = ""

'********** GLOBAL ARRAYS ***********

Global GrhData() As GrhData 'Holds all the grh data

Global BodyData() As BodyData
Global WeaponAnimData() As WeaponAnimData
Global ShieldAnimData() As ShieldAnimData
Global HeadData() As HeadData

Global MapData() As MapBlock 'Holds map data for current map
Global MapInfo As MapInfo 'Holds map info for current map

Public CharList(1 To 10000) As Char 'Holds info about all characters on map

'********** OUTSIDE FUNCTIONS ***********

'For Get and Write Var
Declare Function writeprivateprofilestring Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationname As String, ByVal lpKeyname As Any, ByVal lpString As String, ByVal lpfilename As String) As Long
Declare Function getprivateprofilestring Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationname As String, ByVal lpKeyname As Any, ByVal lpdefault As String, ByVal lpreturnedstring As String, ByVal nSize As Long, ByVal lpfilename As String) As Long
Declare Function GetKeyState Lib "user32" (ByVal nVirtKey As Long) As Integer
Declare Function GetSystemDirectory Lib "kernel32" Alias "GetSystemDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long
