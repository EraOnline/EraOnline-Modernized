VERSION 5.00
Begin VB.Form info 
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   8250
   ClientLeft      =   15
   ClientTop       =   15
   ClientWidth     =   8565
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8250
   ScaleWidth      =   8565
   StartUpPosition =   3  'Windows Default
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Close"
      Height          =   255
      Left            =   8040
      TabIndex        =   0
      Top             =   7560
      Width           =   495
   End
End
Attribute VB_Name = "info"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Label1_Click()
Unload Me

End Sub
