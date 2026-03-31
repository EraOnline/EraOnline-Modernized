VERSION 5.00
Begin VB.Form signread 
   ClientHeight    =   1185
   ClientLeft      =   60
   ClientTop       =   60
   ClientWidth     =   6015
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   ScaleHeight     =   1185
   ScaleWidth      =   6015
   StartUpPosition =   2  'CenterScreen
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      ForeColor       =   &H8000000E&
      Height          =   735
      Left            =   120
      TabIndex        =   0
      Top             =   360
      Width           =   5655
   End
   Begin VB.Image Image6 
      Height          =   7335
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   6120
   End
End
Attribute VB_Name = "signread"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
Image6.Picture = LoadPicture(IniPath & "Grh\wood.bmp")

End Sub

Private Sub Image6_Click()
On Error Resume Next
Unload Me

End Sub

Private Sub Label1_Click()
On Error Resume Next
Unload Me

End Sub
