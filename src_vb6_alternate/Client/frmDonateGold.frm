VERSION 5.00
Begin VB.Form frmDonateGold 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   3195
   ClientLeft      =   15
   ClientTop       =   15
   ClientWidth     =   4680
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000003&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   285
      Left            =   773
      TabIndex        =   1
      Top             =   1440
      Width           =   3135
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Donate how much ?"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
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
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Donate gold to Temple"
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
      Height          =   270
      Left            =   795
      TabIndex        =   0
      Top             =   240
      Width           =   3090
   End
   Begin VB.Image Image4 
      Height          =   480
      Left            =   1808
      Picture         =   "frmDonateGold.frx":0000
      Stretch         =   -1  'True
      Top             =   2400
      Width           =   1065
   End
   Begin VB.Image Image1 
      Height          =   3255
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   4695
   End
End
Attribute VB_Name = "frmDonateGold"
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

On Error Resume Next


If UserGLD < Text1.Text Then
frmMessage.Show
frmMessage.message = "You do not have that much gold !"
Else
SendData "DON" & Text1.Text
Unload Me
End If
End Sub
