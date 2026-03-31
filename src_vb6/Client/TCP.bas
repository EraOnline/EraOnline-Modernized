Attribute VB_Name = "TCP"

Option Explicit

Sub HandleData(rData As String)
On Error Resume Next

'*********************************************
'Handle all data from server
'*********************************************
Dim retVal As Variant
Dim x As Integer
Dim y As Integer
Dim CharIndex As Integer
Dim ServerHandle As Integer
Dim TempInt As Integer
Dim TempStr As String
Dim TempStr2 As String
Dim TempStr3 As String
Dim Slot As Integer
Dim slot2 As Integer
Dim tX As Integer
Dim tY As Integer
Dim Line1 As String
Dim Post As Integer
Dim Help As Integer


On Error Resume Next



'Send to Rectxt
If Left$(rData, 1) = "@" Then
    rData = Right$(rData, Len(rData) - 1)
    AddtoRichTextBox frmMain.RecTxt, ReadField(1, rData, 126), Val(ReadField(2, rData, 126)), Val(ReadField(3, rData, 126)), Val(ReadField(4, rData, 126)), Val(ReadField(5, rData, 126)), Val(ReadField(6, rData, 126))
    
    Exit Sub
End If

On Error Resume Next


'Urgant MsgBox
If Left$(rData, 2) = "!!" Then
    rData = Right$(rData, Len(rData) - 2)
    MsgBox rData, vbApplicationModal
    Exit Sub
End If

On Error Resume Next


'MsgBox
If Left$(rData, 1) = "!" Then
    rData = Right$(rData, Len(rData) - 1)
    MsgBox rData
    Exit Sub
End If

'Get UserServerIndex
If Left$(rData, 3) = "SUI" Then
    rData = Right$(rData, Len(rData) - 3)
    userindex = (Val(rData))
    Exit Sub
End If

'Get UserCharIndex
If Left$(rData, 3) = "SUC" Then
    rData = Right$(rData, Len(rData) - 3)
    UserCharIndex = (Val(rData))
    UserPos = CharList(UserCharIndex).Pos
    Exit Sub
End If

'Load map
If Left$(rData, 3) = "SCM" Then
    rData = Right$(rData, Len(rData) - 3)
    SwitchMap (rData)
    EngineRun = True
    Exit Sub
End If

'Change map name
If Left$(rData, 3) = "SMN" Then
    MapInfo.Name = Right$(rData, Len(rData) - 3)
    frmMain.MapNameLbl.Caption = MapInfo.Name
    Exit Sub
End If

'Set user's screen pos
If Left$(rData, 3) = "SSP" Then
    rData = Right$(rData, Len(rData) - 3)
    UserPos.x = ReadField(1, rData, 44)
    UserPos.y = ReadField(2, rData, 44)
    Exit Sub
End If

'Set user position
If Left$(rData, 3) = "SUP" Then
    rData = Right$(rData, Len(rData) - 3)
    
    x = ReadField(1, rData, 44)
    y = ReadField(2, rData, 44)
    
    MapData(UserPos.x, UserPos.y).CharIndex = 0
    MapData(x, y).CharIndex = UserCharIndex
    
    UserPos.x = x
    UserPos.y = y
    CharList(UserCharIndex).Pos = UserPos
    
    Exit Sub
End If

'Make Char
If Left$(rData, 3) = "MAC" Then
    rData = Right$(rData, Len(rData) - 3)
    
    CharIndex = ReadField(4, rData, 44)
    x = ReadField(5, rData, 44)
    y = ReadField(6, rData, 44)

    
    Call MakeChar(CharIndex, ReadField(1, rData, 44), ReadField(2, rData, 44), ReadField(3, rData, 44), x, y, ReadField(7, rData, 44), ReadField(8, rData, 44))

    Exit Sub
End If

'Erase Char
If Left$(rData, 3) = "ERC" Then
    rData = Right$(rData, Len(rData) - 3)

    Call EraseChar(Val(rData))

    Exit Sub
End If

'Move Char
If Left$(rData, 3) = "MOC" Then
    rData = Right$(rData, Len(rData) - 3)

    CharIndex = Val(ReadField(1, rData, 44))

    Call MoveCharbyPos(CharIndex, ReadField(2, rData, 44), ReadField(3, rData, 44))

    Exit Sub
End If

'Change Char NOW WITH ERROR TRAPS
If Left$(rData, 3) = "CHC" Then
    rData = Right$(rData, Len(rData) - 3)

    CharIndex = Val(ReadField(1, rData, 44))

  
    CharList(CharIndex).body = BodyData(Val(ReadField(2, rData, 44)))
      
      'Error trap in body bug
      If Val(ReadField(2, rData, 44)) < 1 Then
      CharList(CharIndex).body = BodyData(1)
      End If

    CharList(CharIndex).head = HeadData(Val(ReadField(3, rData, 44)))
    
      'Error trap in head bug
      If Val(ReadField(3, rData, 44)) < 1 Then
      CharList(CharIndex).head = HeadData(7)
      End If
    
    CharList(CharIndex).Heading = Val(ReadField(4, rData, 44))
    CharList(CharIndex).weaponanim = WeaponAnimData(Val(ReadField(5, rData, 44)))
    CharList(CharIndex).shieldanim = ShieldAnimData(Val(ReadField(6, rData, 44)))

    
    Exit Sub
End If

'Make Obj layer
If Left$(rData, 3) = "MOB" Then
    rData = Right$(rData, Len(rData) - 3)
    x = Val(ReadField(2, rData, 44))
    y = Val(ReadField(3, rData, 44))
    MapData(x, y).ObjGrh.GrhIndex = Val(ReadField(1, rData, 44))
    InitGrh MapData(x, y).ObjGrh, MapData(x, y).ObjGrh.GrhIndex
    Exit Sub
End If

'Erase Obj layer
If Left$(rData, 3) = "EOB" Then
    rData = Right$(rData, Len(rData) - 3)
    x = Val(ReadField(1, rData, 44))
    y = Val(ReadField(2, rData, 44))
    MapData(x, y).ObjGrh.GrhIndex = 0
    Exit Sub
End If

'Update Main Stats
If Left$(rData, 3) = "SST" Then
    rData = Right$(rData, Len(rData) - 3)

    UserMaxHP = Val(ReadField(1, rData, 44))
    UserMinHP = Val(ReadField(2, rData, 44))
    UserMaxMAN = Val(ReadField(3, rData, 44))
    UserMinMAN = Val(ReadField(4, rData, 44))
    UserMaxSTA = Val(ReadField(5, rData, 44))
    UserMinSTA = Val(ReadField(6, rData, 44))
    UserGLD = Val(ReadField(7, rData, 44))
    UserLvl = Val(ReadField(8, rData, 44))
    

    UserSkill1 = Val(ReadField(9, rData, 44))
    UserSkill2 = Val(ReadField(10, rData, 44))
    UserSkill3 = Val(ReadField(11, rData, 44))
    UserSkill4 = Val(ReadField(12, rData, 44))
    UserSkill5 = Val(ReadField(13, rData, 44))
    UserSkill6 = Val(ReadField(14, rData, 44))
    UserSkill7 = Val(ReadField(15, rData, 44))
    UserSkill8 = Val(ReadField(16, rData, 44))
    UserSkill9 = Val(ReadField(17, rData, 44))
    UserSkill10 = Val(ReadField(18, rData, 44))
    UserSkill11 = Val(ReadField(19, rData, 44))
    UserSkill12 = Val(ReadField(20, rData, 44))
    UserSkill13 = Val(ReadField(21, rData, 44))
    UserSkill14 = Val(ReadField(22, rData, 44))
    UserSkill15 = Val(ReadField(23, rData, 44))
    UserSkill16 = Val(ReadField(24, rData, 44))
    UserSkill17 = Val(ReadField(25, rData, 44))
    UserSkill18 = Val(ReadField(26, rData, 44))
    UserSkill19 = Val(ReadField(27, rData, 44))
    UserSkill20 = Val(ReadField(28, rData, 44))
    UserSkill21 = Val(ReadField(29, rData, 44))
    UserSkill22 = Val(ReadField(30, rData, 44))
    UserSkill23 = Val(ReadField(31, rData, 44))
    UserSkill24 = Val(ReadField(32, rData, 44))
    UserSkill25 = Val(ReadField(33, rData, 44))
    UserSkill26 = Val(ReadField(34, rData, 44))
    UserSkill27 = Val(ReadField(35, rData, 44))
    UserSkill28 = Val(ReadField(36, rData, 44))
    
    UserDrink = Val(ReadField(37, rData, 44))
    UserFood = Val(ReadField(38, rData, 44))
    UserPracticePoints = Val(ReadField(39, rData, 44))
    UserBody = Val(ReadField(40, rData, 44))
    UserHead = Val(ReadField(41, rData, 44))
    UserBankGld = Val(ReadField(42, rData, 44))
    UserWeaponAnim = Val(ReadField(43, rData, 44))
    UserClass = ReadField(44, rData, 44)
    UserRace = ReadField(45, rData, 44)
    UserShieldAnim = Val(ReadField(46, rData, 44))
    inventory.RepRank = ReadField(47, rData, 44)
    UserCriminal = ReadField(48, rData, 44)
    SpecSkill1 = ReadField(49, rData, 44)
    SpecSkill2 = ReadField(50, rData, 44)
    SpecSkill3 = ReadField(51, rData, 44)
    frmMain.experience = ReadField(52, rData, 44) & "/" & ReadField(53, rData, 44)
    CriminalCount = ReadField(54, rData, 44)
    
    frmMain.HPShp.Height = (((UserMinHP / 100) / (UserMaxHP / 100)) * 150)

    frmMain.MANShp.Height = (((UserMinMAN / 100) / (UserMaxMAN / 100)) * 150)

   frmMain.STAShp.Height = (((UserMinSTA / 100) / (UserMaxSTA / 100)) * 150)

    frmMain.GldLbl.Caption = UserGLD
     
    inventory.drink = UserDrink
    inventory.food = UserFood
    
skills.cooking.Caption = UserSkill1
skills.musicanship.Caption = UserSkill2
skills.tailoring.Caption = UserSkill3
skills.carpenting.Caption = UserSkill4
skills.lumberjacking.Caption = UserSkill5
skills.tactics.Caption = UserSkill6
skills.disguise.Caption = UserSkill7
skills.merchant.Caption = UserSkill8
skills.blacksmithing.Caption = UserSkill9
skills.hiding.Caption = UserSkill10
skills.magery.Caption = UserSkill11
skills.lockpicking.Caption = UserSkill12
skills.pickpocket.Caption = UserSkill13
skills.stealth.Caption = UserSkill14
skills.poisoning.Caption = UserSkill15
skills.swordmanship.Caption = UserSkill16
skills.parrying.Caption = UserSkill17
skills.AnimalTaming.Caption = UserSkill18
skills.religionlore.Caption = UserSkill19
skills.fishing.Caption = UserSkill20
skills.mining.Caption = UserSkill21
skills.backstabbing.Caption = UserSkill22
skills.healing.Caption = UserSkill23
skills.surviving.Caption = UserSkill24
            
inventory.gold = UserGLD
inventory.food = UserFood
inventory.drink = UserDrink
inventory.strenght = UserMaxHP
inventory.mana = UserMaxMAN
inventory.fatigue = UserMaxSTA
inventory.navn = UserName
            
Exit Sub
    
End If


'Set Inventory Slot
If Left$(rData, 3) = "SIS" Then
    rData = Right$(rData, Len(rData) - 3)

    Slot = ReadField(1, rData, 44)
    UserInventory(Slot).ObjIndex = ReadField(2, rData, 44)
    UserInventory(Slot).Name = ReadField(3, rData, 44)
    UserInventory(Slot).Amount = ReadField(4, rData, 44)
    UserInventory(Slot).equipped = ReadField(5, rData, 44)
    UserInventory(Slot).GrhIndex = Val(ReadField(6, rData, 44))
    UserInventory(Slot).value = ReadField(7, rData, 44)
    
    TempStr = ""
    If UserInventory(Slot).equipped = 1 Then
        TempStr = TempStr & "(Eqp)"
    End If
    
    If UserInventory(Slot).Amount > 0 Then
        TempStr = TempStr & "(" & UserInventory(Slot).Amount & ") " & UserInventory(Slot).Name
    Else
        TempStr = TempStr & UserInventory(Slot).Name
    End If
    
    inventory.ObjLst.List(Slot - 1) = TempStr
    trade.yourinv.List(Slot - 1) = TempStr
    
    Exit Sub
End If

'Set NPC Inventory Slot
If Left$(rData, 3) = "NIS" Then
    rData = Right$(rData, Len(rData) - 3)

    Slot = ReadField(1, rData, 44)
    NPCinventory(Slot).ObjIndex = ReadField(2, rData, 44)
    NPCinventory(Slot).Name = ReadField(3, rData, 44)
    NPCinventory(Slot).Amount = ReadField(4, rData, 44)
    NPCinventory(Slot).equipped = ReadField(5, rData, 44)
    NPCinventory(Slot).GrhIndex = Val(ReadField(6, rData, 44))
    NPCinventory(Slot).value = Val(ReadField(7, rData, 44))
    NPCinventory(Slot).level = Val(ReadField(8, rData, 44))
    
    TempStr = ""
    If NPCinventory(Slot).equipped = 1 Then
        TempStr = TempStr & "(Eqp)"
    End If
    
    If NPCinventory(Slot).Amount > 0 Then
        TempStr = TempStr & "(" & NPCinventory(Slot).Amount & ") " & NPCinventory(Slot).Name
    Else
        TempStr = TempStr & NPCinventory(Slot).Name
    End If
    
    trade.shopinv.List(Slot - 1) = TempStr
    trade.Show
    
    Exit Sub
End If

'Set Spell Slot
If Left$(rData, 3) = "SPL" Then
    rData = Right$(rData, Len(rData) - 3)

    Slot = ReadField(1, rData, 44)
    UserSpellBook(Slot).SpellIndex = ReadField(2, rData, 44)
    UserSpellBook(Slot).Name = ReadField(3, rData, 44)
    UserSpellBook(Slot).GrhIndex = Val(ReadField(4, rData, 44))
    UserSpellBook(Slot).desc = ReadField(5, rData, 44)
    UserSpellBook(Slot).NeedsMana = Val(ReadField(6, rData, 44))

    
    TempStr2 = ""
    TempStr2 = TempStr2 & UserSpellBook(Slot).Name

    spellbook.SpellLst.List(Slot - 1) = TempStr2
    
    Exit Sub
End If

If Left$(rData, 3) = "OST" Then
    rData = Right$(rData, Len(rData) - 3)

   
    Post = ReadField(1, rData, 44)
    Messageboard(Post).Subject = ReadField(2, rData, 44)
    Messageboard(Post).Post = ReadField(3, rData, 44)
    Messageboard(Post).Author = ReadField(4, rData, 44)
        
    TempStr3 = ""
    TempStr3 = TempStr3 & Messageboard(Post).Subject

msgboard.Posts.List(Slot - 1) = TempStr3
msgboard.Show
    
    Exit Sub
End If

If Left$(rData, 3) = "GMQ" Then
    rData = Right$(rData, Len(rData) - 3)

    Help = ReadField(1, rData, 44)
    GmHelps(Help).helpmsg = ReadField(2, rData, 44)
    GmHelps(Help).userindex = ReadField(3, rData, 44)
    GmHelps(Help).Time = ReadField(4, rData, 44)
    GmHelps(Help).Date = ReadField(5, rData, 44)
    GmHelps(Help).Name = ReadField(6, rData, 44)
        
    TempStr3 = ""
    TempStr3 = TempStr3 & GmHelps(Help).Name & " " & GmHelps(Help).Time & " " & GmHelps(Help).Date

gmque.que.List(Slot - 1) = TempStr3
    
Exit Sub
End If


'Display TARGET message
If Left$(rData, 3) = "TGT" Then
rData = Right$(rData, Len(rData) - 3)

frmMain.TargetMessage.Caption = ReadField(1, rData, 44)

Exit Sub
End If

'Show training form
If Left$(rData, 3) = "TRA" Then
   rData = Right$(rData, Len(rData) - 3)
   
   training.Show
Exit Sub
End If

'Dead
If Left$(rData, 3) = "DEA" Then
   rData = Right$(rData, Len(rData) - 3)
   
   Dead = 1
   
Exit Sub
End If

'Alive
If Left$(rData, 3) = "DEN" Then
   rData = Right$(rData, Len(rData) - 3)
   
   Dead = 0
   
Exit Sub
End If

'Show BODY CLOTHING picture
If Left$(rData, 3) = "PIC" Then
   rData = Right$(rData, Len(rData) - 3)
   
If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = UserInventory(ReadField(1, rData, 44)).GrhIndex
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.body.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.body.Picture = inventory.body.Image
Exit Sub
End If

'Show WEAPON picture
If Left$(rData, 3) = "PC2" Then
   rData = Right$(rData, Len(rData) - 3)
   
If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = UserInventory(ReadField(1, rData, 44)).GrhIndex
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.weapon.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.weapon.Picture = inventory.weapon.Image
Exit Sub
End If


'Show SHIELD picture
If Left$(rData, 3) = "PC3" Then
   rData = Right$(rData, Len(rData) - 3)
   
If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = UserInventory(ReadField(1, rData, 44)).GrhIndex
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.shield.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.shield.Picture = inventory.shield.Image
Exit Sub
End If


'Show HEADWEAR picture
If Left$(rData, 3) = "PC4" Then
   rData = Right$(rData, Len(rData) - 3)
   
If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = UserInventory(ReadField(1, rData, 44)).GrhIndex
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.head.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.head.Picture = inventory.head.Image
Exit Sub
End If


'Play midi
If Left$(rData, 3) = "PLM" Then
    rData = Right$(rData, Len(rData) - 3)
    
    
    'Check to see if music is ON
    If MusicOnOff = 1 Then
    Exit Sub
    End If

    
    CurMidi = IniPath & "music\" & "Mus" & Val(ReadField(1, rData, 45)) & ".mid"
    LoopMidi = Val(ReadField(2, rData, 45))
    Call PlayMidi(CurMidi)

    
    Exit Sub
End If

'Play Wave
If Left$(rData, 3) = "PLW" Then
    rData = Right$(rData, Len(rData) - 3)
    
        Call PlayWaveDS(IniPath & "Sound\" & "Snd" & rData & ".wav")
        
    Exit Sub
End If

'Play MP3
If Left$(rData, 3) = "PL3" Then
    rData = Right$(rData, Len(rData) - 3)
    

    
If Voices = 0 Then frmMain.MP3Player.Stop
If Voices = 0 Then frmMain.MP3Player.FileName = IniPath & "sound\mp" & rData & ".mp3"
If Voices = 0 Then frmMain.MP3Player.Play

    Exit Sub
End If

'Wrong pass sound
If Left$(rData, 3) = "WR1" Then
    rData = Right$(rData, Len(rData) - 3)

frmConnect.MP3Player.Stop
If Voices = 0 Then frmConnect.MP3Player.FileName = IniPath & "sound\mp13.mp3"
If Voices = 0 Then frmConnect.MP3Player.Play

Exit Sub
End If

'Wrong name sound
If Left$(rData, 3) = "WR2" Then
    rData = Right$(rData, Len(rData) - 3)

frmConnect.MP3Player.Stop
If Voices = 0 Then frmConnect.MP3Player.FileName = IniPath & "sound\mp8.mp3"
If Voices = 0 Then frmConnect.MP3Player.Play

Exit Sub
End If

'Unhide
If Left$(rData, 3) = "UNH" Then
    rData = Right$(rData, Len(rData) - 3)

UserHiding = 0

Exit Sub
End If

'Open Note Form With Message
If Left$(rData, 1) = "|" Then
    rData = Right$(rData, Len(rData) - 1)
    noteform.Show
    noteform.message.Caption = rData
    Exit Sub
End If




If Left$(rData, 3) = "ATC" Then
    rData = Right$(rData, Len(rData) - 3)
frmMain.NPCattack.Enabled = True
Exit Sub
End If

If Left$(rData, 3) = "BN1" Then
  rData = Right$(rData, Len(rData) - 3)
deposit.Show
Exit Sub
End If

If Left$(rData, 3) = "BN2" Then
  rData = Right$(rData, Len(rData) - 3)
withdraw.Show
Exit Sub
End If

If Left$(rData, 3) = "TEN" Then
  rData = Right$(rData, Len(rData) - 3)
frmMain.Campfire.Enabled = True
Exit Sub
End If

'Hide
If Left$(rData, 3) = "HID" Then
  rData = Right$(rData, Len(rData) - 3)
UserHiding = 1
Exit Sub
End If

'Disguise
If Left$(rData, 3) = "DIS" Then
  rData = Right$(rData, Len(rData) - 3)
UserDisguising = 1
Exit Sub
End If

If Left$(rData, 3) = "ME1" Then
  rData = Right$(rData, Len(rData) - 3)
frmMain.Meditate.Enabled = True
UserMeditating = 1
Exit Sub
End If

If Left$(rData, 3) = "ME2" Then
  rData = Right$(rData, Len(rData) - 3)
frmMain.Meditate.Enabled = False
UserMeditating = 0
Exit Sub
End If

'Display donate form
If Left$(rData, 3) = "DOT" Then
  rData = Right$(rData, Len(rData) - 3)
donate.Show
Exit Sub
End If

'Open TIP form
If Left$(rData, 3) = "TIP" Then
  rData = Right$(rData, Len(rData) - 3)
tip.Show
Exit Sub
End If

'NOT IN USE
If Left$(rData, 3) = "CON" Then
  rData = Right$(rData, Len(rData) - 3)
Exit Sub
End If

'NOT IN USE
If Left$(rData, 3) = "CO2" Then
  rData = Right$(rData, Len(rData) - 3)
Exit Sub
End If

If Left$(rData, 3) = "GTO" Then
  rData = Right$(rData, Len(rData) - 3)
gmtool.Show
Exit Sub
End If

'Load and read a book
If Left$(rData, 3) = "BOK" Then
rData = Right$(rData, Len(rData) - 3)
BookForm.Show
Open App.Path & "\Books\" & "book" & rData & ".txt" For Input As #1
BookForm.news.Text = StrConv(InputB(LOF(1), 1), vbUnicode)
Close #1
Exit Sub
End If

'*****REMOVE PICS FROM EQUIP CHAR SHEET****
'Weapon
If Left$(rData, 3) = "UWP" Then
   rData = Right$(rData, Len(rData) - 3)
   
If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = 3
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.weapon.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.weapon.Picture = inventory.weapon.Image
Exit Sub
End If

'shield
If Left$(rData, 3) = "USH" Then
   rData = Right$(rData, Len(rData) - 3)
   
If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = 3
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.shield.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.shield.Picture = inventory.shield.Image
Exit Sub
End If

'Clothing
If Left$(rData, 3) = "UCL" Then
   rData = Right$(rData, Len(rData) - 3)
   
If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = 3
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.body.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.body.Picture = inventory.body.Image
Exit Sub
End If

'Head
If Left$(rData, 3) = "UHE" Then
   rData = Right$(rData, Len(rData) - 3)
   
If CurrentGrh.GrhIndex = 0 Then
        InitGrh CurrentGrh, 1
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = 3
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
Call DrawGrhtoHdc(inventory.head.hDC, CurrentGrh, 0, 0, 0, 0, SRCCOPY)
inventory.head.Picture = inventory.head.Image
Exit Sub
End If

'House deed
If Left$(rData, 3) = "DEE" Then
   rData = Right$(rData, Len(rData) - 3)
   
housedeed.Show
housedeed.deedname = ReadField(1, rData, 44)

Exit Sub
End If


'Open Sign & READ
If Left$(rData, 3) = "SGN" Then
    rData = Right$(rData, Len(rData) - 3)
    signread.Show
    signread.Label1 = rData
    Exit Sub
End If

'Open Sign & WRITE
If Left$(rData, 3) = "SII" Then
    rData = Right$(rData, Len(rData) - 3)
    signwrite.Show
    signwrite.Text1 = ReadField(1, rData, 44)
    Exit Sub
End If

'*******WEATHER******

'Make it rain
If Left$(rData, 3) = "RAI" Then
   rData = Right$(rData, Len(rData) - 3)

Raining = 1

Exit Sub
End If

'Stop raining
If Left$(rData, 3) = "SAI" Then
   rData = Right$(rData, Len(rData) - 3)

Raining = 0

Exit Sub
End If


'****************************************************
'****************SKILLS AND ACTIONS******************
'****************************************************

'Initate (skill) action
If Left$(rData, 3) = "DOS" Then
    rData = Right$(rData, Len(rData) - 3)

Working = 1
SkillTime = ReadField(1, rData, 44)
WhatJob = ReadField(2, rData, 44)

frmMain.DoSkill.Enabled = True
frmMain.ActionComplete.Visible = True
frmMain.percentbox.Visible = True
frmMain.percentage.Visible = True
frmMain.percentage.Caption = 0
frmMain.cancelaction.Visible = True

'Make it so skill is not too low
If SkillTime < 3 Then SkillTime = 2

Exit Sub
End If

'Error handler
errorhandler:
Exit Sub

End Sub

Sub SendData(sdData As String)
On Error Resume Next
'*********************************************
'Attach a ENDC to a string and send to server
'*********************************************
Dim retcode

sdData = sdData & ENDC

'To avoid spam set a limit
If Len(sdData) > 300 Then
    Exit Sub
End If

retcode = frmMain.Socket1.Write(sdData, Len(sdData))

End Sub

Sub Login()
On Error Resume Next


'*********************************************
'Send login strings
'*********************************************

'Erase character
If ErasingChar = True Then
SendData ("ERASE" & UserName & "," & UserPassword & "," & UserVersion & "," & Userid)
Exit Sub
End If

'Pre-saved character
If SendNewChar = False Then
    SendData ("LOGIN" & UserName & "," & UserPassword & "," & UserVersion & "," & Userid)
End If

'New character
If SendNewChar = True Then
    SendData ("NLOGIN" & UserName & "," & UserPassword & "," & UserBody & "," & UserHead & "," & UserTown & "," & UserWeaponAnim & "," & UserRace & "," & UserClass & "," & UserShieldAnim & "," & UserGender & "," & UserMail & "," & UserVersion & "," & UserBetaPass & "," & SpecSkill1 & "," & SpecSkill2 & "," & SpecSkill3 & "," & Userid)
End If

End Sub


