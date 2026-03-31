VERSION 5.00
Object = "{22D6F304-B0F6-11D0-94AB-0080C74C7E95}#1.0#0"; "msdxm.ocx"
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Begin VB.Form Form7 
   BackColor       =   &H80000007&
   BorderStyle     =   0  'None
   ClientHeight    =   9000
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12000
   ControlBox      =   0   'False
   LinkTopic       =   "Form7"
   ScaleHeight     =   9000
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.CommandButton Command2 
      Caption         =   "Back"
      Height          =   255
      Left            =   8040
      TabIndex        =   12
      Top             =   5760
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Continue"
      Height          =   255
      Left            =   9240
      TabIndex        =   11
      Top             =   5760
      Width           =   1095
   End
   Begin VB.TextBox email 
      Height          =   285
      Left            =   3480
      TabIndex        =   8
      Top             =   5040
      Width           =   2415
   End
   Begin VB.TextBox SERVERIP 
      Height          =   285
      Left            =   12000
      TabIndex        =   7
      Top             =   7560
      Visible         =   0   'False
      Width           =   1575
   End
   Begin VB.TextBox NameTxt 
      Height          =   285
      Left            =   3480
      TabIndex        =   2
      Top             =   4080
      Width           =   2415
   End
   Begin VB.TextBox PasswordTxt 
      Height          =   285
      IMEMode         =   3  'DISABLE
      Left            =   3480
      PasswordChar    =   "*"
      TabIndex        =   1
      Top             =   4560
      Width           =   2415
   End
   Begin VB.TextBox Porttxt 
      Height          =   285
      Left            =   12000
      TabIndex        =   0
      Text            =   "7777"
      Top             =   8880
      Visible         =   0   'False
      Width           =   1695
   End
   Begin InetCtlsObjects.Inet Inet 
      Left            =   0
      Top             =   0
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      Protocol        =   4
   End
   Begin MediaPlayerCtl.MediaPlayer MP3Player 
      Height          =   375
      Left            =   0
      TabIndex        =   10
      Top             =   0
      Visible         =   0   'False
      Width           =   495
      AudioStream     =   -1
      AutoSize        =   0   'False
      AutoStart       =   -1  'True
      AnimationAtStart=   -1  'True
      AllowScan       =   -1  'True
      AllowChangeDisplaySize=   -1  'True
      AutoRewind      =   0   'False
      Balance         =   0
      BaseURL         =   ""
      BufferingTime   =   5
      CaptioningID    =   ""
      ClickToPlay     =   -1  'True
      CursorType      =   0
      CurrentPosition =   -1
      CurrentMarker   =   0
      DefaultFrame    =   ""
      DisplayBackColor=   0
      DisplayForeColor=   16777215
      DisplayMode     =   0
      DisplaySize     =   4
      Enabled         =   -1  'True
      EnableContextMenu=   -1  'True
      EnablePositionControls=   -1  'True
      EnableFullScreenControls=   0   'False
      EnableTracker   =   -1  'True
      Filename        =   ""
      InvokeURLs      =   -1  'True
      Language        =   -1
      Mute            =   0   'False
      PlayCount       =   1
      PreviewMode     =   0   'False
      Rate            =   1
      SAMILang        =   ""
      SAMIStyle       =   ""
      SAMIFileName    =   ""
      SelectionStart  =   -1
      SelectionEnd    =   -1
      SendOpenStateChangeEvents=   -1  'True
      SendWarningEvents=   -1  'True
      SendErrorEvents =   -1  'True
      SendKeyboardEvents=   0   'False
      SendMouseClickEvents=   0   'False
      SendMouseMoveEvents=   0   'False
      SendPlayStateChangeEvents=   -1  'True
      ShowCaptioning  =   0   'False
      ShowControls    =   -1  'True
      ShowAudioControls=   -1  'True
      ShowDisplay     =   0   'False
      ShowGotoBar     =   0   'False
      ShowPositionControls=   -1  'True
      ShowStatusBar   =   0   'False
      ShowTracker     =   -1  'True
      TransparentAtStart=   0   'False
      VideoBorderWidth=   0
      VideoBorderColor=   0
      VideoBorder3D   =   0   'False
      Volume          =   0
      WindowlessVideo =   0   'False
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "Your E-Mail Address:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1800
      TabIndex        =   9
      Top             =   5160
      Width           =   1575
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Character Name:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1800
      TabIndex        =   6
      Top             =   4200
      Width           =   1335
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Caption         =   "Character Password:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1800
      TabIndex        =   5
      Top             =   4680
      Width           =   1575
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "-Enter Character"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   15.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   1800
      TabIndex        =   4
      Top             =   2520
      Width           =   4095
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"Form7.frx":0000
      ForeColor       =   &H8000000E&
      Height          =   1095
      Left            =   1800
      TabIndex        =   3
      Top             =   3000
      Width           =   8295
   End
   Begin VB.Image Image1 
      Height          =   9120
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   12120
   End
End
Attribute VB_Name = "Form7"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()

On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
frmMain.Birds.Enabled = True


'update user info
UserName = NameTxt.Text
UserPassword = PasswordTxt.Text
UserServerIP = Address
UserPort = "7777"
UserBetaPass = "0"
UserTown = "CastleFall"
UserRace = CreateRace
UserClass = CreateClass
SpecSkill1 = CreateSpecSkill1
SpecSkill2 = CreateSpecSkill2
SpecSkill3 = CreateSpecSkill3


UserBody = 1
UserHead = 1
UserWeaponAnim = 2
UserShieldAnim = 2
UserGender = CreateGender
UserMail = email.Text
UserVersion = CreateVersion

If CheckUserData = True Then

    'FrmMain.Socket1.Close
    frmMain.Socket1.HostName = UserServerIP
    frmMain.Socket1.RemotePort = UserPort

    SendNewChar = True
    Form7.MousePointer = 11
    frmMain.Socket1.Connect
    
    End If
    
End Sub

Private Sub Command2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
homeselect.Show
Unload Me
End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)

On Error Resume Next

'Make Server IP and Port box visible
If KeyCode = vbKeyI And Shift = vbCtrlMask Then
    
    'Port
    Porttxt.Visible = True
    Label4.Visible = True
    
    'Server IP
    IPtxt.Text = Address
    IPtxt.Visible = True
    Label5.Visible = True
    
    KeyCode = 0
    Exit Sub
End If

End Sub

Private Sub Form_Load()

On Error Resume Next
Image1.Picture = LoadPicture(IniPath & "Grh\menu2.jpg")
End Sub

Private Sub Label4_Click()

    



End Sub

Private Sub Label6_Click()


End Sub

