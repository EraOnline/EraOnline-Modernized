VERSION 5.00
Begin VB.Form WaitConnect2 
   BackColor       =   &H80000007&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   1425
   ClientLeft      =   3345
   ClientTop       =   3480
   ClientWidth     =   5250
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1425
   ScaleWidth      =   5250
   Begin VB.Timer Timer1 
      Interval        =   5000
      Left            =   120
      Top             =   120
   End
   Begin VB.Timer Timer2 
      Interval        =   1000
      Left            =   600
      Top             =   120
   End
   Begin VB.Label status 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Waiting for avaiable connection to server. Please wait..."
      ForeColor       =   &H8000000E&
      Height          =   1095
      Left            =   0
      TabIndex        =   1
      Top             =   600
      Width           =   5175
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "/"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2640
      TabIndex        =   0
      Top             =   960
      Width           =   615
   End
   Begin VB.Image Image6 
      Height          =   4215
      Left            =   -120
      Stretch         =   -1  'True
      Top             =   0
      Width           =   5760
   End
End
Attribute VB_Name = "WaitConnect2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
Timer1.Interval = 5000
End Sub

Private Sub Timer1_Timer()
'*****************************************************************
'Makes sure user data is ok then trys to connect to server
'*****************************************************************

On Error Resume Next

If frmConnect.MousePointer = 11 Then
    Exit Sub
End If

If CheckUserData = True Then
       
    'FrmMain.Socket1.Close
    frmMain.Socket1.HostName = UserServerIP
    frmMain.Socket1.RemotePort = UserPort

    SendNewChar = False
    frmConnect.MousePointer = 11
    frmMain.Socket1.Connect
    

frmConnect.Hide
Unload WaitConnect2

End If
End Sub


Private Sub Timer2_Timer()
If Label2 = "/" Then
Label2 = "\"
Else
Label2 = "/"
End If
End Sub
