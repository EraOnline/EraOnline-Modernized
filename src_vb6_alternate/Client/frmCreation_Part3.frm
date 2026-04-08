VERSION 5.00
Begin VB.Form frmCreation_Part3 
   BackColor       =   &H80000007&
   BorderStyle     =   0  'None
   ClientHeight    =   9000
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12000
   ControlBox      =   0   'False
   LinkTopic       =   "Form4"
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
   Begin VB.ComboBox cmbGender 
      BackColor       =   &H80000003&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   315
      ItemData        =   "frmCreation_Part3.frx":0000
      Left            =   4980
      List            =   "frmCreation_Part3.frx":000A
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   3450
      Width           =   2175
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "Select your character's gender:"
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
      Height          =   255
      Left            =   1770
      TabIndex        =   6
      Top             =   3480
      Width           =   3135
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "And now the final touch for your character..."
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
      Height          =   285
      Left            =   1680
      TabIndex        =   5
      Top             =   2880
      Width           =   5085
   End
   Begin VB.Label Num 
      BackStyle       =   0  'Transparent
      BeginProperty DataFormat 
         Type            =   0
         Format          =   "0"
         HaveTrueFalseNull=   0
         FirstDayOfWeek  =   0
         FirstWeekOfYear =   0
         LCID            =   1044
         SubFormatType   =   0
      EndProperty
      Height          =   255
      Left            =   12000
      TabIndex        =   4
      Top             =   0
      Width           =   735
   End
   Begin VB.Label Label1 
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
      Left            =   1680
      TabIndex        =   3
      Top             =   2520
      Width           =   4095
   End
   Begin VB.Image Image1 
      Height          =   9120
      Left            =   0
      Stretch         =   -1  'True
      Top             =   30
      Width           =   12120
   End
End
Attribute VB_Name = "frmCreation_Part3"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmd_Continue_Click()
On Error Resume Next

If Me.cmbGender.Text = "" Then
    MsgBox "You must pick a gender!"
    Me.cmbGender.SetFocus
Else
    Call ButtonClick
    CreateGender = Me.cmbGender.Text
    frmCreation_Part4.Show
    Unload Me
End If
End Sub

Private Sub cmd_Back_Click()
On Error Resume Next

Call ButtonClick
frmCreation_Part2.Show
Unload Me
End Sub

Private Sub Form_Load()
On Error Resume Next

If CreateGender <> "" Then Me.cmbGender.Text = CreateGender

Image1.Picture = LoadPicture(IniPath & "Grh\menu2.jpg")
End Sub
