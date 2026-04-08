VERSION 5.00
Begin VB.Form frmEnterMenath 
   BackColor       =   &H80000007&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   3345
   ClientLeft      =   2685
   ClientTop       =   3015
   ClientWidth     =   7275
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3345
   ScaleWidth      =   7275
   ShowInTaskbar   =   0   'False
   Begin VB.Image Image3 
      Height          =   750
      Left            =   600
      Picture         =   "frmEnterMenath.frx":0000
      Top             =   2160
      Width           =   6270
   End
   Begin VB.Image Image2 
      Height          =   750
      Left            =   600
      Picture         =   "frmEnterMenath.frx":52A3
      Top             =   1440
      Width           =   6270
   End
   Begin VB.Image Image1 
      Height          =   750
      Left            =   600
      Picture         =   "frmEnterMenath.frx":6D85
      Top             =   720
      Width           =   6270
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Please select"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   20.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   465
      Left            =   2115
      TabIndex        =   0
      Top             =   150
      Width           =   3045
   End
   Begin VB.Image Image6 
      Height          =   3375
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   7335
   End
End
Attribute VB_Name = "frmEnterMenath"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
On Error Resume Next

Image6.Picture = frmConnect.Image6.Picture
End Sub

Private Sub Image1_Click()
On Error Resume Next

Call ButtonClick
Unload Me
Unload frmMenu
frmCreation_Part1.Show
End Sub

Private Sub Image2_Click()
On Error Resume Next

Call ButtonClick
Unload Me
frmConnect.Show
End Sub

Private Sub Image3_Click()
On Error Resume Next

Call ButtonClick
Unload Me
frmEraseCharacter.Show
End Sub

Private Sub Image6_Click()

Unload Me
End Sub

Private Sub Label1_Click()
Unload Me
End Sub
