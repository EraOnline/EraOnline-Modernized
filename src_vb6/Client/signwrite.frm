VERSION 5.00
Begin VB.Form signwrite 
   ClientHeight    =   1530
   ClientLeft      =   60
   ClientTop       =   60
   ClientWidth     =   6060
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   ScaleHeight     =   1530
   ScaleWidth      =   6060
   StartUpPosition =   2  'CenterScreen
   Tag             =   "0"
   Begin VB.TextBox Text1 
      BackColor       =   &H00004080&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000009&
      Height          =   285
      Left            =   360
      TabIndex        =   0
      Top             =   480
      Width           =   5295
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "DONE"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   5160
      TabIndex        =   1
      Top             =   1200
      Width           =   495
   End
   Begin VB.Image Image6 
      Height          =   7335
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   6120
   End
End
Attribute VB_Name = "signwrite"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Image1_Click()

End Sub

Private Sub Form_Load()
On Error Resume Next
Image6.Picture = LoadPicture(IniPath & "Grh\wood.bmp")

End Sub

Private Sub Label2_Click()
On Error Resume Next
SendData "WRI" & Text1.Text
Unload Me
End Sub
