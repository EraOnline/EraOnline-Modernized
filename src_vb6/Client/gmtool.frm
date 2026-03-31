VERSION 5.00
Begin VB.Form gmtool 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   8970
   ClientLeft      =   1230
   ClientTop       =   15
   ClientWidth     =   8895
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8970
   ScaleWidth      =   8895
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton Command17 
      Caption         =   "Give yourself one more lock"
      Height          =   255
      Left            =   840
      TabIndex        =   37
      Top             =   4800
      Width           =   2895
   End
   Begin VB.CommandButton Command16 
      Caption         =   "OK"
      Height          =   195
      Left            =   4320
      TabIndex        =   36
      Top             =   6240
      Width           =   735
   End
   Begin VB.TextBox npcnavn 
      Height          =   285
      Left            =   4320
      TabIndex        =   35
      Top             =   5880
      Width           =   2895
   End
   Begin VB.CommandButton Command15 
      Caption         =   "OK"
      Height          =   195
      Left            =   840
      TabIndex        =   33
      Top             =   6240
      Width           =   735
   End
   Begin VB.TextBox hail 
      Height          =   285
      Left            =   840
      TabIndex        =   32
      Top             =   5880
      Width           =   2895
   End
   Begin VB.CommandButton Command14 
      Caption         =   "BAN AND KICK PLAYER"
      Height          =   255
      Left            =   840
      TabIndex        =   30
      Top             =   5280
      Width           =   2895
   End
   Begin VB.CommandButton Command13 
      Caption         =   "Turn Your Immortality From Players On"
      Height          =   255
      Left            =   840
      TabIndex        =   29
      Tag             =   "0"
      Top             =   4320
      Width           =   2895
   End
   Begin VB.CommandButton Command12 
      Caption         =   "HELP QUE"
      Height          =   255
      Left            =   840
      TabIndex        =   28
      Top             =   4560
      Width           =   2895
   End
   Begin VB.TextBox stamina 
      BeginProperty DataFormat 
         Type            =   1
         Format          =   "0"
         HaveTrueFalseNull=   0
         FirstDayOfWeek  =   0
         FirstWeekOfYear =   0
         LCID            =   1044
         SubFormatType   =   1
      EndProperty
      Height          =   285
      Left            =   2280
      TabIndex        =   26
      Top             =   2520
      Width           =   1815
   End
   Begin VB.TextBox mana 
      BeginProperty DataFormat 
         Type            =   1
         Format          =   "0"
         HaveTrueFalseNull=   0
         FirstDayOfWeek  =   0
         FirstWeekOfYear =   0
         LCID            =   1044
         SubFormatType   =   1
      EndProperty
      Height          =   285
      Left            =   2280
      TabIndex        =   25
      Top             =   2160
      Width           =   1815
   End
   Begin VB.TextBox hit 
      BeginProperty DataFormat 
         Type            =   1
         Format          =   "0"
         HaveTrueFalseNull=   0
         FirstDayOfWeek  =   0
         FirstWeekOfYear =   0
         LCID            =   1044
         SubFormatType   =   1
      EndProperty
      Height          =   285
      Left            =   2280
      TabIndex        =   24
      Top             =   1800
      Width           =   1815
   End
   Begin VB.TextBox health 
      BeginProperty DataFormat 
         Type            =   1
         Format          =   "0"
         HaveTrueFalseNull=   0
         FirstDayOfWeek  =   0
         FirstWeekOfYear =   0
         LCID            =   1044
         SubFormatType   =   1
      EndProperty
      Height          =   285
      Left            =   2280
      TabIndex        =   23
      Top             =   1440
      Width           =   1815
   End
   Begin VB.CommandButton Command9 
      Caption         =   "Apply Changes"
      Height          =   195
      Left            =   2280
      TabIndex        =   22
      Top             =   2880
      Width           =   1815
   End
   Begin VB.CommandButton Command11 
      Caption         =   "Give 100 experience to yourself"
      Height          =   255
      Left            =   840
      TabIndex        =   17
      Top             =   3120
      Width           =   2895
   End
   Begin VB.CommandButton Command7 
      Caption         =   "Ressurect Target"
      Height          =   255
      Left            =   840
      TabIndex        =   16
      Top             =   3360
      Width           =   2895
   End
   Begin VB.CommandButton Command10 
      Caption         =   "Polymorph Yourself"
      Height          =   255
      Left            =   840
      TabIndex        =   15
      Top             =   3600
      Width           =   2895
   End
   Begin VB.CommandButton Command8 
      Caption         =   "Give Yourself 1000 gold"
      Height          =   255
      Left            =   840
      TabIndex        =   14
      Top             =   3840
      Width           =   2895
   End
   Begin VB.CommandButton Command2 
      Caption         =   "TELEPORT TO GM MEETING PLACE"
      Height          =   255
      Left            =   840
      TabIndex        =   13
      Top             =   4080
      Width           =   2895
   End
   Begin VB.TextBox obj 
      Height          =   285
      Left            =   1680
      TabIndex        =   12
      Top             =   6840
      Width           =   1095
   End
   Begin VB.TextBox y 
      Height          =   285
      Left            =   3000
      TabIndex        =   9
      Top             =   8160
      Width           =   735
   End
   Begin VB.TextBox x 
      Height          =   285
      Left            =   1800
      TabIndex        =   8
      Top             =   8160
      Width           =   735
   End
   Begin VB.TextBox map 
      Height          =   285
      Left            =   600
      TabIndex        =   7
      Top             =   8160
      Width           =   735
   End
   Begin VB.CommandButton Command5 
      Caption         =   "TELEPORT TARGET"
      Height          =   255
      Left            =   1080
      TabIndex        =   5
      Top             =   8520
      Width           =   2295
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Close GM Tool"
      Height          =   255
      Left            =   6120
      TabIndex        =   4
      Top             =   360
      Width           =   2655
   End
   Begin VB.CommandButton Command6 
      Caption         =   "CREATE OBJECT"
      Height          =   255
      Left            =   960
      TabIndex        =   3
      Top             =   7200
      Width           =   2535
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Do you need help with this tool ?"
      Height          =   375
      Left            =   840
      TabIndex        =   2
      Top             =   720
      Width           =   2895
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Get List Of GM Commands"
      Height          =   375
      Left            =   840
      TabIndex        =   1
      Top             =   360
      Width           =   2895
   End
   Begin VB.Line Line1 
      BorderColor     =   &H80000009&
      X1              =   4200
      X2              =   8760
      Y1              =   6480
      Y2              =   6480
   End
   Begin VB.Label Label11 
      BackStyle       =   0  'Transparent
      Caption         =   "Change  targeted NPC's name:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   4320
      TabIndex        =   34
      Top             =   5640
      Width           =   4215
   End
   Begin VB.Shape Shape4 
      BorderColor     =   &H80000005&
      Height          =   3255
      Left            =   4200
      Top             =   5640
      Width           =   4575
   End
   Begin VB.Shape Shape3 
      BorderColor     =   &H80000005&
      Height          =   855
      Left            =   360
      Top             =   5640
      Width           =   3735
   End
   Begin VB.Shape Shape2 
      BorderColor     =   &H80000005&
      Height          =   1095
      Left            =   360
      Top             =   6480
      Width           =   3735
   End
   Begin VB.Shape Shape1 
      BorderColor     =   &H80000005&
      Height          =   1335
      Left            =   360
      Top             =   7560
      Width           =   3735
   End
   Begin VB.Label Label10 
      BackStyle       =   0  'Transparent
      Caption         =   "Change targeted NPC`s hailing message:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   840
      TabIndex        =   31
      Top             =   5640
      Width           =   3255
   End
   Begin VB.Label Label9 
      BackStyle       =   0  'Transparent
      Caption         =   "Change Target Stats:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1440
      TabIndex        =   27
      Top             =   1080
      Width           =   1575
   End
   Begin VB.Label Label8 
      BackStyle       =   0  'Transparent
      Caption         =   "Change Max Stamina to:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   21
      Top             =   2520
      Width           =   1815
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "Change Max Mana to:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   20
      Top             =   2160
      Width           =   1815
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Change Max Hit to:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   19
      Top             =   1800
      Width           =   1815
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Caption         =   "Change Max Health to:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   18
      Top             =   1440
      Width           =   2535
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   "Object Number:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1680
      TabIndex        =   11
      Top             =   6600
      Width           =   2535
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Teleport Coordinates:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1440
      TabIndex        =   10
      Top             =   7680
      Width           =   1575
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "MAP:                     X:                       Y:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   720
      TabIndex        =   6
      Top             =   7920
      Width           =   3255
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "GameMaster Tool"
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
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   4095
   End
   Begin VB.Image Image6 
      Height          =   9015
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   8895
   End
End
Attribute VB_Name = "gmtool"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me
Gmcommandlist.Show
End Sub

Private Sub Command10_Click()
On Error Resume Next

If AllowClick = 0 Then
AddtoRichTextBox frmMain.RecTxt, "Spam detected. Wait.", 0, 255, 0, 0, 0
Exit Sub
End If
AllowClick = 0

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
polymorph.Show
End Sub

Private Sub Command11_Click()
On Error Resume Next

If AllowClick = 0 Then
AddtoRichTextBox frmMain.RecTxt, "Spam detected. Wait.", 0, 255, 0, 0, 0
Exit Sub
End If
AllowClick = 0


Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
SendData "BOE"
End Sub

Private Sub Command12_Click()
On Error Resume Next

SendData "QUE"
gmque.Show


Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

End Sub

Private Sub Command13_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
If Command13.Tag = 0 Then
Command13.Caption = "Turn Immortality From Players Off"
Command13.Tag = 1
SendData "IMM"
Else
Command13.Caption = "Turn Immortality From Players On"
Command13.Tag = 0
SendData "MMM"
End If

End Sub

Private Sub Command14_Click()
On Error Resume Next

SendData "BAN"


End Sub

Private Sub Command15_Click()
On Error Resume Next
SendData "HAI" & hail.Text
End Sub

Private Sub Command16_Click()
On Error Resume Next
SendData "NAA" & npcnavn.Text
End Sub

Private Sub Command17_Click()
On Error Resume Next

If AllowClick = 0 Then
AddtoRichTextBox frmMain.RecTxt, "Spam detected. Wait.", 0, 255, 0, 0, 0
Exit Sub
End If
AllowClick = 0
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


SendData "GIL"
End Sub

Private Sub Command2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
SendData "TGM"
End Sub

Private Sub Command3_Click()
On Error Resume Next
Unload Me
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
End Sub

Private Sub Command4_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me
gmhelp.Show
End Sub

Private Sub Command5_Click()
On Error Resume Next
If map.Text = "" And x.Text = "" And y.Text = "" Then
MsgBox "First you must fill in the coordinates !"
Else
SendData "TEL" & map.Text & "," & x.Text & "," & y.Text
End If

End Sub

Private Sub Command6_Click()
On Error Resume Next

If AllowClick = 0 Then
AddtoRichTextBox frmMain.RecTxt, "Spam detected. Wait.", 0, 255, 0, 0, 0
Exit Sub
End If
AllowClick = 0

If obj.Text = "" Then
MsgBox "Fill in what object number you want to make !"
Else
SendData "CRE" & obj.Text
End If
End Sub

Private Sub Command7_Click()
On Error Resume Next

If AllowClick = 0 Then
AddtoRichTextBox frmMain.RecTxt, "Spam detected. Wait.", 0, 255, 0, 0, 0
Exit Sub
End If
AllowClick = 0

SendData "RET"
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
End Sub

Private Sub Command8_Click()
On Error Resume Next

If AllowClick = 0 Then
AddtoRichTextBox frmMain.RecTxt, "Spam detected. Wait.", 0, 255, 0, 0, 0
Exit Sub
End If
AllowClick = 0
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

SendData "GVG"
End Sub

Private Sub Command9_Click()
On Error Resume Next

If health.Text = "" Or stamina.Text = "" Or mana.Text = "" Or hit.Text = "" Then
MsgBox "Fill in all the blanks first."
Else
SendData "CH1" & health.Text
SendData "CH2" & mana.Text
SendData "CH3" & hit.Text
SendData "CH4" & stamina.Text

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
End If
End Sub

Private Sub Form_Load()
On Error Resume Next
Image6.Picture = LoadPicture(IniPath & "Grh\wood.bmp")

End Sub

