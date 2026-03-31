VERSION 5.00
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Begin VB.Form Form2 
   BackColor       =   &H80000008&
   BorderStyle     =   0  'None
   ClientHeight    =   8595
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   11880
   ControlBox      =   0   'False
   LinkTopic       =   "Form2"
   ScaleHeight     =   8595
   ScaleWidth      =   11880
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin InetCtlsObjects.Inet Inet 
      Left            =   240
      Top             =   0
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      Protocol        =   4
      RequestTimeout  =   99999999
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   9480
      TabIndex        =   4
      Top             =   5160
      Width           =   2415
   End
   Begin VB.Label version 
      BackStyle       =   0  'Transparent
      Caption         =   "11"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   0
      TabIndex        =   3
      Top             =   0
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   " "
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   10320
      TabIndex        =   2
      Top             =   7200
      Width           =   855
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   10080
      TabIndex        =   1
      Top             =   6000
      Width           =   1215
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   9720
      TabIndex        =   0
      Top             =   6600
      Width           =   2055
   End
   Begin VB.Image Image1 
      Height          =   9000
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   11880
   End
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub Form_Load()
Unload loading
Dim playerid As Long
On Error Resume Next

CreateVersion = version.Caption

If FileExist("C:\idnumwin.cfg", vbNormal) = False Then
    playerid = RandomNumber(100, 999999999)
    Open "C:\idnumwin.cfg" For Output As #1
        Print #1, playerid
    Close #1
    Else
    End If

    Open "C:\idnumwin.cfg" For Input As #1
    Userid = StrConv(InputB(LOF(1), 1), vbUnicode)
Close #1

CurMidi = IniPath & "music\" & "Mus" & 6 & ".mid"
LoopMidi = 1
Call PlayMidi(CurMidi)

Image1.Picture = LoadPicture(IniPath & "Grh\menu1.jpg")
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 41 & ".wav")

End Sub

Private Sub Label1_Click()

  On Error Resume Next
 
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

frmSelect.Show

End Sub

Private Sub Label2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
SetupScreen.Show

End Sub

Private Sub Label3_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
credits.Show

End Sub

Private Sub Label4_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
RestoreRes
'End program
prgRun = False

End Sub

