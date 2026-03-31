VERSION 5.00
Begin VB.Form homeselect 
   BackColor       =   &H80000008&
   BorderStyle     =   0  'None
   ClientHeight    =   9000
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12000
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   ScaleHeight     =   9000
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.CommandButton Command2 
      Caption         =   "Back"
      Height          =   255
      Left            =   8160
      TabIndex        =   4
      Top             =   5640
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Continue"
      Height          =   255
      Left            =   9360
      TabIndex        =   3
      Top             =   5640
      Width           =   1095
   End
   Begin VB.ComboBox Home2 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000005&
      Height          =   315
      ItemData        =   "homeselect.frx":0000
      Left            =   4680
      List            =   "homeselect.frx":0007
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   3960
      Visible         =   0   'False
      Width           =   2175
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"homeselect.frx":0017
      ForeColor       =   &H8000000E&
      Height          =   1095
      Left            =   1560
      TabIndex        =   1
      Top             =   2880
      Width           =   8295
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "-Select Home"
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
      Left            =   1560
      TabIndex        =   0
      Top             =   2400
      Width           =   4095
   End
   Begin VB.Image Image1 
      Height          =   9120
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   12120
   End
End
Attribute VB_Name = "homeselect"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()

On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

Form7.Show
rolerules.Show
Unload Me

End Sub

Private Sub Command2_Click()
On Error Resume Next
Form4.Show
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
End Sub

Private Sub Form_Load()

On Error Resume Next

Image1.Picture = LoadPicture(IniPath & "Grh\menu2.jpg")
homeselect.Home2.Visible = True

End Sub

Private Sub Label4_Click()


End Sub

Private Sub Label6_Click()
End Sub

