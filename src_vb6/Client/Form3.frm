VERSION 5.00
Begin VB.Form Form3 
   BackColor       =   &H80000007&
   BorderStyle     =   0  'None
   ClientHeight    =   9000
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12000
   ControlBox      =   0   'False
   LinkTopic       =   "Form3"
   ScaleHeight     =   9000
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.CommandButton Command2 
      Caption         =   "Back"
      Height          =   255
      Left            =   8160
      TabIndex        =   5
      Top             =   5760
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Continue"
      Height          =   255
      Left            =   9360
      TabIndex        =   4
      Top             =   5760
      Width           =   1095
   End
   Begin VB.ComboBox Combo1 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "Form3.frx":0000
      Left            =   4080
      List            =   "Form3.frx":0010
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   3960
      Width           =   3495
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   $"Form3.frx":0036
      ForeColor       =   &H8000000E&
      Height          =   855
      Left            =   1920
      TabIndex        =   3
      Top             =   4680
      Width           =   8415
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"Form3.frx":0161
      ForeColor       =   &H8000000E&
      Height          =   1095
      Left            =   1920
      TabIndex        =   1
      Top             =   3000
      Width           =   8295
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "-Character Creation"
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
      Left            =   1920
      TabIndex        =   0
      Top             =   2520
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
Attribute VB_Name = "Form3"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub Combo1_Change()
On Error Resume Next
If Combo1.Text = "Wood Elf" Then Label3 = "Wood Elf`s hails from the woods of Menath. Their skills in surviving in wilderness is perfect and they are therefor specialized in hunting, fishing and other skills of nature survival. Wood Elf`s is also very known for be quite a good hider. Wood Elf`s are the most common elf in Menath."
If Combo1.Text = "Dark Elf" Then Label3 = "Dark Elf`s hails from the mountains in the north in Menath. They are good fighters but specialize most in the art of the thief. Many Dark Elf`s turn out to have assasinating or some other unrespecatble choice of career. "
If Combo1.Text = "Human" Then Label3 = "Humans hails from whole Menath. They are the superior race and very flexible in all skills. However they are not that specialized in any skills but they are very charismatic and excellent diplomats and bards."
If Combo1.Text = "Haaki" Then Label3 = "Haakis hails from the deserts in the south in Menath. They are very primitive but are excellent hunters and their culture is richer than you can imagine. Haakis are excellent warriors."

End Sub

Private Sub Combo1_Click()
On Error Resume Next
If Combo1.Text = "Wood Elf" Then Label3 = "Wood Elf`s hails from the woods of Menath. Their skills in surviving in wilderness is perfect and they are therefor specialized in hunting, fishing and other skills of nature survival. Wood Elf`s is also very known for be quite a good hider. Wood Elf`s are the most common elf in Menath."
If Combo1.Text = "Dark Elf" Then Label3 = "Dark Elf`s hails from the mountains in the north in Menath. They are good fighters but specialize most in the art of the thief. Many Dark Elf`s turn out to have assasinating or some other unrespecatble choice of career. "
If Combo1.Text = "Human" Then Label3 = "Humans hails from whole Menath. They are the superior race and very flexible in all skills. However they are not that specialized in any skills but they are very charismatic and excellent diplomats and bards."
If Combo1.Text = "Haaki" Then Label3 = "Haakis hails from the deserts in the south in Menath. They are very primitive but are excellent hunters and their culture is richer than you can imagine. Haakis are excellent warriors."
End Sub

Private Sub Command1_Click()

On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
If Combo1.Text = "" Then
MsgBox "You must select a race"
Else
CreateRace = Combo1.Text
Form5.Show
Unload Me
End If

End Sub

Private Sub Command2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Form2.Show
Unload Me
End Sub

Private Sub Form_Load()
On Error Resume Next
Image1.Picture = LoadPicture(IniPath & "Grh\menu2.jpg")
End Sub

Private Sub Label4_Click()

End Sub

Private Sub Label6_Click()

End Sub
