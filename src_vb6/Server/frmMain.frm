VERSION 5.00
Object = "{33101C00-75C3-11CF-A8A0-444553540000}#1.0#0"; "CSWSK32.OCX"
Begin VB.Form frmMain 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Era Online Server Program"
   ClientHeight    =   3825
   ClientLeft      =   2775
   ClientTop       =   2445
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
   ScaleHeight     =   3825
   ScaleWidth      =   6750
   WindowState     =   1  'Minimized
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
   Begin VB.Timer NpcAttack 
      Interval        =   4000
      Left            =   5160
      Top             =   1080
   End
   Begin VB.CommandButton Command8 
      Caption         =   "Account Creator"
      Height          =   495
      Left            =   4320
      TabIndex        =   15
      Top             =   1560
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Timer rain 
      Left            =   6120
      Top             =   1560
   End
   Begin VB.Frame Frame1 
      Caption         =   "Weather/Time Of Day In The Game World:"
      Height          =   855
      Left            =   120
      TabIndex        =   10
      Top             =   2160
      Width           =   6495
      Begin VB.CommandButton Command7 
         Caption         =   "Make It Sunny"
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
         Top             =   480
         Width           =   1455
      End
      Begin VB.Label Label4 
         Caption         =   "Current Weather:"
         Height          =   255
         Left            =   240
         TabIndex        =   11
         Top             =   240
         Width           =   1575
      End
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Reload Objects"
      Height          =   495
      Left            =   2520
      TabIndex        =   9
      Top             =   1560
      Width           =   1575
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Reload Spells"
      Height          =   495
      Left            =   2520
      TabIndex        =   8
      Top             =   960
      Width           =   1575
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Reset Server"
      Height          =   495
      Left            =   720
      TabIndex        =   5
      Top             =   960
      Width           =   1575
   End
   Begin VB.CommandButton Command2 
      Caption         =   "World Control"
      Height          =   495
      Left            =   720
      TabIndex        =   7
      Top             =   1560
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
      Top             =   3360
      Width           =   6495
   End
   Begin VB.Label Doing 
      Height          =   255
      Left            =   4320
      TabIndex        =   16
      Top             =   1080
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
      Top             =   3120
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
      Top             =   600
      Width           =   1200
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Option Explicit
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


Private Sub Form_Load()
loading.Show
rain.Interval = 65000
NpcAttack.Interval = 4000
loading.Label1 = "Checking directories..."
loading.Picture = LoadPicture("loading.jpg")

'*****************************************************************
'Load up server
'*****************************************************************




Dim LoopC As Integer

'INIT vars

ENDL = Chr(13) & Chr(10)
ENDC = Chr(1)
IniPath = App.Path & "\"
MapPath = App.Path & "\Maps\"
CharPath = App.Path & "\Charfile\"
ClanPath = App.Path & "\Clans\"

loading.Label1 = "Checking directories..."
loading.Picture = LoadPicture("loading.jpg")

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
loading.Picture = LoadPicture("loading.jpg")

Call LoadSini
loading.Label1 = "Loading In Game Data..."
loading.Picture = LoadPicture("loading.jpg")

Call LoadSpellData
loading.Label1 = "Loading In Game Data....."
loading.Picture = LoadPicture("loading.jpg")

Call LoadOBJData
loading.Label1 = "Loading game world. This may take several minutes !"
loading.Picture = LoadPicture("loading.jpg")

Call LoadMapData


'*****************Setup socket
loading.Label1 = "Setting up sockets..."
loading.Picture = LoadPicture("loading.jpg")

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

'Log it
Open App.Path & "\Main.log" For Append Shared As #5
Print #5, "**** Server started. " & Time & " " & Date
Close #5

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
Dim X As Integer
Dim Y As Integer
Dim useai As Integer


'Update Users
For userindex = 1 To LastUser
 
    UserList(userindex).PlayerIndex = userindex
    'make sure user is logged on
    If UserList(userindex).Flags.UserLogged = True Then

        'Update idle counter
        UserList(userindex).Counters.IdleCount = UserList(userindex).Counters.IdleCount + 1
        If UserList(userindex).Counters.IdleCount >= IdleLimit Then
            Call SendData(ToIndex, userindex, 0, "!!Sorry you have been idle to long. Disconnected..")
            Call CloseSocket(userindex)
        End If
        
         'Do special tile events
        Call DoTileEvents(userindex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)

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
If Raining = 0 And WillRain = 30 Then
StartRain = Int(RandomNumber(1, 7))
If StartRain = 2 Then
Raining = 1
Call SendData(ToAll, 0, 0, "RAI")
Call SendData(ToAll, 0, 0, "@It begins to snow..." & FONTTYPE_INFO)
frmMain.weather = "Raining"
Call SendData(ToAll, 0, 0, "PLW" & SOUND_THUNDER)
End If

Else

'Calculate to see if it should stop

If Raining = 1 And WillStopRain = 15 Then
StopRain = Int(RandomNumber(1, 4))
If StopRain = 2 Then
Raining = 0
Call SendData(ToAll, 0, 0, "SAI")
Call SendData(ToAll, 0, 0, "@It stops snowing..." & FONTTYPE_INFO)
frmMain.weather = "Sunny"
Call SendData(ToAll, 0, 0, "PLW" & SOUND_BIRDS)
End If

End If
End If


End Sub

Private Sub Snow_Timer()


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

