VERSION 5.00
Begin VB.Form equipment 
   BackColor       =   &H00008080&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   5190
   ClientLeft      =   2505
   ClientTop       =   915
   ClientWidth     =   6510
   ControlBox      =   0   'False
   LinkTopic       =   "Form9"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "equipment.frx":0000
   ScaleHeight     =   5190
   ScaleWidth      =   6510
   Begin VB.Image feets 
      Height          =   615
      Left            =   3360
      Stretch         =   -1  'True
      Top             =   4200
      Width           =   735
   End
   Begin VB.Image rhand 
      Height          =   615
      Left            =   5040
      Stretch         =   -1  'True
      Top             =   3120
      Width           =   735
   End
   Begin VB.Image arms 
      Height          =   615
      Left            =   5040
      Stretch         =   -1  'True
      Top             =   1440
      Width           =   735
   End
   Begin VB.Image neck 
      Height          =   495
      Left            =   5040
      Stretch         =   -1  'True
      Top             =   360
      Width           =   735
   End
   Begin VB.Image legs 
      Height          =   495
      Left            =   1560
      Stretch         =   -1  'True
      Top             =   3240
      Width           =   735
   End
   Begin VB.Image lhand 
      Height          =   495
      Left            =   1560
      Stretch         =   -1  'True
      Top             =   2040
      Width           =   735
   End
   Begin VB.Image body 
      Height          =   495
      Left            =   1560
      Stretch         =   -1  'True
      Top             =   960
      Width           =   735
   End
   Begin VB.Image head 
      Height          =   615
      Left            =   3360
      Stretch         =   -1  'True
      Top             =   240
      Width           =   735
   End
   Begin VB.Shape Shape1 
      BorderColor     =   &H000040C0&
      BorderWidth     =   4
      Height          =   5175
      Left            =   0
      Top             =   0
      Width           =   6495
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Close"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   5760
      TabIndex        =   0
      Top             =   4800
      Width           =   495
   End
End
Attribute VB_Name = "equipment"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Label1_Click()
Unload Me

End Sub
