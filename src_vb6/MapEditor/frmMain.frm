VERSION 5.00
Begin VB.Form frmMain 
   BackColor       =   &H00004080&
   BorderStyle     =   0  'None
   ClientHeight    =   8685
   ClientLeft      =   15
   ClientTop       =   300
   ClientWidth     =   11970
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   Icon            =   "frmMain.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   579
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   798
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
   WindowState     =   2  'Maximized
   Begin VB.CheckBox RainLayer 
      BackColor       =   &H00004080&
      Caption         =   "View Rain"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   10440
      TabIndex        =   21
      Top             =   6600
      Width           =   1215
   End
   Begin VB.CheckBox DrawGridChk 
      BackColor       =   &H00004080&
      Caption         =   "Draw Grid"
      ForeColor       =   &H80000005&
      Height          =   315
      Left            =   10440
      TabIndex        =   20
      TabStop         =   0   'False
      Top             =   6240
      Width           =   1155
   End
   Begin VB.CheckBox WalkModeChk 
      BackColor       =   &H00004080&
      Caption         =   "Walk Mode"
      ForeColor       =   &H80000005&
      Height          =   315
      Left            =   10440
      TabIndex        =   19
      TabStop         =   0   'False
      Top             =   5880
      Width           =   1335
   End
   Begin VB.CheckBox Check1 
      BackColor       =   &H00004080&
      Caption         =   "Show Blocked Tiles"
      ForeColor       =   &H80000005&
      Height          =   435
      Left            =   10440
      TabIndex        =   18
      TabStop         =   0   'False
      Top             =   6840
      Width           =   1335
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Ultra Fast"
      Height          =   255
      Left            =   10680
      TabIndex        =   15
      Top             =   3840
      Width           =   855
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Fast"
      Height          =   255
      Left            =   10680
      TabIndex        =   14
      Top             =   3600
      Width           =   855
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Medium"
      Height          =   255
      Left            =   10680
      TabIndex        =   13
      Top             =   3360
      Width           =   855
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Normal"
      Height          =   255
      Left            =   10680
      TabIndex        =   12
      Top             =   3120
      Width           =   855
   End
   Begin VB.CommandButton bigcmd 
      Caption         =   "Big"
      Height          =   255
      Left            =   10680
      TabIndex        =   10
      Top             =   5160
      Width           =   855
   End
   Begin VB.CommandButton smalcmd 
      Caption         =   "Small"
      Height          =   255
      Left            =   10680
      TabIndex        =   9
      Top             =   4920
      Width           =   855
   End
   Begin VB.PictureBox ShowPic 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00004080&
      ForeColor       =   &H00FFFFFF&
      Height          =   1800
      Left            =   4380
      ScaleHeight     =   118
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   254
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   120
      Width           =   3840
   End
   Begin VB.TextBox StatTxt 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      ForeColor       =   &H00FFFFFF&
      Height          =   1575
      Left            =   60
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   2
      TabStop         =   0   'False
      Text            =   "frmMain.frx":0442
      Top             =   330
      Width           =   2775
   End
   Begin VB.Timer FPSTimer 
      Interval        =   1000
      Left            =   7560
      Top             =   960
   End
   Begin VB.ListBox MapLst 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      ForeColor       =   &H00FFFFFF&
      Height          =   1590
      Left            =   3060
      TabIndex        =   0
      Top             =   360
      Width           =   1095
   End
   Begin VB.Line Line2 
      X1              =   688
      X2              =   792
      Y1              =   376
      Y2              =   376
   End
   Begin VB.Shape Shape2 
      Height          =   855
      Left            =   600
      Top             =   7680
      Width           =   11295
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Spotlight Studios"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   9600
      TabIndex        =   17
      Top             =   360
      Width           =   1695
   End
   Begin VB.Line Line1 
      X1              =   688
      X2              =   792
      Y1              =   288
      Y2              =   288
   End
   Begin VB.Shape Shape1 
      Height          =   5295
      Left            =   10320
      Top             =   2280
      Width           =   1575
   End
   Begin VB.Label Scroll 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Normal"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   10560
      TabIndex        =   16
      Top             =   2760
      Width           =   975
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Scroll Speed:"
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   10560
      TabIndex        =   11
      Top             =   2400
      Width           =   1095
   End
   Begin VB.Label brushsize 
      BackStyle       =   0  'Transparent
      Caption         =   "Small"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   10800
      TabIndex        =   8
      Top             =   4680
      Width           =   615
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "Brush Size:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   10680
      TabIndex        =   7
      Top             =   4440
      Width           =   855
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "       ERA ONLINE         WORLD DESIGNER"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   1455
      Left            =   8640
      TabIndex        =   6
      Top             =   600
      Width           =   3495
   End
   Begin VB.Shape MainViewShp 
      Height          =   5280
      Left            =   600
      Top             =   2280
      Visible         =   0   'False
      Width           =   9600
   End
   Begin VB.Label Label5 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Maps:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   240
      Left            =   3300
      TabIndex        =   4
      Top             =   60
      Width           =   645
   End
   Begin VB.Label Label4 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Info:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   240
      Left            =   1020
      TabIndex        =   3
      Top             =   60
      Width           =   450
   End
   Begin VB.Label FPSLbl 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      BorderStyle     =   1  'Fixed Single
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   15.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   420
      Left            =   12000
      TabIndex        =   1
      Top             =   1440
      Visible         =   0   'False
      Width           =   675
   End
   Begin VB.Menu FileMnu 
      Caption         =   "File"
      Begin VB.Menu SaveMnu 
         Caption         =   "Save"
      End
      Begin VB.Menu SaveNewMnu 
         Caption         =   "Save as New Map"
      End
      Begin VB.Menu quitter 
         Caption         =   "Quit Without Saving"
      End
   End
   Begin VB.Menu OptionMnu 
      Caption         =   "Options"
      Begin VB.Menu ClsRoomMnu 
         Caption         =   "Clear Map"
      End
      Begin VB.Menu clreast 
         Caption         =   "Clear East Border"
      End
      Begin VB.Menu clrwest 
         Caption         =   "Clear West Border"
      End
      Begin VB.Menu ClrSouth 
         Caption         =   "Clear South Border"
      End
      Begin VB.Menu ClrNorth 
         Caption         =   "Clear North Border"
      End
      Begin VB.Menu ClsBordMnu 
         Caption         =   "Clear All Borders"
      End
   End
   Begin VB.Menu help1 
      Caption         =   "Help"
      Begin VB.Menu help3 
         Caption         =   "About"
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub Blockedchk_Click()

Call PlaceBlockCmd_Click

End Sub

Private Sub Check1_Click()

If DrawBlock = True Then
    DrawBlock = False
Else
    DrawBlock = True
End If

End Sub

Private Sub bigcmd_Click()
brushsize = "Big"
MsgBox "Warning: When using BIG brush size, the program may crash sometimes ! Save before use !"

End Sub

Private Sub clreast_Click()
Dim y As Integer
Dim x As Integer

If CurMap = 0 Then
    Exit Sub
End If

For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize

        If x > 92 Then

            MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt)

            'Setup GRH for layer

            InitGrh MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)), Val(toolbox.Grhtxt.Text)
End If

Next x
Next y

End Sub

Private Sub ClrNorth_Click()
Dim y As Integer
Dim x As Integer

If CurMap = 0 Then
    Exit Sub
End If

For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize

        If y < 6 Then

            MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt)

            'Setup GRH for layer

            InitGrh MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)), Val(toolbox.Grhtxt.Text)
End If

Next x
Next y

End Sub

Private Sub ClrSouth_Click()
Dim y As Integer
Dim x As Integer

If CurMap = 0 Then
    Exit Sub
End If

For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize

        If y > 95 Then

            MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt)

            'Setup GRH for layer

            InitGrh MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)), Val(toolbox.Grhtxt.Text)
End If

Next x
Next y
End Sub

Private Sub clrwest_Click()
Dim y As Integer
Dim x As Integer

If CurMap = 0 Then
    Exit Sub
End If

For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize

        If x < 9 Then

            MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt)

            'Setup GRH for layer

            InitGrh MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)), Val(toolbox.Grhtxt.Text)
End If

Next x
Next y
End Sub

Private Sub ClsBordMnu_Click()

'*****************************************************************
'Clears a border in a room with current GRH
'*****************************************************************

Dim y As Integer
Dim x As Integer

If CurMap = 0 Then
    Exit Sub
End If

For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize

        If x < MinXBorder Or x > MaxXBorder Or y < MinYBorder Or y > MaxYBorder Then

            MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt)

            'Setup GRH for layer

            InitGrh MapData(x, y).Graphic(Val(toolbox.Layertxt.Text)), Val(toolbox.Grhtxt.Text)

            'Erase NPCs
            If MapData(x, y).NPCIndex > 0 Then
                EraseChar MapData(x, y).CharIndex
                MapData(x, y).NPCIndex = 0
            End If

            'Erase Objs
            MapData(x, y).OBJInfo.OBJIndex = 0
            MapData(x, y).OBJInfo.Amount = 0
            MapData(x, y).ObjGrh.GrhIndex = 0

            'Clear exits
            MapData(x, y).TileExit.map = 0
            MapData(x, y).TileExit.x = 0
            MapData(x, y).TileExit.y = 0

        End If

    Next x
Next y

'Set changed flag
MapInfo.Changed = 1

End Sub

Private Sub ClsRoomMnu_Click()
'*****************************************************************
'Clears all layers
'*****************************************************************

Dim y As Integer
Dim x As Integer

If CurMap = 0 Then
    Exit Sub
End If

For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize

        'Change blockes status
        MapData(x, y).Blocked = toolbox.Blockedchk.value
        

        'Erase layer 2 and 3
        MapData(x, y).Graphic(2).GrhIndex = 0
        MapData(x, y).Graphic(3).GrhIndex = 0

        'Erase NPCs
        If MapData(x, y).NPCIndex > 0 Then
            EraseChar MapData(x, y).CharIndex
            MapData(x, y).NPCIndex = 0
        End If

        'Erase Objs
        MapData(x, y).OBJInfo.OBJIndex = 0
        MapData(x, y).OBJInfo.Amount = 0
        MapData(x, y).ObjGrh.GrhIndex = 0

        'Clear exits
        MapData(x, y).TileExit.map = 0
        MapData(x, y).TileExit.x = 0
        MapData(x, y).TileExit.y = 0

        'Place layer 1
        MapData(x, y).Graphic(1).GrhIndex = Val(toolbox.Grhtxt)

        'Setup GRH for layer 1
        InitGrh MapData(x, y).Graphic(1), Val(toolbox.Grhtxt.Text)



    Next x
Next y

'Set changed flag
MapInfo.Changed = 1

End Sub


Private Sub Command1_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
ScrollSpeed = 8
Scroll.Caption = "Normal"

End Sub


Private Sub Command2_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
ScrollSpeed = 15
Scroll.Caption = "Medium"

End Sub

Private Sub Command5_Click()

Dim map As Integer

For map = 2 To NumMaps

SwitchMap (map)
Call SaveMapData(map)

Next map

MsgBox "CONVERTING ALL WORLD FILES DONE !"

End Sub

Private Sub Command6_Click()

            
End Sub

Private Sub DrawGridChk_Click()

If DrawGrid = True Then
    DrawGrid = False
Else
    DrawGrid = True
End If

End Sub

Private Sub EraseAllchk_Click()

'Set Place GRh mode
Call PlaceGrhCmd_Click

toolbox.Erasechk.value = False


End Sub

Private Sub Erasechk_Click()

'Set Place GRh mode
Call PlaceGrhCmd_Click

toolbox.EraseAllchk.value = False

End Sub

Private Sub EraseExitChk_Click()

Call PlaceExitCmd_Click

End Sub

Private Sub EraseNPCChk_Click()

Call PlaceNPCCmd_Click

End Sub

Private Sub EraseObjChk_Click()

Call PlaceObjCmd_Click

End Sub

Private Sub Command3_Click()
ScrollSpeed = 25
Scroll.Caption = "Fast"
End Sub

Private Sub Command4_Click()
ScrollSpeed = 30
Scroll.Caption = "Ultra Fast"
End Sub

Private Sub Form_Click()
toolbox.Show
End Sub

Private Sub Form_Load()
toolbox.Show

End Sub

Private Sub Form_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)

Dim tX As Integer
Dim tY As Integer

'Make sure map is loaded
If CurMap <= 0 Then Exit Sub

'Make sure click is in view window
If x <= MainViewShp.Left Or x >= MainViewShp.Left + MainViewWidth Or y <= MainViewShp.Top Or y >= MainViewShp.Top + MainViewHeight Then
    Exit Sub
End If

ConvertCPtoTP x, y, tX, tY

ReacttoMouseClick Button, tX, tY

End Sub


Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)

Dim tX As Integer
Dim tY As Integer

'Make sure map is loaded
If CurMap <= 0 Then Exit Sub

'Make sure click is in view window
If x <= MainViewShp.Left Or x >= MainViewShp.Left + MainViewWidth Or y <= MainViewShp.Top Or y >= MainViewShp.Top + MainViewHeight Then
    Exit Sub
End If

ConvertCPtoTP x, y, tX, tY

ReacttoMouseClick Button, tX, tY

End Sub


Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

'Allow MainLoop to close program
If prgRun = True Then
    prgRun = False
    Cancel = 1
End If

End Sub

Private Sub FPSTimer_Timer()

'Display and reset FPS
FPSLbl.Caption = FramesPerSec
FramesPerSec = 0

End Sub




Private Sub Grhtxt_Change()

If Val(toolbox.Grhtxt.Text) < 1 Then
  toolbox.Grhtxt.Text = NumGrhs
  Exit Sub
End If

If Val(toolbox.Grhtxt.Text) > NumGrhs Then
  toolbox.Grhtxt.Text = 1
  Exit Sub
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = Val(toolbox.Grhtxt.Text)
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed

End Sub


Private Sub help2_Click()

End Sub

Private Sub help3_Click()
frmAbout.Show
End Sub

Private Sub Layertxt_Change()

If Val(toolbox.Layertxt.Text) < 1 Then
  toolbox.Layertxt.Text = 1
End If

If Val(toolbox.Layertxt.Text) > 3 Then
  toolbox.Layertxt.Text = 3
End If

Call PlaceGrhCmd_Click

End Sub


Private Sub MainPic_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
End Sub



Private Sub MapExitTxt_Change()

If Val(toolbox.MapExitTxt.Text) < 1 Then
  toolbox.MapExitTxt.Text = 1
End If

If Val(toolbox.MapExitTxt.Text) > NumMaps Then
  toolbox.MapExitTxt.Text = NumMaps
End If

Call PlaceExitCmd_Click

End Sub

Private Sub MapLst_DblClick()
'*****************************************************************
'Switch maps
'*****************************************************************

'Check for changes
If MapInfo.Changed = 1 Then
    If MsgBox("Changes have been made to the current map. You will lose all changes if not saved. Save now?", vbYesNo) = vbYes Then
        Call PlaceRain
        Call SaveMapData(CurMap)
    End If
End If

'Set user pos and load map
If MapLst.ListIndex <> -1 Then
    UserPos.x = (XWindow \ 2) + 1
    UserPos.y = (YWindow \ 2) + 1
    Call SwitchMap(MapLst.ListIndex + 1)
    EngineRun = True
Else
    MsgBox ("No map selected.")
End If

End Sub



Private Sub NPCLst_Click()

Call PlaceNPCCmd_Click

End Sub

Private Sub OBJAmountTxt_Change()

If Val(toolbox.OBJAmountTxt.Text) > MAX_INVENORY_OBJS Then
    toolbox.OBJAmountTxt.Text = 0
End If

If Val(toolbox.OBJAmountTxt.Text) < 1 Then
    toolbox.OBJAmountTxt.Text = MAX_INVENORY_OBJS
End If

End Sub

Private Sub ObjLst_Click()

Call PlaceObjCmd_Click

End Sub

Private Sub PlaceBlockCmd_Click()

toolbox.PlaceGrhCmd.Enabled = True
toolbox.PlaceBlockCmd.Enabled = False
toolbox.PlaceExitCmd.Enabled = True
toolbox.PlaceNPCCmd.Enabled = True
toolbox.PlaceObjCmd.Enabled = True

End Sub

Private Sub PlaceExitCmd_Click()

toolbox.PlaceGrhCmd.Enabled = True
toolbox.PlaceBlockCmd.Enabled = True
toolbox.PlaceExitCmd.Enabled = False
toolbox.PlaceNPCCmd.Enabled = True
toolbox.PlaceObjCmd.Enabled = True

End Sub

Private Sub PlaceGrhCmd_Click()

toolbox.PlaceGrhCmd.Enabled = False
toolbox.PlaceBlockCmd.Enabled = True
toolbox.PlaceExitCmd.Enabled = True
toolbox.PlaceNPCCmd.Enabled = True
toolbox.PlaceObjCmd.Enabled = True

End Sub


Private Sub PlaceNPCCmd_Click()

toolbox.PlaceGrhCmd.Enabled = True
toolbox.PlaceBlockCmd.Enabled = True
toolbox.PlaceExitCmd.Enabled = True
toolbox.PlaceNPCCmd.Enabled = False
toolbox.PlaceObjCmd.Enabled = True

End Sub


Private Sub PlaceObjCmd_Click()

toolbox.PlaceGrhCmd.Enabled = True
toolbox.PlaceBlockCmd.Enabled = True
toolbox.PlaceExitCmd.Enabled = True
toolbox.PlaceNPCCmd.Enabled = True
toolbox.PlaceObjCmd.Enabled = False

End Sub

Private Sub quitter_Click()
End
End Sub

Private Sub SaveMnu_Click()

If CurMap = 0 Then
    Exit Sub
End If

Call PlaceRain
Call SaveMapData(CurMap)

'Set changed flag
MapInfo.Changed = 0

End Sub


Private Sub SaveNewMnu_Click()

If CurMap = 0 Then
    Exit Sub
End If

NumMaps = NumMaps + 1
Call PlaceRain
Call SaveMapData(NumMaps)
frmMain.MapLst.AddItem "Map " & NumMaps, NumMaps - 1

End Sub


Private Sub WalkModeChk_Click()

ToggleWalkMode

End Sub


Private Sub XExitTxt_Change()

If Val(toolbox.XExitTxt.Text) < XMinMapSize Then
  toolbox.XExitTxt.Text = XMinMapSize
End If

If Val(toolbox.XExitTxt.Text) > XMaxMapSize Then
  toolbox.XExitTxt.Text = XMaxMapSize
End If

Call PlaceExitCmd_Click

End Sub




Private Sub YExitTxt_Change()

If Val(toolbox.YExitTxt.Text) < YMinMapSize Then
  toolbox.YExitTxt.Text = YMinMapSize
End If

If Val(toolbox.YExitTxt.Text) > YMaxMapSize Then
  toolbox.YExitTxt.Text = YMaxMapSize
End If

Call PlaceExitCmd_Click

End Sub


Private Sub smalcmd_Click()
brushsize = "Small"
End Sub

