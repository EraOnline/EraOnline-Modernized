VERSION 5.00
Begin VB.Form tip 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   4365
   ClientLeft      =   2910
   ClientTop       =   1635
   ClientWidth     =   6105
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4365
   ScaleWidth      =   6105
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Height          =   495
      Left            =   4560
      TabIndex        =   2
      Top             =   3600
      Width           =   1215
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Height          =   495
      Left            =   3240
      TabIndex        =   1
      Top             =   3600
      Width           =   1215
   End
   Begin VB.Label thetip 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   2775
      Left            =   360
      TabIndex        =   0
      Top             =   720
      Width           =   5415
   End
End
Attribute VB_Name = "tip"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
Dim TIPNUMBER As Integer
Dim NumTips As Integer
Dim tips As String

tip.Picture = LoadPicture(IniPath & "Grh\tip.jpg")

NumTips = Val(GetVar(IniPath & "Tips.txt", "INIT", "NumTIPs"))

TIPNUMBER = Int(RandomNumber(1, NumTips))

tips = GetVar(IniPath & "Tips.txt", "TIP" & TIPNUMBER, "Tip")

tip.thetip.Caption = tips

End Sub

Private Sub Label1_Click()
On Error Resume Next

Dim TIPNUMBER As Integer
Dim NumTips As Integer
Dim tips As String

NumTips = Val(GetVar(IniPath & "Tips.txt", "INIT", "NumTIPs"))

TIPNUMBER = Int(RandomNumber(1, NumTips))

tips = GetVar(IniPath & "Tips.txt", "TIP" & TIPNUMBER, "Tip")

tip.thetip.Caption = tips

End Sub

Private Sub Label2_Click()
On Error Resume Next

Unload Me
hearye.Show

End Sub

