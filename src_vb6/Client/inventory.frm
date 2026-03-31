VERSION 5.00
Begin VB.Form inventory 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   6375
   ClientLeft      =   15
   ClientTop       =   465
   ClientWidth     =   11970
   ControlBox      =   0   'False
   LinkTopic       =   "Form9"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6375
   ScaleWidth      =   11970
   Begin VB.PictureBox shield 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H80000007&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   615
      Left            =   960
      ScaleHeight     =   615
      ScaleWidth      =   375
      TabIndex        =   19
      Top             =   4080
      Width           =   375
   End
   Begin VB.PictureBox weapon 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H80000006&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   615
      Left            =   960
      ScaleHeight     =   615
      ScaleWidth      =   375
      TabIndex        =   18
      Top             =   3120
      Width           =   375
   End
   Begin VB.PictureBox head 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   615
      Left            =   960
      ScaleHeight     =   615
      ScaleWidth      =   375
      TabIndex        =   17
      Top             =   1200
      Width           =   375
   End
   Begin VB.PictureBox body 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H80000006&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   615
      Left            =   910
      ScaleHeight     =   615
      ScaleWidth      =   450
      TabIndex        =   16
      Top             =   2160
      Width           =   450
   End
   Begin VB.PictureBox ShowPic 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      ForeColor       =   &H00FFFFFF&
      Height          =   915
      Left            =   10440
      ScaleHeight     =   59
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   38
      TabIndex        =   2
      TabStop         =   0   'False
      Top             =   2640
      Width           =   600
   End
   Begin VB.TextBox DrpAmountTxt 
      Appearance      =   0  'Flat
      BackColor       =   &H80000007&
      ForeColor       =   &H80000009&
      Height          =   285
      Left            =   12000
      TabIndex        =   1
      Text            =   "1"
      Top             =   9999
      Width           =   1815
   End
   Begin VB.ListBox ObjLst 
      BackColor       =   &H80000006&
      ForeColor       =   &H80000005&
      Height          =   1230
      Left            =   7920
      TabIndex        =   0
      Top             =   2640
      Width           =   2415
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "To use/drop etc. an object, click on it with the RIGHT MOUSE button."
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   7920
      TabIndex        =   22
      Top             =   3960
      Width           =   2655
   End
   Begin VB.Label RepRank 
      BackStyle       =   0  'Transparent
      Caption         =   "Label6"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   5400
      TabIndex        =   21
      Top             =   1560
      Width           =   2175
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Caption         =   "Drop Some Gold"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   3000
      TabIndex        =   20
      Top             =   6120
      Width           =   1335
   End
   Begin VB.Label class 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   5040
      TabIndex        =   15
      Top             =   360
      Width           =   1335
   End
   Begin VB.Label status 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3840
      TabIndex        =   14
      Top             =   360
      Width           =   2535
   End
   Begin VB.Label navn 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   720
      TabIndex        =   13
      Top             =   360
      Width           =   2295
   End
   Begin VB.Label fatigue 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   960
      TabIndex        =   12
      Top             =   5640
      Width           =   1335
   End
   Begin VB.Label drink 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   720
      TabIndex        =   11
      Top             =   5160
      Width           =   1575
   End
   Begin VB.Label food 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   2880
      TabIndex        =   10
      Top             =   5160
      Width           =   1455
   End
   Begin VB.Label gold 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   2880
      TabIndex        =   9
      Top             =   5640
      Width           =   1455
   End
   Begin VB.Label mana 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5160
      TabIndex        =   8
      Top             =   5160
      Width           =   1215
   End
   Begin VB.Label strenght 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5160
      TabIndex        =   7
      Top             =   5640
      Width           =   1215
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Height          =   495
      Left            =   7320
      TabIndex        =   6
      Top             =   5640
      Width           =   975
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Height          =   495
      Left            =   8400
      TabIndex        =   5
      Top             =   5640
      Width           =   975
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Height          =   495
      Left            =   9360
      TabIndex        =   4
      Top             =   5640
      Width           =   1095
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Height          =   495
      Left            =   10440
      TabIndex        =   3
      Top             =   5640
      Width           =   1095
   End
   Begin VB.Menu mnufile 
      Caption         =   "mnufile"
      Visible         =   0   'False
      Begin VB.Menu mnufile2 
         Caption         =   "Use"
      End
      Begin VB.Menu mnufile3 
         Caption         =   "Drop"
      End
      Begin VB.Menu mnufile4 
         Caption         =   "Give"
      End
      Begin VB.Menu mnufile5 
         Caption         =   "Evaluate"
      End
      Begin VB.Menu mnufile6 
         Caption         =   "Unequip"
      End
      Begin VB.Menu mnufile7 
         Caption         =   "Discard"
      End
   End
End
Attribute VB_Name = "inventory"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub DropCmd_Click()
On Error Resume Next


Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


'Send the drop command
If ObjLst.ListIndex > -1 Then
    SendData "DRP" & ObjLst.ListIndex + 1 & "," & DrpAmountTxt.Text
End If
End Sub

Private Sub DrpAmountTxt_Change()
On Error Resume Next

'Make sure amount is legal
If DrpAmountTxt.Text < 1 Then
    DrpAmountTxt.Text = MAX_INVENTORY_OBJS
End If

If DrpAmountTxt.Text > MAX_INVENTORY_OBJS Then
    DrpAmountTxt.Text = 1
End If
End Sub

Private Sub Form_Load()
On Error Resume Next
gold = UserGLD
food = UserFood
drink = UserDrink
strenght = UserMaxHP
mana = UserMaxMAN
fatigue = UserMaxSTA
navn = UserName
inventory.Picture = LoadPicture(IniPath & "Grh\charsht.jpg")

End Sub

Private Sub GetCmd_Click()


End Sub

Private Sub Image3_Click()
On Error Resume Next
If food > 0 Then
food = food - 1
SendData "EAT"
End If
End Sub

Private Sub Image4_Click()
On Error Resume Next
If drink > 0 Then
drink = drink - 1
SendData "DRK"
End If
End Sub

Private Sub Label1_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Me.Hide

End Sub

Private Sub Label2_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Me.Hide
Form1.Show

End Sub

Private Sub Label3_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Me.Hide
skills.Show
End Sub

Private Sub Label4_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Me.Hide
SendData "UPS"
spellbook.Show
End Sub

Private Sub Label5_Click()
On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


dropgold.Show

End Sub

Private Sub mnufile2_Click()
On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")



'Send use command
If ObjLst.ListIndex > -1 Then
    SendData "USE" & ObjLst.ListIndex + 1
End If

End Sub
Private Sub mnufile6_Click()

On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


'Send unequip command
If ObjLst.ListIndex > -1 Then
    SendData "UNQ" & ObjLst.ListIndex + 1
End If

End Sub

Private Sub mnufile3_Click()

On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


'Send the drop command
If ObjLst.ListIndex > -1 Then
    SendData "DRP" & ObjLst.ListIndex + 1 & "," & DrpAmountTxt.Text
End If
End Sub

Private Sub ObjLst_Click()

On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")



If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
        End If
        
'Change CurrentGrh
CurrentGrh.GrhIndex = 3
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.ShowPic.Picture = inventory.ShowPic.Image

If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

If UserInventory(ObjLst.ListIndex + 1).ObjIndex > 0 Then

'Change CurrentGrh
CurrentGrh.GrhIndex = UserInventory(ObjLst.ListIndex + 1).GrhIndex
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.ShowPic.Picture = inventory.ShowPic.Image
Else
End If

End Sub

Private Sub ObjLst_ItemCheck(Item As Integer)

On Error Resume Next


ShowPic.Cls


If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
        End If

If UserInventory(ObjLst.ListIndex + 1).ObjIndex > 0 Then

'Change CurrentGrh
CurrentGrh.GrhIndex = UserInventory(ObjLst.ListIndex + 1).GrhIndex
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.ShowPic.Picture = inventory.ShowPic.Image
Else
End If


End Sub

Private Sub ObjLst_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
On Error Resume Next
If Button = 2 Then

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
PopupMenu mnufile
End If

End Sub

Private Sub UseCmd_Click()
On Error Resume Next


Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

'Send use command
If ObjLst.ListIndex > -1 Then
    SendData "USE" & ObjLst.ListIndex + 1
End If
End Sub

Private Sub mnufile4_Click()
On Error Resume Next


Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

'Send GIVE command
If ObjLst.ListIndex > -1 Then
    SendData "GIV" & ObjLst.ListIndex + 1
End If
End Sub

Private Sub mnufile5_Click()

On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


'Send evaluate command
If ObjLst.ListIndex > -1 Then
    SendData "EVA" & ObjLst.ListIndex + 1
End If
End Sub

Private Sub mnufile7_Click()
On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

'Send evaluate command
If ObjLst.ListIndex > -1 Then
    SendData "DIS" & ObjLst.ListIndex + 1
End If
End Sub
