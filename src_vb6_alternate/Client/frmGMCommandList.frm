VERSION 5.00
Begin VB.Form frmGMCommandList 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   4035
   ClientLeft      =   3345
   ClientTop       =   1170
   ClientWidth     =   6660
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4035
   ScaleWidth      =   6660
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2243
      TabIndex        =   1
      Top             =   3480
      Width           =   2175
   End
   Begin VB.TextBox Text1 
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
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
      Height          =   1875
      Left            =   53
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      TabIndex        =   3
      Text            =   "frmGMCommandList.frx":0000
      Top             =   630
      Width           =   6555
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "You find the targeted NPC/creature's index by clicking on them. Their index will appear in ( )'s."
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
      Height          =   555
      Left            =   60
      TabIndex        =   2
      Top             =   2760
      Width           =   6555
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "GameMaster Command List"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   5415
   End
   Begin VB.Image Image6 
      Height          =   4065
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   6690
   End
End
Attribute VB_Name = "frmGMCommandList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()
On Error Resume Next
Call ButtonClick
Unload Me
gmtool.Show
End Sub

Private Sub Form_Load()
On Error Resume Next
Image6.Picture = LoadPicture(IniPath & "Grh\wood.bmp")

End Sub
