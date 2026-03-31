Attribute VB_Name = "Graphics"
Option Explicit

Sub ClearSurface(Surface As IDirectDrawSurface4, RED As Byte, GREEN As Byte, BLUE As Byte)
'*****************************************************************
'Clears a surface with a color
'*****************************************************************
Dim fx As DDBLTFX

With fx
    .dwSize = Len(fx)
    .dwFillColor = RGB(RED, GREEN, BLUE)
End With
' ScreenRect is necessary when used with DirectX.tlb
Surface.Blt ByVal 0&, Nothing, ByVal 0&, DDBLT_COLORFILL, fx
End Sub

Function CreateSurfaceFromFile(ByVal Width As Long, ByVal Height As Long, ByVal strFile As String) As IDirectDrawSurface4
'*****************************************************************
'Creates a DirectDraw surface from a file
'*****************************************************************
Dim frm As Form
Dim tempPicture As StdPicture
Dim PictureWidth As Long
Dim PictureHeight As Long
Dim ddsd As DDSURFACEDESC2     ' Surface description
Dim dds As IDirectDrawSurface   ' DirectDraw surface
Dim hdcPicture As Long          ' Picture device context
Dim hdcSurface As Long          ' Surface device context

Set frm = Screen.ActiveForm
' Load picture
Set tempPicture = LoadPicture(strFile)
PictureWidth = frmMain.ScaleX(tempPicture.Width, vbHimetric, vbPixels)
PictureHeight = frmMain.ScaleY(tempPicture.Height, vbHimetric, vbPixels)
If Width = 0 Then Width = PictureWidth
If Height = 0 Then Height = PictureHeight
' Fill surface description
With ddsd
    .dwSize = Len(ddsd)
    .dwFlags = DDSD_CAPS Or DDSD_HEIGHT Or DDSD_WIDTH
    .DDSCAPS.dwCaps = DDSCAPS_OFFSCREENPLAIN Or DDSCAPS_SYSTEMMEMORY
    .dwWidth = Width
    .dwHeight = Height
End With
' Create surface
DirectDraw.CreateSurface ddsd, dds, Nothing
' Create memory device
hdcPicture = CreateCompatibleDC(ByVal 0&)
' Select the bitmap in this memory device
SelectObject hdcPicture, tempPicture.Handle
' Restore the surface
dds.Restore
' Get the surface's DC
dds.GetDC hdcSurface
' Copy from the memory device to the DirectDrawSurface
StretchBlt hdcSurface, 0, 0, Width, Height, hdcPicture, 0, 0, PictureWidth, PictureHeight, SRCCOPY
' Release the surface's DC
dds.ReleaseDC hdcSurface
' Release the memory device and the bitmap
DeleteDC hdcPicture
Set tempPicture = Nothing
Set CreateSurfaceFromFile = dds
End Function

Sub DDrawGrhtoSurface(Surface As IDirectDrawSurface4, Grh As Grh, x As Integer, y As Integer, Center As Byte, Animate As Byte)
'*****************************************************************
'Draws a Grh at the X and Y positions
'*****************************************************************
Dim CurrentGrh As Grh
Dim DestRect As RECT
Dim SourceRect As RECT
Dim fx As DDBLTFX
Dim SurfaceDesc As DDSURFACEDESC2

On Error GoTo Errorhandler

'Check to make sure it is legal
If Grh.GrhIndex < 1 Then
    Exit Sub
End If
If GrhData(Grh.GrhIndex).NumFrames < 1 Then
    Exit Sub
End If

If Animate Then
    If Grh.Started = 1 Then
        If Grh.SpeedCounter > 0 Then
            Grh.SpeedCounter = Grh.SpeedCounter - 1
            If Grh.SpeedCounter = 0 Then
                Grh.SpeedCounter = GrhData(Grh.GrhIndex).Speed
                Grh.FrameCounter = Grh.FrameCounter + 1
                If Grh.FrameCounter > GrhData(Grh.GrhIndex).NumFrames Then
                    Grh.FrameCounter = 1
                End If
            End If
        End If
    End If
End If

'Figure out what frame to draw (always 1 if not animated)
CurrentGrh.GrhIndex = GrhData(Grh.GrhIndex).Frames(Grh.FrameCounter)

'Center Grh over X,Y pos
If Center Then
    If GrhData(CurrentGrh.GrhIndex).TileWidth <> 1 Then
        x = x - Int(GrhData(CurrentGrh.GrhIndex).TileWidth * 16) + 16 'hard coded for speed
    End If
    If GrhData(CurrentGrh.GrhIndex).TileHeight <> 1 Then
        y = y - Int(GrhData(CurrentGrh.GrhIndex).TileHeight * 50) + 50 'hard coded for speed
    End If
End If

With DestRect
    .Left = x
    .Top = y
    .Right = .Left + GrhData(CurrentGrh.GrhIndex).pixelWidth
    .bottom = .Top + GrhData(CurrentGrh.GrhIndex).pixelHeight
End With
    
SurfaceDesc.dwSize = Len(SurfaceDesc)
Surface.GetSurfaceDesc SurfaceDesc

'Draw
fx.dwSize = Len(fx)

If DestRect.Left >= 0 And DestRect.Top >= 0 And DestRect.Right <= SurfaceDesc.dwWidth And DestRect.bottom <= SurfaceDesc.dwHeight Then
    
    With SourceRect
        .Left = GrhData(CurrentGrh.GrhIndex).sX
        .Top = GrhData(CurrentGrh.GrhIndex).sY
        .Right = .Left + GrhData(CurrentGrh.GrhIndex).pixelWidth
        .bottom = .Top + GrhData(CurrentGrh.GrhIndex).pixelHeight
    End With
    Surface.Blt DestRect, SurfaceDB(GrhData(CurrentGrh.GrhIndex).FileNum), SourceRect, DDBLT_WAIT, fx

End If

Errorhandler:
Exit Sub

End Sub

Sub DDrawTransGrhtoSurface(Surface As IDirectDrawSurface4, Grh As Grh, x As Integer, y As Integer, Center As Byte, Animate As Byte)
'*****************************************************************
'Draws a GRH transparently to a X and Y position
'*****************************************************************
Dim CurrentGrh As Grh
Dim DestRect As RECT
Dim SourceRect As RECT
Dim ddck As DDCOLORKEY
Dim fx As DDBLTFX
Dim SurfaceDesc As DDSURFACEDESC2

'Check to make sure it is legal
If Grh.GrhIndex < 1 Then
    Exit Sub
End If
If GrhData(Grh.GrhIndex).NumFrames < 1 Then
    Exit Sub
End If

If Animate Then
    If Grh.Started = 1 Then
        If Grh.SpeedCounter > 0 Then
            Grh.SpeedCounter = Grh.SpeedCounter - 1
            If Grh.SpeedCounter = 0 Then
                Grh.SpeedCounter = GrhData(Grh.GrhIndex).Speed
                Grh.FrameCounter = Grh.FrameCounter + 1
                If Grh.FrameCounter > GrhData(Grh.GrhIndex).NumFrames Then
                    Grh.FrameCounter = 1
                End If
            End If
        End If
    End If
End If

'Figure out what frame to draw (always 1 if not animated)
CurrentGrh.GrhIndex = GrhData(Grh.GrhIndex).Frames(Grh.FrameCounter)

'Center Grh over X,Y pos
If Center Then
    If GrhData(CurrentGrh.GrhIndex).TileWidth <> 1 Then
        x = x - Int(GrhData(CurrentGrh.GrhIndex).TileWidth * 16) + 16 'hard coded for speed
    End If
    If GrhData(CurrentGrh.GrhIndex).TileHeight <> 1 Then
        y = y - Int(GrhData(CurrentGrh.GrhIndex).TileHeight * 50) + 50 'hard coded for speed
    End If
End If

With DestRect
    .Left = x
    .Top = y
    .Right = .Left + GrhData(CurrentGrh.GrhIndex).pixelWidth
    .bottom = .Top + GrhData(CurrentGrh.GrhIndex).pixelHeight
End With

SurfaceDesc.dwSize = Len(SurfaceDesc)
Surface.GetSurfaceDesc SurfaceDesc

'Draw
fx.dwSize = Len(fx)
ddck.dwColorSpaceLowValue = 0
ddck.dwColorSpaceHighValue = 0
BackBufferSurface.SetColorKey DDCKEY_SRCBLT, ddck

If DestRect.Left >= 0 And DestRect.Top >= 0 And DestRect.Right <= SurfaceDesc.dwWidth And DestRect.bottom <= SurfaceDesc.dwHeight Then
    With SourceRect
        .Left = GrhData(CurrentGrh.GrhIndex).sX
        .Top = GrhData(CurrentGrh.GrhIndex).sY
        .Right = .Left + GrhData(CurrentGrh.GrhIndex).pixelWidth
        .bottom = .Top + GrhData(CurrentGrh.GrhIndex).pixelHeight
    End With
    Surface.Blt DestRect, SurfaceDB(GrhData(CurrentGrh.GrhIndex).FileNum), SourceRect, DDBLT_KEYSRCOVERRIDE Or DDBLT_WAIT, fx
End If

End Sub

Sub DrawBackBufferSurface()
'*****************************************************************
'Copies backbuffer to primarysurface
'*****************************************************************
Dim fx As DDBLTFX
Dim SourceRect As RECT

fx.dwSize = Len(fx)


With SourceRect
    .Left = (TileSizeX * ScreenBuffer) - TileSizeX
    .Top = (TileSizeY * ScreenBuffer) - TileSizeY
    .Right = .Left + MainViewWidth
    .bottom = .Top + MainViewHeight
End With

PrimarySurface.Blt MainViewRect, BackBufferSurface, SourceRect, DDBLT_WAIT, fx

End Sub

Function GetBitmapDimensions(BmpFile As String, ByRef bmWidth As Long, ByRef bmHeight As Long)
'*****************************************************************
'Gets the dimensions of a bmp
'*****************************************************************
Dim BMHeader As BITMAPFILEHEADER
Dim BINFOHeader As BITMAPINFOHEADER

Open BmpFile For Binary Access Read As #1
Get #1, , BMHeader
Get #1, , BINFOHeader
Close #1
bmWidth = BINFOHeader.biWidth
bmHeight = BINFOHeader.biHeight
End Function

Public Sub DesktopHandle()
'*************************************************************
'Get handle to Desktop.
'*************************************************************
Dim hdesktopwnd

hdesktopwnd = GetDesktopWindow()

End Sub

Sub DrawGrhtoHdc(DestHdc As Long, Grh As Grh, x As Integer, y As Integer, Center As Byte, Animate As Byte, ROP As Long)
'*****************************************************************
'Draws a Grh at the X and Y positions
'*****************************************************************
Dim retcode As Long
Dim CurrentGrh As Grh
Dim SourceHdc As Long


'Check to make sure it is legal
If Grh.GrhIndex < 1 Then
    Exit Sub
End If
If GrhData(Grh.GrhIndex).NumFrames < 1 Then
    Exit Sub
End If

If Animate Then
    If Grh.Started = 1 Then
        If Grh.SpeedCounter > 0 Then
            Grh.SpeedCounter = Grh.SpeedCounter - 1
            If Grh.SpeedCounter = 0 Then
                Grh.SpeedCounter = GrhData(Grh.GrhIndex).Speed
                Grh.FrameCounter = Grh.FrameCounter + 1
                If Grh.FrameCounter > GrhData(Grh.GrhIndex).NumFrames Then
                    Grh.FrameCounter = 1
                End If
            End If
        End If
    End If
End If

'Figure out what frame to draw (always 1 if not animated)
CurrentGrh.GrhIndex = GrhData(Grh.GrhIndex).Frames(Grh.FrameCounter)

'Center Grh over X,Y pos
If Center Then
    If GrhData(CurrentGrh.GrhIndex).TileWidth <> 1 Then
        x = x - Int(GrhData(CurrentGrh.GrhIndex).TileWidth * 16) + 16 'hard coded for speed
    End If
    If GrhData(CurrentGrh.GrhIndex).TileHeight <> 1 Then
        y = y - Int(GrhData(CurrentGrh.GrhIndex).TileHeight * 50) + 50 'hard coded for speed
    End If
End If

SurfaceDB(GrhData(CurrentGrh.GrhIndex).FileNum).GetDC SourceHdc

retcode = BitBlt(DestHdc, x, y, GrhData(CurrentGrh.GrhIndex).pixelWidth, GrhData(CurrentGrh.GrhIndex).pixelHeight, SourceHdc, GrhData(CurrentGrh.GrhIndex).sX, GrhData(CurrentGrh.GrhIndex).sY, ROP)

SurfaceDB(GrhData(CurrentGrh.GrhIndex).FileNum).ReleaseDC SourceHdc

End Sub

Sub RenderScreen(TileX As Integer, TileY As Integer, PixelOffsetX As Integer, PixelOffsetY As Integer)
'***********************************************
'Draw current visible to scratch area based on TileX and TileY
'***********************************************
Dim y As Integer    'Keeps track of where on map we are
Dim x As Integer
Dim minY As Integer 'Start Y pos on current map
Dim maxY As Integer 'End Y pos on current map
Dim minX As Integer 'Start X pos on current map
Dim maxX As Integer 'End X pos on current map
Dim ScreenX As Integer 'Keeps track of where to place tile on screen
Dim ScreenY As Integer
Dim PixelOffsetXTemp As Integer 'For centering grhs
Dim PixelOffsetYTemp As Integer
Dim Moved As Byte
Dim Grh As Grh 'Temp Grh for show tile and blocked
Dim TempChar As Char

'Figure out Ends and Starts of screen
minY = (TileY - (YWindow \ 2)) - ScreenBuffer
maxY = (TileY + (YWindow \ 2)) + ScreenBuffer
minX = (TileX - (XWindow \ 2)) - ScreenBuffer
maxX = (TileX + (XWindow \ 2)) + ScreenBuffer

'Draw floor layer
ScreenY = 0
For y = minY To maxY
    ScreenX = 0
    For x = minX To maxX
        
        'Check to see if in bounds
        If InMapBounds(x, y) Then
    
            'Layer 1 **********************************
            'Draw
            Call DDrawGrhtoSurface(BackBufferSurface, MapData(x, y).Graphic(1), PixelPos(ScreenX) + PixelOffsetX, PixelPos(ScreenY) + PixelOffsetY, 0, 1)
            '**********************************
            
        End If
    
        ScreenX = ScreenX + 1
    Next x
    ScreenY = ScreenY + 1
Next y


'Draw transparent layers
ScreenY = 0
For y = minY To maxY
    ScreenX = 0
    For x = minX To maxX

        'Check to see if in bounds
        If InMapBounds(x, y) Then

            'Layer 2 **********************************
            If MapData(x, y).Graphic(2).GrhIndex > 0 Then
            
                PixelOffsetXTemp = PixelOffsetX
                PixelOffsetYTemp = PixelOffsetY
            
                'Draw
                Call DDrawTransGrhtoSurface(BackBufferSurface, MapData(x, y).Graphic(2), (PixelPos(ScreenX) + PixelOffsetXTemp), PixelPos(ScreenY) + PixelOffsetYTemp, 1, 1)
                
            End If
            '**********************************
            
            'Object Layer **********************************
            If MapData(x, y).ObjGrh.GrhIndex > 0 Then
            
                PixelOffsetXTemp = PixelOffsetX
                PixelOffsetYTemp = PixelOffsetY
            
                'Draw
                Call DDrawTransGrhtoSurface(BackBufferSurface, MapData(x, y).ObjGrh, (PixelPos(ScreenX) + PixelOffsetXTemp), PixelPos(ScreenY) + PixelOffsetYTemp, 1, 1)
                
            End If
            '**********************************
            

            
             'Char layer **********************************
            If MapData(x, y).CharIndex > 0 Then
            
                TempChar = CharList(MapData(x, y).CharIndex)
            
                PixelOffsetXTemp = PixelOffsetX
                PixelOffsetYTemp = PixelOffsetY
                
                Moved = 0
                'If needed, move left and right
                If TempChar.MoveOffset.x <> 0 Then
                        TempChar.Body.Walk(TempChar.Heading).Started = 1
                        PixelOffsetXTemp = PixelOffsetXTemp + TempChar.MoveOffset.x
                        TempChar.MoveOffset.x = TempChar.MoveOffset.x - (ScrollSpeed * Sgn(TempChar.MoveOffset.x))
                        Moved = 1
                End If
          
                'If needed, move up and down
                If TempChar.MoveOffset.y <> 0 Then
                        TempChar.Body.Walk(TempChar.Heading).Started = 1
                        PixelOffsetYTemp = PixelOffsetYTemp + TempChar.MoveOffset.y
                        TempChar.MoveOffset.y = TempChar.MoveOffset.y - (ScrollSpeed * Sgn(TempChar.MoveOffset.y))
                        Moved = 1
                End If
                
                'If done moving stop animation
                If Moved = 0 And TempChar.Moving = 1 Then
                    TempChar.Moving = 0
                    TempChar.Body.Walk(TempChar.Heading).FrameCounter = 1
                    TempChar.Body.Walk(TempChar.Heading).Started = 0
                End If
                
                'Draw Body
                Call DDrawTransGrhtoSurface(BackBufferSurface, TempChar.Body.Walk(TempChar.Heading), (PixelPos(ScreenX) + PixelOffsetXTemp), PixelPos(ScreenY) + PixelOffsetYTemp, 1, 1)
                'Draw Head
                Call DDrawTransGrhtoSurface(BackBufferSurface, TempChar.Head.Head(TempChar.Heading), (PixelPos(ScreenX) + PixelOffsetXTemp) + TempChar.Body.HeadOffset.x, PixelPos(ScreenY) + PixelOffsetYTemp + TempChar.Body.HeadOffset.y, 1, 0)
                
                'Refresh charlist
                CharList(MapData(x, y).CharIndex) = TempChar
                
                
            End If
            '**********************************
            
            'Layer 3 **********************************
            If MapData(x, y).Graphic(3).GrhIndex > 0 And frmMain.RainLayer.value = 1 Then

                'Draw
                Call DDrawTransGrhtoSurface(BackBufferSurface, MapData(x, y).Graphic(3), PixelPos(ScreenX) + PixelOffsetXTemp, PixelPos(ScreenY) + PixelOffsetYTemp, 1, 1)
            
            End If
            '**********************************

            
        End If
    
        ScreenX = ScreenX + 1
    Next x
    ScreenY = ScreenY + 1
Next y


'Draw blocked tiles and grid
ScreenY = 0
For y = minY To maxY
    ScreenX = 0
    For x = minX To maxX
            
        'Check to see if in bounds
        If InMapBounds(x, y) Then
                
            'Draw exit
            If MapData(x, y).TileExit.map > 0 Then
                Grh.GrhIndex = 1
                Grh.FrameCounter = 1
                Grh.Started = 0
                Call DDrawTransGrhtoSurface(BackBufferSurface, Grh, PixelPos(ScreenX) + PixelOffsetX, PixelPos(ScreenY) + PixelOffsetY, 0, 0)
            End If
                
            'Draw grid
            If DrawGrid = True Then
                Grh.GrhIndex = 2
                Grh.FrameCounter = 1
                Grh.Started = 0
                Call DDrawTransGrhtoSurface(BackBufferSurface, Grh, PixelPos(ScreenX) + PixelOffsetX, PixelPos(ScreenY) + PixelOffsetY, 0, 0)
            End If
                   
           'Show blocked tiles
            If DrawBlock = True Then
                If LegalPos(x, y) = False Then
                    Grh.GrhIndex = 4
                    Grh.FrameCounter = 1
                    Grh.Started = 0
                    Call DDrawTransGrhtoSurface(BackBufferSurface, Grh, PixelPos(ScreenX) + PixelOffsetX, PixelPos(ScreenY) + PixelOffsetY, 0, 0)
                End If
            End If




        End If
    
        ScreenX = ScreenX + 1
    Next x
    ScreenY = ScreenY + 1
Next y

End Sub

Function PixelPos(x As Integer) As Integer
'*****************************************************************
'Converts a tile position to a screen position
'*****************************************************************

PixelPos = (TileSizeX * x) - TileSizeX

End Function
Sub LoadGraphics()

On Error Resume Next
'*****************************************************************
'Loads all the sprites and tiles from the gif or bmp files
'*****************************************************************
Dim LoopC As Integer
Dim SurfaceDesc As DDSURFACEDESC2
Dim ddck As DDCOLORKEY

NumGrhFiles = Val(GetVar(IniPath & "Grh.ini", "INIT", "NumGrhFiles"))
ReDim SurfaceDB(1 To NumGrhFiles)

'Load the GRHx.bmps into memory
For LoopC = 1 To NumGrhFiles

    If FileExist(App.Path & GrhPath & "Grh" & LoopC & ".bmp", vbNormal) Then
        Set SurfaceDB(LoopC) = CreateSurfaceFromFile(0, 0, App.Path & GrhPath & "Grh" & LoopC & ".bmp")
        'Set color key
        ddck.dwColorSpaceLowValue = 0
        ddck.dwColorSpaceHighValue = 0
        SurfaceDB(LoopC).SetColorKey DDCKEY_SRCBLT, ddck
    End If
 
Next LoopC

End Sub




