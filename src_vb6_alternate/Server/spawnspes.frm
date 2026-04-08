VERSION 5.00
Begin VB.Form spawnspes 
   Caption         =   "Spawn In A Wilderness Zone"
   ClientHeight    =   1995
   ClientLeft      =   3615
   ClientTop       =   3345
   ClientWidth     =   4770
   LinkTopic       =   "Form1"
   ScaleHeight     =   1995
   ScaleWidth      =   4770
   Begin VB.TextBox creature 
      Height          =   285
      Left            =   1680
      TabIndex        =   8
      Top             =   1080
      Width           =   2895
   End
   Begin VB.CommandButton spawnspecefic 
      Caption         =   "SPAWN NOW"
      Height          =   375
      Left            =   120
      TabIndex        =   6
      Top             =   1560
      Width           =   4575
   End
   Begin VB.TextBox ypos 
      Height          =   285
      Left            =   3240
      TabIndex        =   5
      Top             =   600
      Width           =   1335
   End
   Begin VB.TextBox xpos 
      Height          =   285
      Left            =   1680
      TabIndex        =   4
      Top             =   600
      Width           =   1335
   End
   Begin VB.TextBox zone 
      Height          =   285
      Left            =   240
      TabIndex        =   1
      Top             =   600
      Width           =   1215
   End
   Begin VB.Label Label4 
      Caption         =   "Creature Number:"
      Height          =   255
      Left            =   240
      TabIndex        =   7
      Top             =   1080
      Width           =   1335
   End
   Begin VB.Label Label3 
      Caption         =   "Y POS"
      Height          =   255
      Left            =   3600
      TabIndex        =   3
      Top             =   240
      Width           =   1095
   End
   Begin VB.Label Label2 
      Caption         =   "X POS"
      Height          =   375
      Left            =   2040
      TabIndex        =   2
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "ZONE NUMBER:"
      Height          =   255
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   1455
   End
End
Attribute VB_Name = "spawnspes"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub spawnspecefic_Click()



Call MakeNPCChar(ToMap, 0, spawnspes.zone, spawnspes.creature, spawnspes.zone, spawnspes.xpos, spawnspes.ypos)

Unload Me

End Sub
