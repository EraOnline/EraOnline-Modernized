VERSION 5.00
Object = "{22D6F304-B0F6-11D0-94AB-0080C74C7E95}#1.0#0"; "msdxm.ocx"
Object = "{33101C00-75C3-11CF-A8A0-444553540000}#1.0#0"; "CSWSK32.OCX"
Object = "{3B7C8863-D78F-101B-B9B5-04021C009402}#1.2#0"; "RICHTX32.OCX"
Object = "{C1A8AF28-1257-101B-8FB0-0020AF039CA3}#1.1#0"; "MCI32.OCX"
Begin VB.Form frmMain 
   BackColor       =   &H00004080&
   BorderStyle     =   0  'None
   ClientHeight    =   9000
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12000
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "Times New Roman"
      Size            =   15.75
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H0000FFFF&
   Icon            =   "frmMain.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   600
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   800
   Visible         =   0   'False
   WindowState     =   2  'Maximized
   Begin SocketWrenchCtrl.Socket Socket1 
      Left            =   13110
      Top             =   3450
      _Version        =   65536
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   0
      AutoResolve     =   0   'False
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
   Begin VB.Timer DoSkill 
      Enabled         =   0   'False
      Interval        =   5000
      Left            =   10920
      Top             =   1200
   End
   Begin VB.Timer Birds 
      Enabled         =   0   'False
      Interval        =   10000
      Left            =   10440
      Top             =   1200
   End
   Begin VB.Timer Criminal 
      Interval        =   60000
      Left            =   9960
      Top             =   1200
   End
   Begin VB.Timer CheckClick 
      Interval        =   900
      Left            =   9480
      Top             =   1200
   End
   Begin VB.Timer CheckRain 
      Interval        =   30000
      Left            =   9000
      Top             =   1200
   End
   Begin VB.TextBox SendTxt 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   285
      Left            =   120
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   3
      TabStop         =   0   'False
      Top             =   6720
      Width           =   11775
   End
   Begin RichTextLib.RichTextBox RecTxt 
      Height          =   1755
      Left            =   120
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   7080
      Width           =   11775
      _ExtentX        =   20770
      _ExtentY        =   3096
      _Version        =   393217
      BackColor       =   16512
      Enabled         =   -1  'True
      ReadOnly        =   -1  'True
      DisableNoScroll =   -1  'True
      TextRTF         =   $"frmMain.frx":0BC2
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin VB.Timer Thunder 
      Interval        =   20000
      Left            =   10920
      Top             =   720
   End
   Begin VB.Timer Meditate 
      Enabled         =   0   'False
      Interval        =   10000
      Left            =   10440
      Top             =   720
   End
   Begin VB.Timer EatDrink 
      Interval        =   15000
      Left            =   9960
      Top             =   720
   End
   Begin VB.Timer NPCattack 
      Enabled         =   0   'False
      Interval        =   4000
      Left            =   9480
      Top             =   720
   End
   Begin VB.Timer Attack 
      Interval        =   4000
      Left            =   9000
      Top             =   720
   End
   Begin VB.Timer Campfire 
      Enabled         =   0   'False
      Interval        =   10000
      Left            =   11400
      Top             =   720
   End
   Begin VB.Timer FPSTimer 
      Interval        =   1000
      Left            =   12120
      Top             =   3480
   End
   Begin MCI.MMControl MidiPlayer 
      Height          =   420
      Left            =   0
      TabIndex        =   11
      Top             =   0
      Visible         =   0   'False
      Width           =   420
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
      PrevVisible     =   0   'False
      NextVisible     =   0   'False
      PauseVisible    =   0   'False
      BackVisible     =   0   'False
      StepVisible     =   0   'False
      StopVisible     =   0   'False
      RecordVisible   =   0   'False
      EjectVisible    =   0   'False
      DeviceType      =   "Sequencer"
      FileName        =   ""
   End
   Begin MediaPlayerCtl.MediaPlayer MP3Player 
      Height          =   375
      Left            =   480
      TabIndex        =   15
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
   Begin VB.Image cancelaction 
      Height          =   300
      Left            =   180
      Picture         =   "frmMain.frx":0C3E
      Stretch         =   -1  'True
      Top             =   5160
      Visible         =   0   'False
      Width           =   750
   End
   Begin VB.Label experience 
      Alignment       =   2  'Center
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "1"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   285
      Left            =   120
      TabIndex        =   14
      ToolTipText     =   "This shows how much experience before you are upgraded (raise stats, give more training points etc.)"
      Top             =   4800
      Width           =   855
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "Experience:"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   120
      TabIndex        =   13
      ToolTipText     =   "This shows how much experience before you are upgraded (raise stats, give more training points etc.)"
      Top             =   4560
      Width           =   1215
   End
   Begin VB.Label percentage 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "1"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   4560
      TabIndex        =   12
      Top             =   480
      Visible         =   0   'False
      Width           =   3015
   End
   Begin VB.Shape percentbox 
      BorderWidth     =   5
      Height          =   255
      Left            =   4560
      Top             =   480
      Visible         =   0   'False
      Width           =   3000
   End
   Begin VB.Shape ActionComplete 
      BackColor       =   &H00FF0000&
      BackStyle       =   1  'Opaque
      Height          =   210
      Left            =   4560
      Top             =   480
      Visible         =   0   'False
      Width           =   15
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "Get"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   360
      TabIndex        =   10
      Top             =   5880
      Width           =   495
   End
   Begin VB.Image Image2 
      Height          =   480
      Left            =   240
      Picture         =   "frmMain.frx":170E
      ToolTipText     =   "Pick Up Object Your Standing On"
      Top             =   5520
      Width           =   480
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Height          =   975
      Left            =   11040
      TabIndex        =   9
      Top             =   1440
      Width           =   735
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Height          =   1095
      Left            =   11160
      TabIndex        =   8
      Top             =   3480
      Width           =   615
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Height          =   735
      Left            =   11160
      TabIndex        =   7
      Top             =   2520
      Width           =   495
   End
   Begin VB.Shape MainViewShp 
      Height          =   5280
      Left            =   1200
      Top             =   1200
      Width           =   9600
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "H S M"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   6
      ToolTipText     =   "Health, Stamina, Mana"
      Top             =   3600
      Width           =   735
   End
   Begin VB.Label TargetMessage 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   6480
      Width           =   11775
   End
   Begin VB.Shape HPShp 
      BackColor       =   &H000000FF&
      BackStyle       =   1  'Opaque
      BorderStyle     =   0  'Transparent
      Height          =   2250
      Left            =   240
      Top             =   1320
      Width           =   165
   End
   Begin VB.Label GldLbl 
      Alignment       =   2  'Center
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "1"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   285
      Left            =   120
      TabIndex        =   2
      ToolTipText     =   "How much gold you possess"
      Top             =   4200
      Width           =   855
   End
   Begin VB.Shape MANShp 
      BackColor       =   &H00FFFF00&
      BackStyle       =   1  'Opaque
      BorderStyle     =   0  'Transparent
      Height          =   2250
      Left            =   720
      Top             =   1320
      Width           =   165
   End
   Begin VB.Shape STAShp 
      BackColor       =   &H00FF0000&
      BackStyle       =   1  'Opaque
      BorderStyle     =   0  'Transparent
      Height          =   2250
      Left            =   480
      Top             =   1320
      Width           =   165
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Gold:"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   360
      TabIndex        =   1
      ToolTipText     =   "How much gold you possess"
      Top             =   3960
      Width           =   495
   End
   Begin VB.Image Image1 
      Height          =   495
      Left            =   -3480
      Picture         =   "frmMain.frx":1A18
      Stretch         =   -1  'True
      Top             =   4800
      Width           =   1890
   End
   Begin VB.Image Image3 
      Height          =   615
      Left            =   -3480
      Picture         =   "frmMain.frx":24CE
      Stretch         =   -1  'True
      Top             =   4200
      Width           =   1890
   End
   Begin VB.Image Image4 
      Height          =   495
      Left            =   -3480
      Picture         =   "frmMain.frx":2FB5
      Stretch         =   -1  'True
      Top             =   5400
      Width           =   1890
   End
   Begin VB.Label MapNameLbl 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   1  'Fixed Single
      ForeColor       =   &H00000000&
      Height          =   345
      Left            =   12120
      TabIndex        =   0
      Top             =   3060
      Width           =   3285
   End
   Begin VB.Image Image6 
      Height          =   2535
      Left            =   -120
      Picture         =   "frmMain.frx":883F
      Stretch         =   -1  'True
      Top             =   6480
      Width           =   12120
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Private Sub DropCmd_Click()
On Error Resume Next

'Send the drop command
If inventory.ObjLst.ListIndex > -1 Then
    SendData "DRP" & inventory.ObjLst.ListIndex + 1 & "," & inventory.DrpAmountTxt.Text
End If

End Sub

Private Sub DrpAmountTxt_Change()
On Error Resume Next

'Make sure amount is legal
If inventory.DrpAmountTxt.Text < 1 Then
    inventory.DrpAmountTxt.Text = MAX_INVENTORY_OBJS
End If

If inventory.DrpAmountTxt.Text > MAX_INVENTORY_OBJS Then
    inventory.DrpAmountTxt.Text = 1
End If

End Sub


Private Sub Attack_Timer()
UserCanAttack = 1
End Sub

Private Sub Birds_Timer()
On Error Resume Next

Dim Sing As Integer

'make sure not raining
If Raining = 1 Then
Exit Sub
End If


Sing = RandomNumber(1, 6)

If Sing = 2 Then Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 59 & ".wav")
If Sing = 3 Then Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 44 & ".wav")
If Sing = 4 Then Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 60 & ".wav")

End Sub

Private Sub Campfire_Timer()
On Error Resume Next
SendData "CMP"
End Sub

Private Sub ClearScreen_Timer()


End Sub

Private Sub cancelaction_Click()
On Error Resume Next
ActionComplete.Width = 1
ActionComplete.Visible = False
percentbox.Visible = False
percentage.Visible = False
WhatJob = 0
SkillTime = 0
Working = 0
DoSkill.Enabled = False
frmMain.cancelaction.Visible = False

SendData "STP"


End Sub

Private Sub CheckClick_Timer()
On Error Resume Next
AllowClick = 1
End Sub

Private Sub CheckRain_Timer()
On Error Resume Next

'Dont substract stamina if on floor 5 (in house)
If MapData(UserPos.x, UserPos.y).graphic(1).GrhIndex = 5 And UserCanAttack = 1 Then
Exit Sub
End If

'Dont substract stamina if on floor 75 (in house)
If MapData(UserPos.x, UserPos.y).graphic(1).GrhIndex = 75 And UserCanAttack = 1 Then
Exit Sub
End If

'Dont substract stamina if on floor 47 (in house)
If MapData(UserPos.x, UserPos.y).graphic(1).GrhIndex = 47 And UserCanAttack = 1 Then
Exit Sub
End If

'Substract stamina if raining and not in house...
If Raining = 1 Then
SendData "STA"
End If


End Sub

Private Sub Command1_Click()

  End Sub

Private Sub Criminal_Timer()

On Error Resume Next

If UserCriminal < 2 Then Exit Sub

If CriminalCount < 1 Then
SendData "CRM"
Else
CriminalCount = CriminalCount - 1
End If

End Sub

Private Sub DoSkill_Timer()
On Error Resume Next
Dim TameSentence As Integer

'Make sure player is working
If Working = 0 Then
DoSkill.Enabled = False
Exit Sub
End If

'Check to see if make any sounds
If WhatJob = 2 Then SendData "PLY" & 40
If WhatJob = 3 Then SendData "PLY" & 12
If WhatJob = 4 Then SendData "PLY" & 26
If WhatJob = 5 Then SendData "PLY" & 28
If WhatJob = 7 Then SendData "PLY" & 5
If WhatJob = 8 Then SendData "PLY" & 28
If WhatJob = 9 Then SendData "PLY" & 26
If WhatJob = 10 Then SendData "PLY" & 12
If WhatJob = 15 Then SendData "PLY" & 28

'If taming, do some fun sentences
If WhatJob = 14 Then
TameSentence = RandomNumber(1, 4)
If TameSentence = 1 Then AddtoRichTextBox frmMain.RecTxt, UserName & ":Will you be my friend?", 0, 255, 0, 0, 0
If TameSentence = 2 Then AddtoRichTextBox frmMain.RecTxt, UserName & ":I won't try to hurt you!", 0, 255, 0, 0, 0
If TameSentence = 3 Then AddtoRichTextBox frmMain.RecTxt, UserName & ":I will treat you real nice!", 0, 255, 0, 0, 0
If TameSentence = 4 Then AddtoRichTextBox frmMain.RecTxt, UserName & ":You are safe with me.", 0, 255, 0, 0, 0
End If


ActionComplete.Width = ActionComplete.Width + SkillTime
percentage.Caption = ActionComplete.Width / 2

'Check to see if finished first
If ActionComplete.Width > 199 Then
SendData "XBX" & WhatJob
ActionComplete.Width = 1
ActionComplete.Visible = False
percentbox.Visible = False
percentage.Visible = False
WhatJob = 0
SkillTime = 0
Working = 0
DoSkill.Enabled = False
frmMain.cancelaction.Visible = False
Exit Sub
End If

If ActionComplete.Width > 200 Then ActionComplete.Width = 200

End Sub

Private Sub EatDrink_Timer()
On Error Resume Next
If UserDrink > 0 Then
SendData "DRN"
End If

If UserFood > 0 Then
SendData "EAT"
End If


End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
On Error Resume Next

If KeyCode = vbKeyEscape Then
Form1.Show
End If

If KeyCode = vbKeyF2 Then
MP3Player.Stop
If Voices = 0 Then MP3Player.FileName = IniPath & "sound\mp14.mp3"
If Voices = 0 Then MP3Player.Play

End If

If KeyCode = vbKeyControl Then
SendData "BTL"
End If


If KeyCode = vbKeyTab Then
SendData "COO"
End If


End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
On Error Resume Next

'If a letter,number,or backspace key send it to the sendtxt box
If KeyAscii >= 32 And KeyAscii <= 126 Or KeyAscii = 8 Then
    SendTxt.SetFocus
    Exit Sub
End If

End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
On Error Resume Next

'Attack key
If KeyCode = 18 And UserCanAttack = 1 Then
    SendData "ATT"
    KeyCode = 0
    UserCanAttack = 0
    Exit Sub
End If

End Sub
Private Sub Form_Load()
On Error Resume Next
frmMain.Picture = LoadPicture(IniPath & "Grh\interface.jpg")
Image6.Picture = LoadPicture(IniPath & "Grh\bottomface.jpg")
Campfire.Interval = 10000
Campfire.Interval = 10000
Attack.Interval = 4000
NPCattack.Interval = 4000
EatDrink.Interval = 15000
Meditate.Interval = 10000
Thunder.Interval = 20000
CheckRain.Interval = 65000
CheckClick.Interval = 900
Criminal.Interval = 60000
Birds.Interval = 10000
DoSkill.Interval = 5000

End Sub

Private Sub Form_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)

On Error Resume Next

'*****************************************************************
'See if user is clicking in the view window then send
'the tile click position to the server
'*****************************************************************
Dim tX As Integer
Dim tY As Integer

'Check to see if spam
If AllowClick = 0 Then
Exit Sub
End If

AllowClick = 0


'Make sure engine is running
If EngineRun = False Then Exit Sub

'Make sure click is in view window
If x <= MainViewShp.Left Or x >= MainViewShp.Left + MainViewWidth Or y <= MainViewShp.Top Or y >= MainViewShp.Top + MainViewHeight Then
    Exit Sub
End If

ConvertCPtoTP x, y, tX, tY

If Button = vbLeftButton Then
    SendData "LC" & tX & "," & tY
Else
    SendData "RC" & tX & "," & tY
End If


'Msgboard
If MapData(tX, tY).graphic(2).GrhIndex = 772 Then
SendData "BOO" & 1
End If

'Info board
If MapData(tX, tY).graphic(2).GrhIndex = 780 Then
If CurMap = 81 Then
info.Show
info.Picture = LoadPicture(IniPath & "Grh\cfwelcome.jpg")
End If
If CurMap = 22 Then
info.Show
info.Picture = LoadPicture(IniPath & "Grh\dwelcome.jpg")
End If
If CurMap = 189 Then
info.Show
info.Picture = LoadPicture(IniPath & "Grh\ugwelcome.jpg")
End If
If CurMap = 155 Then
info.Show
info.Picture = LoadPicture(IniPath & "Grh\vawelcome.jpg")
End If
End If

'Water
If MapData(tX, tY).graphic(1).GrhIndex = 3500 And UserCanAttack = 1 Then
SendData "FSH"
UserCanAttack = 0
End If

'Water
If MapData(tX, tY).graphic(2).GrhIndex = 3500 And UserCanAttack = 1 Then
SendData "FSH"
UserCanAttack = 0
End If

'Rock
If MapData(tX, tY).graphic(2).GrhIndex = 19 And UserCanAttack = 1 Then
SendData "MIN"
UserCanAttack = 0
End If

'Cliff
If MapData(tX, tY).graphic(1).GrhIndex = 115 And UserCanAttack = 1 Then
SendData "MIN"
UserCanAttack = 0
End If

'Cliff
If MapData(tX, tY).graphic(2).GrhIndex = 115 And UserCanAttack = 1 Then
SendData "MIN"
UserCanAttack = 0
End If

'Trees
If MapData(tX, tY).graphic(2).GrhIndex = 17 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 78 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 79 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 80 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 81 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 82 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 83 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 84 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 85 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 86 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 124 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 125 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 196 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 197 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

If MapData(tX, tY).graphic(2).GrhIndex = 193 And UserCanAttack = 1 Then
SendData "CHP" 'Send to server to start chopping
UserCanAttack = 0
End If

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
On Error Resume Next

'Allow the MainLoop to close program
If prgRun = True Then
    prgRun = False
    Cancel = 1
End If

End Sub

Private Sub FPSTimer_Timer()
On Error Resume Next

'Display and reset FPS
FramesPerSec = FramesPerSecCounter
FramesPerSecCounter = 0

End Sub









Private Sub MainPic_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)

End Sub




Private Sub GetCmd_Click()
On Error Resume Next

'Send the get command
SendData "GET"

End Sub

Private Sub Image7_Click()


End Sub

Private Sub Image8_Click()

End Sub

Private Sub Image9_Click()

End Sub

Private Sub Image2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
'Send the get command
SendData "GET"
End Sub

Private Sub Image5_Click()
On Error Resume Next
skills.Show

End Sub

Private Sub Label4_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
SendData "UPS"
spellbook.Show

End Sub

Private Sub Label5_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
skills.Show

End Sub

Private Sub Label6_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
SendData "UCS"
inventory.Show
End Sub

Private Sub Label7_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
'Send the get command
SendData "GET"
End Sub

Private Sub Label8_Click()


End Sub

Private Sub Meditate_Timer()
On Error Resume Next

SendData "REG"

End Sub

Private Sub MidiPlayer_StatusUpdate()
On Error Resume Next

'LSee if MIDI is done
If MidiPlayer.Length = MidiPlayer.Position Then
        
    'Loop if needed
    If LoopMidi Then
        Call PlayMidi(CurMidi)
    End If

End If

End Sub


Private Sub NPCattack_Timer()
On Error Resume Next
SendData "AT4"
End Sub

Private Sub Rectxt_KeyDown(KeyCode As Integer, Shift As Integer)

On Error Resume Next
If KeyCode = vbKeyEscape Then
Form1.Show
End If

End Sub

Private Sub SendTxt_Change()
On Error Resume Next
stxtbuffer = SendTxt.Text
End Sub

Private Sub SendTxt_KeyDown(KeyCode As Integer, Shift As Integer)
On Error Resume Next
If KeyCode = vbKeyEscape Then
Form1.Show
End If

End Sub

Private Sub SendTxt_KeyPress(KeyAscii As Integer)
On Error Resume Next

'BackSpace
If KeyAscii = 8 Then
    Exit Sub
End If

'Every other letter
If KeyAscii >= 32 And KeyAscii <= 126 Then
    Exit Sub
End If

KeyAscii = 0

End Sub


Private Sub SendTxt_KeyUp(KeyCode As Integer, Shift As Integer)
On Error Resume Next

Dim retcode As Integer

'Send text
If KeyCode = vbKeyReturn Then

    'Command
    If UCase(stxtbuffer) = "/MIDIOFF" Then
        retcode = mciSendString("close all", 0, 0, 0)
        LoopMidi = 0
        
    ElseIf Left$(stxtbuffer, 1) = "/" Then
        SendData (stxtbuffer)

    'yell
    ElseIf Left$(stxtbuffer, 1) = "'" Then
        SendData ("'" & Right$(stxtbuffer, Len(stxtbuffer) - 1))
    
    'Shout
    ElseIf Left$(stxtbuffer, 1) = "-" Then
        SendData ("-" & Right$(stxtbuffer, Len(stxtbuffer) - 1))

    'Whisper
    ElseIf Left$(stxtbuffer, 1) = "\" Then
        SendData ("\" & Right$(stxtbuffer, Len(stxtbuffer) - 1))

    'Emote
    ElseIf Left$(stxtbuffer, 1) = ":" Then
        SendData (":" & Right$(stxtbuffer, Len(stxtbuffer) - 1))

    'Say
    ElseIf stxtbuffer <> "" Then
        SendData (";" & stxtbuffer)

    End If

    stxtbuffer = ""
    SendTxt.Text = ""
    KeyCode = 0
    Exit Sub

End If

End Sub

Private Sub Socket1_Connect()
On Error Resume Next

loading.Show
Call Login
Call SetConnected

End Sub


Private Sub Socket1_Disconnect()
On Error Resume Next

prgRun = False
Connected = False

End Sub

Private Sub Socket1_LastError(ErrorCode As Integer, ErrorString As String, Response As Integer)
'*********************************************
'Handle socket errors
'*********************************************

Select Case (ErrorCode)

Case 24065
    MsgBox "The server seems to be down or unreachable. Please try again."
    End
    Response = 0
    
Case 24061
    MsgBox "The server seems to be down or unreachable. Please try again."
    End
    Response = 0
    
Case 24064
    MsgBox "The server seems to be down or unreachable. Please try again."
    End
    Response = 0
    
Case Else
    MsgBox (ErrorString)
    End

End Select


End Sub

Private Sub Socket1_Read(DataLength As Integer, IsUrgent As Integer)
'*********************************************
'Seperate lines by ENDC and send each to HandleData()
'*********************************************
On Error Resume Next

Dim LoopC As Integer

Dim RD As String
Dim rBuffer(1 To 500) As String
Static TempString As String

Dim CR As Integer
Dim tChar As String
Dim sChar As Integer
Dim eChar As Integer

Socket1.Read RD, DataLength

'Check for previous broken data and add to current data
If TempString <> "" Then
    RD = TempString & RD
    TempString = ""
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
    TempString = Mid$(RD, sChar, Len(RD))
End If

'Send buffer to Handle data
For LoopC = 1 To CR
    Call HandleData(rBuffer(LoopC))
Next LoopC

End Sub


Private Sub UseCmd_Click()
On Error Resume Next

'Send use command
If inventory.ObjLst.ListIndex > -1 Then
    SendData "USE" & inventory.ObjLst.ListIndex + 1
End If

End Sub


Private Sub Thunder_Timer()

On Error Resume Next

If Raining = 1 Then
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 43 & ".wav")
End If

End Sub
