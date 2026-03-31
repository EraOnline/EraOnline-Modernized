VERSION 5.00
Begin VB.Form worldcontrol 
   Caption         =   "Server Controller "
   ClientHeight    =   8595
   ClientLeft      =   2175
   ClientTop       =   345
   ClientWidth     =   7320
   LinkTopic       =   "Form1"
   ScaleHeight     =   8595
   ScaleWidth      =   7320
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame5 
      Caption         =   "General Information"
      Height          =   4815
      Left            =   0
      TabIndex        =   16
      Top             =   1440
      Width           =   3015
      Begin VB.CommandButton Command12 
         Caption         =   "Update"
         Height          =   255
         Left            =   120
         TabIndex        =   21
         Top             =   4440
         Width           =   2775
      End
      Begin VB.Label goldcirc 
         Alignment       =   2  'Center
         Caption         =   "0"
         Height          =   255
         Left            =   120
         TabIndex        =   20
         Top             =   1200
         Width           =   2775
      End
      Begin VB.Label Label12 
         Caption         =   "PLAYER GOLD IN CIRCULATION:"
         Height          =   255
         Left            =   240
         TabIndex        =   19
         Top             =   960
         Width           =   2535
      End
      Begin VB.Label Label11 
         Caption         =   "PLAYERS PLAYING:"
         Height          =   255
         Left            =   720
         TabIndex        =   18
         Top             =   360
         Width           =   1575
      End
      Begin VB.Label Label4 
         Alignment       =   2  'Center
         Caption         =   "0"
         Height          =   255
         Left            =   120
         TabIndex        =   17
         Top             =   600
         Width           =   2775
      End
   End
   Begin VB.Frame Frame4 
      Caption         =   "Important Information:"
      Height          =   1695
      Left            =   0
      TabIndex        =   14
      Top             =   6360
      Width           =   7215
      Begin VB.Label status 
         Alignment       =   2  'Center
         Height          =   1215
         Left            =   240
         TabIndex        =   15
         Top             =   360
         Width           =   6855
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Broadcasting"
      Height          =   2295
      Left            =   3120
      TabIndex        =   5
      Top             =   3960
      Width           =   4095
      Begin VB.CommandButton Command2 
         Caption         =   "Send System Message"
         Height          =   255
         Left            =   120
         TabIndex        =   13
         Top             =   1920
         Width           =   3855
      End
      Begin VB.CommandButton Command1 
         Caption         =   "Send Emergency Message"
         Height          =   255
         Left            =   120
         TabIndex        =   12
         Top             =   960
         Width           =   3855
      End
      Begin VB.TextBox smsg 
         Height          =   285
         Left            =   120
         TabIndex        =   9
         Top             =   1560
         Width           =   3855
      End
      Begin VB.TextBox emsg 
         Height          =   285
         Left            =   120
         TabIndex        =   7
         Top             =   600
         Width           =   3855
      End
      Begin VB.Label Label2 
         BackStyle       =   0  'Transparent
         Caption         =   "Send out SYSTEM message to all:"
         Height          =   255
         Left            =   120
         TabIndex        =   8
         Top             =   1320
         Width           =   2895
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Send out EMERGENCY message to all:"
         Height          =   255
         Left            =   120
         TabIndex        =   6
         Top             =   360
         Width           =   3375
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "General"
      Height          =   2415
      Left            =   3120
      TabIndex        =   1
      Top             =   1440
      Width           =   4095
      Begin VB.CommandButton Command16 
         Caption         =   "Restart Server"
         Height          =   375
         Left            =   120
         TabIndex        =   4
         Top             =   1200
         Width           =   3855
      End
      Begin VB.CommandButton Command15 
         Caption         =   "Shutdown Server"
         Height          =   375
         Left            =   120
         TabIndex        =   3
         Top             =   720
         Width           =   3855
      End
      Begin VB.CommandButton Command11 
         Caption         =   "Save World"
         Height          =   375
         Left            =   120
         TabIndex        =   2
         Top             =   240
         Width           =   3855
      End
   End
   Begin VB.CommandButton Command10 
      Caption         =   "Leave World Control Tools"
      Height          =   315
      Left            =   0
      TabIndex        =   0
      Top             =   8160
      Width           =   2055
   End
   Begin VB.Shape Shape2 
      Height          =   1095
      Left            =   0
      Top             =   120
      Width           =   7215
   End
   Begin VB.Label Label8 
      BackStyle       =   0  'Transparent
      Caption         =   $"worldcontrol.frx":0000
      ForeColor       =   &H000000FF&
      Height          =   1095
      Left            =   960
      TabIndex        =   11
      Top             =   120
      Width           =   6135
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "WARNING:"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   10
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

Dim userindex As Integer
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

Private Sub gmmsg_Change()

End Sub

