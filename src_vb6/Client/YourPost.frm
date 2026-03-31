VERSION 5.00
Begin VB.Form YourPost 
   BackColor       =   &H80000007&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   4215
   ClientLeft      =   3345
   ClientTop       =   2085
   ClientWidth     =   5745
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4215
   ScaleWidth      =   5745
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox Content 
      BackColor       =   &H00004080&
      ForeColor       =   &H80000009&
      Height          =   285
      Left            =   120
      TabIndex        =   5
      Top             =   2640
      Width           =   5415
   End
   Begin VB.TextBox Subject 
      BackColor       =   &H00004080&
      ForeColor       =   &H80000009&
      Height          =   285
      Left            =   120
      TabIndex        =   3
      Top             =   1920
      Width           =   1695
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Cancel"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   15.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   3480
      TabIndex        =   7
      Top             =   3240
      Width           =   975
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Caption         =   "Post"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   15.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   4680
      TabIndex        =   6
      Top             =   3240
      Width           =   1335
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   "Post Content"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   2400
      Width           =   1695
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Subject"
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   1680
      Width           =   2895
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"YourPost.frx":0000
      ForeColor       =   &H8000000E&
      Height          =   615
      Left            =   120
      TabIndex        =   1
      Top             =   840
      Width           =   5535
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Posting"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   27.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   855
      Left            =   240
      TabIndex        =   0
      Top             =   120
      Width           =   5295
   End
   Begin VB.Image Image6 
      Height          =   4215
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   5760
   End
End
Attribute VB_Name = "YourPost"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
Image6.Picture = LoadPicture(IniPath & "Grh\wood.bmp")

End Sub

Private Sub Label5_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
SendData "YUP" & Subject.Text & "," & Content.Text
Unload Me
End Sub

Private Sub Label6_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me

End Sub
