VERSION 5.00
Begin VB.Form frmTrade 
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
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
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
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   3765
      Left            =   6795
      TabIndex        =   1
      Top             =   600
      Width           =   3015
   End
   Begin VB.ListBox shopinv 
      BackColor       =   &H00808080&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
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
         Name            =   "Verdana"
         Size            =   9
         Charset         =   0
         Weight          =   700
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
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
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
      Picture         =   "frmTrade.frx":0000
      Stretch         =   -1  'True
      Top             =   4680
      Width           =   1575
   End
   Begin VB.Label keepername 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Npc:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   270
      Left            =   1837
      TabIndex        =   5
      Top             =   240
      Width           =   540
   End
   Begin VB.Label price 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
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
         Name            =   "Verdana"
         Size            =   9
         Charset         =   0
         Weight          =   700
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
      Picture         =   "frmTrade.frx":041A
      Stretch         =   -1  'True
      Top             =   4680
      Width           =   1575
   End
   Begin VB.Image sell 
      Height          =   495
      Left            =   7320
      Picture         =   "frmTrade.frx":0D97
      Stretch         =   -1  'True
      Top             =   4680
      Width           =   1530
   End
   Begin VB.Label Label2 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Your Inventory:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   270
      Index           =   0
      Left            =   7320
      TabIndex        =   2
      Top             =   240
      Width           =   1965
   End
   Begin VB.Image Image1 
      Height          =   5415
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   10215
   End
End
Attribute VB_Name = "frmTrade"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub buy_Click()
On Error Resume Next
Call ButtonClick
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
Call ButtonClick
Me.Hide
End Sub

Private Sub sell_Click()
On Error Resume Next
Call ButtonClick
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
frmTrade.ShowPic.Picture = Nothing
Call DrawGrhtoHdc(frmTrade.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
frmTrade.ShowPic.Picture = frmTrade.ShowPic.Image

Dim NpcWillTake As Integer
Dim Luck As Integer
Dim luck2 As Integer

Randomize
Luck = UserSkill8
If Luck < 20 Then luck2 = 2.5
If Luck < 30 Then luck2 = 2.25
If Luck < 40 Then luck2 = 2
If Luck < 50 Then luck2 = 1.75
If Luck < 60 Then luck2 = 1.5
If Luck < 70 Then luck2 = 1.25
If Luck < 80 Then luck2 = 1.2
If Luck >= 80 Then luck2 = 1

If NPCinventory(shopinv.ListIndex + 1).value > 20 Then
NpcWillTake = Int(NPCinventory(shopinv.ListIndex + 1).value * luck2)
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
Call DrawGrhtoHdc(frmTrade.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
frmTrade.ShowPic.Picture = frmTrade.ShowPic.Image
End If


End Sub

Private Sub yourinv_Click()

    On Error Resume Next
    Dim NpcWillTake As Long
    
    
    If CurrentGrh.GrhIndex = 0 Then
            InitGrh CurrentGrh, 1
    End If
    
    'Change CurrentGrh
    CurrentGrh.GrhIndex = 3
    CurrentGrh.Started = 1
    CurrentGrh.FrameCounter = 1
    CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
    frmTrade.ShowPic.Picture = Nothing
    Call DrawGrhtoHdc(frmTrade.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
    frmTrade.ShowPic.Picture = frmTrade.ShowPic.Image
    
    Label3 = ""
    Label1 = "The NPC would give:"
    levellabel = ""
    
    NpcWillTake = UserInventory(yourinv.ListIndex + 1).value / 2
    
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
        frmTrade.ShowPic.Picture = Nothing
        Call DrawGrhtoHdc(frmTrade.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
        frmTrade.ShowPic.Picture = frmTrade.ShowPic.Image
    End If
End Sub
