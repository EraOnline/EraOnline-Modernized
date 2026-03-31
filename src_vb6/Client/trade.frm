VERSION 5.00
Begin VB.Form trade 
   BackColor       =   &H80000007&
   BorderStyle     =   0  'None
   Caption         =   "Form8"
   ClientHeight    =   5355
   ClientLeft      =   900
   ClientTop       =   675
   ClientWidth     =   10215
   LinkTopic       =   "Form8"
   ScaleHeight     =   5355
   ScaleWidth      =   10215
   ShowInTaskbar   =   0   'False
   Begin VB.PictureBox ShowPic 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      ForeColor       =   &H00FFFFFF&
      Height          =   675
      Left            =   4680
      ScaleHeight     =   43
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   46
      TabIndex        =   6
      TabStop         =   0   'False
      Top             =   1680
      Width           =   720
   End
   Begin VB.ListBox yourinv 
      BackColor       =   &H00808080&
      ForeColor       =   &H8000000E&
      Height          =   3765
      Left            =   6600
      TabIndex        =   1
      Top             =   600
      Width           =   3015
   End
   Begin VB.ListBox shopinv 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000005&
      Height          =   3765
      Left            =   600
      TabIndex        =   0
      Top             =   600
      Width           =   3015
   End
   Begin VB.Label levellabel 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   4200
      TabIndex        =   8
      Top             =   3240
      Width           =   1695
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Health requiered to use this item:"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   3720
      TabIndex        =   7
      Top             =   3000
      Width           =   2775
   End
   Begin VB.Image Image2 
      Height          =   495
      Left            =   4320
      Picture         =   "trade.frx":0000
      Stretch         =   -1  'True
      Top             =   4680
      Width           =   1575
   End
   Begin VB.Label keepername 
      BackStyle       =   0  'Transparent
      Caption         =   "Npc:"
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
      Height          =   375
      Left            =   1800
      TabIndex        =   5
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label price 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   4200
      TabIndex        =   4
      Top             =   2640
      Width           =   1695
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   3960
      TabIndex        =   3
      Top             =   2400
      Width           =   2175
   End
   Begin VB.Image buy 
      Height          =   495
      Left            =   1320
      Picture         =   "trade.frx":041A
      Stretch         =   -1  'True
      Top             =   4680
      Width           =   1575
   End
   Begin VB.Image sell 
      Height          =   495
      Left            =   7320
      Picture         =   "trade.frx":0D97
      Stretch         =   -1  'True
      Top             =   4680
      Width           =   1530
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "Your Inventory:"
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
      Height          =   255
      Index           =   0
      Left            =   7320
      TabIndex        =   2
      Top             =   240
      Width           =   2055
   End
   Begin VB.Image Image1 
      Height          =   5415
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   10215
   End
End
Attribute VB_Name = "trade"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub buy_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
If shopinv.ListIndex > -1 Then
    SendData "BUY" & shopinv.ListIndex + 1
End If
End Sub

Private Sub Form_Load()
On Error Resume Next
Image1.Picture = LoadPicture(IniPath & "Grh\stone.bmp")

End Sub

Private Sub Image2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Me.Hide
End Sub

Private Sub sell_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
If UserInventory(yourinv.ListIndex + 1).equipped = 1 Then

Else

If yourinv.ListIndex > -1 Then
    SendData "SLL" & yourinv.ListIndex + 1
End If

End If
End Sub

Private Sub shopinv_Click()

On Error Resume Next

Label1 = "The NPC would take:"
Label3 = "Health requiered to use this item:"
levellabel = NPCinventory(shopinv.ListIndex + 1).level

If NPCinventory(shopinv.ListIndex + 1).level < 2 Then
levellabel = "Everyone"
End If

If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If


'Change CurrentGrh
CurrentGrh.GrhIndex = 3
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(trade.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
trade.ShowPic.Picture = trade.ShowPic.Image

Dim NpcWillTake As Long
Dim Luck As Long
Dim luck2 As Long

Randomize
Luck = UserSkill8
If Luck < 10 And Luck > -1 Then luck2 = 5
If Luck < 20 And Luck > 9 Then luck2 = 5
If Luck < 30 And Luck > 19 Then luck2 = 4.5
If Luck < 40 And Luck > 29 Then luck2 = 4
If Luck < 50 And Luck > 39 Then luck2 = 3.5
If Luck < 60 And Luck > 49 Then luck2 = 3
If Luck < 70 And Luck > 59 Then luck2 = 2.5
If Luck < 80 And Luck > 69 Then luck2 = 2
If Luck < 99 And Luck > 79 Then luck2 = 1.5
If Luck < 999999 And Luck > 99 Then luck2 = 1

If NPCinventory(shopinv.ListIndex + 1).value > 20 Then
NpcWillTake = NPCinventory(shopinv.ListIndex + 1).value * luck2
Else
NpcWillTake = NPCinventory(shopinv.ListIndex + 1).value
End If

price.Caption = NpcWillTake

If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
        End If

If NPCinventory(shopinv.ListIndex + 1).ObjIndex > 0 Then

'Change CurrentGrh
CurrentGrh.GrhIndex = NPCinventory(shopinv.ListIndex + 1).GrhIndex
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(trade.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
trade.ShowPic.Picture = trade.ShowPic.Image
End If


End Sub

Private Sub yourinv_Click()

On Error Resume Next

If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = 3
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(trade.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
trade.ShowPic.Picture = trade.ShowPic.Image

Label3 = ""
Label1 = "The NPC would give:"
levellabel = ""

Dim NpcWillTake As Long
Dim Luck As Long
Dim luck2 As Long

Randomize
Luck = UserSkill8
If Luck < 10 And Luck > -1 Then luck2 = 5
If Luck < 20 And Luck > 9 Then luck2 = 5
If Luck < 30 And Luck > 19 Then luck2 = 4.5
If Luck < 40 And Luck > 29 Then luck2 = 4
If Luck < 50 And Luck > 39 Then luck2 = 3.5
If Luck < 60 And Luck > 49 Then luck2 = 3
If Luck < 70 And Luck > 59 Then luck2 = 2.5
If Luck < 80 And Luck > 69 Then luck2 = 2
If Luck < 99 And Luck > 79 Then luck2 = 1.5
If Luck < 999999 And Luck > 99 Then luck2 = 1

If UserInventory(yourinv.ListIndex + 1).value > 20 Then
NpcWillTake = UserInventory(yourinv.ListIndex + 1).value / luck2
Else
NpcWillTake = UserInventory(yourinv.ListIndex + 1).value
End If

price.Caption = NpcWillTake

If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
        End If

If UserInventory(yourinv.ListIndex + 1).ObjIndex > 0 Then

'Change CurrentGrh
CurrentGrh.GrhIndex = UserInventory(yourinv.ListIndex + 1).GrhIndex
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(trade.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
trade.ShowPic.Picture = trade.ShowPic.Image
Else
End If
End Sub
