VERSION 5.00
Begin VB.Form frmCreation_Part1 
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
   Begin VB.CommandButton cmd_Continue 
      Caption         =   "Continue ->"
      Default         =   -1  'True
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   9120
      TabIndex        =   2
      Top             =   5910
      Width           =   1395
   End
   Begin VB.CommandButton cmd_Back 
      Caption         =   "<- Back"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   7680
      TabIndex        =   1
      Top             =   5910
      Width           =   1395
   End
   Begin VB.ComboBox cmbRace 
      BackColor       =   &H00808080&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "frmCreation_Part1.frx":0000
      Left            =   4080
      List            =   "frmCreation_Part1.frx":0010
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   3990
      Width           =   3495
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   $"frmCreation_Part1.frx":0036
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   855
      Left            =   1920
      TabIndex        =   5
      Top             =   4680
      Width           =   8415
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"frmCreation_Part1.frx":015E
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   765
      Left            =   1920
      TabIndex        =   4
      Top             =   3000
      Width           =   8295
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Character Creation"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   14.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   1920
      TabIndex        =   3
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
Attribute VB_Name = "frmCreation_Part1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmbRace_Click()
On Error Resume Next
If cmbRace.Text = "Wood Elf" Then Label3 = "Wood Elves hail from the forests of Menath. Their skills in surviving in the wilderness are perfect and they are therefore proficient in hunting, fishing and other skills of natural survival. Wood Elves are also known to be good at hiding. They are the most common of the elves in Menath."
If cmbRace.Text = "Dark Elf" Then Label3 = "DDark Elves hail from the rocky south of the Elfin continent. They are good fighters but specialize mostly in the art of deception. Many Dark Elves choose a questionable career such as that of the assassin."
If cmbRace.Text = "Human" Then Label3 = "Humans hail from all of Menath. They are the dominating race and very flexible in all skills. However they dominate in no particular skills. Human's are charismatic and make excellent diplomats and Bards."
If cmbRace.Text = "Haaki" Then Label3 = "Haakis hail from the deserts in southern Menath. They are very primitive but are natural hunters and their culture is richer than most know. Haakis are excellent warriors."
End Sub

Private Sub cmd_Continue_Click()
On Error Resume Next

Call ButtonClick

If cmbRace.Text = "" Then
    MsgBox "You must select a race"
    Me.cmbRace.SetFocus
Else
    CreateRace = cmbRace.Text
    
    Select Case cmbRace.Text
        Case "Haaki"
            CreateHome = "Denc"
        Case "Human"
            CreateHome = "CastleFall"
        Case "Dark Elf"
            CreateHome = "Ug"
        Case "Wood Elf"
            CreateHome = "Valen"
    End Select
    frmCreation_Part2.Show
    Unload Me
End If
End Sub

Private Sub cmd_Back_Click()
On Error Resume Next

Call ButtonClick

frmMenu.Show
Unload Me
End Sub

Private Sub Form_Load()
On Error Resume Next

If CreateRace <> "" Then Me.cmbRace.Text = CreateRace
Image1.Picture = LoadPicture(IniPath & "Grh\menu2.jpg")
End Sub

