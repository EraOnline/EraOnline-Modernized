VERSION 5.00
Begin VB.Form npcsay 
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   5160
   ClientLeft      =   2280
   ClientTop       =   915
   ClientWidth     =   7020
   ControlBox      =   0   'False
   LinkTopic       =   "Form9"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5160
   ScaleWidth      =   7020
   Begin VB.Label Label6 
      BackColor       =   &H00404040&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Farewell ! Good travels !"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   8
      Top             =   4680
      Width           =   2295
   End
   Begin VB.Label Label5 
      BackColor       =   &H00404040&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Here you got..."
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   7
      Top             =   4320
      Width           =   2295
   End
   Begin VB.Label Label4 
      BackColor       =   &H00404040&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Can you tell me about..."
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   6
      Top             =   3960
      Width           =   2295
   End
   Begin VB.Label Label3 
      BackColor       =   &H00404040&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Are thee interested in trading ?"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   5
      Top             =   3600
      Width           =   2295
   End
   Begin VB.Label Label2 
      BackColor       =   &H00404040&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Any news or gossip ?"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   4
      Top             =   3240
      Width           =   2295
   End
   Begin VB.Image yourface 
      BorderStyle     =   1  'Fixed Single
      Height          =   1095
      Left            =   240
      Top             =   120
      Width           =   855
   End
   Begin VB.Label yurname 
      BackStyle       =   0  'Transparent
      Caption         =   "Your Name"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   6.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   3
      Top             =   1200
      Width           =   2295
   End
   Begin VB.Label youtalk 
      BackColor       =   &H00404040&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Hail to thee !"
      BeginProperty Font 
         Name            =   "Eurasia"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   1695
      Left            =   240
      TabIndex        =   2
      Top             =   1440
      Width           =   2295
   End
   Begin VB.Label npcname 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "A shopkeeper"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   6.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   4440
      TabIndex        =   1
      Top             =   1200
      Width           =   2295
   End
   Begin VB.Image npcface 
      BorderStyle     =   1  'Fixed Single
      Height          =   1095
      Left            =   5760
      Top             =   120
      Width           =   855
   End
   Begin VB.Label npctalk 
      BackColor       =   &H00404040&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Hail to thee traveller !"
      BeginProperty Font 
         Name            =   "Eurasia"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   3495
      Left            =   4440
      TabIndex        =   0
      Top             =   1440
      Width           =   2295
   End
End
Attribute VB_Name = "npcsay"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
npcsay.Picture = LoadPicture("grh\chat.gif")
End Sub

Private Sub Label2_Click()
youtalk.Caption = "Doust thee have any interesting news or gossip to share with me ?"
End Sub

Private Sub Label3_Click()
youtalk.Caption = "Are doust interesting in trading with me ? I got many fine wares !"
End Sub

Private Sub Label4_Click()
youtalk.Caption = "I was wondering you thee knew anything about this ?"

End Sub

Private Sub Label5_Click()
youtalk.Caption = "Here take this ! Its yours !"
End Sub

Private Sub Label6_Click()
youtalk.Caption = "I must leave now ! Farewell and good travels to thee !"
Unload Me

End Sub
