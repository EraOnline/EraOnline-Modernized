VERSION 5.00
Begin VB.Form worldcontrol 
   Caption         =   "Server Controller (CAUTION! USE GENTLY !)"
   ClientHeight    =   8595
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   11400
   LinkTopic       =   "Form1"
   ScaleHeight     =   8595
   ScaleWidth      =   11400
   Begin VB.Frame Frame5 
      Caption         =   "General Information"
      Height          =   4815
      Left            =   0
      TabIndex        =   20
      Top             =   1440
      Width           =   3015
      Begin VB.CommandButton Command12 
         Caption         =   "Update"
         Height          =   255
         Left            =   840
         TabIndex        =   25
         Top             =   1440
         Width           =   1455
      End
      Begin VB.Label goldcirc 
         Alignment       =   2  'Center
         Caption         =   "0"
         Height          =   255
         Left            =   120
         TabIndex        =   24
         Top             =   1200
         Width           =   2775
      End
      Begin VB.Label Label12 
         Caption         =   "PLAYER GOLD IN CIRCULATION:"
         Height          =   255
         Left            =   240
         TabIndex        =   23
         Top             =   960
         Width           =   2535
      End
      Begin VB.Label Label11 
         Caption         =   "PLAYERS PLAYING:"
         Height          =   255
         Left            =   720
         TabIndex        =   22
         Top             =   360
         Width           =   1575
      End
      Begin VB.Label Label4 
         Alignment       =   2  'Center
         Caption         =   "0"
         Height          =   255
         Left            =   120
         TabIndex        =   21
         Top             =   600
         Width           =   2775
      End
   End
   Begin VB.Frame Frame4 
      Caption         =   "Important Information:"
      Height          =   1095
      Left            =   7320
      TabIndex        =   18
      Top             =   120
      Width           =   4455
      Begin VB.Label status 
         Alignment       =   2  'Center
         Height          =   375
         Left            =   120
         TabIndex        =   19
         Top             =   360
         Width           =   4215
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Broadcasting"
      Height          =   3135
      Left            =   3120
      TabIndex        =   6
      Top             =   3120
      Width           =   4095
      Begin VB.CommandButton Command3 
         Caption         =   "Send GameMaster Message"
         Height          =   255
         Left            =   120
         TabIndex        =   17
         Top             =   2760
         Width           =   3855
      End
      Begin VB.CommandButton Command2 
         Caption         =   "Send System Message"
         Height          =   255
         Left            =   120
         TabIndex        =   16
         Top             =   1800
         Width           =   3855
      End
      Begin VB.CommandButton Command1 
         Caption         =   "Send Emergency Message"
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   840
         Width           =   3855
      End
      Begin VB.TextBox gmmsg 
         Height          =   285
         Left            =   120
         TabIndex        =   12
         Top             =   2400
         Width           =   3855
      End
      Begin VB.TextBox smsg 
         Height          =   285
         Left            =   120
         TabIndex        =   10
         Top             =   1440
         Width           =   3855
      End
      Begin VB.TextBox emsg 
         Height          =   285
         Left            =   120
         TabIndex        =   8
         Top             =   480
         Width           =   3855
      End
      Begin VB.Label Label3 
         BackStyle       =   0  'Transparent
         Caption         =   "Send out a message to all GAME MASTERS:"
         Height          =   255
         Left            =   120
         TabIndex        =   11
         Top             =   2160
         Width           =   3855
      End
      Begin VB.Label Label2 
         BackStyle       =   0  'Transparent
         Caption         =   "Send out SYSTEM message to all:"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   1200
         Width           =   2895
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Send out EMERGENCY message to all:"
         Height          =   255
         Left            =   120
         TabIndex        =   7
         Top             =   240
         Width           =   3375
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "General"
      Height          =   1695
      Left            =   3120
      TabIndex        =   2
      Top             =   1320
      Width           =   4095
      Begin VB.CommandButton Command16 
         Caption         =   "Restart Server"
         Height          =   375
         Left            =   120
         TabIndex        =   5
         Top             =   1200
         Width           =   3855
      End
      Begin VB.CommandButton Command15 
         Caption         =   "Shutdown Server"
         Height          =   375
         Left            =   120
         TabIndex        =   4
         Top             =   720
         Width           =   3855
      End
      Begin VB.CommandButton Command11 
         Caption         =   "Save World"
         Height          =   375
         Left            =   120
         TabIndex        =   3
         Top             =   240
         Width           =   3855
      End
   End
   Begin VB.CommandButton Command10 
      Caption         =   "Leave World Control Tools"
      Height          =   315
      Left            =   7440
      TabIndex        =   1
      Top             =   8160
      Width           =   4335
   End
   Begin VB.Frame Frame1 
      Caption         =   "Other"
      Height          =   6615
      Left            =   7440
      TabIndex        =   0
      Top             =   1320
      Width           =   4335
   End
   Begin VB.Shape Shape2 
      Height          =   1095
      Left            =   0
      Top             =   120
      Width           =   7215
   End
   Begin VB.Shape Shape1 
      Height          =   2055
      Left            =   0
      Top             =   6480
      Width           =   6375
   End
   Begin VB.Label Label8 
      BackStyle       =   0  'Transparent
      ForeColor       =   &H000000FF&
      Height          =   1095
      Left            =   960
      TabIndex        =   14
      Top             =   120
      Width           =   6135
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "WARNING:"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   13
      Top             =   120
      Width           =   975
   End
End
Attribute VB_Name = "worldcontrol"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()
Call SendData(ToAll, 0, 0, "!!" & emsg.Text)
End Sub

Private Sub Command10_Click()
Unload Me

End Sub

Private Sub Command11_Click()
status.Caption = "Saving world..."

Call SaveWorld

End Sub

Private Sub Command12_Click()
Dim userindex
goldcirc.Caption = 0



For userindex = 1 To LastUser

goldcirc.Caption = goldcirc.Caption + UserList(userindex).Stats.GLD
goldcirc.Caption = goldcirc.Caption + UserList(userindex).Stats.BANKGLD

Next userindex


End Sub

Private Sub Command15_Click()
   
Unload frmMain

End Sub

Private Sub Command16_Click()
  
Call Restart

End Sub

Private Sub Command2_Click()
Call SendData(ToAll, 0, 0, "!" & smsg.Text)
End Sub

Private Sub Command3_Click()
Call SendData(ToAll, 0, 0, "!" & gmmsg.Text)
End Sub

Private Sub Command8_Click()
spawnspes.Show
End Sub

Private Sub Command9_Click()
spawnwhole.Show
End Sub

Private Sub Command4_Click()

End Sub

Private Sub Form_Load()
Label4.Caption = NumUsers
End Sub

Private Sub rpmsg_KeyDown(KeyCode As Integer, Shift As Integer)

End Sub

