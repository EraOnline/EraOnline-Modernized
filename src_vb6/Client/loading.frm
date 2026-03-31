VERSION 5.00
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Begin VB.Form loading 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   8970
   ClientLeft      =   4545
   ClientTop       =   3390
   ClientWidth     =   11970
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8970
   ScaleWidth      =   11970
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin InetCtlsObjects.Inet Inet 
      Left            =   0
      Top             =   0
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      Protocol        =   4
      RequestTimeout  =   99999999
   End
   Begin VB.Label loadstatus 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Loading"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   3720
      TabIndex        =   0
      Top             =   8040
      Width           =   5055
   End
   Begin VB.Shape Shape1 
      BorderColor     =   &H00C0C0C0&
      BorderWidth     =   4
      Height          =   255
      Left            =   3720
      Top             =   8040
      Width           =   5000
   End
   Begin VB.Shape percentcomp 
      BackColor       =   &H00FF8080&
      BackStyle       =   1  'Opaque
      BorderColor     =   &H00FF8080&
      FillColor       =   &H00FF8080&
      Height          =   210
      Left            =   3720
      Top             =   8040
      Width           =   15
   End
End
Attribute VB_Name = "loading"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next


    
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
End Sub

Private Sub Timer1_Timer()
On Error Resume Next

If Label2 = "/" Then
Label2 = "\"
Else
Label2 = "/"
End If

End Sub

