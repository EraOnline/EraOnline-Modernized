Attribute VB_Name = "General"
Option Explicit

Sub ConvertCPtoTP(ByVal CX As Single, ByVal CY As Single, tX As Integer, tY As Integer)
'******************************************
'Converts where the user click in the main window
'to a tile position
'******************************************
Dim HWindowX As Integer
Dim HWindowY As Integer

CX = CX - frmMain.MainViewShp.Left
CY = CY - frmMain.MainViewShp.Top

HWindowX = (XWindow \ 2)
HWindowY = (YWindow \ 2)

'Figure out X and Y tiles
CX = (CX \ TileSizeX)
CY = (CY \ TileSizeY)

If CX > HWindowX Then
    CX = (CX - HWindowX)

Else
    If CX < HWindowX Then
        CX = (0 - (HWindowX - CX))
    Else
        CX = 0
    End If
End If

If CY > HWindowY Then
    CY = (0 - (HWindowY - CY))
Else
    If CY < HWindowY Then
        CY = (CY - HWindowY)
    Else
        CY = 0
    End If
End If

tX = UserPos.x + CX
tY = UserPos.y + CY

End Sub

Sub Main()
'*****************************************************************
'Main
'*****************************************************************
Dim retcode As Integer
Dim OffsetCounterX As Integer
Dim OffsetCounterY As Integer
Dim SurfaceDesc As DDSURFACEDESC2
Dim LoopC As Integer

'***************************************************
'Start up
'***************************************************
'****** INIT vars ******
IniPath = App.Path & "\"
ENDL = Chr(13) & Chr(10)

'Setup borders
MinXBorder = XMinMapSize + (XWindow \ 3)
MaxXBorder = XMaxMapSize - (XWindow \ 3)
MinYBorder = YMinMapSize + (YWindow \ 2)
MaxYBorder = YMaxMapSize - (YWindow \ 2)

MainViewWidth = TileSizeX * XWindow
MainViewHeight = TileSizeY * YWindow
ScrollSpeed = 8

'****** Check and setup screen ******
Call DesktopHandle
hdccaps = GetDC(hdesktopwnd)
'Bits per pixel.
DisplayBits = GetDeviceCaps(hdccaps, 12)
'Horz. Resolution.
DisplayWidth = GetDeviceCaps(hdccaps, 8)
'Vert. Resolution.
DisplayHeight = GetDeviceCaps(hdccaps, 10)
'Release it
retcode = ReleaseDC(hdesktopwnd, hdccaps)

'If smaller than 800x600 and 16 bit, terminate.
If DisplayWidth < 800 Or DisplayHeight < 600 Or DisplayBits < 16 Then
MsgBox "WARNING: This game can only be run in 800x600 Screen Resulution and 16 Bits of color. Program will quit now."
End
End If

'If bigger than 800x600 and 16 bit, terminate.
If DisplayWidth > 800 Or DisplayHeight > 600 Or DisplayBits > 16 Then
MsgBox "WARNING: This game can only be run in 800x600 Screen Resulution and 16 Bits of color. Program will quit now."
End
End If

'If 800 by 600 maximize form
If DisplayWidth = 800 And DisplayHeight = 600 Then
    frmMain.WindowState = 2
End If

'****** INIT DirectDraw ******
' Create the root DirectDraw object
DirectDrawCreate ByVal 0&, DirectDraw, Nothing
DirectDraw.SetCooperativeLevel 0, DDSCL_NORMAL

'Primary Surface
' Fill the surface description structure
With SurfaceDesc
    .dwSize = Len(SurfaceDesc)        ' Indicates what members are valid
    .dwFlags = DDSD_CAPS
    .DDSCAPS.dwCaps = DDSCAPS_PRIMARYSURFACE
End With
' Create the surface
DirectDraw.CreateSurface SurfaceDesc, PrimarySurface, Nothing
'Create clipper
DirectDraw.CreateClipper 0, PrimaryClipper, Nothing
PrimaryClipper.SetHWnd 0, frmMain.hWnd
PrimarySurface.SetClipper PrimaryClipper



'Back Buffer Surface
With BackBufferRect
    .Left = 0
    .Top = 0
    .Right = TileSizeX * (XWindow + (2 * ScreenBuffer))
    .bottom = TileSizeY * (YWindow + (2 * ScreenBuffer))
End With
With SurfaceDesc
    .dwSize = Len(SurfaceDesc)
    .dwFlags = DDSD_CAPS Or DDSD_HEIGHT Or DDSD_WIDTH
    .DDSCAPS.dwCaps = DDSCAPS_OFFSCREENPLAIN Or DDSCAPS_SYSTEMMEMORY
    .dwWidth = BackBufferRect.Right
    .dwHeight = BackBufferRect.bottom
End With
' Create surface
DirectDraw.CreateSurface SurfaceDesc, BackBufferSurface, Nothing

'****** Load files into memory ******
Call LoadGrhData
Call LoadBodyData
Call LoadHeadData
Call LoadGraphics
Call LoadMapData
Call LoadNPCData
Call LoadOBJData

'****** Show frmmain ******
frmMain.Show
tip.Show

'***************************************************
'Main Loop
'***************************************************
prgRun = True
Do While prgRun
    
    '****** Set main view rectangle ******
    With MainViewRect
        .Left = (frmMain.Left / Screen.TwipsPerPixelX) + MainViewOffsetX
        .Top = (frmMain.Top / Screen.TwipsPerPixelY) + MainViewOffsetY
        .Right = .Left + MainViewWidth
        .bottom = .Top + MainViewHeight
    End With

    '***** Check if engine is allowed to run ******
    If EngineRun Then
        'Make sure frmmain isn't minimized
        If frmMain.WindowState <> vbMinimized Then
            'Make sure noone goes above 30 FPS
            If FramesPerSec <= 30 Then
        
                '****** Move screen Left and Right if needed ******
                If AddtoUserPos.x <> 0 Then
                    OffsetCounterX = (OffsetCounterX - (ScrollSpeed * Sgn(AddtoUserPos.x)))
                    If Abs(OffsetCounterX) >= Abs(TileSizeX * AddtoUserPos.x) Then
                        OffsetCounterX = 0
                        AddtoUserPos.x = 0
                        UserMoving = 0
                    End If
                End If

                '****** Move screen Up and Down if needed ******
                If AddtoUserPos.y <> 0 Then
                    OffsetCounterY = OffsetCounterY - (ScrollSpeed * Sgn(AddtoUserPos.y))
                    If Abs(OffsetCounterY) >= Abs(TileSizeY * AddtoUserPos.y) Then
                        OffsetCounterY = 0
                        AddtoUserPos.y = 0
                        UserMoving = 0
                    End If
                End If

                '****** Update screen ******
                Call RenderScreen(UserPos.x - AddtoUserPos.x, UserPos.y - AddtoUserPos.y, OffsetCounterX, OffsetCounterY)
                DrawBackBufferSurface
                FramesPerSec = FramesPerSec + 1

                '****** Check keys ******
                Call CheckKeys

            End If
        End If
    End If
    
    '****** Draw currently selected Grh in ShowPic ******
    If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
    End If
    Call DrawGrhtoHdc(frmMain.ShowPic.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
    frmMain.ShowPic.Picture = frmMain.ShowPic.Image


    '****** Go do other events ******
    DoEvents

Loop
    

'*****************************************************************
'Close Down
'*****************************************************************

'****** Check if map is saved ******
If MapInfo.Changed = 1 Then
    If MsgBox("Changes have been made to the current map. You will lose all changes if not saved. Save now?", vbYesNo) = vbYes Then
        Call SaveMapData(CurMap)
    End If
End If

'****** Clear DirectX objects ******
Set PrimarySurface = Nothing
Set PrimaryClipper = Nothing
Set BackBufferSurface = Nothing
'Clear GRH memory
For LoopC = 1 To NumGrhFiles
    Set SurfaceDB(LoopC) = Nothing
Next LoopC
Set DirectDraw = Nothing

'****** Unload forms and end******
Unload frmMain
End

End Sub


Sub MakeChar(Body As Integer, Head As Integer, Heading As Byte, x As Integer, y As Integer)
'*****************************************************************
'Makes a new character and puts it on the map
'*****************************************************************
Dim CharIndex As Integer

'Find Next open character slot
CharIndex = NextOpenChar

'Error trap
If Body = 0 Then
Body = 1
End If
If Head = 0 Then
Head = 1
End If
If Heading = 0 Then
Heading = 1
End If

'Update head, body, ect.
CharList(CharIndex).Body = BodyData(Body)
CharList(CharIndex).Head = HeadData(Head)
CharList(CharIndex).Heading = Heading

'Reset moving stats
CharList(CharIndex).Moving = 0
CharList(CharIndex).MoveOffset.x = 0
CharList(CharIndex).MoveOffset.y = 0

'Update position
CharList(CharIndex).Pos.x = x
CharList(CharIndex).Pos.y = y

'Make active
CharList(CharIndex).Active = 1

'Plot on map
MapData(x, y).CharIndex = CharIndex

End Sub

Sub CheckKeys()
'*****************************************************************
'Checks keys
'*****************************************************************

'Check arrow keys
If UserMoving = 0 Then

    If GetKeyState(VK_UP) < 0 Then
        If WalkMode = True Then
            If LegalPos(UserPos.x, UserPos.y - 1) Then
                MoveCharbyHead UserCharIndex, NORTH
                MoveScreen NORTH
            End If
        Else
            MoveScreen NORTH
        End If
        Exit Sub
    End If

    If GetKeyState(VK_RIGHT) < 0 Then
        If WalkMode = True Then
            If LegalPos(UserPos.x + 1, UserPos.y) Then
                MoveCharbyHead UserCharIndex, EAST
                MoveScreen EAST
            End If
        Else
            MoveScreen EAST
        End If
        Exit Sub
    End If

    If GetKeyState(VK_DOWN) < 0 Then
        If WalkMode = True Then
            If LegalPos(UserPos.x, UserPos.y + 1) Then
                MoveCharbyHead UserCharIndex, SOUTH
                MoveScreen SOUTH
            End If
        Else
            MoveScreen SOUTH
        End If
        Exit Sub
    End If

    If GetKeyState(VK_LEFT) < 0 Then
        If WalkMode = True Then
            If LegalPos(UserPos.x - 1, UserPos.y) Then
                MoveCharbyHead UserCharIndex, WEST
                MoveScreen WEST
            End If
        Else
            MoveScreen WEST
        End If
        Exit Sub
    End If

End If

End Sub

Sub EraseChar(CharIndex As Integer)
'*****************************************************************
'Erases a character from CharList and map
'*****************************************************************

'Check
If CharIndex <= 0 Then
    Exit Sub
End If

'Make un-active
CharList(CharIndex).Active = 0

'Remove from map
MapData(CharList(CharIndex).Pos.x, CharList(CharIndex).Pos.y).CharIndex = 0

End Sub

Sub InitGrh(ByRef Grh As Grh, ByVal GrhIndex As Integer, Optional Started As Byte = 2)
'*****************************************************************
'Sets up a grh. MUST be done before rendering
'*****************************************************************

Grh.GrhIndex = GrhIndex

If Started = 2 Then
    If GrhData(Grh.GrhIndex).NumFrames > 1 Then
        Grh.Started = 1
    Else
        Grh.Started = 0
    End If
Else
    Grh.Started = Started
End If

Grh.FrameCounter = 1
Grh.SpeedCounter = GrhData(Grh.GrhIndex).Speed

End Sub

Sub MoveCharbyHead(CharIndex As Integer, nHeading As Byte)
'*****************************************************************
'Starts the movement of a character in nHeading direction
'*****************************************************************
Dim addX As Integer
Dim addY As Integer
Dim x As Integer
Dim y As Integer
Dim nX As Integer
Dim nY As Integer

x = CharList(CharIndex).Pos.x
y = CharList(CharIndex).Pos.y

'Figure out which way to move
Select Case nHeading

    Case NORTH
        addY = -1

    Case EAST
        addX = 1

    Case SOUTH
        addY = 1
    
    Case WEST
        addX = -1
        
End Select

nX = x + addX
nY = y + addY

MapData(nX, nY).CharIndex = CharIndex
CharList(CharIndex).Pos.x = nX
CharList(CharIndex).Pos.y = nY
MapData(x, y).CharIndex = 0

CharList(CharIndex).MoveOffset.x = -1 * (TileSizeX * addX)
CharList(CharIndex).MoveOffset.y = -1 * (TileSizeY * addY)

CharList(CharIndex).Moving = 1
CharList(CharIndex).Heading = nHeading

End Sub

Sub MoveCharbyPos(CharIndex As Integer, nX As Integer, nY As Integer)
'*****************************************************************
'Starts the movement of a character to nX,nY
'*****************************************************************
Dim x As Integer
Dim y As Integer
Dim addX As Integer
Dim addY As Integer
Dim nHeading As Byte

x = CharList(CharIndex).Pos.x
y = CharList(CharIndex).Pos.y

addX = nX - x
addY = nY - y

If Sgn(addX) = 1 Then
    nHeading = EAST
End If

If Sgn(addX) = -1 Then
    nHeading = WEST
End If

If Sgn(addY) = -1 Then
    nHeading = NORTH
End If

If Sgn(addY) = 1 Then
    nHeading = SOUTH
End If

MapData(nX, nY).CharIndex = CharIndex
CharList(CharIndex).Pos.x = nX
CharList(CharIndex).Pos.y = nY
MapData(x, y).CharIndex = 0

CharList(CharIndex).MoveOffset.x = -1 * (TileSizeX * addX)
CharList(CharIndex).MoveOffset.y = -1 * (TileSizeY * addY)

CharList(CharIndex).Moving = 1
CharList(CharIndex).Heading = nHeading

End Sub

Sub MoveScreen(Heading As Byte)
'******************************************
'Starts the screen moving in a direction
'******************************************
Dim x As Integer
Dim y As Integer
Dim tX As Integer
Dim tY As Integer

'Figure out which way to move
Select Case Heading

    Case NORTH
        y = -1

    Case EAST
        x = 1

    Case SOUTH
        y = 1
    
    Case WEST
        x = -1
        
End Select

'Fill temp pos
tX = UserPos.x + x
tY = UserPos.y + y

'Check to see if its out of bounds
If tX < MinXBorder Or tX > MaxXBorder Or tY < MinYBorder Or tY > MaxYBorder Then
    Exit Sub
Else
    'Start moving... MainLoop does the rest
    AddtoUserPos.x = x
    UserPos.x = tX
    AddtoUserPos.y = y
    UserPos.y = tY
    UserMoving = 1
End If

End Sub


Function NextOpenChar() As Integer
'*****************************************************************
'Finds next open char slot in CharList
'*****************************************************************
Dim LoopC As Integer

LoopC = 1
Do While CharList(LoopC).Active
    LoopC = LoopC + 1
Loop

NextOpenChar = LoopC

End Function

Sub ReacttoMouseClick(Button As Integer, tX As Integer, tY As Integer)
'*****************************************************************
'React to mouse button
'*****************************************************************
Dim LoopC As Integer
Dim NPCIndex As Integer
Dim OBJIndex As Integer
Dim Head As Integer
Dim Body As Integer
Dim Heading As Byte
Dim npcfile As String

On Error GoTo Errorhandler

'Right
If Button = vbRightButton Then
    
    'Show Info
    
    'Position
    frmMain.StatTxt.Text = frmMain.StatTxt.Text & ENDL & "Position " & tX & "," & tY & "  Blocked=" & MapData(tX, tY).Blocked
    
    'Exits
    If MapData(tX, tY).TileExit.map > 0 Then
        frmMain.StatTxt.Text = frmMain.StatTxt.Text & ENDL & "Tile Exit: " & MapData(tX, tY).TileExit.map & "," & MapData(tX, tY).TileExit.x & "," & MapData(tX, tY).TileExit.y
    End If
    
    'Check to see if water. Then announce that you can fish there !
    If MapData(tX, tY).Graphic(1).GrhIndex = 3500 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "This area is also inhabitated by fish."
    End If
    
    'Check to see if tree. Then announce that you can chop it down !
    If MapData(tX, tY).Graphic(2).GrhIndex = 17 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
    If MapData(tX, tY).Graphic(2).GrhIndex = 78 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
      If MapData(tX, tY).Graphic(2).GrhIndex = 79 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
      If MapData(tX, tY).Graphic(2).GrhIndex = 80 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
      If MapData(tX, tY).Graphic(2).GrhIndex = 81 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
      If MapData(tX, tY).Graphic(2).GrhIndex = 82 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
      If MapData(tX, tY).Graphic(2).GrhIndex = 83 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
      If MapData(tX, tY).Graphic(2).GrhIndex = 84 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
      If MapData(tX, tY).Graphic(2).GrhIndex = 85 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
      If MapData(tX, tY).Graphic(2).GrhIndex = 86 Then
    frmMain.StatTxt.Text = frmMain.StatTxt & ENDL & "You can chop this tree down !"
    End If
    
    'NPCs
    If MapData(tX, tY).NPCIndex > 0 Then
    
                      'Set NPC file
                If MapData(tX, tY).NPCIndex < 499 Then npcfile = IniPath & "NPC.dat"
                If MapData(tX, tY).NPCIndex > 499 Then npcfile = IniPath & "NPC2.dat"
 
        frmMain.StatTxt.Text = frmMain.StatTxt.Text & ENDL & "NPC: " & GetVar(npcfile, "NPC" & MapData(tX, tY).NPCIndex, "Name")
    End If
    
    'OBJs
    If MapData(tX, tY).OBJInfo.OBJIndex > 0 Then
        frmMain.StatTxt.Text = frmMain.StatTxt.Text & ENDL & "OBJ: " & GetVar(IniPath & "OBJ.dat", "OBJ" & MapData(tX, tY).OBJInfo.OBJIndex, "Name") & "   Amount=" & MapData(tX, tY).OBJInfo.Amount
    End If
    
    'Append
    frmMain.StatTxt.Text = frmMain.StatTxt.Text & ENDL
    frmMain.StatTxt.SelStart = Len(frmMain.StatTxt.Text)
    
    Exit Sub
End If


'Left click
If Button = vbLeftButton Then

    '************** Place grh
    If toolbox.PlaceGrhCmd.Enabled = False Then

        'Erase 2-3
        If toolbox.EraseAllchk.value = 1 Then
            For LoopC = 2 To 3
                MapData(tX, tY).Graphic(LoopC).GrhIndex = 0
            Next LoopC
            Exit Sub
        End If

        'Erase layer
        If toolbox.Erasechk.value = 1 Then
        
            If Val(toolbox.Layertxt.Text) = 1 Then
                MsgBox "Can't Erase Layer 1"
                Exit Sub
            End If
            
            MapData(tX, tY).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = 0
            Exit Sub
        End If

        'Else Place graphic
        MapData(tX, tY).Blocked = toolbox.Blockedchk.value
       
        MapData(tX, tY).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
        
        'Setup GRH

        InitGrh MapData(tX, tY).Graphic(Val(toolbox.Layertxt.Text)), Val(toolbox.Grhtxt.Text)

    If frmMain.brushsize = "Big" Then
    MapData(tX, tY).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
    MapData(tX - 1, tY).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
    MapData(tX + 1, tY).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
    MapData(tX, tY - 1).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
    MapData(tX, tY + 1).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
    MapData(tX - 1, tY - 1).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
    MapData(tX + 1, tY + 1).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
    MapData(tX - 1, tY + 1).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
    MapData(tX + 1, tY - 1).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt.Text)
    End If
    
    End If
    
    '************** Place blocked tile
    If toolbox.PlaceBlockCmd.Enabled = False Then
        MapData(tX, tY).Blocked = toolbox.Blockedchk.value
    End If



    '************** Place exit
    If toolbox.PlaceExitCmd.Enabled = False Then
        If toolbox.EraseExitChk.value = 0 Then
            MapData(tX, tY).TileExit.map = Val(toolbox.MapExitTxt.Text)
            MapData(tX, tY).TileExit.x = Val(toolbox.XExitTxt.Text)
            MapData(tX, tY).TileExit.y = Val(toolbox.YExitTxt.Text)
        Else
            MapData(tX, tY).TileExit.map = 0
            MapData(tX, tY).TileExit.x = 0
            MapData(tX, tY).TileExit.y = 0
        End If
    End If

    '************** Place NPC
    If toolbox.PlaceNPCCmd.Enabled = False Then
        If toolbox.EraseNPCChk.value = 0 Then
            If toolbox.NPCLst.ListIndex >= 0 Then
                NPCIndex = toolbox.NPCLst.ListIndex + 1
                
                'Set NPC file
                If NPCIndex < 499 Then npcfile = IniPath & "NPC.dat"
                If NPCIndex > 499 Then npcfile = IniPath & "NPC2.dat"
                
                Body = Val(GetVar(npcfile, "NPC" & NPCIndex, "Body"))
                Head = Val(GetVar(npcfile, "NPC" & NPCIndex, "Head"))
                Heading = Val(GetVar(npcfile, "NPC" & NPCIndex, "Heading"))
                Call MakeChar(Body, Head, Heading, tX, tY)
                MapData(tX, tY).NPCIndex = NPCIndex
            End If
        Else
            If MapData(tX, tY).NPCIndex > 0 Then
                MapData(tX, tY).NPCIndex = 0
                Call EraseChar(MapData(tX, tY).CharIndex)
            End If
        End If
    End If
    
    '************** Place OBJ
    If toolbox.PlaceObjCmd.Enabled = False Then
        If toolbox.EraseObjChk.value = 0 Then
            If toolbox.ObjLst.ListIndex >= 0 Then
                OBJIndex = toolbox.ObjLst.ListIndex + 1
                InitGrh MapData(tX, tY).ObjGrh, Val(GetVar(IniPath & "OBJ.dat", "OBJ" & OBJIndex, "GrhIndex"))
                MapData(tX, tY).OBJInfo.OBJIndex = OBJIndex
                MapData(tX, tY).OBJInfo.Amount = Val(toolbox.OBJAmountTxt)
            End If
        Else
            MapData(tX, tY).OBJInfo.OBJIndex = 0
            MapData(tX, tY).OBJInfo.Amount = 0
            MapData(tX, tY).ObjGrh.GrhIndex = 0
        End If
    End If
    
    
    'Set changed flag
    MapInfo.Changed = 1
End If

Errorhandler:
Exit Sub

End Sub

Sub SwitchMap(map As Integer)
'*****************************************************************
'Loads and switches to a new room
'*****************************************************************
Dim LoopC As Integer
Dim TempInt As Integer
Dim Body As Integer
Dim Head As Integer
Dim Heading As Byte
Dim y As Integer
Dim x As Integer
Dim npcfile As String

   
'Change mouse icon
frmMain.MousePointer = 11
   
'*******CLEAN CURRENT MAP FOR NPC`S AND OBJECTS*******

For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize

If MapData(x, y).NPCIndex > 0 Then
MapData(x, y).NPCIndex = 0
Call EraseChar(MapData(x, y).CharIndex)
End If

If MapData(x, y).OBJInfo.OBJIndex > 0 Then
MapData(x, y).OBJInfo.OBJIndex = 0
MapData(x, y).OBJInfo.Amount = 0
MapData(x, y).ObjGrh.GrhIndex = 0
End If

Next x
Next y

'*******DONE CLEANING MAP.***********
      
'Open files
Open App.Path & "\maps\Map" & map & ".map" For Binary As #1
Seek #1, 1
        
Open App.Path & "\maps\Map" & map & ".inf" For Binary As #2
Seek #2, 1

Open App.Path & "\maps\Map" & map & ".obj" For Binary As #3
Seek #3, 1


'Load arrays
For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize

        '.map file
        Get #1, , MapData(x, y).Blocked
    
        For LoopC = 1 To 3
            Get #1, , MapData(x, y).Graphic(LoopC).GrhIndex
            
            'Set up GRH
            If MapData(x, y).Graphic(LoopC).GrhIndex > 0 Then

                InitGrh MapData(x, y).Graphic(LoopC), MapData(x, y).Graphic(LoopC).GrhIndex

            End If
        
        Next LoopC
                                    
        '.inf file
        
        'Tile exit
        Get #2, , MapData(x, y).TileExit.map
        Get #2, , MapData(x, y).TileExit.x
        Get #2, , MapData(x, y).TileExit.y
                      
        'make NPC
        Get #2, , MapData(x, y).NPCIndex
        If MapData(x, y).NPCIndex > 0 Then
            
                  'Set NPC file
                If MapData(x, y).NPCIndex < 499 Then npcfile = IniPath & "NPC.dat"
                If MapData(x, y).NPCIndex > 499 Then npcfile = IniPath & "NPC2.dat"
                          
            
            Body = Val(GetVar(npcfile, "NPC" & MapData(x, y).NPCIndex, "Body"))
            Head = Val(GetVar(npcfile, "NPC" & MapData(x, y).NPCIndex, "Head"))
            Heading = Val(GetVar(npcfile, "NPC" & MapData(x, y).NPCIndex, "Heading"))
            Call MakeChar(Body, Head, Heading, x, y)
        End If
        
        'Make obj
        Get #3, , MapData(x, y).OBJInfo.OBJIndex
        Get #3, , MapData(x, y).OBJInfo.Amount
        If MapData(x, y).OBJInfo.OBJIndex > 0 Then
            InitGrh MapData(x, y).ObjGrh, Val(GetVar(IniPath & "OBJ.dat", "OBJ" & MapData(x, y).OBJInfo.OBJIndex, "GrhIndex"))
        End If
        
        'Empty place holders for future expansion
        Get #2, , TempInt
        Get #2, , TempInt
             
    Next x
Next y

'Close files
Close #1
Close #2
Close #3

'Other Room Data
MapInfo.Name = GetVar(App.Path & "\maps\Map" & map & ".dat", "Map" & map, "Name")
MapInfo.Music = GetVar(App.Path & "\maps\Map" & map & ".dat", "Map" & map, "MusicNum")

CurMap = map
toolbox.RoomLbl.Caption = "Map " & CurMap

'Set changed flag
MapInfo.Changed = 0

'Change mouse icon
frmMain.MousePointer = 0

End Sub

Sub LoadGrhData()
'*****************************************************************
'Loads Grh.dat
'*****************************************************************

On Error GoTo Errorhandler

Dim Grh As Integer
Dim Frame As Integer
Dim TempInt As Integer


'Get Number of Graphics
GrhPath = GetVar(IniPath & "Grh.ini", "INIT", "Path")
NumGrhs = Val(GetVar(IniPath & "Grh.ini", "INIT", "NumGrhs"))

'Resize arrays
ReDim GrhData(1 To NumGrhs) As GrhData

'Open files
Open IniPath & "Grh.dat" For Binary As #1
Seek #1, 1

'Get Header
Get #1, , TempInt
Get #1, , TempInt
Get #1, , TempInt
Get #1, , TempInt
Get #1, , TempInt

'Fill Grh List

'Get first Grh Number
Get #1, , Grh

Do Until Grh = 0
        
    'Get number of frames
    Get #1, , GrhData(Grh).NumFrames
    
    If GrhData(Grh).NumFrames > 1 Then
    
        'Read a animation GRH set
        For Frame = 1 To GrhData(Grh).NumFrames
        
            Get #1, , GrhData(Grh).Frames(Frame)
            If GrhData(Grh).Frames(Frame) <= 0 Or GrhData(Grh).Frames(Frame) > NumGrhs Then GoTo Errorhandler
        
        Next Frame
    
        Get #1, , GrhData(Grh).Speed
 
        'Compute width and height
        GrhData(Grh).pixelHeight = GrhData(GrhData(Grh).Frames(1)).pixelHeight

        GrhData(Grh).pixelWidth = GrhData(GrhData(Grh).Frames(1)).pixelWidth

        GrhData(Grh).TileWidth = GrhData(GrhData(Grh).Frames(1)).TileWidth

        GrhData(Grh).TileHeight = GrhData(GrhData(Grh).Frames(1)).TileHeight

    Else
    
        'Read in normal GRH data
        Get #1, , GrhData(Grh).FileNum
 
        Get #1, , GrhData(Grh).sX
   
        Get #1, , GrhData(Grh).sY
        If GrhData(Grh).sY < 0 Then GoTo Errorhandler
            
        Get #1, , GrhData(Grh).pixelWidth
    
        Get #1, , GrhData(Grh).pixelHeight
    
        'Compute width and height
        GrhData(Grh).TileWidth = GrhData(Grh).pixelWidth / TileSizeX
        GrhData(Grh).TileHeight = GrhData(Grh).pixelHeight / TileSizeY
        
        GrhData(Grh).Frames(1) = Grh
            
    End If

    'Get Next Grh Number
    Get #1, , Grh

Loop
'************************************************

Close #1

Exit Sub

Errorhandler:
Close #1
MsgBox "Error while loading the Grh.dat! Stopped at GRH number: " & Grh


End Sub


Sub LoadMapData()
'*****************************************************************
'Sets up Map arrays
'*****************************************************************
Dim map As Integer

'Get Number of Maps
NumMaps = Val(GetVar(App.Path & "\maps\Map.dat", "INIT", "NumMaps"))

'Resize mapdata array
ReDim MapData(XMinMapSize To XMaxMapSize, YMinMapSize To YMaxMapSize) As MapBlock

'Add maps to the map list
For map = 1 To NumMaps
    frmMain.MapLst.AddItem "Map " & map, map - 1
Next map

End Sub

Sub LoadNPCData()
'*****************************************************************
'Setup NPC list
'*****************************************************************
Dim NumNPCs As Integer
Dim NPC As Integer
Dim npcfile As String

'Get Number of Maps
NumNPCs = Val(GetVar(IniPath & "NPC.dat", "INIT", "NumNPCs"))


'Add NPCs to the NPC list
For NPC = 1 To NumNPCs
    
'Set NPC file
If NPC < 499 Then npcfile = IniPath & "NPC.dat"
If NPC > 499 Then npcfile = IniPath & "NPC2.dat"
    
    toolbox.NPCLst.AddItem GetVar(npcfile, "NPC" & NPC, "Name")
Next NPC

End Sub

Sub LoadOBJData()
'*****************************************************************
'Setup OBJ list
'*****************************************************************
Dim NumOBJs As Integer
Dim Obj As Integer

'Get Number of Maps
NumOBJs = Val(GetVar(IniPath & "OBJ.dat", "INIT", "NumOBJs"))

'Add OBJs to the OBJ list
For Obj = 1 To NumOBJs
    toolbox.ObjLst.AddItem GetVar(IniPath & "OBJ.dat", "OBJ" & Obj, "Name")
Next Obj

End Sub

Public Function ReadField(Pos As Integer, Text As String, SepASCII As Integer) As String
'*****************************************************************
'Gets a field from a string
'*****************************************************************
Dim i As Integer
Dim LastPos As Integer
Dim CurChar As String * 1
Dim FieldNum As Integer
Dim Seperator As String

Seperator = Chr(SepASCII)
LastPos = 0
FieldNum = 0

For i = 1 To Len(Text)
    CurChar = Mid(Text, i, 1)
    If CurChar = Seperator Then
        FieldNum = FieldNum + 1
        If FieldNum = Pos Then
            ReadField = Mid(Text, LastPos + 1, (InStr(LastPos + 1, Text, Seperator, vbTextCompare) - 1) - (LastPos))
            Exit Function
        End If
        LastPos = i
    End If
Next i
FieldNum = FieldNum + 1

If FieldNum = Pos Then
    ReadField = Mid(Text, LastPos + 1)
End If


End Function

Function FileExist(File As String, FileType As VbFileAttribute) As Boolean
'*****************************************************************
'Checks to see if a file exists
'*****************************************************************

If Dir(File, FileType) = "" Then
    FileExist = False
Else
    FileExist = True
End If

End Function

Sub SaveMapData(SaveAs As Integer)
'*****************************************************************
'Saves map data to text files
'*****************************************************************
Dim LoopC As Integer
Dim TempInt As Integer
Dim y As Integer
Dim x As Integer

'If FileExist(App.Path & "\maps\Map" & SaveAs & ".dat", vbNormal) = True Then
 '   If MsgBox("Overwrite existing Map" & SaveAs & ".x files?", vbYesNo) = vbNo Then
 '       Exit Sub
 '   End If
'End If


'Change mouse icon
frmMain.MousePointer = 11

'Write header info on Map.dat
Call WriteVar(App.Path & "\maps\Map.dat", "INIT", "NumMaps", Str(NumMaps))

If FileExist(App.Path & "\maps\Map" & SaveAs & ".map", vbNormal) = True Then
    Kill App.Path & "\maps\Map" & SaveAs & ".map"
End If

If FileExist(App.Path & "maps\Map" & SaveAs & ".inf", vbNormal) = True Then
    Kill App.Path & "\maps\Map" & SaveAs & ".inf"
End If

If FileExist(App.Path & "maps\Map" & SaveAs & ".obj", vbNormal) = True Then
    Kill App.Path & "\maps\Map" & SaveAs & ".obj"
End If

'Open .map file
Open App.Path & "\maps\Map" & SaveAs & ".map" For Binary As #1
Seek #1, 1

'Open .inf file
Open App.Path & "\maps\Map" & SaveAs & ".inf" For Binary As #2
Seek #2, 1

'Open .obj file
Open App.Path & "\maps\Map" & SaveAs & ".obj" For Binary As #3
Seek #3, 1

'Write .map file
For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize
        
        '.map file
        Put #1, , MapData(x, y).Blocked
     
        For LoopC = 1 To 3
            Put #1, , MapData(x, y).Graphic(LoopC).GrhIndex
        Next LoopC
        
        '.inf file
        'Tile exit
        Put #2, , MapData(x, y).TileExit.map
        Put #2, , MapData(x, y).TileExit.x
        Put #2, , MapData(x, y).TileExit.y
        
        'NPC
        Put #2, , MapData(x, y).NPCIndex
                
        'Empty place holders for future expansion
        Put #2, , TempInt
        Put #2, , TempInt
        
        'Object
        Put #3, , MapData(x, y).OBJInfo.OBJIndex
        Put #3, , MapData(x, y).OBJInfo.Amount
        
    Next x
Next y

'Close .map file
Close #1

'Close .inf file
Close #2

'Close .obj file
Close #3

'write .dat file
Call WriteVar(App.Path & "\maps\Map" & SaveAs & ".dat", "Map" & SaveAs, "Name", MapInfo.Name)


'Change mouse icon
frmMain.MousePointer = 0

'MsgBox ("Current map saved as map # " & SaveAs)

End Sub

Sub ToggleWalkMode()
'*****************************************************************
'Toggle walk mode on or off
'*****************************************************************

If WalkMode = False Then
    WalkMode = True
Else
    WalkMode = False
End If

If WalkMode = False Then
    'Erase character
    Call EraseChar(UserCharIndex)
    MapData(UserPos.x, UserPos.y).CharIndex = 0
Else
    'MakeCharacter
    If LegalPos(UserPos.x, UserPos.y) Then
        Call MakeChar(24, 1, SOUTH, UserPos.x, UserPos.y)
        UserCharIndex = MapData(UserPos.x, UserPos.y).CharIndex
    Else
        MsgBox "Error: Must move over a spot which is not blocked first."
        frmMain.WalkModeChk.value = 0
    End If
End If

End Sub

Sub WriteVar(File As String, Main As String, Var As String, value As String)
'*****************************************************************
'Writes a var to a text file
'*****************************************************************

writeprivateprofilestring Main, Var, value, File

End Sub

Function GetVar(File As String, Main As String, Var As String) As String
'*****************************************************************
'Get a var to from a text file
'*****************************************************************
Dim l As Integer
Dim Char As String
Dim sSpaces As String ' This will hold the input that the program will retrieve
Dim szReturn As String ' This will be the defaul value if the string is not found

szReturn = ""

sSpaces = Space(5000) ' This tells the computer how long the longest string can be. If you want, you can change the number 75 to any number you wish


getprivateprofilestring Main, Var, szReturn, sSpaces, Len(sSpaces), File

GetVar = RTrim(sSpaces)
GetVar = Left(GetVar, Len(GetVar) - 1)

End Function

Function LegalPos(x As Integer, y As Integer) As Boolean
'*****************************************************************
'Checks to see if a tile position is legal
'*****************************************************************

'Check to see if its out of bounds
If x < MinXBorder Or x > MaxXBorder Or y < MinYBorder Or y > MaxYBorder Then
    LegalPos = False
    Exit Function
End If

'Check to see if its blocked
If MapData(x, y).Blocked = 1 Then
    LegalPos = False
    Exit Function
End If

'Check for character
If MapData(x, y).CharIndex > 0 Then
    LegalPos = False
    Exit Function
End If

LegalPos = True

End Function

Sub LoadBodyData()
'*****************************************************************
'Loads Head.dat
'*****************************************************************
Dim LoopC As Integer

'Get number of bodies
NumBodies = Val(GetVar(IniPath & "Body.dat", "INIT", "NumBodies"))

'Resize array
ReDim BodyData(1 To NumBodies) As BodyData

'Fill list
For LoopC = 1 To NumBodies
    InitGrh BodyData(LoopC).Walk(1), Val(GetVar(IniPath & "Body.dat", "Body" & LoopC, "Walk1")), 0
    InitGrh BodyData(LoopC).Walk(2), Val(GetVar(IniPath & "Body.dat", "Body" & LoopC, "Walk2")), 0
    InitGrh BodyData(LoopC).Walk(3), Val(GetVar(IniPath & "Body.dat", "Body" & LoopC, "Walk3")), 0
    InitGrh BodyData(LoopC).Walk(4), Val(GetVar(IniPath & "Body.dat", "Body" & LoopC, "Walk4")), 0

    BodyData(LoopC).HeadOffset.x = Val(GetVar(IniPath & "Body.dat", "Body" & LoopC, "HeadOffsetX"))
    BodyData(LoopC).HeadOffset.y = Val(GetVar(IniPath & "Body.dat", "Body" & LoopC, "HeadOffsetY"))

Next LoopC

End Sub

Sub LoadHeadData()
'*****************************************************************
'Loads Head.dat
'*****************************************************************
Dim LoopC As Integer

'Get Number of heads
NumHeads = Val(GetVar(IniPath & "Head.dat", "INIT", "NumHeads"))

'Resize array
ReDim HeadData(1 To NumHeads) As HeadData

'Fill List
For LoopC = 1 To NumHeads
    InitGrh HeadData(LoopC).Head(1), Val(GetVar(IniPath & "Head.dat", "Head" & LoopC, "Head1")), 0
    InitGrh HeadData(LoopC).Head(2), Val(GetVar(IniPath & "Head.dat", "Head" & LoopC, "Head2")), 0
    InitGrh HeadData(LoopC).Head(3), Val(GetVar(IniPath & "Head.dat", "Head" & LoopC, "Head3")), 0
    InitGrh HeadData(LoopC).Head(4), Val(GetVar(IniPath & "Head.dat", "Head" & LoopC, "Head4")), 0
Next LoopC

End Sub

Function InMapLegalBounds(x As Integer, y As Integer) As Boolean
'*****************************************************************
'Checks to see if a tile position is in the maps
'LEGAL/Walkable bounds
'*****************************************************************

If x < MinXBorder Or x > MaxXBorder Or y < MinYBorder Or y > MaxYBorder Then
    InMapLegalBounds = False
    Exit Function
End If

InMapLegalBounds = True

End Function

Function InMapBounds(x As Integer, y As Integer) As Boolean
'*****************************************************************
'Checks to see if a tile position is in the maps bounds
'*****************************************************************

If x < XMinMapSize Or x > XMaxMapSize Or y < YMinMapSize Or y > YMaxMapSize Then
    InMapBounds = False
    Exit Function
End If

InMapBounds = True

End Function

Function RandomNumber(ByVal LowerBound As Variant, ByVal UpperBound As Variant) As Single
'*****************************************************************
'Find a Random number between a range
'*****************************************************************

Randomize Timer
RandomNumber = (UpperBound - LowerBound + 1) * Rnd + LowerBound

End Function

Sub PlaceRain()

Dim xvalue As Integer
Dim Yvalue As Integer
Dim x
Dim y
Dim xcoor
Dim Yline As Integer


xvalue = 1

For Yline = 1 To 100

looper:

MapData(xvalue, Yline).Graphic(3).GrhIndex = 3501
InitGrh MapData(xvalue, Yline).Graphic(3), 3501


If xvalue < 100 Then
xvalue = xvalue + 4
End If

If xvalue < 100 Then
GoTo looper
End If

xvalue = 1

Yline = Yline + 4
Next Yline

End Sub
