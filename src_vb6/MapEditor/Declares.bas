Attribute VB_Name = "Declares"
Option Explicit

'********** CONSTANTS ***********
'Heading Constants
Public Const NORTH = 1
Public Const EAST = 2
Public Const SOUTH = 3
Public Const WEST = 4

'Map sizes in tiles
Public Const XMaxMapSize = 100
Public Const XMinMapSize = 1
Public Const YMaxMapSize = 100
Public Const YMinMapSize = 1

'How many tiles the engine "looks ahead" when
'drawing the screen
Public Const ScreenBuffer = 8

'Tile size in pixels
Public Const TileSizeX = 50
Public Const TileSizeY = 50

'Main window size in tiles
Public Const XWindow = 15
Public Const YWindow = 11

Public Const MainViewOffsetX = 40
Public Const MainViewOffsetY = 172

'Object Constants
Public Const MAX_INVENORY_OBJS = 99


'********** TYPES ***********
'Holds a local position
Public Type Position
    x As Integer
    y As Integer
End Type

'Holds a world position
Public Type WorldPos
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
Public Type Grh
    GrhIndex As Integer
    FrameCounter As Byte
    SpeedCounter As Byte
    Started As Byte
End Type

'Bodies list
Public Type BodyData
    Walk(1 To 4) As Grh
    HeadOffset As Position
End Type

'Heads list
Public Type HeadData
    Head(1 To 4) As Grh
End Type

'Hold info about a character
Public Type Char
    Active As Byte
    Heading As Byte
    Pos As Position

    Body As BodyData
    Head As HeadData
    
    Moving As Byte
    MoveOffset As Position
End Type

'Holds info about a object
Public Type Obj
    OBJIndex As Integer
    Amount As Integer
End Type

'Holds info about each tile position
Public Type MapBlock
    Graphic(1 To 3) As Grh
    CharIndex As Integer
    ObjGrh As Grh
    
    NPCIndex As Integer
    OBJInfo As Obj
    TileExit As WorldPos
    Blocked As Byte

End Type

'Hold info about each map
Public Type MapInfo
    Music As String
    Name As String
    StartPos As WorldPos
    
    'ME Only
    Changed As Byte
End Type

'********** Public VARS ***********
'Paths
Public GrhPath As String
Public IniPath As String

'Where the map borders are.. Set during load
Public MinXBorder As Byte
Public MaxXBorder As Byte
Public MinYBorder As Byte
Public MaxYBorder As Byte

'User status vars
Public CurMap As Integer 'Current map loaded
Public UserIndex As Integer
Public UserMoving As Byte
Public UserPos As Position 'Holds current user pos
Public AddtoUserPos As Position 'For moving user
Public UserCharIndex As Integer

Public CurrentGrh As Grh 'Grh shown in ShowPic
Public ENDL As String 'Holds the Endline character
Public prgRun As Boolean 'When true the program ends
Public EngineRun As Boolean

'For getting screen res
Public DisplayBits As Integer
Public DisplayHeight As Integer
Public DisplayWidth As Integer
Public hdccaps As Integer
Public hdesktopwnd As Integer

'Map editor variables
Public WalkMode As Boolean
Public FramesPerSec As Integer
Public DrawGrid As Boolean
Public DrawBlock As Boolean

'Totals
Public NumMaps As Integer 'Number of maps
Public NumBodies As Integer
Public NumHeads As Integer
Public NumGrhFiles As Integer 'Number of bmps
Public NumGrhs As Integer 'Number of Grhs


'Scroll speed
Public ScrollSpeed As Integer


'********** Direct X ***********
Public MainViewRect As RECT
Public MainViewWidth As Integer
Public MainViewHeight As Integer
Public BackBufferRect As RECT

Public DirectDraw As IDirectDraw4

Public PrimarySurface As IDirectDrawSurface4
Public PrimaryClipper As IDirectDrawClipper
Public BackBufferSurface As IDirectDrawSurface4
Public SurfaceDB() As IDirectDrawSurface4


'********** Public ARRAYS ***********
Public GrhData() As GrhData 'Holds all the grh data

Public BodyData() As BodyData
Public HeadData() As HeadData

Public MapData() As MapBlock 'Holds map data for current map
Public MapInfo As MapInfo 'Holds map info for current map
Public CharList(1 To 10000) As Char 'Holds info about all characters on map


'********** OUTSIDE FUNCTIONS ***********
'For Get and Write Var
Declare Function writeprivateprofilestring Lib "Kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationname As String, ByVal lpKeyname As Any, ByVal lpString As String, ByVal lpfilename As String) As Long
Declare Function getprivateprofilestring Lib "Kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationname As String, ByVal lpKeyname As Any, ByVal lpdefault As String, ByVal lpreturnedstring As String, ByVal nsize As Long, ByVal lpfilename As String) As Long

Declare Function GetKeyState Lib "user32" (ByVal nVirtKey As Long) As Integer
