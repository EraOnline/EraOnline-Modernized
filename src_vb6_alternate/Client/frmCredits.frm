VERSION 5.00
Begin VB.Form frmCredits 
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   ClientHeight    =   9000
   ClientLeft      =   4005
   ClientTop       =   2070
   ClientWidth     =   12000
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   ScaleHeight     =   9000
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
End
Attribute VB_Name = "frmCredits"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Click()
On Error Resume Next
Unload Me

End Sub

Private Sub Form_Load()
On Error Resume Next
Me.Picture = LoadPicture(IniPath & "Grh\credits.jpg")
End Sub
