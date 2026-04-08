VERSION 5.00
Begin VB.Form news 
   BorderStyle     =   0  'None
   ClientHeight    =   6705
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   8595
   ControlBox      =   0   'False
   LinkTopic       =   "Form9"
   ScaleHeight     =   6705
   ScaleWidth      =   8595
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Venture Forth"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   6840
      TabIndex        =   2
      Top             =   6360
      Width           =   1695
   End
   Begin VB.Label news 
      BackStyle       =   0  'Transparent
      Caption         =   $"news.frx":0000
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   5175
      Left            =   1200
      TabIndex        =   1
      Top             =   960
      Width           =   7095
   End
   Begin VB.Label headline 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Todays News:"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   20.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   0
      TabIndex        =   0
      Top             =   120
      Width           =   8655
   End
   Begin VB.Image Image1 
      Height          =   6735
      Left            =   0
      Picture         =   "news.frx":0257
      Stretch         =   -1  'True
      Top             =   0
      Width           =   8655
   End
End
Attribute VB_Name = "news"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Label1_Click()
Unload Me
End Sub
