VERSION 5.00
Begin VB.Form Minimized 
   Caption         =   "Minimized"
   ClientHeight    =   585
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   1710
   LinkTopic       =   "Form6"
   ScaleHeight     =   585
   ScaleWidth      =   1710
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Maximize"
      Height          =   375
      Left            =   240
      TabIndex        =   0
      Top             =   120
      Width           =   1215
   End
End
Attribute VB_Name = "Minimized"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
frmMain.Show
Minimized.Hide
End Sub
