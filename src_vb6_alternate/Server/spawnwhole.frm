VERSION 5.00
Begin VB.Form spawnwhole 
   Caption         =   "Spawn A Whole Zone"
   ClientHeight    =   1530
   ClientLeft      =   3615
   ClientTop       =   3570
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   1530
   ScaleWidth      =   4680
   Begin VB.TextBox creature 
      Height          =   285
      Left            =   1560
      TabIndex        =   4
      Top             =   600
      Width           =   2895
   End
   Begin VB.CommandButton spawnspecefic 
      Caption         =   "SPAWN NOW"
      Height          =   375
      Left            =   0
      TabIndex        =   2
      Top             =   1080
      Width           =   4575
   End
   Begin VB.TextBox zone 
      Height          =   285
      Left            =   1680
      TabIndex        =   1
      Top             =   120
      Width           =   2775
   End
   Begin VB.Label Label4 
      Caption         =   "Creature Number:"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   600
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "ZONE NUMBER:"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1455
   End
End
Attribute VB_Name = "spawnwhole"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub spawnspecefic_Click()
Unload Me

End Sub
