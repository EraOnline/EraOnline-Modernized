Attribute VB_Name = "FileIO"
Option Explicit

Sub LoadOBJData()
On Error Resume Next

'*****************************************************************
'Setup OBJ list
'*****************************************************************
Dim Object As Integer

'Get Number of Objects
NumObjDatas = Val(GetVar(IniPath & "Obj.dat", "INIT", "NumOBJs"))
ReDim ObjData(1 To NumObjDatas) As ObjData
  
'Fill Object List
For Object = 1 To NumObjDatas
    
loading.percent = "Loading object " & Object & " of " & NumObjDatas
loading.Picture = LoadPicture(App.Path & "\loading.jpg")
          
    
    With ObjData(Object)
        .Name = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Name")
        .Category = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Category")
        .ClassForbid1 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid1")
        .ClassForbid2 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid2")
        .ClassForbid3 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid3")
        .ClassForbid4 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid4")
        .ClassForbid5 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid5")
        .ClassForbid6 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid6")
        .ClassForbid7 = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Classforbid7")
        .Grhindex = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "GrhIndex"))
        .MakeItem = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Makeitem"))
        .Pickable = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Pickable"))
        .ObjType = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "ObjType"))
        .Sellable = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Sellable"))
        .Food = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Food"))
        .Value = GetVar(IniPath & "Obj.dat", "OBJ" & Object, "VALUE")
        .Level = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "LEVEL"))
        .SpellType = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "SPELLTYPE"))
        .NeedPlanks = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "NeedPlanks"))
        .NeedFoldedCloth = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "NeedFoldedCloth"))
        .NeedSteel = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "NeedSteel"))
        .skill = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "Skill"))
        .MaxHIT = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "MaxHIT"))
        .MinHIT = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "MinHIT"))
        .MaxHP = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "MaxHP"))
        .MinHP = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "MinHP"))
        .DEF = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "DEF"))
        .ClothingType = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "ClothingType"))
        .HandleRain = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "TakeRain"))
        .ShieldAnim = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "ShieldAnim"))
        .WeaponAnim = Val(GetVar(IniPath & "Obj.dat", "OBJ" & Object, "WeaponAnim"))
    End With
Next Object

End Sub

Sub LoadSpellData()
'*****************************************************************
'Setup SPELL list
'*****************************************************************
Dim SpellObj As Integer

'Get Number of Spells
NumSPELLDatas = Val(GetVar(IniPath & "Spells.dat", "INIT", "NumSpells"))
ReDim SpellData(1 To NumSPELLDatas) As SpellData
  
'Fill Spells List
For SpellObj = 1 To NumSPELLDatas
    
    With SpellData(SpellObj)
        .Name = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Name")
        .Desc = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Desc")
        .CasterMessage = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "CasterMessage")
        .TargetMessage = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "TargetMessage")
        .School1 = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "School1")
        .School2 = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "School2")
        .School3 = GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "School3")
        .GrhEffect = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GrhEffect"))
        .Grhindex = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GrhIndex"))
        .GrhIcon = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GrhIcon"))
        .Sound = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Sound"))
        .NeedsMana = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "NeedsMana"))
        .GiveHp = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveHP"))
        .GiveMan = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveMan"))
        .GiveFat = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveFat"))
        .GiveMoney = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveMoney"))
        .GiveFood = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveFood"))
        .GiveDrink = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveDrink"))
        .GiveEXP = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "GiveExp"))
        .HealHP = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "HealHP"))
        .HealMan = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "HealMan"))
        .HealFat = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "HealFat"))
        .DamageHp = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "DamageHP"))
        .DamageMan = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "DamageMan"))
        .DamageFat = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "DamageFat"))
        .Invisibility = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Invisibility"))
        .CreateObj = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "CreateOBJ"))
        .SummonCreature = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "SummonCreature"))
        .Paralyze = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Paralyze"))
        .Destruction = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Destruction"))
        .Ressurection = Val(GetVar(IniPath & "Spells.dat", "SPELL" & SpellObj, "Ressurection"))
    End With

Next SpellObj

End Sub
Sub LoadUserStats(userindex As Integer, UserFile As String)
On Error Resume Next


'*****************************************************************
'Loads a user's stats from a text file
'*****************************************************************

UserList(userindex).Stats.GLD = Val(GetVar(UserFile, "STATS", "GLD"))
UserList(userindex).Stats.BANKGLD = Val(GetVar(UserFile, "STATS", "BANKGLD"))
UserList(userindex).Stats.Food = Val(GetVar(UserFile, "STATS", "Food"))
UserList(userindex).Stats.Drink = Val(GetVar(UserFile, "STATS", "Drink"))
UserList(userindex).Stats.PracticePoints = Val(GetVar(UserFile, "STATS", "PracticePoints"))
UserList(userindex).Stats.AnimalIndex = Val(GetVar(UserFile, "STATS", "AnimalIndex"))
UserList(userindex).Stats.OwnAnimal = Val(GetVar(UserFile, "STATS", "AnimalIndex"))


UserList(userindex).Flags.status = Val(GetVar(UserFile, "FLAGS", "STATUS"))
UserList(userindex).Flags.Criminal = Val(GetVar(UserFile, "FLAGS", "CRIMINAL"))
UserList(userindex).Flags.StartHead = Val(GetVar(UserFile, "FLAGS", "StartHead"))
UserList(userindex).Flags.StartName = GetVar(UserFile, "FLAGS", "StartName")
UserList(userindex).Flags.SpecSkill1 = GetVar(UserFile, "FLAGS", "SpecSkill1")
UserList(userindex).Flags.SpecSkill2 = GetVar(UserFile, "FLAGS", "SpecSkill2")
UserList(userindex).Flags.SpecSkill3 = GetVar(UserFile, "FLAGS", "SpecSkill3")
UserList(userindex).Flags.CriminalCount = Val(GetVar(UserFile, "FLAGS", "CriminalCount"))
UserList(userindex).Flags.YourID = Val(GetVar(UserFile, "FLAGS", "YourID"))
UserList(userindex).Flags.Locks = Val(GetVar(UserFile, "FLAGS", "Locks"))

UserList(userindex).Community.NobleRep = Val(GetVar(UserFile, "Community", "NobleRep"))
UserList(userindex).Community.UnderRep = Val(GetVar(UserFile, "Community", "UnderRep"))
UserList(userindex).Community.CommonRep = Val(GetVar(UserFile, "Community", "CommonRep"))
UserList(userindex).Community.BendarrRep = Val(GetVar(UserFile, "Community", "BendarrRep"))
UserList(userindex).Community.VeegaRep = Val(GetVar(UserFile, "Community", "VeegaRep"))
UserList(userindex).Community.ZeendicRep = Val(GetVar(UserFile, "Community", "ZeendicRep"))
UserList(userindex).Community.GriigoRep = Val(GetVar(UserFile, "Community", "GriigoRep"))
UserList(userindex).Community.HyliiosRep = Val(GetVar(UserFile, "Community", "HyliiosRep"))
UserList(userindex).Community.OverallRep = Val(GetVar(UserFile, "Community", "OverallRep"))
UserList(userindex).Community.RepRank = GetVar(UserFile, "Community", "RepRank")


UserList(userindex).Stats.MET = Val(GetVar(UserFile, "STATS", "MET"))
UserList(userindex).Stats.MaxHP = Val(GetVar(UserFile, "STATS", "MaxHP"))
UserList(userindex).Stats.MinHP = Val(GetVar(UserFile, "STATS", "MinHP"))

UserList(userindex).Stats.FIT = Val(GetVar(UserFile, "STATS", "FIT"))
UserList(userindex).Stats.MinSTA = Val(GetVar(UserFile, "STATS", "MinSTA"))
UserList(userindex).Stats.MaxSTA = Val(GetVar(UserFile, "STATS", "MaxSTA"))

UserList(userindex).Stats.MaxMAN = Val(GetVar(UserFile, "STATS", "MaxMAN"))
UserList(userindex).Stats.MinMAN = Val(GetVar(UserFile, "STATS", "MinMAN"))

UserList(userindex).Stats.MaxHIT = Val(GetVar(UserFile, "STATS", "MaxHIT"))
UserList(userindex).Stats.MinHIT = Val(GetVar(UserFile, "STATS", "MinHIT"))
UserList(userindex).Stats.DEF = Val(GetVar(UserFile, "STATS", "DEF"))

UserList(userindex).Stats.EXP = Val(GetVar(UserFile, "STATS", "EXP"))
UserList(userindex).Stats.ELU = Val(GetVar(UserFile, "STATS", "ELU"))
UserList(userindex).Stats.ELV = Val(GetVar(UserFile, "STATS", "ELV"))

UserList(userindex).Stats.Skill1 = Val(GetVar(UserFile, "SKILLS", "SKILL1"))
UserList(userindex).Stats.Skill2 = Val(GetVar(UserFile, "SKILLS", "SKILL2"))
UserList(userindex).Stats.Skill3 = Val(GetVar(UserFile, "SKILLS", "SKILL3"))
UserList(userindex).Stats.Skill4 = Val(GetVar(UserFile, "SKILLS", "SKILL4"))
UserList(userindex).Stats.Skill5 = Val(GetVar(UserFile, "SKILLS", "SKILL5"))
UserList(userindex).Stats.Skill6 = Val(GetVar(UserFile, "SKILLS", "SKILL6"))
UserList(userindex).Stats.Skill7 = Val(GetVar(UserFile, "SKILLS", "SKILL7"))
UserList(userindex).Stats.Skill8 = Val(GetVar(UserFile, "SKILLS", "SKILL8"))
UserList(userindex).Stats.Skill9 = Val(GetVar(UserFile, "SKILLS", "SKILL9"))
UserList(userindex).Stats.Skill10 = Val(GetVar(UserFile, "SKILLS", "SKILL10"))
UserList(userindex).Stats.Skill11 = Val(GetVar(UserFile, "SKILLS", "SKILL11"))
UserList(userindex).Stats.Skill12 = Val(GetVar(UserFile, "SKILLS", "SKILL12"))
UserList(userindex).Stats.Skill13 = Val(GetVar(UserFile, "SKILLS", "SKILL13"))
UserList(userindex).Stats.Skill14 = Val(GetVar(UserFile, "SKILLS", "SKILL14"))
UserList(userindex).Stats.Skill15 = Val(GetVar(UserFile, "SKILLS", "SKILL15"))
UserList(userindex).Stats.Skill16 = Val(GetVar(UserFile, "SKILLS", "SKILL16"))
UserList(userindex).Stats.Skill17 = Val(GetVar(UserFile, "SKILLS", "SKILL17"))
UserList(userindex).Stats.Skill18 = Val(GetVar(UserFile, "SKILLS", "SKILL18"))
UserList(userindex).Stats.Skill19 = Val(GetVar(UserFile, "SKILLS", "SKILL19"))
UserList(userindex).Stats.Skill20 = Val(GetVar(UserFile, "SKILLS", "SKILL20"))
UserList(userindex).Stats.Skill21 = Val(GetVar(UserFile, "SKILLS", "SKILL21"))
UserList(userindex).Stats.Skill22 = Val(GetVar(UserFile, "SKILLS", "SKILL22"))
UserList(userindex).Stats.Skill23 = Val(GetVar(UserFile, "SKILLS", "SKILL23"))
UserList(userindex).Stats.Skill24 = Val(GetVar(UserFile, "SKILLS", "SKILL24"))
UserList(userindex).Stats.Skill25 = Val(GetVar(UserFile, "SKILLS", "SKILL25"))
UserList(userindex).Stats.Skill26 = Val(GetVar(UserFile, "SKILLS", "SKILL26"))
UserList(userindex).Stats.Skill27 = Val(GetVar(UserFile, "SKILLS", "SKILL27"))
UserList(userindex).Stats.Skill28 = Val(GetVar(UserFile, "SKILLS", "SKILL28"))



End Sub

Sub LoadUserInit(userindex As Integer, UserFile As String)


'*****************************************************************
'Loads the user's Init stuff
'*****************************************************************
Dim loopb As Integer
Dim LoopC As Integer
Dim ln As String

'Get INIT
UserList(userindex).Char.Heading = Val(GetVar(UserFile, "INIT", "Heading"))
UserList(userindex).Char.Head = Val(GetVar(UserFile, "INIT", "Head"))
UserList(userindex).Char.Body = Val(GetVar(UserFile, "INIT", "Body"))
UserList(userindex).Char.WeaponAnim = Val(GetVar(UserFile, "INIT", "WeaponAnim"))
UserList(userindex).Char.ShieldAnim = Val(GetVar(UserFile, "INIT", "ShieldAnim"))
UserList(userindex).Desc = GetVar(UserFile, "INIT", "Desc")
UserList(userindex).Gender = GetVar(UserFile, "INIT", "Gender")
UserList(userindex).Email = GetVar(UserFile, "INIT", "Email")

UserList(userindex).theid = GetVar(UserFile, "INIT", "THEID")

UserList(userindex).Race = GetVar(UserFile, "INIT", "Race")
UserList(userindex).class = GetVar(UserFile, "INIT", "Class")
UserList(userindex).MagicSchool = GetVar(UserFile, "INIT", "MagicSchool")

UserList(userindex).Clan = GetVar(UserFile, "INIT", "Clan")
UserList(userindex).ClanRank = GetVar(UserFile, "INIT", "ClanRank")
UserList(userindex).ClanMember = Val(GetVar(UserFile, "INIT", "ClanMember"))


'Get last postion
UserList(userindex).Pos.map = Val(ReadField(1, GetVar(UserFile, "INIT", "Position"), 45))
UserList(userindex).Pos.x = Val(ReadField(2, GetVar(UserFile, "INIT", "Position"), 45))
UserList(userindex).Pos.y = Val(ReadField(3, GetVar(UserFile, "INIT", "Position"), 45))

'Get object list
For LoopC = 1 To MAX_INVENTORY_SLOTS
    ln = GetVar(UserFile, "Inventory", "Obj" & LoopC)
    UserList(userindex).Object(LoopC).ObjIndex = Val(ReadField(1, ln, 45))
    UserList(userindex).Object(LoopC).Amount = Val(ReadField(2, ln, 45))
    UserList(userindex).Object(LoopC).Equipped = Val(ReadField(3, ln, 45))
Next LoopC

'Get spell list
For loopb = 1 To MAX_SPELL_SLOTS
    ln = GetVar(UserFile, "Spells", "SPELL" & loopb)
    UserList(userindex).SpellObj(loopb).SpellIndex = Val(ReadField(1, ln, 45))
Next loopb

'Get Weapon objectindex and slot
UserList(userindex).WeaponEqpSlot = Val(GetVar(UserFile, "Inventory", "WeaponEqpSlot"))
If UserList(userindex).WeaponEqpSlot > 0 Then
    UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(UserList(userindex).WeaponEqpSlot).ObjIndex
End If

'Get Armour objectindex and slot
UserList(userindex).ArmourEqpSlot = Val(GetVar(UserFile, "Inventory", "ArmourEqpSlot"))
If UserList(userindex).ArmourEqpSlot > 0 Then
    UserList(userindex).ArmourEqpObjIndex = UserList(userindex).Object(UserList(userindex).ArmourEqpSlot).ObjIndex
End If

'Get Clothing objectindex and slot
UserList(userindex).ClothingEqpSlot = Val(GetVar(UserFile, "Inventory", "ClothingEqpSlot"))
If UserList(userindex).ClothingEqpSlot > 0 Then
    UserList(userindex).ClothingEqpObjindex = UserList(userindex).Object(UserList(userindex).ClothingEqpSlot).ObjIndex
End If

'Get HEAD objectindex and slot
UserList(userindex).HEADEqpSlot = Val(GetVar(UserFile, "Inventory", "HEADEqpSlot"))
If UserList(userindex).HEADEqpSlot > 0 Then
    UserList(userindex).HEADEqpObjindex = UserList(userindex).Object(UserList(userindex).HEADEqpSlot).ObjIndex
End If

'Get SHIELD objectindex and slot
UserList(userindex).SHIELDEqpSlot = Val(GetVar(UserFile, "Inventory", "SHIELDEqpSlot"))
If UserList(userindex).SHIELDEqpSlot > 0 Then
    UserList(userindex).SHIELDEqpObjindex = UserList(userindex).Object(UserList(userindex).SHIELDEqpSlot).ObjIndex
End If

'Set clothing slot
UserList(userindex).Object(UserList(userindex).ClothingEqpSlot).Equipped = 1



End Sub

Sub ModName(userindex As Integer)
'*****************************************************************
'Finds the ModName of a person
'*****************************************************************
Dim NumWizTypes As Integer
Dim NumWizs As Integer
Dim Wiznum As Integer
Dim WizType As Integer
Dim Name As String
Dim temp As Integer
Dim TempModName As String
Name = UserList(userindex).Name

NumWizs = Val(GetVar(IniPath & "Server.ini", "INIT", "NumWizs"))
For Wiznum = 1 To NumWizs
    If UCase(Name) = UCase(GetVar(IniPath & "Server.ini", "WIZLIST", "wiz" & Wiznum)) Then
        temp = Val(GetVar(IniPath & "Server.ini", "LEVEL" & Val(GetVar(IniPath & "Server.ini", "WIZLIST", "level" & Wiznum)), "Power"))
        If temp <> 0 Then
            TempModName = " " & GetVar(IniPath & "Server.ini", "LEVEL" & Val(GetVar(IniPath & "Server.ini", "WIZLIST", "Level" & Wiznum)), "Name")
            Call SendData(ToAll, 0, 0, "PLW41")
            Call SendData(ToAll, 0, 0, "@" & Right(Left(TempModName, Len(TempModName) - 1), Len(TempModName) - 3) & " " & Name & " has entered the world of Menath!~255~255~0~1~0")
            UserList(userindex).Stats.Power = temp
        Else
            TempModName = ""
            UserList(userindex).Stats.Power = 0
        End If
        UserList(userindex).ModName = Name & TempModName
        Exit Sub
    End If
Next Wiznum

UserList(userindex).ModName = Name
UserList(userindex).Stats.Power = 0

End Sub

Function GetVar(File As String, Main As String, Var As String) As String
On Error Resume Next


'*****************************************************************
'Gets a variable from a text file
'*****************************************************************
Dim sSpaces As String ' This will hold the input that the program will retrieve
Dim szReturn As String ' This will be the defaul value if the string is not found
  
szReturn = ""
  
sSpaces = Space(5000) ' This tells the computer how long the longest string can be. If you want, you can change the number 75 to any number you wish
  
  
getprivateprofilestring Main, Var, szReturn, sSpaces, Len(sSpaces), File
  
GetVar = RTrim(sSpaces)
GetVar = Left(GetVar, Len(GetVar) - 1)
  
End Function

Sub LoadMapData()
On Error Resume Next


'*****************************************************************
'Loads the MapX.X files
'*****************************************************************
Dim map As Integer
Dim LoopC As Integer
Dim x As Integer
Dim y As Integer
Dim DummyInt As Integer

NumMaps = Val(GetVar(IniPath & "\maps\Map.dat", "INIT", "NumMaps"))
ReDim MapData(1 To NumMaps, XMinMapSize To XMaxMapSize, YMinMapSize To YMaxMapSize) As MapBlock
ReDim MapInfo(1 To NumMaps) As MapInfo
  
For map = 1 To NumMaps
   
loading.percent = "Loading Map " & map & " of " & NumMaps
loading.Picture = LoadPicture(App.Path & "\loading.jpg")
      
MapInfo(map).UsersOnMap = 0

    'Open files
    
    'map
    Open IniPath & "\maps\Map" & map & ".map" For Binary As #1
    Seek #1, 1
    
    'inf
    Open IniPath & "\maps\Map" & map & ".inf" For Binary As #2
    Seek #2, 1
        
    'obj
    Open IniPath & "\maps\Map" & map & ".obj" For Binary As #3
    Seek #3, 1
    
       
    'Load arrays
    For y = YMinMapSize To YMaxMapSize
        For x = XMinMapSize To XMaxMapSize

            '.dat file
            Get #1, , MapData(map, x, y).Blocked
            
            'Throw away GRH data...Not needed for server
            For LoopC = 1 To 3
                Get #1, , DummyInt
            Next LoopC
                                
            '.inf file
            Get #2, , MapData(map, x, y).TileExit.map
            Get #2, , MapData(map, x, y).TileExit.x
            Get #2, , MapData(map, x, y).TileExit.y
            
            'Get and make NPC
            Get #2, , MapData(map, x, y).Npcindex
            If MapData(map, x, y).Npcindex > 0 Then
                MapData(map, x, y).Npcindex = OpenNPC(MapData(map, x, y).Npcindex)
                NPCList(MapData(map, x, y).Npcindex).Pos.map = map
                NPCList(MapData(map, x, y).Npcindex).Pos.x = x
                NPCList(MapData(map, x, y).Npcindex).Pos.y = y
                Call MakeNPCChar(ToNone, 0, 0, MapData(map, x, y).Npcindex, map, x, y)
            End If

            'Get and make Object
            Get #3, , MapData(map, x, y).ObjInfo.ObjIndex
            Get #3, , MapData(map, x, y).ObjInfo.Amount
                 
            Get #3, , MapData(map, x, y).Locked
            
            Get #3, , MapData(map, x, y).Sign
            Get #3, , MapData(map, x, y).SignOwner
            
            'Space holder for future expansion (Objects, ect.)
            Get #2, , DummyInt
            Get #2, , DummyInt
        
        Next x
    Next y

    'Close files
    Close #1
    Close #2
    Close #3
    
    'Other Room Data
    With MapInfo(map)
        .Name = GetVar(IniPath & "\maps\Map" & map & ".dat", "Map" & map, "Name")
        .Music = GetVar(IniPath & "\maps\Map" & map & ".dat", "Map" & map, "MusicNum")
        .StartPos.map = Val(ReadField(1, GetVar(IniPath & "\maps\Map" & map & ".dat", "Map" & map, "StartPos"), 45))
        .StartPos.x = Val(ReadField(2, GetVar(IniPath & "\maps\Map" & map & ".dat", "Map" & map, "StartPos"), 45))
        .StartPos.y = Val(ReadField(3, GetVar(IniPath & "\maps\Map" & map & ".dat", "Map" & map, "StartPos"), 45))
        .NorthExit = Val(GetVar(IniPath & "\maps\Map" & map & ".dat", "Map" & map, "NorthExit"))
        .SouthExit = Val(GetVar(IniPath & "\maps\Map" & map & ".dat", "Map" & map, "SouthExit"))
        .WestExit = Val(GetVar(IniPath & "\maps\Map" & map & ".dat", "Map" & map, "WestExit"))
        .EastExit = Val(GetVar(IniPath & "\maps\Map" & map & ".dat", "Map" & map, "EastExit"))
    End With
Next map
End Sub

Sub LoadSini()
On Error Resume Next


'*****************************************************************
'Loads the Server.ini
'*****************************************************************

'Misc
frmMain.txPortNumber.Text = GetVar(IniPath & "Server.ini", "INIT", "StartPort")
HideMe = Val(GetVar(IniPath & "Server.ini", "INIT", "Hide"))
AllowMultiLogins = Val(GetVar(IniPath & "Server.ini", "INIT", "AllowMultiLogins"))
IdleLimit = Val(GetVar(IniPath & "Server.ini", "INIT", "IdleLimit"))
MessageboardNews = GetVar(IniPath & "Server.ini", "INIT", "MessageboardNews")
ClientVersion = GetVar(IniPath & "Server.ini", "INIT", "ClientVersion")


LevelSkill(1).LevelValue = 3
LevelSkill(2).LevelValue = 5
LevelSkill(3).LevelValue = 7
LevelSkill(4).LevelValue = 10
LevelSkill(5).LevelValue = 13
LevelSkill(6).LevelValue = 15
LevelSkill(7).LevelValue = 17
LevelSkill(8).LevelValue = 20
LevelSkill(9).LevelValue = 23
LevelSkill(10).LevelValue = 25
LevelSkill(11).LevelValue = 27
LevelSkill(12).LevelValue = 30
LevelSkill(13).LevelValue = 33
LevelSkill(14).LevelValue = 35
LevelSkill(15).LevelValue = 37
LevelSkill(16).LevelValue = 40
LevelSkill(17).LevelValue = 43
LevelSkill(18).LevelValue = 45
LevelSkill(19).LevelValue = 47
LevelSkill(20).LevelValue = 50
LevelSkill(21).LevelValue = 53
LevelSkill(22).LevelValue = 55
LevelSkill(23).LevelValue = 57
LevelSkill(24).LevelValue = 60
LevelSkill(25).LevelValue = 63
LevelSkill(26).LevelValue = 65
LevelSkill(27).LevelValue = 67
LevelSkill(28).LevelValue = 70
LevelSkill(29).LevelValue = 73
LevelSkill(30).LevelValue = 75
LevelSkill(31).LevelValue = 77
LevelSkill(32).LevelValue = 80
LevelSkill(33).LevelValue = 83
LevelSkill(34).LevelValue = 85
LevelSkill(35).LevelValue = 87
LevelSkill(36).LevelValue = 90
LevelSkill(37).LevelValue = 93
LevelSkill(38).LevelValue = 95
LevelSkill(39).LevelValue = 97
LevelSkill(40).LevelValue = 100
LevelSkill(41).LevelValue = 100
LevelSkill(42).LevelValue = 100
LevelSkill(43).LevelValue = 100
LevelSkill(44).LevelValue = 100
LevelSkill(45).LevelValue = 100
LevelSkill(46).LevelValue = 100
LevelSkill(47).LevelValue = 100
LevelSkill(48).LevelValue = 100
LevelSkill(49).LevelValue = 100
LevelSkill(50).LevelValue = 100




'Start pos for different villages
CastleFallStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "CastleFall"), 45))
CastleFallStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "CastleFall"), 45))
CastleFallStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "CastleFall"), 45))

BernVillageStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "Bernvillage"), 45))
BernVillageStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "Bernvillage"), 45))
BernVillageStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "Bernvillage"), 45))

AngelmoorStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "AngelMoor"), 45))
AngelmoorStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "AngelMoor"), 45))
AngelmoorStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "AngelMoor"), 45))

GorthStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "Gorth"), 45))
GorthStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "Gorth"), 45))
GorthStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "Gorth"), 45))

JemhooStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "Jemhoo"), 45))
JemhooStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "Jemhoo"), 45))
JemhooStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "Jemhoo"), 45))

DencStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "Denc"), 45))
DencStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "Denc"), 45))
DencStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "Denc"), 45))

ValenStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "Valen"), 45))
ValenStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "Valen"), 45))
ValenStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "Valen"), 45))

ValenfallStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "Valenfall"), 45))
ValenfallStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "Valenfall"), 45))
ValenfallStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "Valenfall"), 45))

MolgStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "Molg"), 45))
MolgStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "Molg"), 45))
MolgStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "Molg"), 45))

UgStartPos.map = Val(ReadField(1, GetVar(IniPath & "Server.ini", "INIT", "Ug"), 45))
UgStartPos.x = Val(ReadField(2, GetVar(IniPath & "Server.ini", "INIT", "Ug"), 45))
UgStartPos.y = Val(ReadField(3, GetVar(IniPath & "Server.ini", "INIT", "Ug"), 45))

  
'Max users
MaxUsers = Val(GetVar(IniPath & "Server.ini", "INIT", "MaxUsers"))
ReDim UserList(1 To MaxUsers) As User

End Sub

Sub WriteVar(File As String, Main As String, Var As String, Value As String)
On Error Resume Next

'*****************************************************************
'Writes a var to a text file
'*****************************************************************

writeprivateprofilestring Main, Var, Value, File
    
End Sub

Sub SaveUser(userindex As Integer, UserFile As String)
On Error Resume Next


Open App.Path & "\Log.txt" For Append Shared As #5
Print #5, "SaveUSER"
Close #5

'*****************************************************************
'Saves a user's data to a .chr file
'*****************************************************************
Dim LoopC As Integer
Dim SaveSpell As Integer


Call WriteVar(UserFile, "INIT", "Password", UserList(userindex).Password)
Call WriteVar(UserFile, "INIT", "Position", UserList(userindex).Pos.map & "-" & UserList(userindex).Pos.x & "-" & UserList(userindex).Pos.y)
Call WriteVar(UserFile, "INIT", "Desc", UserList(userindex).Desc)
Call WriteVar(UserFile, "INIT", "Heading", Str(UserList(userindex).Char.Heading))
Call WriteVar(UserFile, "INIT", "Head", Str(UserList(userindex).Char.Head))
Call WriteVar(UserFile, "INIT", "Body", Str(UserList(userindex).Char.Body))
Call WriteVar(UserFile, "INIT", "WeaponAnim", Str(UserList(userindex).Char.WeaponAnim))
Call WriteVar(UserFile, "INIT", "ShieldAnim", Str(UserList(userindex).Char.ShieldAnim))
Call WriteVar(UserFile, "INIT", "MagicSchool", UserList(userindex).MagicSchool)

Call WriteVar(UserFile, "INIT", "Clan", UserList(userindex).Clan)
Call WriteVar(UserFile, "INIT", "ClanRank", UserList(userindex).ClanRank)
Call WriteVar(UserFile, "INIT", "ClanMember", Str(UserList(userindex).ClanMember))


Call WriteVar(UserFile, "INIT", "THEID", Str(UserList(userindex).theid))

Call WriteVar(UserFile, "INIT", "Gender", UserList(userindex).Gender)
Call WriteVar(UserFile, "INIT", "Email", UserList(userindex).Email)

Call WriteVar(UserFile, "INIT", "Race", UserList(userindex).Race)
Call WriteVar(UserFile, "INIT", "Class", UserList(userindex).class)


Call WriteVar(UserFile, "FLAGS", "Status", Str(UserList(userindex).Flags.status))
Call WriteVar(UserFile, "FLAGS", "Criminal", Str(UserList(userindex).Flags.Criminal))
Call WriteVar(UserFile, "FLAGS", "StartHead", Str(UserList(userindex).Flags.StartHead))
Call WriteVar(UserFile, "FLAGS", "StartName", UserList(userindex).Flags.StartName)
Call WriteVar(UserFile, "FLAGS", "SpecSkill1", UserList(userindex).Flags.SpecSkill1)
Call WriteVar(UserFile, "FLAGS", "SpecSkill2", UserList(userindex).Flags.SpecSkill2)
Call WriteVar(UserFile, "FLAGS", "SpecSkill3", UserList(userindex).Flags.SpecSkill3)
Call WriteVar(UserFile, "FLAGS", "CriminalCount", Str(UserList(userindex).Flags.CriminalCount))
Call WriteVar(UserFile, "FLAGS", "YourID", Str(UserList(userindex).Flags.YourID))
Call WriteVar(UserFile, "FLAGS", "Locks", Str(UserList(userindex).Flags.Locks))



Call WriteVar(UserFile, "COMMUNITY", "NobleRep", Str(UserList(userindex).Community.NobleRep))
Call WriteVar(UserFile, "COMMUNITY", "UnderRep", Str(UserList(userindex).Community.UnderRep))
Call WriteVar(UserFile, "COMMUNITY", "CommonRep", Str(UserList(userindex).Community.CommonRep))
Call WriteVar(UserFile, "COMMUNITY", "BendarrRep", Str(UserList(userindex).Community.BendarrRep))
Call WriteVar(UserFile, "COMMUNITY", "VeegaRep", Str(UserList(userindex).Community.VeegaRep))
Call WriteVar(UserFile, "COMMUNITY", "ZeendicRep", Str(UserList(userindex).Community.ZeendicRep))
Call WriteVar(UserFile, "COMMUNITY", "GriigoRep", Str(UserList(userindex).Community.GriigoRep))
Call WriteVar(UserFile, "COMMUNITY", "HyliiosRep", Str(UserList(userindex).Community.HyliiosRep))
Call WriteVar(UserFile, "COMMUNITY", "OverallRep", Str(UserList(userindex).Community.OverallRep))
Call WriteVar(UserFile, "COMMUNITY", "RepRank", UserList(userindex).Community.RepRank)


Call WriteVar(UserFile, "INIT", "LastIP", UserList(userindex).IP)

Call WriteVar(UserFile, "STATS", "GLD", Str(UserList(userindex).Stats.GLD))
Call WriteVar(UserFile, "STATS", "BANKGLD", Str(UserList(userindex).Stats.BANKGLD))
Call WriteVar(UserFile, "STATS", "Food", Str(UserList(userindex).Stats.Food))
Call WriteVar(UserFile, "STATS", "Drink", Str(UserList(userindex).Stats.Drink))
Call WriteVar(UserFile, "STATS", "PracticePoints", Str(UserList(userindex).Stats.PracticePoints))
Call WriteVar(UserFile, "STATS", "AnimalIndex", Str(UserList(userindex).Stats.AnimalIndex))


Call WriteVar(UserFile, "STATS", "MET", Str(UserList(userindex).Stats.MET))
Call WriteVar(UserFile, "STATS", "MaxHP", Str(UserList(userindex).Stats.MaxHP))
Call WriteVar(UserFile, "STATS", "MinHP", Str(UserList(userindex).Stats.MinHP))

Call WriteVar(UserFile, "STATS", "FIT", Str(UserList(userindex).Stats.FIT))
Call WriteVar(UserFile, "STATS", "MaxSTA", Str(UserList(userindex).Stats.MaxSTA))
Call WriteVar(UserFile, "STATS", "MinSTA", Str(UserList(userindex).Stats.MinSTA))

Call WriteVar(UserFile, "STATS", "MaxMAN", Str(UserList(userindex).Stats.MaxMAN))
Call WriteVar(UserFile, "STATS", "MinMAN", Str(UserList(userindex).Stats.MinMAN))

Call WriteVar(UserFile, "STATS", "MaxHIT", Str(UserList(userindex).Stats.MaxHIT))
Call WriteVar(UserFile, "STATS", "MinHIT", Str(UserList(userindex).Stats.MinHIT))
Call WriteVar(UserFile, "STATS", "DEF", Str(UserList(userindex).Stats.DEF))
  
Call WriteVar(UserFile, "STATS", "EXP", Str(UserList(userindex).Stats.EXP))
Call WriteVar(UserFile, "STATS", "ELV", Str(UserList(userindex).Stats.ELV))
Call WriteVar(UserFile, "STATS", "ELU", Str(UserList(userindex).Stats.ELU))
  
 
Call WriteVar(UserFile, "SKILLS", "Skill1", Str(UserList(userindex).Stats.Skill1))
Call WriteVar(UserFile, "SKILLS", "Skill2", Str(UserList(userindex).Stats.Skill2))
Call WriteVar(UserFile, "SKILLS", "Skill3", Str(UserList(userindex).Stats.Skill3))
Call WriteVar(UserFile, "SKILLS", "Skill4", Str(UserList(userindex).Stats.Skill4))
Call WriteVar(UserFile, "SKILLS", "Skill5", Str(UserList(userindex).Stats.Skill5))
Call WriteVar(UserFile, "SKILLS", "Skill6", Str(UserList(userindex).Stats.Skill6))
Call WriteVar(UserFile, "SKILLS", "Skill7", Str(UserList(userindex).Stats.Skill7))
Call WriteVar(UserFile, "SKILLS", "Skill8", Str(UserList(userindex).Stats.Skill8))
Call WriteVar(UserFile, "SKILLS", "Skill9", Str(UserList(userindex).Stats.Skill9))
Call WriteVar(UserFile, "SKILLS", "Skill10", Str(UserList(userindex).Stats.Skill10))
Call WriteVar(UserFile, "SKILLS", "Skill11", Str(UserList(userindex).Stats.Skill11))
Call WriteVar(UserFile, "SKILLS", "Skill12", Str(UserList(userindex).Stats.Skill12))
Call WriteVar(UserFile, "SKILLS", "Skill13", Str(UserList(userindex).Stats.Skill13))
Call WriteVar(UserFile, "SKILLS", "Skill14", Str(UserList(userindex).Stats.Skill14))
Call WriteVar(UserFile, "SKILLS", "Skill15", Str(UserList(userindex).Stats.Skill15))
Call WriteVar(UserFile, "SKILLS", "Skill16", Str(UserList(userindex).Stats.Skill16))
Call WriteVar(UserFile, "SKILLS", "Skill17", Str(UserList(userindex).Stats.Skill17))
Call WriteVar(UserFile, "SKILLS", "Skill18", Str(UserList(userindex).Stats.Skill18))
Call WriteVar(UserFile, "SKILLS", "Skill19", Str(UserList(userindex).Stats.Skill19))
Call WriteVar(UserFile, "SKILLS", "Skill20", Str(UserList(userindex).Stats.Skill20))
Call WriteVar(UserFile, "SKILLS", "Skill21", Str(UserList(userindex).Stats.Skill21))
Call WriteVar(UserFile, "SKILLS", "Skill22", Str(UserList(userindex).Stats.Skill22))
Call WriteVar(UserFile, "SKILLS", "Skill23", Str(UserList(userindex).Stats.Skill23))
Call WriteVar(UserFile, "SKILLS", "Skill24", Str(UserList(userindex).Stats.Skill24))
Call WriteVar(UserFile, "SKILLS", "Skill25", Str(UserList(userindex).Stats.Skill25))
Call WriteVar(UserFile, "SKILLS", "Skill26", Str(UserList(userindex).Stats.Skill26))
Call WriteVar(UserFile, "SKILLS", "Skill27", Str(UserList(userindex).Stats.Skill27))
Call WriteVar(UserFile, "SKILLS", "Skill28", Str(UserList(userindex).Stats.Skill28))
  
'Save Inv
For LoopC = 1 To MAX_INVENTORY_SLOTS
    Call WriteVar(UserFile, "Inventory", "Obj" & LoopC, UserList(userindex).Object(LoopC).ObjIndex & "-" & UserList(userindex).Object(LoopC).Amount & "-" & UserList(userindex).Object(LoopC).Equipped)
Next

'Write Weapon and Armour slots
Call WriteVar(UserFile, "Inventory", "WeaponEqpSlot", Str(UserList(userindex).WeaponEqpSlot))
Call WriteVar(UserFile, "Inventory", "ArmourEqpSlot", Str(UserList(userindex).ArmourEqpSlot))
Call WriteVar(UserFile, "Inventory", "ClothingEqpSlot", Str(UserList(userindex).ClothingEqpSlot))
Call WriteVar(UserFile, "Inventory", "HEADEqpSlot", Str(UserList(userindex).HEADEqpSlot))
Call WriteVar(UserFile, "Inventory", "SHIELDEqpSlot", Str(UserList(userindex).SHIELDEqpSlot))

'Save Inv
For SaveSpell = 1 To MAX_SPELL_SLOTS
    Call WriteVar(UserFile, "Spells", "Spell" & SaveSpell, UserList(userindex).SpellObj(SaveSpell).SpellIndex & "-")
Next SaveSpell



End Sub
Sub SaveWorld()
On Error Resume Next


Open App.Path & "\Log.txt" For Append Shared As #5
Print #5, "Saveworld"
Close #5

On Error Resume Next
'*****************************************************************
'Saves the current state of all objects and npc`s
'in the world.
'*****************************************************************
worldcontrol.status.Caption = "Saving world: Users " & LastUser & "..."
'save the current users first
    Dim playeruser123 As Integer
    For playeruser123 = 1 To LastUser
        Call SaveUser(playeruser123, CharPath & UCase(UserList(playeruser123).Flags.StartName) & ".chr")
    Next playeruser123


worldcontrol.status.Caption = "Saving world..."


Dim TempInt As Integer
Dim map As Integer
Dim LoopC As Integer
Dim y As Integer
Dim x As Integer
Dim DummyInt As Integer

For map = 1 To NumMaps
   
   worldcontrol.status.Caption = "Saving world: Map " & map & " of " & NumMaps & "..."
   
Kill App.Path & "\maps\Map" & map & ".obj"
   
    'Open files
    
    'inf
    Open App.Path & "\maps\Map" & map & ".obj" For Binary As #1
    Seek #1, 1
    
    'Load arrays
    For y = YMinMapSize To YMaxMapSize
    For x = XMinMapSize To XMaxMapSize
    
        'Object
        Put #1, , MapData(map, x, y).ObjInfo.ObjIndex
        Put #1, , MapData(map, x, y).ObjInfo.Amount
       
        'Locked
        Put #1, , MapData(map, x, y).Locked
              
        'Sign data
        Put #1, , MapData(map, x, y).Sign
        Put #1, , MapData(map, x, y).SignOwner
              
    Next x
    Next y

    'Close files

    Close #1

Next map


worldcontrol.status = "Done saving world !"
 


 
End Sub
