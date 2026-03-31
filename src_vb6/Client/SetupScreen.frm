VERSION 5.00
Begin VB.Form SetupScreen 
   BackColor       =   &H80000007&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   4035
   ClientLeft      =   15
   ClientTop       =   15
   ClientWidth     =   5700
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4035
   ScaleWidth      =   5700
   StartUpPosition =   2  'CenterScreen
   Begin VB.Label Label7 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "TURN VOICES ON"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2040
      TabIndex        =   5
      Tag             =   "1"
      Top             =   2400
      Width           =   1575
   End
   Begin VB.Label Current 
      BackStyle       =   0  'Transparent
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   720
      TabIndex        =   4
      Top             =   3240
      Width           =   1695
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   "OK"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   4680
      TabIndex        =   3
      Top             =   3480
      Width           =   1095
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   $"SetupScreen.frx":0000
      ForeColor       =   &H8000000E&
      Height          =   855
      Left            =   120
      TabIndex        =   2
      Top             =   1200
      Width           =   5295
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "VOICES"
      ForeColor       =   &H8000000E&
      Height          =   735
      Left            =   120
      TabIndex        =   1
      Top             =   960
      Width           =   5415
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Setup"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   20.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   615
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   5295
   End
   Begin VB.Image Image6 
      Height          =   4215
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   5760
   End
End
Attribute VB_Name = "SetupScreen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
Image6.Picture = LoadPicture(IniPath & "Grh\wood.bmp")

End Sub

Private Sub Label4_Click()
On Error Resume Next
Unload Me

End Sub

Private Sub Label7_Click()
On Error Resume Next

If Label7.Tag = 0 Then
Label7.Tag = 1
Voices = 0
Label7 = "TURN VOICES OFF"
Else
Label7.Tag = 0
Voices = 1
Label7 = "TURN VOICES ON"
End If

End Sub
