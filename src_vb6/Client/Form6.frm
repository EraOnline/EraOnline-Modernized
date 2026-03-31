VERSION 5.00
Begin VB.Form Form6 
   BorderStyle     =   0  'None
   ClientHeight    =   9000
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12000
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   9000
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.TextBox IPtxt 
      Height          =   285
      Left            =   7200
      TabIndex        =   10
      Text            =   "(TYPE IN SERVER IP HERE)"
      Top             =   4800
      Width           =   3015
   End
   Begin VB.TextBox Porttxt 
      Height          =   285
      Left            =   7200
      TabIndex        =   8
      Text            =   "7777"
      Top             =   4320
      Width           =   3015
   End
   Begin VB.TextBox PasswordTxt 
      Height          =   285
      IMEMode         =   3  'DISABLE
      Left            =   3360
      PasswordChar    =   "*"
      TabIndex        =   6
      Top             =   4800
      Width           =   2415
   End
   Begin VB.TextBox NameTxt 
      Height          =   285
      Left            =   3360
      TabIndex        =   4
      Top             =   4320
      Width           =   2415
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "Server IP:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   6120
      TabIndex        =   9
      Top             =   4800
      Width           =   975
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Server Port:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   6120
      TabIndex        =   7
      Top             =   4320
      Width           =   1095
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Caption         =   "Character Password:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1800
      TabIndex        =   5
      Top             =   4800
      Width           =   1575
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Character Name:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1800
      TabIndex        =   3
      Top             =   4320
      Width           =   1335
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   "Continue"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   9120
      TabIndex        =   2
      Top             =   5640
      Width           =   1095
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"Form6.frx":0000
      ForeColor       =   &H8000000E&
      Height          =   1095
      Left            =   1680
      TabIndex        =   1
      Top             =   3000
      Width           =   8295
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "-Creating A Character Account"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   15.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   1680
      TabIndex        =   0
      Top             =   2520
      Width           =   4095
   End
   Begin VB.Image Image1 
      Height          =   9120
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   12120
   End
End
Attribute VB_Name = "Form6"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)

'Make Server IP and Port box visible
If KeyCode = vbKeyI And Shift = vbCtrlMask Then
    
    'Port
    Porttxt.Visible = True
    Label4.Visible = True
    
    'Server IP
    IPtxt.Text = "localhost"
    IPtxt.Visible = True
    Label5.Visible = True
    
    KeyCode = 0
    Exit Sub
End If

End Sub




Private Sub Form_Load()
Image1.Picture = Form3.Image1.Picture



End Sub

Private Sub Label4_Click()

'*****************************************************************
'Makes sure user data is ok then begins new character process
'*****************************************************************

'Get all info user selected when making the character



'update user info
UserName = NameTxt.Text
UserPassword = PasswordTxt.Text
UserServerIP = IPtxt.Text
UserPort = Val(Porttxt.Text)

UserBody = 1
UserHead = 1

If CheckUserData = True Then

    'FrmMain.Socket1.Close
    frmMain.Socket1.HostName = UserServerIP
    frmMain.Socket1.RemotePort = UserPort

    SendNewChar = True
    Form6.MousePointer = 11
    frmMain.Socket1.Connect
    
    End If

End Sub

