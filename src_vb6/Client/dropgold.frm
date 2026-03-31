VERSION 5.00
Begin VB.Form dropgold 
   BackColor       =   &H80000007&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   3210
   ClientLeft      =   3870
   ClientTop       =   2625
   ClientWidth     =   4620
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3210
   ScaleWidth      =   4620
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000003&
      ForeColor       =   &H80000005&
      Height          =   285
      Left            =   720
      TabIndex        =   1
      Top             =   1800
      Width           =   3135
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Never drop more than 30 000 gold at a time."
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   720
      TabIndex        =   3
      Top             =   960
      Width           =   3135
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "How much ?"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1080
      TabIndex        =   2
      Top             =   1560
      Width           =   2415
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Drop How Much Gold ?"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   960
      TabIndex        =   0
      Top             =   240
      Width           =   3015
   End
   Begin VB.Image Image4 
      Height          =   480
      Left            =   1800
      Picture         =   "dropgold.frx":0000
      Stretch         =   -1  'True
      Top             =   2400
      Width           =   1065
   End
   Begin VB.Image Image1 
      Height          =   3255
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   4695
   End
End
Attribute VB_Name = "dropgold"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
Image1.Picture = deposit.Image1.Picture
End Sub

Private Sub Image2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
If gold < UserGLD Then
gold = gold + 1
End If
End Sub

Private Sub Image3_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
If gold > 0 Then
gold = gold - 1
End If
End Sub

Private Sub Image4_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

On Error Resume Next


If UserGLD < Text1.Text Then
msgform.Show
msgform.message = "You do not have that much gold !"
Else
SendData "DRG" & Text1.Text
Unload Me
End If

End Sub
