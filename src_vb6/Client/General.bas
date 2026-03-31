Attribute VB_Name = "General"

Option Explicit

Function InMapLegalBounds(x As Integer, y As Integer) As Boolean

On Error Resume Next
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

On Error Resume Next
'*****************************************************************
'Checks to see if a tile position is in the maps bounds
'*****************************************************************

If x < XMinMapSize Or x > XMaxMapSize Or y < YMinMapSize Or y > YMaxMapSize Then
    InMapBounds = False
    Exit Function
End If

InMapBounds = True

End Function
Sub AddtoRichTextBox(RichTextBox As RichTextBox, Text As String, RED As Byte, GREEN As Byte, BLUE As Byte, Bold As Byte, Italic As Byte)

On Error Resume Next

'******************************************
'Adds text to a Richtext box at the bottom.
'Automatically scrolls to new text.
'Text box MUST be multiline and have a 3D
'apperance!
'******************************************

RichTextBox.SelStart = Len(RichTextBox.Text)
RichTextBox.SelLength = 0
RichTextBox.SelColor = RGB(RED, GREEN, BLUE)

If Bold Then
    RichTextBox.SelBold = True
Else
    RichTextBox.SelBold = False
End If

If Italic Then
    RichTextBox.SelItalic = True
Else
    RichTextBox.SelItalic = False
End If

RichTextBox.SelText = Chr(13) & Chr(10) & Text

End Sub
Sub ConvertCPtoTP(ByVal CX As Single, ByVal CY As Single, tX As Integer, tY As Integer)

On Error Resume Next
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

Sub AddtoTextBox(TextBox As TextBox, Text As String)

On Error Resume Next
'******************************************
'Adds text to a text box at the bottom.
'Automatically scrolls to new text.
'******************************************

TextBox.SelStart = Len(TextBox.Text)
TextBox.SelLength = 0


TextBox.SelText = Chr(13) & Chr(10) & Text

End Sub
Sub MoveCharbyPos(CharIndex As Integer, nX As Integer, nY As Integer)

On Error Resume Next
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

Sub RefreshAllChars()

On Error Resume Next
'*****************************************************************
'Goes through the charlist and replots all the characters on the map
'Used to make sure everyone is visible
'*****************************************************************

Dim LoopC As Integer

For LoopC = 1 To LastChar
    If CharList(LoopC).Active = 1 Then
        MapData(CharList(LoopC).Pos.x, CharList(LoopC).Pos.y).CharIndex = LoopC
    End If
Next LoopC
    
End Sub

Sub SaveGameini()

On Error Resume Next
'******************************************
'Saves Game.ini
'******************************************

'update Game.ini
Call WriteVar(IniPath & "Game.ini", "INIT", "Name", UserName)
Call WriteVar(IniPath & "Game.ini", "INIT", "Password", UserPassword)
Call WriteVar(IniPath & "Game.ini", "INIT", "Port", Str(UserPort))

End Sub

Function CheckUserData() As Boolean

On Error Resume Next
'*****************************************************************
'Checks all user data for mistakes and reports them.
'*****************************************************************

Dim LoopC As Integer
Dim CharAscii As Integer


'Password
If UserPassword = "" Then
    MsgBox ("Password box is empty.")
    Exit Function
End If

If Len(UserPassword) > 10 Then
    MsgBox ("Password must be 10 characters or less.")
    Exit Function
End If

For LoopC = 1 To Len(UserPassword)

    CharAscii = Asc(Mid$(UserPassword, LoopC, 1))
    If LegalCharacter(CharAscii) = False Then
        MsgBox ("Invalid Password.")
        Exit Function
    End If
    
Next LoopC

'Name
If UserName = "" Then
    MsgBox ("Name box is empty.")
    Exit Function
End If

If Len(UserName) > 30 Then
    MsgBox ("Name must be 30 characters or less.")
    Exit Function
End If

For LoopC = 1 To Len(UserName)

    CharAscii = Asc(Mid$(UserName, LoopC, 1))
    If LegalCharacter(CharAscii) = False Then
        MsgBox ("Invalid Name.")
        Exit Function
    End If
    
Next LoopC

'If all good send true
CheckUserData = True

End Function

Sub UnloadAllForms()

On Error Resume Next
'*****************************************************************
'Unloads all forms
'*****************************************************************

On Error Resume Next

Unload frmConnect
Unload frmMain

End Sub

Function LegalCharacter(KeyAscii As Integer) As Boolean

On Error Resume Next
'*****************************************************************
'Only allow characters that are Win 95 filename compatible
'*****************************************************************

'if backspace allow
If KeyAscii = 8 Then
    LegalCharacter = True
    Exit Function
End If

'Only allow space,numbers,letters and special characters
If KeyAscii < 32 Then
    LegalCharacter = False
    Exit Function
End If

If KeyAscii > 126 Then
    LegalCharacter = False
    Exit Function
End If

'Check for bad special characters in between
If KeyAscii = 34 Or KeyAscii = 42 Or KeyAscii = 47 Or KeyAscii = 58 Or KeyAscii = 60 Or KeyAscii = 62 Or KeyAscii = 63 Or KeyAscii = 92 Or KeyAscii = 124 Then
    LegalCharacter = False
    Exit Function
End If

'else everything is cool
LegalCharacter = True

End Function

Sub SetConnected()

On Error Resume Next
'*****************************************************************
'Sets the client to "Connect" mode
'*****************************************************************

'Set Connected
Connected = True

'Save Game.ini
If frmConnect.SavePassChk.value = 0 Then
    UserPassword = ""
End If
Call SaveGameini

'Unload the connect form
Unload frmConnect

'Load main form
frmMain.Visible = True
Unload loading


End Sub

Sub MakeChar(CharIndex As Integer, body As Integer, head As Integer, Heading As Byte, x As Integer, y As Integer, weaponanim As Integer, shieldanim As Integer)

On Error Resume Next
'*****************************************************************
'Makes a new character and puts it on the map
'*****************************************************************

'Update LastChar
If CharIndex > LastChar Then LastChar = CharIndex
NumChars = NumChars + 1

'Error trap
If body = 0 Then
body = 1
End If
If head = 0 Then
head = 1
End If
If Heading = 0 Then
Heading = 1
End If
If shieldanim = 0 Then
shieldanim = 2
End If
If weaponanim = 0 Then
weaponanim = 2
End If

'Update body,head,ect.
CharList(CharIndex).body = BodyData(body)
CharList(CharIndex).head = HeadData(head)
CharList(CharIndex).weaponanim = WeaponAnimData(weaponanim)
CharList(CharIndex).shieldanim = ShieldAnimData(shieldanim)
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

'Place char on map
MapData(x, y).CharIndex = CharIndex

'Update NumChars
NumChars = NumChars + 1

End Sub
Sub CheckMoveKeys()

On Error Resume Next
'*****************************************************************
'Checks keys and respond
'*****************************************************************
Static KeyTimer As Integer

'Makes sure keys aren't being pressed to fast
If KeyTimer > 0 Then
    KeyTimer = KeyTimer - 1
    Exit Sub
End If


'Don't allow any these keys during movement..
If UserMoving = 0 Then

    'Move Up
    If GetKeyState(VK_UP) < 0 Then
'Check to see if user is meditating
'Check to see if player is meditating

If Working = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You are working on something right now. Wait til your done.", 0, 255, 0, 0, 0
Exit Sub
End If

If UserMeditating = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You cannot move because you are meditating. Exit the trance first !", 0, 255, 0, 0, 0
Exit Sub
Else


If frmMain.TargetMessage <> "" Then frmMain.TargetMessage = ""

        If LegalPos(UserPos.x, UserPos.y - 1) Then
            Call SendData("M" & NORTH)
            MoveCharbyHead UserCharIndex, NORTH
            MoveScreen NORTH
        Else
          
            KeyTimer = 10
        End If
        
        Exit Sub
    End If
    End If
    
    'Move Right
    If GetKeyState(VK_RIGHT) < 0 And GetKeyState(VK_SHIFT) >= 0 Then
'Check to see if user is meditating
'Check to see if player is meditating

If Working = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You are working on something right now. Wait til your done.", 0, 255, 0, 0, 0
Exit Sub
End If

If UserMeditating = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You cannot move because you are meditating. Exit the trance first !", 0, 255, 0, 0, 0
Exit Sub
Else


If frmMain.TargetMessage <> "" Then frmMain.TargetMessage = ""

        If LegalPos(UserPos.x + 1, UserPos.y) Then
            Call SendData("M" & EAST)
            MoveCharbyHead UserCharIndex, EAST
            MoveScreen EAST
        Else
           
            KeyTimer = 10
        End If

        Exit Sub
    End If
    End If
    
    'Move down
    If GetKeyState(VK_DOWN) < 0 Then
    'Check to see if user is meditating
'Check to see if player is meditating

If Working = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You are working on something right now. Wait til your done.", 0, 255, 0, 0, 0
Exit Sub
End If


If UserMeditating = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You cannot move because you are meditating. Exit the trance first !", 0, 255, 0, 0, 0
Exit Sub
Else
        

If frmMain.TargetMessage <> "" Then frmMain.TargetMessage = ""
        
        If LegalPos(UserPos.x, UserPos.y + 1) Then
            Call SendData("M" & SOUTH)
            MoveCharbyHead UserCharIndex, SOUTH
            MoveScreen SOUTH
        Else
           
            KeyTimer = 10
        End If

        Exit Sub
    End If
    End If
    
    'Move left
    If GetKeyState(VK_LEFT) < 0 And GetKeyState(VK_SHIFT) >= 0 Then
    'Check to see if user is meditating
'Check to see if player is meditating

If Working = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You are working on something right now. Wait til your done.", 0, 255, 0, 0, 0
Exit Sub
End If



If UserMeditating = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You cannot move because you are meditating. Exit the trance first !", 0, 255, 0, 0, 0
Exit Sub
Else
        

If frmMain.TargetMessage <> "" Then frmMain.TargetMessage = ""
        
        If LegalPos(UserPos.x - 1, UserPos.y) Then
            Call SendData("M" & WEST)
            MoveCharbyHead UserCharIndex, WEST
            MoveScreen WEST
        Else
            Call PlayWaveDS(IniPath & "Sound\" & "Snd" & "1" & ".wav")
            KeyTimer = 10
        End If

        Exit Sub
    End If
    End If
    
    'Rotate left
    If GetKeyState(VK_LEFT) < 0 And GetKeyState(VK_SHIFT) < 0 Then
    
'Check to see if user is meditating
'Check to see if player is meditating
If UserMeditating = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You cannot move because you are meditating. Exit the trance first !", 0, 255, 0, 0, 0
Exit Sub
Else

If frmMain.TargetMessage <> "" Then frmMain.TargetMessage = ""
    
        Call SendData("<")

        KeyTimer = 10
        Exit Sub
    End If
    End If
    
    'Rotate right
    If GetKeyState(VK_RIGHT) < 0 And GetKeyState(VK_SHIFT) < 0 Then
    
    'Check to see if user is meditating
'Check to see if player is meditating

If Working = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You are working on something right now. Wait til your done.", 0, 255, 0, 0, 0
Exit Sub
End If

If UserMeditating = 1 Then
AddtoRichTextBox frmMain.RecTxt, "You cannot move because you are meditating. Exit the trance first !", 0, 255, 0, 0, 0
Exit Sub
Else
    

If frmMain.TargetMessage <> "" Then frmMain.TargetMessage = ""
    
    
        Call SendData(">")

        KeyTimer = 10
        Exit Sub
    End If
    End If

End If

End Sub

Sub EraseChar(CharIndex As Integer)
'*****************************************************************
'Erases a character from CharList and map
'*****************************************************************

'Make un-active
CharList(CharIndex).Active = 0

'Update lastchar
If CharIndex = LastChar Then
    Do Until CharList(LastChar).Active = 1
        LastChar = LastChar - 1
        If LastChar = 0 Then Exit Do
    Loop
End If

'Remove char from map
MapData(CharList(CharIndex).Pos.x, CharList(CharIndex).Pos.y).CharIndex = 0

'Update NumChars
NumChars = NumChars - 1

End Sub

Sub InitGrh(ByRef Grh As Grh, ByVal GrhIndex As Integer, Optional Started As Byte = 2)

On Error Resume Next
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

On Error Resume Next
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
frmMain.Campfire.Enabled = False

'Unhide if player is hiding
If UserHiding = 1 Then
UserHiding = 0
skills.Image2.Picture = LoadPicture(IniPath & "Grh\diamond.bmp")
SendData "UHD"
End If

'Check to see if player is meditating
If UserMeditating = 1 Then
SendData "UMS"
End If

End Sub

Sub MoveScreen(Heading As Byte)

On Error Resume Next

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
    'Start moving... the main loop does the rest
    AddtoUserPos.x = x
    UserPos.x = tX
    AddtoUserPos.y = y
    UserPos.y = tY
    UserMoving = 1
End If

End Sub


Function NextOpenChar()

On Error Resume Next
'******************************************
'Finds next open Char
'******************************************

Dim LoopC As Integer

LoopC = 1
Do While CharList(LoopC).Active
    LoopC = LoopC + 1
Loop

NextOpenChar = LoopC

End Function

Sub SwitchMap(map As Integer)

On Error Resume Next
'*****************************************************************
'Loads and switches to a new map
'*****************************************************************

Dim LoopC As Integer
Dim y As Integer
Dim x As Integer
      
'Open files
Open IniPath & "Maps\Map" & map & ".map" For Binary As #1
Seek #1, 1
        
'Load arrays
For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize

        '.dat file
        Get #1, , MapData(x, y).Blocked
        For LoopC = 1 To 3
            Get #1, , MapData(x, y).graphic(LoopC).GrhIndex
            
            'Set up GRH
            If MapData(x, y).graphic(LoopC).GrhIndex > 0 Then
                InitGrh MapData(x, y).graphic(LoopC), MapData(x, y).graphic(LoopC).GrhIndex
            End If
            
        Next LoopC
        
        'Erase NPCs
        If MapData(x, y).CharIndex > 0 Then
            Call EraseChar(MapData(x, y).CharIndex)
        End If
        
        'Erase OBJs
        MapData(x, y).ObjGrh.GrhIndex = 0
                            
    Next x
Next y

Close #1

MapInfo.Name = ""
MapInfo.Music = ""

CurMap = map

End Sub

Sub LoadGrhData()
'*****************************************************************
'Loads Grh.dat
'*****************************************************************
On Error Resume Next



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


End Sub

Public Function ReadField(Pos As Integer, Text As String, SepASCII As Integer) As String
'*****************************************************************
'Gets a field from a string
'*****************************************************************
On Error Resume Next
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

On Error Resume Next
'*****************************************************************
'Checks to see if a file exists
'*****************************************************************

If Dir(File, FileType) = "" Then
    FileExist = False
Else
    FileExist = True
End If

End Function

Sub Main()

On Error Resume Next
'*****************************************************************
'Main
'*****************************************************************
Dim retcode As Integer
Dim OffsetCounterX As Integer
Dim OffsetCounterY As Integer
Dim SurfaceDesc As DDSURFACEDESC2
Dim LoopC As Integer
Dim lngStatus As Long

'***************************************************
'Start up
'***************************************************


SetRes
loading.Show
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 200
loading.loadstatus = "Setting up..."

      
'****** Init vars ******
IniPath = App.Path & "\"
ENDL = Chr(13) & Chr(10)
ENDC = Chr(1)

'Setup borders
MinXBorder = XMinMapSize + (XWindow \ 3)
MaxXBorder = XMaxMapSize - (XWindow \ 3)
MinYBorder = YMinMapSize + (YWindow \ 2)
MaxYBorder = YMaxMapSize - (YWindow \ 2)

'Set intial user position
UserPos.x = MinXBorder
UserPos.y = MinYBorder

MainViewWidth = TileSizeX * XWindow
MainViewHeight = TileSizeY * YWindow

'Resize mapdata array
ReDim MapData(XMinMapSize To XMaxMapSize, YMinMapSize To YMaxMapSize) As MapBlock
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 1000
loading.loadstatus = "Checking and setting up screen..."
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

loading.percentcomp.Width = 1200
  
  'Download game address
    loading.Inet.Url = "http://www.erlingellingsen.com/era/address.txt"
    Address = loading.Inet.OpenURL(loading.Inet.Url, icString)


loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 1500
loading.loadstatus = "Loading graphic data..."
'If 800 by 600 maximize form
If DisplayWidth = 800 And DisplayHeight = 600 Then
    frmMain.WindowState = 2
End If
'****** Init DirectDraw ******
' Create the root DirectDraw object
DirectDrawCreate ByVal 0&, DirectDraw, Nothing
DirectDraw.SetCooperativeLevel 0, DDSCL_NORMAL

'Primary Surface
' Fill the surface description structure
With SurfaceDesc
    .dwSize = Len(SurfaceDesc)        ' Indicates what members are valid
    .dwflags = DDSD_CAPS
    .DDSCAPS.dwCaps = DDSCAPS_PRIMARYSURFACE
End With
' Create the surface
DirectDraw.CreateSurface SurfaceDesc, PrimarySurface, Nothing
'Create clipper
DirectDraw.CreateClipper 0, PrimaryClipper, Nothing
PrimaryClipper.SetHWnd 0, frmMain.hWnd
PrimarySurface.SetClipper PrimaryClipper
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 2000
'Back Buffer Surface
With BackBufferRect
    .Left = 0
    .Top = 0
    .Right = TileSizeX * (XWindow + (2 * screenbuffer))
    .bottom = TileSizeY * (YWindow + (2 * screenbuffer))
End With
With SurfaceDesc
    .dwSize = Len(SurfaceDesc)
    .dwflags = DDSD_CAPS Or DDSD_HEIGHT Or DDSD_WIDTH
    .DDSCAPS.dwCaps = DDSCAPS_OFFSCREENPLAIN Or DDSCAPS_SYSTEMMEMORY
    .dwWidth = BackBufferRect.Right
    .dwHeight = BackBufferRect.bottom
End With
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 2200
' Create surface
DirectDraw.CreateSurface SurfaceDesc, BackBufferSurface, Nothing

'****** Load files into memory ******
Call LoadGrhData
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 2500
loading.loadstatus = "Loading Animation Data..."
Call LoadBodyData
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 3000
loading.loadstatus = "Loading Animation Data..."
Call LoadWeaponAnimData
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 3500
loading.loadstatus = "Loading Animation Data..."
Call LoadShieldAnimData
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 4000
Call LoadHeadData
Call LoadGraphics
loading.Picture = LoadPicture(IniPath & "Grh\loading.jpg")
loading.percentcomp.Width = 4500
'****** MidiPlayer INIT ******
frmMain.MidiPlayer.Notify = False
frmMain.MidiPlayer.Wait = False
frmMain.MidiPlayer.Shareable = False
frmMain.MidiPlayer.TimeFormat = mciFormatMilliseconds
frmMain.MidiPlayer.DeviceType = "Sequencer"

'****** Create the DirectSound object ******
DirectSoundCreate ByVal 0&, DirectSound, Nothing
DirectSound.SetCooperativeLevel frmMain.hWnd, DSSCL_NORMAL
loading.percentcomp.Width = 5000

'****** Display connect window ******
intro.Show
loading.Hide

'Turn voices off by deafult
Voices = 1


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
                    RequestPosTimer = 0
                    OffsetCounterX = (OffsetCounterX - (8 * Sgn(AddtoUserPos.x)))
                    If Abs(OffsetCounterX) >= Abs(TileSizeX * AddtoUserPos.x) Then
                        OffsetCounterX = 0
                        AddtoUserPos.x = 0
                        UserMoving = 0
                    
                        'Start Request position timer
                        RequestPosTimer = 30
                    End If
                End If

                '***** Move screen Up and Down if needed ******
                If AddtoUserPos.y <> 0 Then
                    RequestPosTimer = 0
                    OffsetCounterY = OffsetCounterY - (8 * Sgn(AddtoUserPos.y))
                    If Abs(OffsetCounterY) >= Abs(TileSizeY * AddtoUserPos.y) Then
                        OffsetCounterY = 0
                        AddtoUserPos.y = 0
                        UserMoving = 0
                    
                        'Start Request position timer
                        RequestPosTimer = 30
                    End If
                End If

                '****** Check Request position timer ******
                If RequestPosTimer > 0 Then
                    RequestPosTimer = RequestPosTimer - 1
                    If RequestPosTimer = 0 Then
                        'Request position Update
                        Call SendData("RPU")
                    End If
                End If
            
                '****** Refesh characters on map ******
                Call RefreshAllChars
                
                '****** Update screen ******
                Call RenderScreen(UserPos.x - AddtoUserPos.x, UserPos.y - AddtoUserPos.y, OffsetCounterX, OffsetCounterY)
                DrawBackBufferSurface
                FramesPerSec = FramesPerSec + 1
            
                'Check keys
                Call CheckMoveKeys
            
            End If
        End If
    End If
    
    '****** Go do other events ******
   DoEvents

Loop
    

'*****************************************************************
'Close Down
'*****************************************************************

'****** Stop any midis ******
retcode = mciSendString("close all", 0, 0, 0)

'****** Clear DirectX objects ******
Set PrimarySurface = Nothing
Set PrimaryClipper = Nothing
Set BackBufferSurface = Nothing
'Clear GRH memory
For LoopC = 1 To NumGrhFiles
    Set SurfaceDB(LoopC) = Nothing
Next LoopC
Set DirectDraw = Nothing

'Reset any channels that are done
For LoopC = 0 To NumSoundChannels
    If Not (DSBuffer(LoopC) Is Nothing) Then
        Set DSBuffer(LoopC) = Nothing
    End If
Next LoopC
Set DirectSound = Nothing

'****** Unload forms and end******
Call UnloadAllForms
End

End Sub

Sub SaveMapData(SaveAs As Integer)

On Error Resume Next
'*****************************************************************
'Saves map data to text files
'*****************************************************************

Dim LoopC As Integer
Dim y As Integer
Dim x As Integer

If FileExist(IniPath & "Maps\Map" & SaveAs & ".map", vbNormal) = True Then
    Kill IniPath & "Maps\Map" & SaveAs & ".map"
End If

'Open .map file
Open IniPath & "Maps\Map" & SaveAs & ".map" For Binary As #1
Seek #1, 1

'Write .map file
For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize
        
        '.map file
        Put #1, , MapData(x, y).Blocked
        For LoopC = 1 To 3
            Put #1, , MapData(x, y).graphic(LoopC).GrhIndex
        Next LoopC
        
    Next x
Next y

'Close .map file
Close #1

End Sub

Sub WriteVar(File As String, Main As String, Var As String, value As String)

On Error Resume Next
'*****************************************************************
'Writes a var to a text file
'*****************************************************************

writeprivateprofilestring Main, Var, value, File

End Sub

Function GetVar(File As String, Main As String, Var As String) As String

On Error Resume Next
'*****************************************************************
'Gets a Var from a text file
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

On Error Resume Next
'*****************************************************************
'Checks to see if a tile position is legal
'*****************************************************************

'Check to see if its out of bounds
If x < MinXBorder Or x > MaxXBorder Or y < MinYBorder Or y > MaxYBorder Then
    LegalPos = False
    Exit Function
End If

'Check to see if its blocked
If MapData(x, y).Blocked = 1 And Dead = 0 Then
    LegalPos = False
    Exit Function
End If

'Check to see if its blocked
If MapData(x, y).CharIndex > 0 Then
    LegalPos = False
    Exit Function
End If

LegalPos = True

End Function

Sub LoadBodyData()

On Error Resume Next
'*****************************************************************
'Loads Body.dat
'*****************************************************************

Dim LoopC As Integer
DoEvents

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
    loading.Show
    
Next LoopC

End Sub
Sub LoadWeaponAnimData()

On Error Resume Next
'*****************************************************************
'Loads wpanim.dat
'*****************************************************************

Dim LoopC As Integer
DoEvents
'Get number of Weapon anims
NumWeaponAnims = Val(GetVar(IniPath & "wpanim.dat", "INIT", "NumWeaponAnims"))

'Resize array
ReDim WeaponAnimData(1 To NumWeaponAnims) As WeaponAnimData

'Fill list
For LoopC = 1 To NumWeaponAnims
    InitGrh WeaponAnimData(LoopC).WeaponWalk(1), Val(GetVar(IniPath & "wpanim.dat", "WeaponAnim" & LoopC, "WeaponWalk1")), 0
    InitGrh WeaponAnimData(LoopC).WeaponWalk(2), Val(GetVar(IniPath & "wpanim.dat", "WeaponAnim" & LoopC, "WeaponWalk2")), 0
    InitGrh WeaponAnimData(LoopC).WeaponWalk(3), Val(GetVar(IniPath & "wpanim.dat", "WeaponAnim" & LoopC, "WeaponWalk3")), 0
    InitGrh WeaponAnimData(LoopC).WeaponWalk(4), Val(GetVar(IniPath & "wpanim.dat", "WeaponAnim" & LoopC, "WeaponWalk4")), 0
loading.Show
Next LoopC

End Sub
Sub LoadShieldAnimData()

On Error Resume Next
'*****************************************************************
'Loads wpanim.dat
'*****************************************************************

Dim LoopC As Integer
DoEvents
'Get number of Shield anims
NumShieldAnims = Val(GetVar(IniPath & "shanim.dat", "INIT", "NumShieldAnims"))

'Resize array
ReDim ShieldAnimData(1 To NumShieldAnims) As ShieldAnimData

'Fill list
For LoopC = 1 To NumShieldAnims
    InitGrh ShieldAnimData(LoopC).ShieldWalk(1), Val(GetVar(IniPath & "shanim.dat", "ShieldAnim" & LoopC, "ShieldWalk1")), 0
    InitGrh ShieldAnimData(LoopC).ShieldWalk(2), Val(GetVar(IniPath & "shanim.dat", "ShieldAnim" & LoopC, "ShieldWalk2")), 0
    InitGrh ShieldAnimData(LoopC).ShieldWalk(3), Val(GetVar(IniPath & "shanim.dat", "ShieldAnim" & LoopC, "ShieldWalk3")), 0
    InitGrh ShieldAnimData(LoopC).ShieldWalk(4), Val(GetVar(IniPath & "shanim.dat", "ShieldAnim" & LoopC, "ShieldWalk4")), 0
loading.Show
Next LoopC

End Sub



Sub LoadHeadData()

On Error Resume Next
'*****************************************************************
'Loads Head.dat
'*****************************************************************

Dim LoopC As Integer
DoEvents
'Get Number of heads
NumHeads = Val(GetVar(IniPath & "Head.dat", "INIT", "NumHeads"))

'Resize array
ReDim HeadData(1 To NumHeads) As HeadData

'Fill List
For LoopC = 1 To NumHeads
    InitGrh HeadData(LoopC).head(1), Val(GetVar(IniPath & "Head.dat", "Head" & LoopC, "Head1")), 0
    InitGrh HeadData(LoopC).head(2), Val(GetVar(IniPath & "Head.dat", "Head" & LoopC, "Head2")), 0
    InitGrh HeadData(LoopC).head(3), Val(GetVar(IniPath & "Head.dat", "Head" & LoopC, "Head3")), 0
    InitGrh HeadData(LoopC).head(4), Val(GetVar(IniPath & "Head.dat", "Head" & LoopC, "Head4")), 0
loading.Show
Next LoopC

End Sub

Function RandomNumber(ByVal LowerBound As Variant, ByVal UpperBound As Variant) As Single

On Error Resume Next
'*****************************************************************
'Find a Random number between a range
'*****************************************************************

Randomize Timer
RandomNumber = (UpperBound - LowerBound + 1) * Rnd + LowerBound

End Function

Function SpecializedSkill(skill As String)
On Error Resume Next

If skill = SpecSkill1 Then
SpecializedSkill = True
Exit Function
End If

If skill = SpecSkill2 Then
SpecializedSkill = True
Exit Function
End If

If skill = SpecSkill3 Then
SpecializedSkill = True
Exit Function
End If

SpecializedSkill = False

End Function


