VERSION 5.00
Begin VB.Form gmhelp 
   BackColor       =   &H80000007&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   7305
   ClientLeft      =   2685
   ClientTop       =   240
   ClientWidth     =   6615
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7305
   ScaleWidth      =   6615
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   375
      Left            =   2160
      TabIndex        =   4
      Top             =   6840
      Width           =   2175
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   $"gmhelp.frx":0000
      ForeColor       =   &H8000000E&
      Height          =   975
      Left            =   240
      TabIndex        =   5
      Top             =   4560
      Width           =   6015
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   $"gmhelp.frx":0095
      ForeColor       =   &H8000000E&
      Height          =   975
      Left            =   240
      TabIndex        =   3
      Top             =   3240
      Width           =   5655
   End
   Begin VB.Line Line1 
      BorderColor     =   &H80000009&
      X1              =   240
      X2              =   6240
      Y1              =   2040
      Y2              =   2040
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   $"gmhelp.frx":020C
      ForeColor       =   &H8000000E&
      Height          =   855
      Left            =   240
      TabIndex        =   2
      Top             =   2280
      Width           =   6135
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"gmhelp.frx":0376
      ForeColor       =   &H8000000E&
      Height          =   1215
      Left            =   240
      TabIndex        =   1
      Top             =   720
      Width           =   6135
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Some Help With This GM Tool:"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   6135
   End
   Begin VB.Image Image6 
      Height          =   8775
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   6615
   End
End
Attribute VB_Name = "gmhelp"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me
gmtool.Show
End Sub

Private Sub Form_Load()
On Error Resume Next
Image6.Picture = LoadPicture(IniPath & "Grh\wood.bmp")

End Sub

