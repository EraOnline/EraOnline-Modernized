VERSION 5.00
Object = "{22D6F304-B0F6-11D0-94AB-0080C74C7E95}#1.0#0"; "msdxm.ocx"
Begin VB.Form frmIntro_Part1 
   BackColor       =   &H80000008&
   ClientHeight    =   8880
   ClientLeft      =   1905
   ClientTop       =   1170
   ClientWidth     =   11880
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   ScaleHeight     =   8880
   ScaleWidth      =   11880
   Tag             =   "1"
   WindowState     =   2  'Maximized
   Begin VB.Timer Timer1 
      Interval        =   9999
      Left            =   120
      Top             =   600
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
      Height          =   8895
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   11895
   End
End
Attribute VB_Name = "frmIntro_Part1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
On Error Resume Next
If KeyCode = vbKeyEscape Then
frmMenu.Show
Unload Me
End If

End Sub

Private Sub Form_Load()
On Error Resume Next
frmIntro_Part1.Tag = 1
Image1.Picture = LoadPicture(IniPath & "Intro\1.jpg")
Timer1.Interval = 8500
MP3Player.Stop
If Voices = 0 Then MP3Player.FileName = IniPath & "Music\Undead.mp3"
If Voices = 0 Then MP3Player.Play
End Sub

Private Sub Image1_Click()
On Error Resume Next
Timer1.Enabled = False
Unload Me
frmMenu.Show

End Sub

Private Sub Timer1_Timer()
On Error Resume Next
If frmIntro_Part1.Tag = 4 Then
Timer1.Enabled = False
frmMenu.Show
Unload Me
Else

frmIntro_Part1.Tag = frmIntro_Part1.Tag + 1
Image1.Picture = LoadPicture(IniPath & "Intro\" & frmIntro_Part1.Tag & ".jpg")

End If

End Sub
