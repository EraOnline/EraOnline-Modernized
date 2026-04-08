VERSION 5.00
Begin VB.Form WaitConnect 
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   1830
   ClientLeft      =   3570
   ClientTop       =   3480
   ClientWidth     =   5190
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1830
   ScaleWidth      =   5190
   Begin VB.Timer Timer2 
      Interval        =   1000
      Left            =   840
      Top             =   120
   End
   Begin VB.Timer Timer1 
      Interval        =   5000
      Left            =   120
      Top             =   120
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "/"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2520
      TabIndex        =   1
      Top             =   1200
      Width           =   255
   End
   Begin VB.Label status 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Waiting for avaiable connection to server. Please wait..."
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   0
      TabIndex        =   0
      Top             =   720
      Width           =   5175
   End
   Begin VB.Image Image6 
      Height          =   4215
      Left            =   -360
      Picture         =   "WaitConnect.frx":0000
      Stretch         =   -1  'True
      Top             =   -720
      Width           =   5760
   End
End
Attribute VB_Name = "WaitConnect"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
Timer1.Interval = 5000
End Sub

Private Sub Timer1_Timer()
'*****************************************************************
'Makes sure user data is ok then begins new character process
'*****************************************************************

'Get all info user selected when making the character

If CheckUserData = True Then

    'FrmMain.Socket1.Close
    frmMain.Socket1.HostName = UserServerIP
    frmMain.Socket1.RemotePort = UserPort

    SendNewChar = True
    Form7.MousePointer = 11
    frmMain.Socket1.Connect
    
End If

Unload WaitConnect

End Sub

Private Sub Timer2_Timer()
If Label2 = "/" Then
Label2 = "\"
Else
Label2 = "/"
End If

End Sub
