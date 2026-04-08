VERSION 5.00
Object = "{33101C00-75C3-11CF-A8A0-444553540000}#1.0#0"; "CSWSK32.OCX"
Begin VB.Form frmMain 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Era Online Server Program"
   ClientHeight    =   6825
   ClientLeft      =   1950
   ClientTop       =   1530
   ClientWidth     =   6750
   BeginProperty Font 
      Name            =   "Arial"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6825
   ScaleWidth      =   6750
   WindowState     =   1  'Minimized
   Begin VB.Timer ServerBot 
      Enabled         =   0   'False
      Interval        =   60000
      Left            =   360
      Top             =   1080
   End
   Begin SocketWrenchCtrl.Socket Socket1 
      Left            =   120
      Top             =   -120
      _Version        =   65536
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   0
      AutoResolve     =   -1  'True
      Backlog         =   1
      Binary          =   0   'False
      Blocking        =   0   'False
      Broadcast       =   0   'False
      BufferSize      =   2048
      HostAddress     =   ""
      HostFile        =   ""
      HostName        =   ""
      InLine          =   0   'False
      Interval        =   0
      KeepAlive       =   0   'False
      Library         =   ""
      Linger          =   0
      LocalPort       =   0
      LocalService    =   ""
      Protocol        =   0
      RemotePort      =   0
      RemoteService   =   ""
      ReuseAddress    =   0   'False
      Route           =   -1  'True
      Timeout         =   0
      Type            =   1
      Urgent          =   0   'False
   End
   Begin SocketWrenchCtrl.Socket Socket2 
      Index           =   0
      Left            =   600
      Top             =   -120
      _Version        =   65536
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   0
      AutoResolve     =   -1  'True
      Backlog         =   1
      Binary          =   0   'False
      Blocking        =   0   'False
      Broadcast       =   0   'False
      BufferSize      =   0
      HostAddress     =   ""
      HostFile        =   ""
      HostName        =   ""
      InLine          =   0   'False
      Interval        =   0
      KeepAlive       =   0   'False
      Library         =   ""
      Linger          =   0
      LocalPort       =   0
      LocalService    =   ""
      Protocol        =   0
      RemotePort      =   0
      RemoteService   =   ""
      ReuseAddress    =   0   'False
      Route           =   -1  'True
      Timeout         =   0
      Type            =   1
      Urgent          =   0   'False
   End
   Begin VB.CommandButton cmdReloadVersion 
      Caption         =   "Reload Client Version"
      Height          =   285
      Left            =   1020
      TabIndex        =   22
      Top             =   2370
      Width           =   2025
   End
   Begin VB.TextBox txtReloadSpl 
      Height          =   315
      Left            =   2640
      TabIndex        =   21
      Top             =   1980
      Width           =   1455
   End
   Begin VB.CommandButton cmdReloadSpl 
      Caption         =   "Reload Spell:"
      Height          =   285
      Left            =   1020
      TabIndex        =   20
      Top             =   2010
      Width           =   1575
   End
   Begin VB.TextBox txtReloadObj 
      Height          =   315
      Left            =   2640
      TabIndex        =   19
      Top             =   1620
      Width           =   1455
   End
   Begin VB.CommandButton cmdReloadObj 
      Caption         =   "Reload Object:"
      Height          =   285
      Left            =   1020
      TabIndex        =   18
      Top             =   1650
      Width           =   1575
   End
   Begin VB.Timer NpcAttack 
      Interval        =   4000
      Left            =   5160
      Top             =   3480
   End
   Begin VB.Timer Doevents 
      Interval        =   65000
      Left            =   5640
      Top             =   3480
   End
   Begin VB.Timer DeleteLog 
      Interval        =   65000
      Left            =   6120
      Top             =   3480
   End
   Begin VB.CommandButton Command8 
      Caption         =   "Account Creator"
      Height          =   495
      Left            =   4320
      TabIndex        =   16
      Top             =   3960
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Timer rain 
      Left            =   6120
      Top             =   3960
   End
   Begin VB.Frame Frame1 
      Caption         =   "Weather/Time Of Day In The Game World:"
      Height          =   1455
      Left            =   120
      TabIndex        =   10
      Top             =   4560
      Width           =   6495
      Begin VB.CommandButton Command7 
         Caption         =   "Make It Sunny"
         Height          =   255
         Left            =   5040
         TabIndex        =   15
         Top             =   1080
         Width           =   1335
      End
      Begin VB.CommandButton Command6 
         Caption         =   "Start Snowing"
         Height          =   255
         Left            =   5040
         TabIndex        =   14
         Top             =   480
         Width           =   1335
      End
      Begin VB.CommandButton Command3 
         Caption         =   "Start Raining"
         Height          =   255
         Left            =   5040
         TabIndex        =   13
         Top             =   240
         Width           =   1335
      End
      Begin VB.Label weather 
         Alignment       =   2  'Center
         Caption         =   "Sunny"
         Height          =   255
         Left            =   240
         TabIndex        =   12
         Top             =   600
         Width           =   1455
      End
      Begin VB.Label Label4 
         Caption         =   "Current Weather:"
         Height          =   255
         Left            =   240
         TabIndex        =   11
         Top             =   360
         Width           =   1575
      End
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Reload Objects"
      Height          =   495
      Left            =   2520
      TabIndex        =   9
      Top             =   3960
      Width           =   1575
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Reload Spells"
      Height          =   495
      Left            =   2520
      TabIndex        =   8
      Top             =   3360
      Width           =   1575
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Reset Server"
      Height          =   495
      Left            =   720
      TabIndex        =   5
      Top             =   3360
      Width           =   1575
   End
   Begin VB.CommandButton Command2 
      Caption         =   "World Control"
      Height          =   495
      Left            =   720
      TabIndex        =   7
      Top             =   3960
      Width           =   1575
   End
   Begin VB.TextBox LocalAdd 
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   1320
      Locked          =   -1  'True
      TabIndex        =   3
      Top             =   240
      Width           =   5295
   End
   Begin VB.Timer GameTimer 
      Interval        =   50
      Left            =   1080
      Top             =   -120
   End
   Begin VB.TextBox txPortNumber 
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   1320
      Locked          =   -1  'True
      TabIndex        =   2
      Top             =   600
      Width           =   5295
   End
   Begin VB.TextBox txStatus 
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   330
      Left            =   120
      Locked          =   -1  'True
      TabIndex        =   0
      Top             =   6360
      Width           =   6495
   End
   Begin VB.Label Doing 
      Height          =   255
      Left            =   4320
      TabIndex        =   17
      Top             =   3480
      Width           =   1215
   End
   Begin VB.Label Label3 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Status"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   3120
      TabIndex        =   6
      Top             =   6120
      Width           =   450
   End
   Begin VB.Label Label1 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Server IP:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   60
      TabIndex        =   4
      Top             =   300
      Width           =   705
   End
   Begin VB.Label Label5 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Running on Port:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   15
      TabIndex        =   1
      Top             =   660
      Width           =   1200
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdReloadObj_Click()
    Dim Object As Integer
    
    Object = Me.txtReloadObj
    ObjData(Object).Name = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Name")
    ObjData(Object).Category = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Category")
    ObjData(Object).ClassForbid1 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid1")
    ObjData(Object).ClassForbid2 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid2")
    ObjData(Object).ClassForbid3 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid3")
    ObjData(Object).ClassForbid4 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid4")
    ObjData(Object).ClassForbid5 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid5")
    ObjData(Object).ClassForbid6 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid6")
    ObjData(Object).ClassForbid7 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid7")
    ObjData(Object).Grhindex = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "GrhIndex"))
    ObjData(Object).MakeItem = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Makeitem"))
    ObjData(Object).Pickable = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Pickable"))
    ObjData(Object).ObjType = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "ObjType"))
    ObjData(Object).Sellable = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Sellable"))
    ObjData(Object).Food = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Food"))
    ObjData(Object).Value = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "VALUE")
    ObjData(Object).Level = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "LEVEL"))
    ObjData(Object).SpellType = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "SPELLTYPE"))
    ObjData(Object).NeedPlanks = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "NeedPlanks"))
    ObjData(Object).NeedFoldedCloth = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "NeedFoldedCloth"))
    ObjData(Object).NeedSteel = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "NeedSteel"))
    ObjData(Object).skill = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Skill"))
    ObjData(Object).MaxHIT = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "MaxHIT"))
    ObjData(Object).MinHIT = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "MinHIT"))
    ObjData(Object).MaxHP = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "MaxHP"))
    ObjData(Object).MinHP = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "MinHP"))
    ObjData(Object).DEF = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "DEF"))
    ObjData(Object).ClothingType = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "ClothingType"))
    ObjData(Object).HandleRain = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "TakeRain"))
    ObjData(Object).ShieldAnim = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "ShieldAnim"))
    ObjData(Object).WeaponAnim = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "WeaponAnim"))
    Me.txStatus.Text = "Object " & Object & " (" & ObjData(Object).Name & ") reloaded"
End Sub

Private Sub cmdReloadSpl_Click()
    Dim SpellObj As Integer
    SpellObj = Me.txtReloadSpl.Text
    SpellData(SpellObj).Name = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Name")
    SpellData(SpellObj).Desc = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Desc")
    SpellData(SpellObj).CasterMessage = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "CasterMessage")
    SpellData(SpellObj).TargetMessage = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "TargetMessage")
    SpellData(SpellObj).School1 = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "School1")
    SpellData(SpellObj).School2 = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "School2")
    SpellData(SpellObj).School3 = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "School3")
    SpellData(SpellObj).GrhEffect = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GrhEffect"))
    SpellData(SpellObj).Grhindex = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GrhIndex"))
    SpellData(SpellObj).GrhIcon = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GrhIcon"))
    SpellData(SpellObj).Sound = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Sound"))
    SpellData(SpellObj).NeedsMana = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "NeedsMana"))
    SpellData(SpellObj).GiveHp = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveHP"))
    SpellData(SpellObj).GiveMan = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveMan"))
    SpellData(SpellObj).GiveFat = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveFat"))
    SpellData(SpellObj).GiveMoney = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveMoney"))
    SpellData(SpellObj).GiveFood = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveFood"))
    SpellData(SpellObj).GiveDrink = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveDrink"))
    SpellData(SpellObj).GiveEXP = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveExp"))
    SpellData(SpellObj).HealHP = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "HealHP"))
    SpellData(SpellObj).HealMan = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "HealMan"))
    SpellData(SpellObj).HealFat = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "HealFat"))
    SpellData(SpellObj).DamageHp = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "DamageHP"))
    SpellData(SpellObj).DamageMan = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "DamageMan"))
    SpellData(SpellObj).DamageFat = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "DamageFat"))
    SpellData(SpellObj).Invisibility = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Invisibility"))
    SpellData(SpellObj).CreateObj = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "CreateOBJ"))
    SpellData(SpellObj).SummonCreature = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "SummonCreature"))
    SpellData(SpellObj).Paralyze = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Paralyze"))
    SpellData(SpellObj).Destruction = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Destruction"))
    SpellData(SpellObj).Ressurection = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Ressurection"))
    Me.txStatus.Text = "Spell " & SpellObj & " (" & SpellData(SpellObj).Name & ") reloaded"
End Sub

Private Sub cmdReloadVersion_Click()
    ClientVersion = GetVar(IniPath & "Server.ini", "INIT", "ClientVersion")
    Me.txStatus.Text = "Done, now accepting version " & ClientVersion
End Sub

Private Sub Command1_Click()
    Call Restart
End Sub

Private Sub Command2_Click()
    worldcontrol.Show
End Sub

Private Sub Command3_Click()
    Call SendData(ToAll, 0, 0, "RAI")
    Call SendData(ToAll, 0, 0, "@It begins to snow..." & FONTTYPE_INFO)
    frmMain.weather = "Raining"
    Raining = 1
    Call SendData(ToAll, 0, 0, "PLW" & SOUND_THUNDER)
End Sub

Private Sub Command4_Click()
    Call LoadSpellData
End Sub

Private Sub Command5_Click()
    Call LoadOBJData
    frmMain.txStatus.Text = "Objects reloaded"
End Sub

Private Sub Command7_Click()
    Call SendData(ToAll, 0, 0, "PLW" & SOUND_BIRDS)
    Raining = 0
    Snowing = 0
    Call SendData(ToAll, 0, 0, "SAI")
    Call SendData(ToAll, 0, 0, "@The snow stops from falling..." & FONTTYPE_INFO)
    frmMain.weather = "Sunny"
End Sub

Private Sub Command8_Click()
Form1.Show
End Sub

Private Sub Command9_Click()

Dim NpcNum As Integer
Dim NPC As String

For NpcNum = 1 To 530

NPC = NpcNum
Call WriteVar(IniPath & "NPC.DAT", "NPC" & NpcNum, "NpcNumber", NPC)

Next NpcNum

End Sub

Private Sub DeleteLog_Timer()

On Error Resume Next

'Delete the log file
Kill (IniPath & "Log.txt")

End Sub
Private Sub Doevents_Timer()

If Doing = "" Then
Doing = "Beating..."
Else
Doing = ""
End If




Call Beat

End Sub

Private Sub Form_Load()
loading.Show
rain.Interval = 65000
DeleteLog.Interval = 65000
Doevents.Interval = 65000
NpcAttack.Interval = 4000
loading.Label1 = "Checking directories..."
loading.Picture = LoadPicture(App.Path & "\loading.jpg")

'*****************************************************************
'Load up server
'*****************************************************************




Dim LoopC As Integer

'INIT vars

ENDL = Chr(13) & Chr(10)
ENDC = Chr(1)
IniPath = App.Path & "\"
CharPath = App.Path & "\Charfile\"
ClanPath = App.Path & "\Clans\"

loading.Label1 = "Checking directories..."
loading.Picture = LoadPicture(App.Path & "\loading.jpg")

'Setup Map borders
MinXBorder = XMinMapSize + (XWindow \ 3)
MaxXBorder = XMaxMapSize - (XWindow \ 3)
MinYBorder = YMinMapSize + (YWindow \ 2)
MaxYBorder = YMaxMapSize - (YWindow \ 2)

'Reset User connections
For LoopC = 1 To MaxUsers
    UserList(LoopC).ConnID = -1
Next LoopC


'*****************Load data text data
loading.Label1 = "Loading Server Data..."
loading.Picture = LoadPicture(App.Path & "\loading.jpg")

Call LoadSini
loading.Label1 = "Loading Spells..."
loading.Picture = LoadPicture(App.Path & "\loading.jpg")

Call LoadSpellData
loading.Label1 = "Loading In Objects...."
loading.Picture = LoadPicture(App.Path & "\loading.jpg")

Call LoadOBJData
loading.Label1 = "Loading game world. This may take several minutes !"
loading.Picture = LoadPicture(App.Path & "\loading.jpg")

Call LoadMapData


'*****************Setup socket
loading.Label1 = "Setting up sockets..."
loading.Picture = LoadPicture(App.Path & "\loading.jpg")

frmMain.Socket1.AddressFamily = AF_INET
frmMain.Socket1.Protocol = IPPROTO_IP
frmMain.Socket1.SocketType = SOCK_STREAM
frmMain.Socket1.Binary = False
frmMain.Socket1.Blocking = False
frmMain.Socket1.BufferSize = 1024

frmMain.Socket2(0).AddressFamily = AF_INET
frmMain.Socket2(0).Protocol = IPPROTO_IP
frmMain.Socket2(0).SocketType = SOCK_STREAM
frmMain.Socket2(0).Binary = False
frmMain.Socket2(0).Blocking = False
frmMain.Socket2(0).BufferSize = 2048


'Listen
frmMain.Socket1.LocalPort = Val(frmMain.txPortNumber.Text)
frmMain.Socket1.Listen
frmMain.txStatus.Text = "Listening for connection ..."

'******************Misc

Unload loading
rain.Interval = 10000

'Show local IP
frmMain.LocalAdd.Text = frmMain.Socket1.LocalAddress

'Set the save hour
LastSaveHour = TimeHour

'Log it
Open App.Path & "\Main.log" For Append Shared As #5
Print #5, "**** Server started. " & Time & " " & Date
Close #5

Call ServerBot_Timer

End Sub

Private Sub Form_Unload(Cancel As Integer)

Dim LoopC As Integer

'ensure that the sockets are closed, ignore any errors
On Error Resume Next

Socket1.Cleanup

For LoopC = 1 To MaxUsers
    CloseSocket (LoopC)
Next

'Log it
Open App.Path & "\Main.log" For Append Shared As #5
Print #5, "**** Server unloaded. " & Time & " " & Date
Close #5

End

End Sub

Sub GameTimer_Timer()
'*****************************************************************
'update world
'*****************************************************************
Dim userindex As Integer
Dim Npcindex As Integer
Dim map As Integer
Dim x As Integer
Dim y As Integer
Dim useai As Integer

If TimeMinute = SaveAtMinute And TimeHour = SaveHour Then
    Call SendData(ToAll, 0, 0, "@AUTO WORLDSAVE INITIATED...PLEASE EXCUSE ANY POSSIBLE LAG FOR THE NEXT FEW MINUTES." & FONTTYPE_INFO)
    Call SendData(ToAll, 0, 0, "@AUTO WORLDSAVE INITIATED...PLEASE EXCUSE ANY POSSIBLE LAG FOR THE NEXT FEW MINUTES." & FONTTYPE_INFO)
    Call SendData(ToAll, 0, 0, "@AUTO WORLDSAVE INITIATED...PLEASE EXCUSE ANY POSSIBLE LAG FOR THE NEXT FEW MINUTES." & FONTTYPE_INFO)
    Call SaveWorld
    SaveHour = TimeHour + 4
    If SaveHour > 23 Then SaveHour = SaveHour - 24
End If

'Update Users
For userindex = 1 To LastUser
 
    UserList(userindex).PlayerIndex = userindex
    'make sure user is logged on
    If UserList(userindex).Flags.UserLogged = True Then

        'Update idle counter
        UserList(userindex).Counters.IdleCount = UserList(userindex).Counters.IdleCount + 1
        If UserList(userindex).Counters.IdleCount >= IdleLimit Then
            Call SendData(ToIndex, userindex, 0, "IDL")
            Call SendData(ToIndex, userindex, 0, "!!Sorry you have been idle to long. Disconnected..")
            Call CloseSocket(userindex)
        End If
        
         'Do special tile events
        Call DoTileEvents(userindex, UserList(userindex).Pos.map, UserList(userindex).Pos.x, UserList(userindex).Pos.y)

       End If
        
Next userindex

'Update NPCs
For Npcindex = 1 To LastNPC
map = NPCList(Npcindex).Pos.map
    
    'make sure NPC is active
    If NPCList(Npcindex).Flags.NPCActive = 1 Then
    NPCList(Npcindex).Flags.UseAINow = 1
    End If
        
    'Only do AI if there is users on map
    If NPCList(Npcindex).Flags.UseAINow = 1 Then
    If MapInfo(map).NumUsers = 0 Then
    NPCList(Npcindex).Flags.UseAINow = 0
    End If
    End If
    
    'If NPC has stop movment, then dont use AI
    If NPCList(Npcindex).Flags.UseAINow = 1 Then
    If NPCList(Npcindex).Movement = 1 Then
    NPCList(Npcindex).Flags.UseAINow = 0
    End If
    End If
       
    'HOSTILE
    If NPCList(Npcindex).Flags.UseAINow = 1 Then
    If NPCList(Npcindex).Hostile = 1 Then
    NPCList(Npcindex).Flags.UseAINow = 0
    useai = RandomNumber(1, 4)
    If useai = 2 Then
    Call NPCAI(Npcindex)
    End If
    End If
    End If
    
    
    'Dont move NPC hyper active if random movment
    If NPCList(Npcindex).Flags.UseAINow = 1 Then
    If NPCList(Npcindex).Movement = 2 Then
    NPCList(Npcindex).Flags.UseAINow = 0
    useai = RandomNumber(1, 4)
    If useai = 1 Then
    Call NPCAI(Npcindex)
    End If
    End If
    End If


    'If to use ai, then do it
    If NPCList(Npcindex).Flags.UseAINow = 1 Then
    Call NPCAI(Npcindex)
    End If

Next Npcindex



End Sub

Private Sub NpcAttack_Timer()
Dim NPC As Integer

For NPC = 1 To LastNPC
NPCList(NPC).CanAttack = 1
Next NPC

End Sub

Private Sub rain_Timer()

Dim StartRain
Dim StopRain

If WillRain < 30 Then
WillRain = WillRain + 1
Else
WillRain = 0
End If

If WillStopRain < 15 Then
WillStopRain = WillStopRain + 1
Else
WillStopRain = 0
End If

'If it dosnt rain, calculate to see if it should start
'If Raining = 0 And WillRain = 30 Then
'StartRain = Int(RandomNumber(1, 7))
'If StartRain = 2 Then
'Raining = 1
'Call SendData(ToAll, 0, 0, "RAI")
'Call SendData(ToAll, 0, 0, "@It begins to snow..." & FONTTYPE_INFO)
'frmMain.weather = "Raining"
'Call SendData(ToAll, 0, 0, "PLW" & SOUND_THUNDER)
'End If

'Else

'Calculate to see if it should stop

If Raining = 1 Then 'And WillStopRain = 15 Then
StopRain = 2 'Int(RandomNumber(1, 4))
If StopRain = 2 Then
Raining = 0
Call SendData(ToAll, 0, 0, "SAI")
Call SendData(ToAll, 0, 0, "@It stops snowing..." & FONTTYPE_INFO)
frmMain.weather = "Sunny"
Call SendData(ToAll, 0, 0, "PLW" & SOUND_BIRDS)
End If

End If
'End If


End Sub

Private Sub Snow_Timer()


End Sub

Private Sub ServerBot_Timer()

ServerBot.Enabled = True
Open App.Path & "\num.dat" For Output As #128
Print #128, Trim(Str(NumUsers)) & " "
Close #128

End Sub

Sub Socket1_Accept(SocketId As Integer)
'*********************************************
'Accepts new user and assigns an open Index
'*********************************************
Dim Index As Integer

Index = NextOpenUser

If UserList(Index).ConnID >= 0 Then
    'Close down user socket
    Call CloseSocket(Index)
End If

UserList(Index).ConnID = SocketId
Load Socket2(Index)

Socket2(Index).AddressFamily = AF_INET
Socket2(Index).Protocol = IPPROTO_IP
Socket2(Index).SocketType = SOCK_STREAM
Socket2(Index).Binary = False
Socket2(Index).BufferSize = 2048
Socket2(Index).Blocking = False

Socket2(Index).Accept = SocketId

End Sub

Sub Socket2_Disconnect(Index As Integer)
'*********************************************
'Begins close procedure
'*********************************************

CloseSocket (Index)

End Sub


Sub Socket2_Read(Index As Integer, DataLength As Integer, IsUrgent As Integer)
'*********************************************
'Seperate lines by ENDC and send each to HandleData()
'*********************************************
On Error GoTo Errorhandler

Dim LoopC As Integer
Dim RD As String
Dim rBuffer(1 To 100) As String
Dim CR As Integer
Dim tChar As String
Dim sChar As Integer
Dim eChar As Integer


Socket2(Index).Read RD, DataLength

'Check for previous broken data and add to current data
If UserList(Index).RDBuffer <> "" Then
    RD = UserList(Index).RDBuffer & RD
    UserList(Index).RDBuffer = ""
End If

'Check for more than one line
sChar = 1
For LoopC = 1 To Len(RD)

    tChar = Mid$(RD, LoopC, 1)

    If tChar = ENDC Then
        CR = CR + 1
        eChar = LoopC - sChar
        rBuffer(CR) = Mid$(RD, sChar, eChar)
        sChar = LoopC + 1
    End If

        
Next LoopC

'Check for broken line and save for next time
If Len(RD) - (sChar - 1) <> 0 Then
    UserList(Index).RDBuffer = Mid$(RD, sChar, Len(RD))
End If

'Send buffer to Handle data
For LoopC = 1 To CR
    Call HandleData(Index, rBuffer(LoopC))
Next LoopC

Errorhandler:
Exit Sub

End Sub

Private Sub Timer1_Timer()

End Sub

Private Sub Text3_Change()

End Sub
