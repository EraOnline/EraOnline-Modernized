VERSION 5.00
Begin VB.Form frmSignup 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   0  'None
   Caption         =   "Form6"
   ClientHeight    =   9000
   ClientLeft      =   1485
   ClientTop       =   -1470
   ClientWidth     =   12000
   FillColor       =   &H00FFFFFF&
   BeginProperty Font 
      Name            =   "Verdana"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H00FFFFFF&
   LinkTopic       =   "Form6"
   Picture         =   "frmSignup.frx":0000
   ScaleHeight     =   9000
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox Picture1 
      BackColor       =   &H00C0C0C0&
      Height          =   3255
      Left            =   5220
      ScaleHeight     =   3195
      ScaleWidth      =   3870
      TabIndex        =   11
      Top             =   4200
      Width           =   3930
      Begin VB.OptionButton optGender 
         BackColor       =   &H00000000&
         Caption         =   "Female"
         ForeColor       =   &H00FFFFFF&
         Height          =   240
         Index           =   3
         Left            =   2130
         TabIndex        =   24
         Top             =   2790
         Width           =   1230
      End
      Begin VB.OptionButton optGender 
         Caption         =   "Male"
         ForeColor       =   &H00FFFFFF&
         Height          =   240
         Index           =   2
         Left            =   420
         TabIndex        =   23
         Top             =   2730
         Width           =   855
      End
      Begin VB.TextBox txtEmail 
         Height          =   285
         Left            =   1680
         TabIndex        =   15
         Top             =   1440
         Width           =   2055
      End
      Begin VB.TextBox txtLogin 
         Height          =   285
         Left            =   1680
         TabIndex        =   14
         Top             =   120
         Width           =   2055
      End
      Begin VB.TextBox txtPassword 
         Height          =   285
         IMEMode         =   3  'DISABLE
         Left            =   1680
         PasswordChar    =   "*"
         TabIndex        =   13
         Top             =   510
         Width           =   2055
      End
      Begin VB.TextBox txtPasswordConfirm 
         Height          =   285
         IMEMode         =   3  'DISABLE
         Left            =   1680
         PasswordChar    =   "*"
         TabIndex        =   12
         Top             =   900
         Width           =   2055
      End
      Begin VB.Label Label5 
         Caption         =   "Caracter Name:"
         ForeColor       =   &H00FFFFFF&
         Height          =   345
         Left            =   90
         TabIndex        =   20
         Top             =   150
         Width           =   1545
      End
      Begin VB.Label Label6 
         Caption         =   "Password:"
         ForeColor       =   &H00FFFFFF&
         Height          =   345
         Left            =   90
         TabIndex        =   19
         Top             =   540
         Width           =   1545
      End
      Begin VB.Label Label7 
         Caption         =   "Email adress:"
         ForeColor       =   &H00FFFFFF&
         Height          =   345
         Left            =   90
         TabIndex        =   18
         Top             =   1470
         Width           =   1545
      End
      Begin VB.Label Label8 
         Caption         =   "Password:              (confirm)"
         ForeColor       =   &H00FFFFFF&
         Height          =   465
         Left            =   90
         TabIndex        =   17
         Top             =   930
         Width           =   1545
      End
      Begin VB.Label Label9 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Character names must be of fantasy nature! Characters with names that is not fantasy related, may be deleted."
         ForeColor       =   &H8000000E&
         Height          =   1470
         Left            =   60
         TabIndex        =   16
         Top             =   1860
         Width           =   3765
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Race"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   2895
      Left            =   240
      TabIndex        =   4
      Top             =   5190
      Width           =   3930
      Begin VB.OptionButton obtRace 
         Caption         =   "Wood Elf"
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Index           =   3
         Left            =   1950
         TabIndex        =   9
         Top             =   720
         Width           =   1635
      End
      Begin VB.OptionButton obtRace 
         Caption         =   "Human"
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Index           =   2
         Left            =   330
         TabIndex        =   8
         Top             =   720
         Width           =   1635
      End
      Begin VB.OptionButton obtRace 
         Caption         =   "Haaki"
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Index           =   1
         Left            =   1950
         TabIndex        =   7
         Top             =   300
         Width           =   1635
      End
      Begin VB.OptionButton obtRace 
         Caption         =   "Dark Elf"
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Index           =   0
         Left            =   330
         TabIndex        =   6
         Top             =   300
         Width           =   1635
      End
      Begin VB.Label Label3 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   $"frmSignup.frx":AB92
         ForeColor       =   &H8000000E&
         Height          =   1470
         Left            =   90
         TabIndex        =   5
         Top             =   1350
         Width           =   3765
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Gender"
      ClipControls    =   0   'False
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   645
      Left            =   240
      TabIndex        =   3
      Top             =   4290
      Width           =   3930
      Begin VB.OptionButton optGender 
         Caption         =   "Male"
         ForeColor       =   &H00FFFFFF&
         Height          =   240
         Index           =   0
         Left            =   480
         TabIndex        =   22
         Top             =   240
         Width           =   855
      End
      Begin VB.OptionButton optGender 
         Caption         =   "Female"
         ForeColor       =   &H00FFFFFF&
         Height          =   240
         Index           =   1
         Left            =   2190
         TabIndex        =   21
         Top             =   270
         Width           =   1230
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Login Information"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   2715
      Left            =   240
      TabIndex        =   10
      Top             =   1410
      Width           =   3930
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   "Character Creation"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   15.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   45
      TabIndex        =   2
      Top             =   45
      Width           =   4095
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   $"frmSignup.frx":AC8B
      ForeColor       =   &H8000000E&
      Height          =   480
      Left            =   142
      TabIndex        =   1
      Top             =   495
      Width           =   12420
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   555
      Left            =   1650
      TabIndex        =   0
      Top             =   9660
      Width           =   9495
   End
End
Attribute VB_Name = "frmSignup"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
Set ShapeTheForm = New clsTransForm 'instantiate the object from the class

ShapeTheForm.ShapeMe Me.optGender(3), RGB(0, 0, 0) 'do the real work
'Me.Picture1.Refresh
End Sub

Private Sub Picture1_Paint()
  Me.Picture1.PaintPicture Me.Picture, 0, 0, Me.ScaleWidth, Me.ScaleHeight, Me.Picture1.Left, Me.Picture1.Top, Me.ScaleWidth, Me.ScaleHeight
End Sub
