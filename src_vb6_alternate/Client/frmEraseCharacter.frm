VERSION 5.00
Begin VB.Form frmEraseCharacter 
   BackColor       =   &H80000008&
   BorderStyle     =   0  'None
   ClientHeight    =   4185
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   4425
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   ScaleHeight     =   4185
   ScaleWidth      =   4425
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox NameTxt 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   285
      Left            =   1500
      TabIndex        =   0
      Top             =   2040
      Width           =   2475
   End
   Begin VB.TextBox PasswordTxt 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   285
      IMEMode         =   3  'DISABLE
      Left            =   1500
      PasswordChar    =   "*"
      TabIndex        =   1
      Top             =   2520
      Width           =   2475
   End
   Begin VB.Label Label3 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "By erasing a character, the character is removed from the game server and you can never use that character ever again."
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   960
      Left            =   142
      TabIndex        =   5
      Top             =   840
      Width           =   4140
      WordWrap        =   -1  'True
   End
   Begin VB.Image Image2 
      Height          =   615
      Left            =   2400
      Picture         =   "frmEraseCharacter.frx":0000
      Stretch         =   -1  'True
      Top             =   3240
      Width           =   1650
   End
   Begin VB.Label Label1 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Name:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   240
      Left            =   240
      TabIndex        =   4
      Top             =   2040
      Width           =   705
   End
   Begin VB.Label Label2 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Password:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   240
      Left            =   240
      TabIndex        =   3
      Top             =   2520
      Width           =   1125
   End
   Begin VB.Label Label6 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Erase a character"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   14.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   345
      Left            =   765
      TabIndex        =   2
      Top             =   270
      Width           =   2820
   End
   Begin VB.Image Image1 
      Height          =   615
      Left            =   240
      Picture         =   "frmEraseCharacter.frx":23A9
      Stretch         =   -1  'True
      Top             =   3240
      Width           =   1650
   End
   Begin VB.Image Image6 
      Height          =   4215
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   4455
   End
End
Attribute VB_Name = "frmEraseCharacter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
On Error Resume Next
Image6.Picture = frmConnect.Image6.Picture
End Sub

Private Sub Image1_Click()
Unload Me

End Sub

Private Sub Image2_Click()
BackToMainMenu = True
On Error Resume Next
Call ButtonClick


UserName = NameTxt.Text
UserPassword = PasswordTxt.Text
UserServerIP = Address
'UserPort = "7777"
UserPort = "6665"
UserVersion = App.Major & "." & App.Minor & "." & App.Revision


If frmConnect.MousePointer = 11 Then
    Exit Sub
End If

If CheckUserData = True Then
       
    'FrmMain.Socket1.Close
    frmMain.Socket1.HostName = UserServerIP
    frmMain.Socket1.RemotePort = UserPort

    ErasingChar = True
    frmConnect.MousePointer = 11
    frmMain.Socket1.Connect
    

erasecharacter.Hide

End If

End Sub

