VERSION 5.00
Begin VB.Form gmque 
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   4155
   ClientLeft      =   3300
   ClientTop       =   2565
   ClientWidth     =   5760
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4155
   ScaleWidth      =   5760
   Begin VB.CommandButton Command2 
      Caption         =   "Close"
      Height          =   255
      Left            =   3720
      TabIndex        =   3
      Top             =   3600
      Width           =   1815
   End
   Begin VB.ListBox que 
      BackColor       =   &H00000000&
      ForeColor       =   &H80000009&
      Height          =   1425
      Left            =   240
      TabIndex        =   1
      Top             =   600
      Width           =   5295
   End
   Begin VB.Label helpmsg 
      BackStyle       =   0  'Transparent
      ForeColor       =   &H8000000E&
      Height          =   975
      Left            =   360
      TabIndex        =   4
      Top             =   2400
      Width           =   5055
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "What this person wrote:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   240
      TabIndex        =   2
      Top             =   2040
      Width           =   4455
   End
   Begin VB.Shape Shape1 
      BorderColor     =   &H80000009&
      Height          =   1215
      Left            =   240
      Top             =   2280
      Width           =   5295
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "GameMaster HELP QUE"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   14.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   735
      Left            =   120
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
Attribute VB_Name = "gmque"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command2_Click()
On Error Resume Next
Unload Me

End Sub

Private Sub Form_Load()
On Error Resume Next
Image6.Picture = LoadPicture(IniPath & "Grh\wood.bmp")

End Sub

Private Sub que_Click()
On Error Resume Next

On Error Resume Next

helpmsg = GmHelps(que.ListIndex + 1).helpmsg


End Sub

Private Sub que_DblClick()
On Error Resume Next
If GmHelps(que.ListIndex + 1).userindex <= 0 Then
Exit Sub
End If

SendData "GMH" & que.ListIndex + 1

End Sub
