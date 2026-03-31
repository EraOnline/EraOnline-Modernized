VERSION 5.00
Begin VB.Form Form4 
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
   Begin VB.CommandButton Command2 
      Caption         =   "Back"
      Height          =   255
      Left            =   7920
      TabIndex        =   4
      Top             =   5760
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Continue"
      Height          =   255
      Left            =   9120
      TabIndex        =   3
      Top             =   5760
      Width           =   1095
   End
   Begin VB.ComboBox Combo1 
      BackColor       =   &H80000003&
      ForeColor       =   &H80000005&
      Height          =   315
      ItemData        =   "Form4.frx":0000
      Left            =   4560
      List            =   "Form4.frx":000A
      Style           =   2  'Dropdown List
      TabIndex        =   1
      Top             =   3840
      Width           =   2175
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "Select You Characters Gender:"
      ForeColor       =   &H8000000E&
      Height          =   1215
      Left            =   4560
      TabIndex        =   6
      Top             =   3480
      Width           =   4095
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "And now the final touch for your character..."
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   1680
      TabIndex        =   5
      Top             =   2880
      Width           =   3855
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
      TabIndex        =   2
      Top             =   0
      Width           =   735
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
      Left            =   1680
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
Attribute VB_Name = "Form4"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Private Sub Command1_Click()
On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

CreateGender = Combo1.Text

homeselect.Show
Unload Me

End Sub

Private Sub Command2_Click()
On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Form5.Show
Unload Me
End Sub



Private Sub Form_Load()
On Error Resume Next

Form4.Show
Image1.Picture = LoadPicture(IniPath & "Grh\menu2.jpg")

End Sub

