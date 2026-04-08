VERSION 5.00
Begin VB.Form frmMenu 
   BackColor       =   &H80000008&
   BorderStyle     =   0  'None
   Caption         =   "EraOnline"
   ClientHeight    =   8595
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   11880
   ControlBox      =   0   'False
   LinkTopic       =   "Form2"
   Picture         =   "frmMenu.frx":0000
   ScaleHeight     =   8595
   ScaleWidth      =   11880
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.Label version 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   210
      Left            =   60
      TabIndex        =   4
      Top             =   0
      Width           =   60
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
      Left            =   10440
      TabIndex        =   3
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
      Height          =   495
      Left            =   10200
      TabIndex        =   2
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
      Left            =   10200
      TabIndex        =   1
      Top             =   6600
      Width           =   1335
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
      Height          =   735
      Left            =   9720
      TabIndex        =   0
      Top             =   5040
      Width           =   2175
   End
End
Attribute VB_Name = "frmMenu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
Dim playerid As Long
On Error Resume Next

Unload frmLoading
If BackToLogin = True Then
    Unload frmMain
    BackToLogin = False
End If

version.Caption = "Version " & MyVersion
CreateVersion = App.Major & "." & App.Minor & "." & App.Revision

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

'No more stupid midi restart when you come back from signup
'PL 11/20/2000
If CurMidi <> IniPath & "\music\" & "Mus" & 6 & ".mid" Then
    CurMidi = IniPath & "\music\" & "Mus" & 6 & ".mid"
    LoopMidi = 1
    Call PlayMidi(CurMidi)
End If

Image1.Picture = LoadPicture(IniPath & "\Grh\menu1.jpg")
'Why the hell was this midi playing? It's ruining all the theme!
'PL 11/20/2000
'Call PlayWaveDS(IniPath & "\Sound\" & "Snd" & 41 & ".wav")

End Sub

Private Sub Label1_Click()

  On Error Resume Next
 
Call ButtonClick
frmEnterMenath.Show
End Sub

Private Sub Label2_Click()
On Error Resume Next
Call ButtonClick
frmSetup.Show

End Sub

Private Sub Label3_Click()
On Error Resume Next
Call ButtonClick
frmCredits.Show

End Sub

Private Sub Label4_Click()
On Error Resume Next
Call ButtonClick
'End program
prgRun = False
End Sub

