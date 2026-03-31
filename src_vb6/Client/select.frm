VERSION 5.00
Begin VB.Form frmSelect 
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   2790
   ClientLeft      =   15
   ClientTop       =   15
   ClientWidth     =   3000
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2790
   ScaleWidth      =   3000
   StartUpPosition =   2  'CenterScreen
   Begin VB.Image Image3 
      Height          =   930
      Left            =   0
      Picture         =   "select.frx":0000
      Top             =   1860
      Width           =   3015
   End
   Begin VB.Image Image2 
      Height          =   930
      Left            =   0
      Picture         =   "select.frx":0DAA
      Top             =   930
      Width           =   3015
   End
   Begin VB.Image Image1 
      Height          =   930
      Left            =   0
      Picture         =   "select.frx":1B6F
      Top             =   0
      Width           =   3015
   End
End
Attribute VB_Name = "frmSelect"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Image1_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
Image2.Picture = LoadPicture(App.Path & "\grh\loginto.jpg")
Image3.Picture = LoadPicture(App.Path & "\grh\startnew.jpg")

End Sub

Private Sub Image2_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me
frmConnect.Show

End Sub

Private Sub Image2_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
Image2.Picture = LoadPicture(IniPath & "grh\loginto2.jpg")
Image3.Picture = LoadPicture(IniPath & "grh\startnew.jpg")

End Sub

Private Sub Image3_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me
Form3.Show

End Sub

Private Sub Image3_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
Image2.Picture = LoadPicture(IniPath & "grh\loginto.jpg")
Image3.Picture = LoadPicture(IniPath & "grh\startnew2.jpg")

End Sub
