VERSION 5.00
Object = "{22D6F304-B0F6-11D0-94AB-0080C74C7E95}#1.0#0"; "MSDXM.OCX"
Begin VB.Form Form1 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   3660
   ClientLeft      =   3645
   ClientTop       =   2040
   ClientWidth     =   4680
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3660
   ScaleWidth      =   4680
   Begin MediaPlayerCtl.MediaPlayer MP3Player 
      Height          =   375
      Left            =   0
      TabIndex        =   8
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
   Begin VB.Label musicon 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Turn Music Off"
      BeginProperty Font 
         Name            =   "Lucida Handwriting"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   -1  'True
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1200
      TabIndex        =   7
      Tag             =   "0"
      Top             =   2160
      Width           =   2295
   End
   Begin VB.Label Label7 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Quit Era Online"
      BeginProperty Font 
         Name            =   "Lucida Handwriting"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   -1  'True
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1200
      TabIndex        =   6
      Top             =   2520
      Width           =   2295
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Back To Game"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1680
      TabIndex        =   5
      Top             =   3120
      Width           =   1095
   End
   Begin VB.Label Label5 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   720
      Width           =   4575
   End
   Begin VB.Label Label4 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BorderStyle     =   1  'Fixed Single
      Caption         =   "CONTACT A GM"
      BeginProperty Font 
         Name            =   "Lucida Handwriting"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1200
      TabIndex        =   3
      Top             =   1800
      Width           =   2295
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BorderStyle     =   1  'Fixed Single
      Caption         =   "ERA WEB SITE"
      BeginProperty Font 
         Name            =   "Lucida Handwriting"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1200
      TabIndex        =   2
      Top             =   1440
      Width           =   2295
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BorderStyle     =   1  'Fixed Single
      Caption         =   "SERVER STATUS"
      BeginProperty Font 
         Name            =   "Lucida Handwriting"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1200
      TabIndex        =   1
      Top             =   1080
      Width           =   2295
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "GAME MENU:"
      BeginProperty Font 
         Name            =   "Lucida Handwriting"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   1080
      TabIndex        =   0
      Top             =   240
      Width           =   2775
   End
   Begin VB.Image Image1 
      Height          =   3735
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   4695
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub Form_Load()
On Error Resume Next
Image1.Picture = LoadPicture(IniPath & "Grh\stone.bmp")

End Sub

Private Sub Image1_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
On Error Resume Next
Label5 = ""
End Sub

Private Sub Label1_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
On Error Resume Next
Label5 = ""
End Sub

Private Sub Label2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
msgform.message = "Feature Not Implented Yet"
msgform.Show
End Sub

Private Sub Label2_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
Label5 = "For information about the server"

End Sub

Private Sub Label3_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
msgform.message = "www.eraonline.net"
msgform.Show
End Sub

Private Sub Label3_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
On Error Resume Next
Label5 = "Takes you directly to our web site"
End Sub

Private Sub Label4_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
gmcall.Show
End Sub

Private Sub Label4_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
On Error Resume Next
Label5 = "If you wish to speak to one of our game masters"
End Sub

Private Sub Label6_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me

End Sub

Private Sub Label6_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
On Error Resume Next
Label5 = "Click to go back to the world"
End Sub

Private Sub Label7_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
MP3Player.Stop
If Voices = 0 Then MP3Player.FileName = IniPath & "sound\mp1.mp3"
If Voices = 0 Then MP3Player.Play

Dim PauseTime, Start, Finish, TotalTime
   
   PauseTime = 5   ' Set duration.
   Start = Timer   ' Set start time.
   Do While Timer < Start + PauseTime
      DoEvents   ' Yield to other processes.
   Loop
   Finish = Timer   ' Set end time.
   TotalTime = Finish - Start   ' Calculate total time.
   
SendData "QIT"
RestoreRes

End Sub

Private Sub Label7_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
On Error Resume Next
Label5 = "If you wish to leave Era Online..."
End Sub

Private Sub Label8_Click()



End Sub

Private Sub musicon_Click()
On Error Resume Next

If MusicOnOff = 0 Then
musicon.Caption = "Turn Music On"
MusicOnOff = 1
retcode = mciSendString("close all", 0, 0, 0)
MP3Player.Stop
If Voices = 0 Then MP3Player.FileName = IniPath & "Sound\mp9.mp3"
If Voices = 0 Then MP3Player.Play
LoopMidi = 0
Else
musicon.Caption = "Turn Music Off"
MusicOnOff = 0
MP3Player.Stop
If Voices = 0 Then MP3Player.FileName = IniPath & "Sound\mp12.mp3"
If Voices = 0 Then MP3Player.Play
End If

End Sub

Private Sub musicon_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
On Error Resume Next
Label5 = "Turn Music ON/OFF"
End Sub
