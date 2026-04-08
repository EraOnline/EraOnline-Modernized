VERSION 5.00
Begin VB.Form frmDeposit 
   BackColor       =   &H80000007&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   3195
   ClientLeft      =   3405
   ClientTop       =   1140
   ClientWidth     =   4680
   ControlBox      =   0   'False
   LinkTopic       =   "Form8"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000003&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   315
      Left            =   773
      TabIndex        =   1
      Top             =   1530
      Width           =   3135
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "How much ?"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1133
      TabIndex        =   2
      Top             =   1200
      Width           =   2415
   End
   Begin VB.Image Image4 
      Height          =   480
      Left            =   1748
      Picture         =   "frmDeposit.frx":0000
      Stretch         =   -1  'True
      Top             =   2400
      Width           =   1185
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Deposit Gold To Bank"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   315
      Left            =   893
      TabIndex        =   0
      Top             =   240
      Width           =   2895
   End
   Begin VB.Image Image1 
      Height          =   3255
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   4695
   End
End
Attribute VB_Name = "frmDeposit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
Image1 = frmTrade.Image1.Picture
End Sub

Private Sub Image2_Click()
On Error Resume Next
Call ButtonClick
If gold < UserGLD Then
gold = gold + 1
End If

End Sub

Private Sub Image3_Click()
On Error Resume Next
Call ButtonClick
If gold > 0 Then
gold = gold - 1
End If
End Sub

Private Sub Image4_Click()
On Error Resume Next

Call ButtonClick


If UserGLD < Text1.Text Then
frmMessage.Show
frmMessage.message = "You do not have that much gold !"
Else
SendData "DPT" & Text1.Text
Unload Me
End If

End Sub
