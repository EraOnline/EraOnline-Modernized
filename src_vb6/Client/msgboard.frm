VERSION 5.00
Begin VB.Form msgboard 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   8250
   ClientLeft      =   1380
   ClientTop       =   240
   ClientWidth     =   9195
   ControlBox      =   0   'False
   LinkTopic       =   "Form9"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8250
   ScaleWidth      =   9195
   ShowInTaskbar   =   0   'False
   Begin VB.ListBox Posts 
      BackColor       =   &H00000000&
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000009&
      Height          =   6435
      Left            =   1320
      TabIndex        =   2
      Top             =   600
      Width           =   6315
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "Post A Message"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   20.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   1440
      TabIndex        =   3
      Top             =   7560
      Width           =   2775
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Close"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   20.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   6840
      TabIndex        =   1
      Top             =   7560
      Width           =   1575
   End
   Begin VB.Label message 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   15.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   5715
      Left            =   1680
      TabIndex        =   0
      Top             =   960
      Width           =   5610
      WordWrap        =   -1  'True
   End
End
Attribute VB_Name = "msgboard"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
msgboard.Picture = LoadPicture(IniPath & "Grh\msgboard.jpg")
End Sub

Private Sub Label1_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me
End Sub

Private Sub Label2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me
YourPost.Show
End Sub

Private Sub Posts_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
'Display the contents of the post
Dim postnumber As Integer

If Posts.ListIndex > -1 Then
    Post.Show
    postnumber = msgboard.Posts.ListIndex + 1
    Post.PostContent = Messageboard(postnumber).Post
    Post.postedby = "Posted By " & Messageboard(postnumber).Author

End If
End Sub
