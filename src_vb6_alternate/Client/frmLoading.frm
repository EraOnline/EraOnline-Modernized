VERSION 5.00
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Begin VB.Form frmLoading 
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   Caption         =   "EraOnline"
   ClientHeight    =   8970
   ClientLeft      =   4530
   ClientTop       =   3375
   ClientWidth     =   11970
   ControlBox      =   0   'False
   Icon            =   "frmLoading.frx":0000
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8970
   ScaleWidth      =   11970
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.PictureBox Picture1 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      Height          =   5160
      Left            =   -15
      Picture         =   "frmLoading.frx":030A
      ScaleHeight     =   5160
      ScaleWidth      =   12000
      TabIndex        =   2
      Top             =   1905
      Width           =   12000
   End
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
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   195
      Left            =   11880
      TabIndex        =   1
      Top             =   8610
      Width           =   60
   End
   Begin VB.Label loadstatus 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
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
      Left            =   158
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

'Me.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
End Sub
