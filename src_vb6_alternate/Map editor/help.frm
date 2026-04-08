VERSION 5.00
Begin VB.Form helpform 
   BackColor       =   &H00004080&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   7725
   ClientLeft      =   2730
   ClientTop       =   915
   ClientWidth     =   6120
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7725
   ScaleWidth      =   6120
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   255
      Left            =   4800
      TabIndex        =   2
      Top             =   7320
      Width           =   1215
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"help.frx":0000
      ForeColor       =   &H8000000E&
      Height          =   6495
      Left            =   240
      TabIndex        =   1
      Top             =   840
      Width           =   5655
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "How Does It Work ?"
      BeginProperty Font 
         Name            =   "Jester"
         Size            =   21.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   615
      Left            =   1200
      TabIndex        =   0
      Top             =   120
      Width           =   6135
   End
End
Attribute VB_Name = "helpform"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Unload Me

End Sub

