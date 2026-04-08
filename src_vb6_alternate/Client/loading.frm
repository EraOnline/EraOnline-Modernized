VERSION 5.00
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Begin VB.Form frmLoading 
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
   Begin VB.Label lblVersion 
      Alignment       =   1  'Right Justify
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   195
      Left            =   11865
      TabIndex        =   3
      Top             =   8610
      Width           =   75
   End
   Begin VB.Label lblPercent 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   0
      TabIndex        =   2
      Top             =   7800
      Width           =   11895
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   0
      TabIndex        =   1
      Top             =   7800
      Width           =   12015
   End
   Begin VB.Label loadstatus 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   1200
      Width           =   11655
   End
End
Attribute VB_Name = "frmLoading"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
'Set the version on a label located on bottom of this form
'it's always fun to see
'PL 11/20/2000
lblVersion.Caption = "EraOnline Version " & MyVersion

Me.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
End Sub

Private Sub Timer1_Timer()
On Error Resume Next

If Label2 = "/" Then
Label2 = "\"
Else
Label2 = "/"
End If

End Sub

