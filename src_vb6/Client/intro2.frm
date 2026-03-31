VERSION 5.00
Object = "{22D6F304-B0F6-11D0-94AB-0080C74C7E95}#1.0#0"; "MSDXM.OCX"
Begin VB.Form intro2 
   BackColor       =   &H80000007&
   BorderStyle     =   0  'None
   Caption         =   "Form6"
   ClientHeight    =   9000
   ClientLeft      =   1560
   ClientTop       =   1380
   ClientWidth     =   12000
   LinkTopic       =   "Form6"
   ScaleHeight     =   9000
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.Timer Timer1 
      Interval        =   5000
      Left            =   9120
      Top             =   4560
   End
   Begin MediaPlayerCtl.MediaPlayer MP3Player 
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   120
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
   Begin VB.Image Image1 
      Height          =   9015
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   12015
   End
End
Attribute VB_Name = "intro2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
On Error Resume Next
If KeyCode = vbKeyEscape Then
Form2.Show
Unload Me
End If


End Sub

Private Sub Form_Load()
On Error Resume Next

Image1.Picture = LoadPicture(IniPath & "Intro\present1.jpg")
intro2.Tag = 1
Timer1.Interval = 5000


CurMidi = IniPath & "music\" & "Mus" & 6 & ".mid"
LoopMidi = 1
Call PlayMidi(CurMidi)

End Sub

Private Sub Image1_Click()
On Error Resume Next
Timer1.Enabled = False
Unload Me
Form2.Show
End Sub

Private Sub Timer1_Timer()
On Error Resume Next
If intro2.Tag = 3 Then
Timer1.Enabled = False
intro1.Show
Unload Me
Else

intro2.Tag = intro2.Tag + 1
Image1.Picture = LoadPicture(IniPath & "Intro\" & "present" & intro2.Tag & ".jpg")
End If

End Sub
Private Sub MP3Player_EndOfStream(ByVal Result As Long)
On Error Resume Next
MP3Player.Play
End Sub
