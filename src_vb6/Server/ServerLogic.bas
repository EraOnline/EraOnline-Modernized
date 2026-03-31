Attribute VB_Name = "ServerLogic"
Option Explicit
Sub WipeJunk()
On Error Resume Next
'******************************************************
'CLEAR THE WORLD FOR JUNK SUCH AS TOMBSTONES/CORPSES...
'******************************************************

Dim map As Integer
Dim X As Integer
Dim Y As Integer
Dim obj As ObjData

For map = 1 To NumMaps

    For Y = YMinMapSize To YMaxMapSize
    For X = XMinMapSize To XMaxMapSize
        
    obj = ObjData(MapData(map, X, Y).ObjInfo.ObjIndex)
        
    'Wipe all player tombstone
    If MapData(map, X, Y).ObjInfo.ObjIndex = 157 Then
    Call EraseObj(ToMap, 0, map, MapData(map, X, Y).ObjInfo.Amount, map, X, Y)
    End If
    
    
    'Wipe all meditation auras
    If MapData(map, X, Y).ObjInfo.ObjIndex = 231 Then
    Call EraseObj(ToMap, 0, map, MapData(map, X, Y).ObjInfo.Amount, map, X, Y)
    End If

    'Wipe all corpses
    If obj.ObjType = 40 Then
    Call EraseObj(ToMap, 0, map, MapData(map, X, Y).ObjInfo.Amount, map, X, Y)
    End If
    
    'Wipe all camp fires
    If MapData(map, X, Y).ObjInfo.ObjIndex = 155 Then
    Call EraseObj(ToMap, 0, map, MapData(map, X, Y).ObjInfo.Amount, map, X, Y)
    End If

    Next X
    Next Y

Next map

End Sub
Sub ChangeUserChar(sndRoute As Byte, sndIndex As Integer, sndMap As Integer, userindex As Integer, Body As Integer, Head As Integer, Heading As Byte, WeaponAnim As Integer, ShieldAnim As Integer)
On Error Resume Next
'*****************************************************************
'Changes a user char's head,body and heading
'*****************************************************************
Dim obj1 As ObjData
obj1 = ObjData(UserList(userindex).Object(UserList(userindex).ClothingEqpSlot).ObjIndex)

'If UserList(userindex).Flags.Morphed = 0 Then UserList(userindex).Char.Body = obj1.ClothingType
If UserList(userindex).Flags.Morphed = 1 Then UserList(userindex).Char.Body = Body
If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Body = 16
If UserList(userindex).Flags.Hiding = 1 Then UserList(userindex).Char.Body = 53

UserList(userindex).Char.Head = Head
UserList(userindex).Char.Heading = Heading
UserList(userindex).Char.WeaponAnim = WeaponAnim
UserList(userindex).Char.ShieldAnim = ShieldAnim

Call SendData(sndRoute, sndIndex, sndMap, "CHC" & UserList(userindex).Char.CharIndex & "," & Body & "," & Head & "," & Heading & "," & WeaponAnim & "," & ShieldAnim)

End Sub

Sub ChangeNPCChar(sndRoute As Byte, sndIndex As Integer, sndMap As Integer, Npcindex As Integer, Body As Integer, Head As Integer, Heading As Byte, WeaponAnim As Integer, ShieldAnim As Integer)
On Error Resume Next
'*****************************************************************
'Changes a NPC char's head,body and heading
'*****************************************************************

NPCList(Npcindex).Char.Body = Body
NPCList(Npcindex).Char.Head = Head
NPCList(Npcindex).Char.Heading = Heading
NPCList(Npcindex).Char.WeaponAnim = WeaponAnim
NPCList(Npcindex).Char.ShieldAnim = ShieldAnim

Call SendData(sndRoute, sndIndex, sndMap, "CHC" & NPCList(Npcindex).Char.CharIndex & "," & Body & "," & Head & "," & Heading & "," & WeaponAnim & "," & ShieldAnim)

End Sub


Sub DoTileEvents(userindex As Integer, map As Integer, X As Integer, Y As Integer)
On Error Resume Next
'*****************************************************************
'Do any events on a tile (zone switching, exits and so on)
'*****************************************************************
Dim xer
Dim yer
xer = UserList(userindex).Pos.X
yer = UserList(userindex).Pos.Y

'Loads to the adjecent map to the current zone
'if the player walks out of the zone
If UserList(userindex).Pos.Y < 7 Then
If MapInfo(map).NorthExit > 1 Then
If LegalPos(userindex, MapInfo(map).NorthExit, UserList(userindex).Pos.X, 94) Then
    Call WarpUserChar(userindex, MapInfo(map).NorthExit, UserList(userindex).Pos.X, 94)
End If
End If
End If

If UserList(userindex).Pos.Y > 94 Then
If MapInfo(map).SouthExit > 1 Then
If LegalPos(userindex, MapInfo(map).SouthExit, UserList(userindex).Pos.X, 7) Then
    Call WarpUserChar(userindex, MapInfo(map).SouthExit, UserList(userindex).Pos.X, 7)
End If
End If
End If

If UserList(userindex).Pos.X < 9 Then
If MapInfo(map).WestExit > 1 Then
If LegalPos(userindex, MapInfo(map).WestExit, 91, UserList(userindex).Pos.Y) Then
    Call WarpUserChar(userindex, MapInfo(map).WestExit, 91, UserList(userindex).Pos.Y)
End If
End If
End If

If UserList(userindex).Pos.X > 92 Then
If MapInfo(map).EastExit > 1 Then
If LegalPos(userindex, MapInfo(map).EastExit, 10, UserList(userindex).Pos.Y) Then
    Call WarpUserChar(userindex, MapInfo(map).EastExit, 10, UserList(userindex).Pos.Y)
End If
End If
End If

'Check for tile exit
If MapData(map, X, Y).TileExit.map > 0 Then
    If LegalPos(userindex, MapData(map, X, Y).TileExit.map, MapData(map, X, Y).TileExit.X, MapData(map, X, Y).TileExit.Y) Then
        Call WarpUserChar(userindex, MapData(map, X, Y).TileExit.map, MapData(map, X, Y).TileExit.X, MapData(map, X, Y).TileExit.Y)
    Exit Sub
    End If
End If

'Check to see if camp fire here...
If MapData(map, xer - 1, yer).ObjInfo.ObjIndex = 155 Then
Call SendData(ToIndex, userindex, 0, "TEN")
End If
If MapData(map, xer + 1, yer).ObjInfo.ObjIndex = 155 Then
Call SendData(ToIndex, userindex, 0, "TEN")
End If
If MapData(map, xer, yer + 1).ObjInfo.ObjIndex = 155 Then
Call SendData(ToIndex, userindex, 0, "TEN")
End If
If MapData(map, xer, yer - 1).ObjInfo.ObjIndex = 155 Then
Call SendData(ToIndex, userindex, 0, "TEN")
End If

End Sub

Function InMapBounds(map As Integer, X As Integer, Y As Integer) As Boolean
On Error Resume Next
'*****************************************************************
'Checks to see if a tile position is in the maps bounds
'*****************************************************************

If X < MinXBorder Or X > MaxXBorder Or Y < MinYBorder Or Y > MaxYBorder Then
    InMapBounds = False
    Exit Function
End If

InMapBounds = True

End Function

Sub NPCDie(Npcindex, userindex As Integer)
On Error Resume Next
'*****************************************************************
'Kill a NPC
'*****************************************************************
'Initialize some stuff
Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer
Dim LOOT As Integer
X = NPCList(Npcindex).Pos.X
Y = NPCList(Npcindex).Pos.Y
map = NPCList(Npcindex).Pos.map
LOOT = RandomNumber(1, NPCList(Npcindex).LootChance)

If LOOT > 1 Then
Call SendData(ToIndex, userindex, 0, "@You recover no loot from the corpse." & FONTTYPE_INFO)
End If

'Make corpse there
obj.ObjIndex = NPCList(Npcindex).DeathObj
obj.Amount = 1
Call MakeObj(ToMap, 0, NPCList(Npcindex).Pos.map, obj, NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X, NPCList(Npcindex).Pos.Y)

NPCList(Npcindex).Flags.AttackedBy = 0

'Place inventory 1 beside npc corpse
If LegalPos(userindex, map, X - 1, Y) = True And LOOT = 1 Then
obj.ObjIndex = NPCList(Npcindex).Object(1).ObjIndex
obj.Amount = 1
Call MakeObj(ToMap, 0, NPCList(Npcindex).Pos.map, obj, NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X - 1, NPCList(Npcindex).Pos.Y)
End If

'Place inventory 2 beside npc corpse
If LegalPos(userindex, map, X + 1, Y) = True And LOOT = 1 Then
obj.ObjIndex = NPCList(Npcindex).Object(2).ObjIndex
obj.Amount = 1
Call MakeObj(ToMap, 0, NPCList(Npcindex).Pos.map, obj, NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X + 1, NPCList(Npcindex).Pos.Y)
End If

'Place inventory 3 beside npc corpse
If LegalPos(userindex, map, X, Y + 1) = True And LOOT = 1 Then
obj.ObjIndex = NPCList(Npcindex).Object(3).ObjIndex
obj.Amount = 1
Call MakeObj(ToMap, 0, NPCList(Npcindex).Pos.map, obj, NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X, NPCList(Npcindex).Pos.Y + 1)
End If

'Place inventory 4 beside npc corpse
If LegalPos(userindex, map, X, Y - 1) = True And LOOT = 1 Then
obj.ObjIndex = NPCList(Npcindex).Object(4).ObjIndex
obj.Amount = 1
Call MakeObj(ToMap, 0, NPCList(Npcindex).Pos.map, obj, NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X, NPCList(Npcindex).Pos.Y - 1)
End If

'Reset TARGETS
NPCList(Npcindex).Target = 0

'Play NPC sound
If NPCList(Npcindex).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(Npcindex).Flags.Sound)
 
'Reset stats for NPC
NPCList(Npcindex).Stats.MinHP = NPCList(Npcindex).Stats.MaxHP


    'Spawn the NPC to another place on the map
Looper:
    X = Int(RandomNumber(XMinMapSize, XMaxMapSize))
    Y = Int(RandomNumber(YMinMapSize, XMaxMapSize))
    map = NPCList(Npcindex).Pos.map
    If LegalPos(userindex, map, X, Y) Then
    Call WarpNPCChar(Npcindex, map, X, Y)
    Else
    GoTo Looper
    End If
      




End Sub

Sub UserDie(userindex As Integer)
On Error Resume Next
'*****************************************************************
'Kill a user and makes the user a ghost
'*****************************************************************

Dim obj As obj
Dim LoseExp As Integer
Dim LoseGold As Long
Dim Item As Byte
Dim objo As ObjData


'Find out which item to loose
Item = RandomNumber(1, 5)

UserList(userindex).Stats.Food = 0
UserList(userindex).Stats.Drink = 0
UserList(userindex).Flags.status = 1
Call SendData(ToIndex, userindex, 0, "DEA")

UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MaxHP
UserList(userindex).Stats.MinMAN = UserList(userindex).Stats.MaxMAN
UserList(userindex).Stats.MinSTA = UserList(userindex).Stats.MaxSTA

SendData ToIndex, userindex, 0, "@You have lost all food and drink" & FONTTYPE_FIGHT
If UserList(userindex).Flags.Criminal = 2 Then
SendData ToIndex, userindex, 0, "@You are no longer a criminal." & FONTTYPE_INFO
UserList(userindex).Flags.Criminal = 0
End If

'Make user NON morphed
UserList(userindex).Flags.Morphed = 0

'Calculate out experience to loose
LoseExp = UserList(userindex).Stats.EXP / 6
LoseGold = UserList(userindex).Stats.GLD / 5

UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MaxHP
SendData ToIndex, userindex, 0, "@You are dead..." & FONTTYPE_FIGHT

'loose gold if over level 5
If UserList(userindex).Stats.ELV > 5 And UserList(userindex).Stats.GLD > 299 Then
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - LoseGold
SendData ToIndex, userindex, 0, "@You have lost " & LoseGold & " gold !" & FONTTYPE_FIGHT
End If

'Loose 100 exp if over level 3 and have more than 99 exp
If UserList(userindex).Stats.ELV > 3 Then
UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP - LoseExp
SendData ToIndex, userindex, 0, "@You have lost " & LoseExp & " experience !" & FONTTYPE_FIGHT
End If

'Set exp to 0 if bellow 1
If UserList(userindex).Stats.EXP < 1 Then UserList(userindex).Stats.EXP = 0

'Make item there...
If UserList(userindex).Object(Item).ObjIndex > 0 And UserList(userindex).Object(Item).Equipped = 0 Then
obj.ObjIndex = UserList(userindex).Object(Item).ObjIndex
obj.Amount = UserList(userindex).Object(Item).Amount
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
Call SendData(ToIndex, userindex, 0, "@You have lost " & ObjData(UserList(userindex).Object(Item).ObjIndex).Name & " !" & FONTTYPE_FIGHT)
UserList(userindex).Object(Item).Amount = 0
UserList(userindex).Object(Item).ObjIndex = 0
UserList(userindex).Object(Item).Equipped = 0
End If

UserList(userindex).Char.Body = 16
UserList(userindex).Char.Head = 5

Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
Call SendUserStatsBox(userindex)
Call CheckUserLevel(userindex)
Call UpdateUserInv(True, userindex, Item)





End Sub

Sub UseInvItem(userindex As Integer, slot As Byte)
On Error Resume Next
'*****************************************************************
'Use/Equip a inventory item
'*****************************************************************

Dim obj As ObjData
Dim objo As ObjData
objo = ObjData(UserList(userindex).Object(UserList(userindex).ClothingEqpSlot).ObjIndex)
If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Body = 16
If UserList(userindex).Flags.Hiding = 1 Then UserList(userindex).Char.Body = 53

obj = ObjData(UserList(userindex).Object(slot).ObjIndex)
UserList(userindex).Flags.LastSlot = slot

'Check to see if user is high enough level to equip
If UserList(userindex).Stats.MaxHP < obj.Level Then
Call SendData(ToIndex, userindex, 0, "@You don`t have enough health to equip this. You need " & obj.Level & " health to equip this." & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if class allows it
If UserList(userindex).class = obj.ClassForbid1 Then
Call SendData(ToIndex, userindex, 0, "@Your class forbid you in using this !" & FONTTYPE_INFO)
Exit Sub
End If
If UserList(userindex).class = obj.ClassForbid2 Then
Call SendData(ToIndex, userindex, 0, "@Your class forbid you in using this !" & FONTTYPE_INFO)
Exit Sub
End If
If UserList(userindex).class = obj.ClassForbid3 Then
Call SendData(ToIndex, userindex, 0, "@Your class forbid you in using this !" & FONTTYPE_INFO)
Exit Sub
End If
If UserList(userindex).class = obj.ClassForbid4 Then
Call SendData(ToIndex, userindex, 0, "@Your class forbid you in using this !" & FONTTYPE_INFO)
Exit Sub
End If
If UserList(userindex).class = obj.ClassForbid5 Then
Call SendData(ToIndex, userindex, 0, "@Your class forbid you in using this !" & FONTTYPE_INFO)
Exit Sub
End If
If UserList(userindex).class = obj.ClassForbid6 Then
Call SendData(ToIndex, userindex, 0, "@Your class forbid you in using this !" & FONTTYPE_INFO)
Exit Sub
End If
If UserList(userindex).class = obj.ClassForbid7 Then
Call SendData(ToIndex, userindex, 0, "@Your class forbid you in using this !" & FONTTYPE_INFO)
Exit Sub
End If


'Check to see if user is morphed
If UserList(userindex).Flags.Morphed = 1 Then
Call SendData(ToIndex, userindex, 0, "@You cannot do this when you are morphed." & FONTTYPE_INFO)
Exit Sub
End If


Select Case obj.ObjType

    Case OBJTYPE_USEONCE
    
        'use item
        AddtoVar UserList(userindex).Stats.MaxHP, obj.MaxHP, 999
        AddtoVar UserList(userindex).Stats.MinHP, obj.MinHP, UserList(userindex).Stats.MaxHP
        
        'Remove from inventory
        UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - 1
        If UserList(userindex).Object(slot).Amount <= 0 Then
            UserList(userindex).Object(slot).ObjIndex = 0
        End If


    Case OBJTYPE_WEAPON
     SendData ToIndex, userindex, 0, "PLW" & SOUND_SWORDSWING

        'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
        UserList(userindex).Stats.MaxHIT = UserList(userindex).Stats.MaxHIT + obj.MaxHIT
        UserList(userindex).Stats.MinHIT = UserList(userindex).Stats.MinHIT + obj.MinHIT
        UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        
        'Equip in hands
        UserList(userindex).Char.WeaponAnim = obj.WeaponAnim
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)

        Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)

    Case OBJTYPE_ARMOUR

        'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Make user wear it also make it equipe in body slot
        UserList(userindex).Char.Body = obj.ClothingType
        UserList(userindex).Object(slot).Equipped = 1
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        Call SendUserStatsBox(userindex)
        
        'Remove old item if exists
        If UserList(userindex).ArmourEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).ArmourEqpSlot
        End If
        
        UserList(userindex).Stats.DEF = UserList(userindex).Stats.DEF + obj.DEF
        
        UserList(userindex).ArmourEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).ArmourEqpSlot = slot
        UserList(userindex).ClothingEqpObjindex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).ClothingEqpSlot = slot
        Call SendData(ToIndex, userindex, 0, "PIC" & UserList(userindex).ClothingEqpSlot)

    
    Case OBJTYPE_PRIESTNOTE
    SendData ToIndex, userindex, 0, "PLW" & SOUND_PAPER
    Call SendData(ToIndex, userindex, 0, "|Welcome to Menath ! Before leaping into the world of Era Online, read the manual found on our web site (www.eraonline.net) because you will need any help you can get. You are starting off with some water, food and a rusty dagger.")

    Case OBJTYPE_FISHINGROD
    
      'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
         UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        UserList(userindex).OBJtarget = 16
        
         Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
         
        'Equip in hands
        UserList(userindex).Char.WeaponAnim = obj.WeaponAnim
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)

    Case OBJTYPE_LUMBERJACKAXE
    
   SendData ToIndex, userindex, 0, "PLW" & SOUND_SWORDSWING

    
            'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
         UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        UserList(userindex).OBJtarget = 17
        
        'Equip in hands
        UserList(userindex).Char.WeaponAnim = obj.WeaponAnim
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        
         Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
        
        Case OBJTYPE_Food
        
    
        'Add  to food
        UserList(userindex).Stats.Food = UserList(userindex).Stats.Food + obj.Food
        
        'Remove from inventory
        UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - 1
        If UserList(userindex).Object(slot).Amount <= 0 Then
            UserList(userindex).Object(slot).ObjIndex = 0
        End If
    
        Case OBJTYPE_Drink
        
        'Add to drink
        UserList(userindex).Stats.Drink = UserList(userindex).Stats.Drink + obj.Food
        
        'Remove from inventory
        UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - 1
        If UserList(userindex).Object(slot).Amount <= 0 Then
            UserList(userindex).Object(slot).ObjIndex = 0
        End If
        
        Case OBJTYPE_CLOTHING
        
       SendData ToIndex, userindex, 0, "PLW" & SOUND_FOLDCLOTHING

        
        'Make user wear it also make it equipe in body slot
        UserList(userindex).Char.Body = obj.ClothingType
        UserList(userindex).Object(slot).Equipped = 1
     
       
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        Call SendUserStatsBox(userindex)
        
        'Remove old item if exists
        If UserList(userindex).ClothingEqpObjindex > 0 Then
            RemoveInvItem userindex, UserList(userindex).ClothingEqpSlot
        End If
        
        UserList(userindex).Stats.DEF = UserList(userindex).Stats.DEF + obj.DEF
        UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).ClothingEqpObjindex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).ClothingEqpSlot = slot
        
        Call SendData(ToIndex, userindex, 0, "PIC" & UserList(userindex).ClothingEqpSlot)
        
        Case OBJTYPE_SHIELD
        
        SendData ToIndex, userindex, 0, "PLW" & SOUND_SWORDSWING

        'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).SHIELDEqpObjindex > 0 Then
            RemoveInvItem userindex, UserList(userindex).SHIELDEqpSlot
        End If
       
        'Equip in hands
        UserList(userindex).Char.ShieldAnim = obj.ShieldAnim
        UserList(userindex).Stats.DEF = UserList(userindex).Stats.DEF + obj.DEF
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        
        'Make user wear it also make it equipe in shield slot
        UserList(userindex).Object(slot).Equipped = 1
          
        UserList(userindex).SHIELDEqpObjindex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).SHIELDEqpSlot = slot

        Call SendData(ToIndex, userindex, 0, "PC3" & UserList(userindex).SHIELDEqpSlot)
        
        
        Case OBJTYPE_HELMET
        
        'Make user wear it also make it equipe in shield slot
        UserList(userindex).Object(slot).Equipped = 1
        Call SendUserStatsBox(userindex)
        
        'Remove old item if exists
        If UserList(userindex).HEADEqpObjindex > 0 Then
            RemoveInvItem userindex, UserList(userindex).HEADEqpSlot
        End If
        
        UserList(userindex).HEADEqpObjindex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).HEADEqpSlot = slot
        UserList(userindex).Stats.DEF = UserList(userindex).Stats.DEF + obj.DEF
        
        UserList(userindex).Char.Body = objo.ClothingType
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        Call SendData(ToIndex, userindex, 0, "PC4" & UserList(userindex).HEADEqpSlot)
        
        '*****CARPENTRY STUFF********
        Case OBJTYPE_LOG
        If UserList(userindex).WeaponEqpObjIndex = 128 Then
        Call CreatePlanks(userindex, slot)
        End If
        
        Case OBJTYPE_SAW
        
        'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
        UserList(userindex).Stats.MaxHIT = UserList(userindex).Stats.MaxHIT + obj.MaxHIT
        UserList(userindex).Stats.MinHIT = UserList(userindex).Stats.MinHIT + obj.MinHIT
        UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        'Equip in hands
        UserList(userindex).Char.WeaponAnim = obj.WeaponAnim
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        
        Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
        
        
        Case OBJTYPE_CARPENTRYDRAWING
        UserList(userindex).Throw.MakeItem = obj.MakeItem
        UserList(userindex).Throw.NeedPlanks = obj.NeedPlanks
        UserList(userindex).Throw.skill = obj.skill
        SendData ToIndex, userindex, 0, "PLW" & SOUND_PAPER
        Call SendData(ToIndex, userindex, 0, "@You look at the drawing and you are ready to make it ! Just find the planks now !" & FONTTYPE_INFO)
           
           
        Case OBJTYPE_PLANKS
        Call MakeCarpentryObj(userindex, slot)
        
        '*********Tailoring Stuff*******
        
        Case OBJTYPE_CLOTH
        If UserList(userindex).WeaponEqpObjIndex = 149 Then
        Call CreateFoldedCloth(userindex, slot)
        End If
        
        Case OBJTYPE_SEWINGKIT
        
        'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
        UserList(userindex).Stats.MaxHIT = UserList(userindex).Stats.MaxHIT + obj.MaxHIT
        UserList(userindex).Stats.MinHIT = UserList(userindex).Stats.MinHIT + obj.MinHIT
        UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
        
        
        Case OBJTYPE_TAILORDRAWING
        UserList(userindex).Throw.MakeItem = obj.MakeItem
        UserList(userindex).Throw.NeedFoldedCloth = obj.NeedFoldedCloth
        UserList(userindex).Throw.skill = obj.skill
        SendData ToIndex, userindex, 0, "PLW" & SOUND_PAPER
        Call SendData(ToIndex, userindex, 0, "@You look at the drawing and you are ready to make it ! Just find the folded cloth now !" & FONTTYPE_INFO)
           
           
        Case OBJTYPE_FOLDEDCLOTH
        Call MakeTailoringObj(userindex, slot)
        
        
        '*********Blacksmithing stuff*******
        
        Case OBJTYPE_ORE
        If UserList(userindex).WeaponEqpObjIndex = 38 Then
        Call CreateSteel(userindex, slot)
        End If
        
        Case OBJTYPE_HAMMER
        
        'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
        UserList(userindex).Stats.MaxHIT = UserList(userindex).Stats.MaxHIT + obj.MaxHIT
        UserList(userindex).Stats.MinHIT = UserList(userindex).Stats.MinHIT + obj.MinHIT
        UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
        
        
        Case OBJTYPE_BLACKSMITHINGDRAWING
        UserList(userindex).Throw.MakeItem = obj.MakeItem
        UserList(userindex).Throw.NeedSteel = obj.NeedSteel
        UserList(userindex).Throw.skill = obj.skill
        SendData ToIndex, userindex, 0, "PLW" & SOUND_PAPER
        Call SendData(ToIndex, userindex, 0, "@You look at the drawing and you are ready to make it ! Just find the steel now !" & FONTTYPE_INFO)
           
           
        Case OBJTYPE_STEEL
        Call MakeBlacksmithingObj(userindex, slot)
        
        Case OBJTYPE_PICKAXE
    
      'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
         UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        UserList(userindex).OBJtarget = 48
        
         Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
         
        'Equip in hands
        UserList(userindex).Char.WeaponAnim = obj.WeaponAnim
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        
        Case OBJTYPE_EMPTYBOWL
        
        'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
        UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
        
        Case OBJTYPE_BOWLOFWATER
        
        'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
        UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
           
        Case OBJTYPE_SPELL
        Call InscribeSpell(userindex, slot)
        SendData ToIndex, userindex, 0, "PLW" & SOUND_PAPER
    
        Case OBJTYPE_MEAT
        
        'If currently equipped remove instead
        If UserList(userindex).Object(slot).Equipped Then
            RemoveInvItem userindex, slot
            Exit Sub
        End If
        
        'Remove old item if exists
        If UserList(userindex).WeaponEqpObjIndex > 0 Then
            RemoveInvItem userindex, UserList(userindex).WeaponEqpSlot
        End If

        'Equip
        UserList(userindex).Object(slot).Equipped = 1
        UserList(userindex).WeaponEqpObjIndex = UserList(userindex).Object(slot).ObjIndex
        UserList(userindex).WeaponEqpSlot = slot
        Call SendData(ToIndex, userindex, 0, "@You have the meat in your hand. To cook it, click on a camp fire." & FONTTYPE_INFO)
        Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
                              
        Case OBJTYPE_GOLD
        UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + UserList(userindex).Object(slot).Amount
        UserList(userindex).Object(slot).ObjIndex = 0
        UserList(userindex).Object(slot).Amount = 0
        
        Case OBJTYPE_HOUSEDEED
        Call SendData(ToIndex, userindex, 0, "DEE" & obj.Name)
        
        Case OBJTYPE_BANDAGE
        Call Bandage(userindex, slot)
        
End Select



'Update user's stats and inventory

SendUserStatsBox userindex
UpdateUserInv True, userindex, 0
UpdateUserSpell True, userindex, 0
Call CheckUserLevel(userindex)

End Sub



Sub AddtoVar(Var As Variant, Addon As Variant, Max As Variant)
'*****************************************************************
'Adds a value to a variable respecting a max value
'*****************************************************************
On Error Resume Next


If Var >= Max Then
    Var = Max
    Exit Sub
End If

Var = Var + Addon
If Var > Max Then
    Var = Max
End If

End Sub

Sub RemoveInvItem(userindex As Integer, slot As Byte)
On Error Resume Next
'*****************************************************************
'Unequip a inventory item
'*****************************************************************

Dim obj As ObjData

If UserList(userindex).Object(slot).ObjIndex = 0 Then
Exit Sub
End If

'Error trap
If UserList(userindex).Object(slot).Equipped = 0 Then
Exit Sub
End If

obj = ObjData(UserList(userindex).Object(slot).ObjIndex)

Select Case obj.ObjType


    Case OBJTYPE_WEAPON

        UserList(userindex).Stats.MaxHIT = UserList(userindex).Stats.MaxHIT - obj.MaxHIT
        UserList(userindex).Stats.MinHIT = UserList(userindex).Stats.MinHIT - obj.MinHIT
                
        UserList(userindex).Object(slot).Equipped = 0
        UserList(userindex).WeaponEqpObjIndex = 0
        UserList(userindex).WeaponEqpSlot = 0
        
        UserList(userindex).Char.WeaponAnim = 2
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        Call SendData(ToIndex, userindex, 0, "UWP")
        UserList(userindex).OBJtarget = 0


    Case OBJTYPE_ARMOUR

   UserList(userindex).Stats.DEF = UserList(userindex).Stats.DEF - obj.DEF
   UserList(userindex).Object(slot).Equipped = 0
   UserList(userindex).ArmourEqpObjIndex = 0
   UserList(userindex).ArmourEqpSlot = 0
   Call SendData(ToIndex, userindex, 0, "UCL")
   

    Case OBJTYPE_CLOTHING

   UserList(userindex).Stats.DEF = UserList(userindex).Stats.DEF - obj.DEF
   UserList(userindex).Object(slot).Equipped = 0
   UserList(userindex).ClothingEqpObjindex = 0
   UserList(userindex).ClothingEqpSlot = 0
   Call SendData(ToIndex, userindex, 0, "UCL")
   

    Case OBJTYPE_SHIELD
    
    UserList(userindex).Stats.DEF = UserList(userindex).Stats.DEF - obj.DEF

        UserList(userindex).Object(slot).Equipped = 0
        UserList(userindex).SHIELDEqpObjindex = 0
        UserList(userindex).SHIELDEqpSlot = 0

    UserList(userindex).Char.ShieldAnim = 2
    Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
    Call SendData(ToIndex, userindex, 0, "USH")

    Case OBJTYPE_HELMET

        UserList(userindex).Object(slot).Equipped = 0
        UserList(userindex).HEADEqpObjindex = 0
        UserList(userindex).HEADEqpSlot = 0
        UserList(userindex).Stats.DEF = UserList(userindex).Stats.DEF - obj.DEF
 
        Call SendData(ToIndex, userindex, 0, "UHE")


    Case OBJTYPE_LUMBERJACKAXE

        UserList(userindex).Object(slot).Equipped = 0
        UserList(userindex).WeaponEqpObjIndex = 0
        UserList(userindex).WeaponEqpSlot = 0
        
        UserList(userindex).Char.WeaponAnim = 2
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        Call SendData(ToIndex, userindex, 0, "UWP")
        UserList(userindex).OBJtarget = 0

Case OBJTYPE_FISHINGROD

        UserList(userindex).Object(slot).Equipped = 0
        UserList(userindex).WeaponEqpObjIndex = 0
        UserList(userindex).WeaponEqpSlot = 0
        
        UserList(userindex).Char.WeaponAnim = 2
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        Call SendData(ToIndex, userindex, 0, "UWP")
        UserList(userindex).OBJtarget = 0

    Case OBJTYPE_SAW

        UserList(userindex).Object(slot).Equipped = 0
        UserList(userindex).WeaponEqpObjIndex = 0
        UserList(userindex).WeaponEqpSlot = 0
        
        UserList(userindex).Char.WeaponAnim = 2
        Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        Call SendData(ToIndex, userindex, 0, "UWP")
        UserList(userindex).OBJtarget = 0

End Select

SendUserStatsBox userindex
UpdateUserInv True, userindex, 0
UpdateUserSpell True, userindex, 0




End Sub

Function NextOpenCharIndex() As Integer
On Error Resume Next
'*****************************************************************
'Finds the next open CharIndex in Charlist
'*****************************************************************
Dim LoopC As Integer

For LoopC = 1 To LastChar + 1
    If CharList(LoopC) = 0 Then
        NextOpenCharIndex = LoopC
        NumChars = NumChars + 1
        If LoopC > LastChar Then LastChar = LoopC
        Exit Function
    End If
Next LoopC

End Function

Function NextOpenUser() As Integer
On Error Resume Next
'*****************************************************************
'Finds the next open UserIndex in UserList
'*****************************************************************
Dim LoopC As Integer
  
LoopC = 1
  
Do Until UserList(LoopC).Flags.UserLogged = False
    LoopC = LoopC + 1
Loop
  
NextOpenUser = LoopC

End Function

Function NextOpenNPC() As Integer
On Error Resume Next
'*****************************************************************
'Finds the next open UserIndex in UserList
'*****************************************************************
Dim LoopC As Integer
  
LoopC = 1
  
Do Until NPCList(LoopC).Flags.NPCActive = 0
    LoopC = LoopC + 1
Loop
  
NextOpenNPC = LoopC

End Function

Sub ClosestLegalPos(userindex As Integer, Pos As WorldPos, nPos As WorldPos)
On Error Resume Next
'*****************************************************************
'Finds the closest legal tile to Pos and stores it in nPos
'*****************************************************************
Dim Notfound As Boolean
Dim LoopC As Integer
Dim tX As Integer
Dim tY As Integer

nPos.map = Pos.map

Do While LegalPos(userindex, Pos.map, nPos.X, nPos.Y) = False
    
    If LoopC > 10 Then
        Notfound = True
        Exit Do
    End If
    
    For tY = Pos.Y - LoopC To Pos.Y + LoopC
        For tX = Pos.X - LoopC To Pos.X + LoopC
        
            If LegalPos(userindex, nPos.map, tX, tY) = True Then
                nPos.X = tX
                nPos.Y = tY
                tX = Pos.X + LoopC
                tY = Pos.Y + LoopC
            End If
        
        Next tX
    Next tY
    
    LoopC = LoopC + 1
    
Loop

If Notfound = True Then
    nPos.X = 0
    nPos.Y = 0
End If


End Sub

Function NameIndex(Name As String) As Integer
On Error Resume Next
'*****************************************************************
'Searches userlist for a name and return userindex
'*****************************************************************
Dim userindex As Integer
  
'check for bad name
If Name = "" Then
    NameIndex = 0
    Exit Function
End If
  
userindex = 1
Do Until UCase(Left$(UserList(userindex).Name, Len(Name))) = UCase(Name)
    
    userindex = userindex + 1
    
    If userindex > LastUser Then
        userindex = 0
        Exit Do
    End If
    
Loop
  
NameIndex = userindex

End Function

Sub NPCAI(Npcindex As Integer)
On Error Resume Next
'*****************************************************************
'Moves NPC based on it's .movement value
'*****************************************************************
Dim nPos As WorldPos
Dim HeadingLoop As Byte
Dim HeadingLoop2 As Byte
Dim tHeading As Byte
Dim Y As Integer
Dim X As Integer

Dim Target As Integer


'Look for someone to attack if hostile
If NPCList(Npcindex).Hostile Then
 
    'Check in all directions
    For HeadingLoop = NORTH To WEST
        nPos = NPCList(Npcindex).Pos
        HeadtoPos HeadingLoop, nPos
        
        'if a legal pos and a user is found attack
        If InMapBounds(nPos.map, nPos.X, nPos.Y) Then
            If MapData(nPos.map, nPos.X, nPos.Y).userindex > 0 Then
                'Face NPC to target
                NPCList(Npcindex).Target = MapData(nPos.map, nPos.X, nPos.Y).userindex
                ChangeNPCChar ToMap, 0, nPos.map, Npcindex, NPCList(Npcindex).Char.Body, NPCList(Npcindex).Char.Head, HeadingLoop, NPCList(Npcindex).Char.WeaponAnim, NPCList(Npcindex).Char.ShieldAnim
                'Attack
                NPCAttackUser Npcindex, (NPCList(Npcindex).Target)
                'Don't move if fighting
               Exit Sub
               
End If
End If
Next HeadingLoop
End If
        
'Guard attack player if ciminal
If NPCList(Npcindex).Guard = 1 Then

    'Check in all directions
    For HeadingLoop2 = NORTH To WEST
        nPos = NPCList(Npcindex).Pos
        HeadtoPos HeadingLoop2, nPos
        
        'if a legal pos and a user is found attack
        If InMapBounds(nPos.map, nPos.X, nPos.Y) Then
            If MapData(nPos.map, nPos.X, nPos.Y).userindex > 0 Then
                'Face NPC to target
                NPCList(Npcindex).Target = MapData(nPos.map, nPos.X, nPos.Y).userindex
                ChangeNPCChar ToMap, 0, nPos.map, Npcindex, NPCList(Npcindex).Char.Body, NPCList(Npcindex).Char.Head, HeadingLoop2, NPCList(Npcindex).Char.WeaponAnim, NPCList(Npcindex).Char.ShieldAnim
                'Attack
                If UserList(MapData(nPos.map, nPos.X, nPos.Y).userindex).Flags.Criminal = 2 Then NPCAttackUser Npcindex, MapData(nPos.map, nPos.X, nPos.Y).userindex
                'Don't move if fighting
               Exit Sub
               
End If
End If
Next HeadingLoop2
End If

'Chaotic Guard attack player if Wood Elf or Human
If NPCList(Npcindex).Guard = 2 Then

    'Check in all directions
    For HeadingLoop2 = NORTH To WEST
        nPos = NPCList(Npcindex).Pos
        HeadtoPos HeadingLoop2, nPos
        
        'if a legal pos and a user is found attack
        If InMapBounds(nPos.map, nPos.X, nPos.Y) Then
            If MapData(nPos.map, nPos.X, nPos.Y).userindex > 0 Then
                'Face NPC to target
                ChangeNPCChar ToMap, 0, nPos.map, Npcindex, NPCList(Npcindex).Char.Body, NPCList(Npcindex).Char.Head, HeadingLoop2, NPCList(Npcindex).Char.WeaponAnim, NPCList(Npcindex).Char.ShieldAnim
                'Attack if player is human or dark elf
                 If UserList(MapData(nPos.map, nPos.X, nPos.Y).userindex).Race = "Human" Or UserList(MapData(nPos.map, nPos.X, nPos.Y).userindex).Race = "Wood Elf" Or UserList(MapData(nPos.map, nPos.X, nPos.Y).userindex).Flags.Criminal = 2 Then
                 NPCAttackUser Npcindex, MapData(nPos.map, nPos.X, nPos.Y).userindex
                'Don't move if fighting
                Exit Sub
            End If
            End If
            End If
            
             Next HeadingLoop2
             End If

'Movement
Select Case NPCList(Npcindex).Movement
 
    'Stand
    Case 1
        'Do nothing
        
    'Move randomly
    Case 2
        Call MoveNPCChar(Npcindex, Int(RandomNumber(1, 7)))
 
 
    'Go towards any nearby Users
    Case 3
        For Y = NPCList(Npcindex).Pos.Y - 10 To NPCList(Npcindex).Pos.Y + 10    'Makes a loop that looks at
            For X = NPCList(Npcindex).Pos.X - 10 To NPCList(Npcindex).Pos.X + 10   '10 tiles in every direction
 
                'Make sure tile is legal
                If X > MinXBorder And X < MaxXBorder And Y > MinYBorder And Y < MaxYBorder Then
                'look for a user
                    If MapData(NPCList(Npcindex).Pos.map, X, Y).userindex > 0 Then
                        'Move towards user
                        If UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Flags.status = 0 And UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Flags.Hiding = 0 And CheckIfAttack(Npcindex, MapData(NPCList(Npcindex).Pos.map, X, Y).userindex) = True Then
                        tHeading = FindDirection(NPCList(Npcindex).Pos, UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Pos)
                        MoveNPCChar Npcindex, tHeading
                        Exit Sub
                     End If
                  End If
                End If
                     
            Next X
        Next Y
  
'Guard go after criminals
Case 4
        For Y = NPCList(Npcindex).Pos.Y - 10 To NPCList(Npcindex).Pos.Y + 10
        For X = NPCList(Npcindex).Pos.X - 10 To NPCList(Npcindex).Pos.X + 10
 
                'Make sure tile is legal
                If X > MinXBorder And X < MaxXBorder And Y > MinYBorder And Y < MaxYBorder Then

                    'look for a user
                    If MapData(NPCList(Npcindex).Pos.map, X, Y).userindex > 0 Then
                        
                        'Move towards user IF CRIMINAL
                        If UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Flags.Criminal = 2 Then
                            tHeading = FindDirection(NPCList(Npcindex).Pos, UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Pos)
                            MoveNPCChar Npcindex, tHeading
                            'Leave sub
                            Exit Sub
                          
                        End If

                    End If
                    
                End If
                     
            Next X
        Next Y

'Beggars follow players
Case 5
       
        For Y = NPCList(Npcindex).Pos.Y - 10 To NPCList(Npcindex).Pos.Y + 10    'Makes a loop that looks at
            For X = NPCList(Npcindex).Pos.X - 10 To NPCList(Npcindex).Pos.X + 10   '5 tiles in every direction
 
                'Make sure tile is legal
                If X > MinXBorder And X < MaxXBorder And Y > MinYBorder And Y < MaxYBorder Then
                'look for a user
                    If MapData(NPCList(Npcindex).Pos.map, X, Y).userindex > 0 Then
                                          
                        'Go irritate player of the player hasnt been giving to beggars lately.
                       If UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Flags.Giving = 0 And UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Flags.status = 0 Then
                        tHeading = FindDirection(NPCList(Npcindex).Pos, UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Pos)
                        MoveNPCChar Npcindex, tHeading
                        'Leave sub
                        Exit Sub
                        End If
                    End If
                    
                     End If
                     
            Next X
        Next Y

'Tamed animal go after owner
Case 6
       
        For Y = NPCList(Npcindex).Pos.Y - 10 To NPCList(Npcindex).Pos.Y + 10    'Makes a loop that looks at
            For X = NPCList(Npcindex).Pos.X - 10 To NPCList(Npcindex).Pos.X + 10   '10 tiles in every direction
 
                'Make sure tile is legal
                If X > MinXBorder And X < MaxXBorder And Y > MinYBorder And Y < MaxYBorder Then
                'look for a user
                    If MapData(NPCList(Npcindex).Pos.map, X, Y).userindex = NPCList(Npcindex).Owner Then
                        'Follow player...
                        tHeading = FindDirection(NPCList(Npcindex).Pos, UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Pos)
                        MoveNPCChar Npcindex, tHeading
                        'Leave sub
                        Exit Sub
                        End If
                    End If
           
            Next X
        Next Y
        
    'Go towards any nearby Users within short distance
    Case 7
        For Y = NPCList(Npcindex).Pos.Y - 3 To NPCList(Npcindex).Pos.Y + 3   'Makes a loop that looks at
            For X = NPCList(Npcindex).Pos.X - 3 To NPCList(Npcindex).Pos.X + 3   '3 tiles in every direction
 
                'Make sure tile is legal
                If X > MinXBorder And X < MaxXBorder And Y > MinYBorder And Y < MaxYBorder Then
                'look for a user
                    If MapData(NPCList(Npcindex).Pos.map, X, Y).userindex > 0 Then
                        'Move towards user
                        If UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Flags.status = 0 Then
                        tHeading = FindDirection(NPCList(Npcindex).Pos, UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Pos)
                        MoveNPCChar Npcindex, tHeading
                        Exit Sub
                     End If
                  End If
                End If
                     
            Next X
        Next Y

'Chaotic guard go after humans and wood elves
Case 8
        For Y = NPCList(Npcindex).Pos.Y - 10 To NPCList(Npcindex).Pos.Y + 10
        For X = NPCList(Npcindex).Pos.X - 10 To NPCList(Npcindex).Pos.X + 10
 
                'Make sure tile is legal
                If X > MinXBorder And X < MaxXBorder And Y > MinYBorder And Y < MaxYBorder Then

                    'look for a user
                    If MapData(NPCList(Npcindex).Pos.map, X, Y).userindex > 0 Then
                        
                        'Move towards user human or wood elf
                        If UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Race = "Wood Elf" Or UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Race = "Human" Or UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Flags.Criminal = 2 Then
                            tHeading = FindDirection(NPCList(Npcindex).Pos, UserList(MapData(NPCList(Npcindex).Pos.map, X, Y).userindex).Pos)
                            MoveNPCChar Npcindex, tHeading
                            'Leave sub
                            Exit Sub
                          
                        End If

                    End If
                    
                End If
                     
            Next X
        Next Y
        
End Select
 
End Sub

Function OpenNPC(NpcNumber As Integer) As Integer
On Error Resume Next
'*****************************************************************
'Loads a NPC and returns its index
'*****************************************************************
Dim Npcindex As Integer
Dim NPCFile As String
Dim LoopC As Byte
Dim ln As String

'Find next open NPCindex
Npcindex = NextOpenNPC

'Set NPC file
If NpcNumber < 499 Then NPCFile = IniPath & "NPC.dat"
If NpcNumber > 499 Then NPCFile = IniPath & "NPC2.dat"

'Random HAILING initialization
NPCList(Npcindex).Hail = "Hail to thee. How can i assist you ?"

'Load stats from file
NPCList(Npcindex).Name = GetVar(NPCFile, "NPC" & NpcNumber, "Name")
NPCList(Npcindex).Desc = GetVar(NPCFile, "NPC" & NpcNumber, "Desc")
NPCList(Npcindex).Movement = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Movement"))

'Categories
NPCList(Npcindex).Flags.Category1 = GetVar(NPCFile, "NPC" & NpcNumber, "Category1")
NPCList(Npcindex).Flags.Category2 = GetVar(NPCFile, "NPC" & NpcNumber, "Category2")
NPCList(Npcindex).Flags.Category3 = GetVar(NPCFile, "NPC" & NpcNumber, "Category3")
NPCList(Npcindex).Flags.Category4 = GetVar(NPCFile, "NPC" & NpcNumber, "Category4")
NPCList(Npcindex).Flags.Category5 = GetVar(NPCFile, "NPC" & NpcNumber, "Category5")

'Load special hail if NPC has so
If Val(GetVar(NPCFile, "NPC" & NpcNumber, "SpecialHail")) = 1 Then NPCList(Npcindex).Hail = GetVar(NPCFile, "NPC" & NpcNumber, "Hail")

NPCList(Npcindex).Gold = GetVar(NPCFile, "NPC" & NpcNumber, "Gold")
NPCList(Npcindex).NpcNumber = GetVar(NPCFile, "NPC" & NpcNumber, "NpcNumber")
NPCList(Npcindex).SkillNeeded = GetVar(NPCFile, "NPC" & NpcNumber, "SkillNeeded")

NPCList(Npcindex).Level = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Level"))
NPCList(Npcindex).LootChance = Val(GetVar(NPCFile, "NPC" & NpcNumber, "LootChance"))


NPCList(Npcindex).DeathObj = Val(GetVar(NPCFile, "NPC" & NpcNumber, "DeathObj"))

NPCList(Npcindex).Tameable = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Tameable"))
NPCList(Npcindex).Tradeable = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Tradeable"))
NPCList(Npcindex).Tamed = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Tamed"))
NPCList(Npcindex).Owner = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Owner"))

NPCList(Npcindex).Char.Body = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Body"))
NPCList(Npcindex).Char.Head = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Head"))
NPCList(Npcindex).Char.Heading = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Heading"))
NPCList(Npcindex).Char.WeaponAnim = Val(GetVar(NPCFile, "NPC" & NpcNumber, "WeaponAnim"))
NPCList(Npcindex).Char.ShieldAnim = Val(GetVar(NPCFile, "NPC" & NpcNumber, "ShieldAnim"))


NPCList(Npcindex).Attackable = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Attackable"))
NPCList(Npcindex).NPCtype = Val(GetVar(NPCFile, "NPC" & NpcNumber, "NpcType"))
NPCList(Npcindex).Hostile = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Hostile"))
NPCList(Npcindex).Guard = Val(GetVar(NPCFile, "NPC" & NpcNumber, "Guard"))
NPCList(Npcindex).GiveEXP = Val(GetVar(NPCFile, "NPC" & NpcNumber, "GiveEXP"))
NPCList(Npcindex).GiveGLD = Val(GetVar(NPCFile, "NPC" & NpcNumber, "GiveGLD"))

NPCList(Npcindex).Stats.MaxHP = Val(GetVar(NPCFile, "NPC" & NpcNumber, "MaxHP"))
NPCList(Npcindex).Stats.MinHP = Val(GetVar(NPCFile, "NPC" & NpcNumber, "MinHP"))
NPCList(Npcindex).Stats.MaxHIT = Val(GetVar(NPCFile, "NPC" & NpcNumber, "MaxHIT"))
NPCList(Npcindex).Stats.MinHIT = Val(GetVar(NPCFile, "NPC" & NpcNumber, "MinHIT"))
NPCList(Npcindex).Stats.DEF = Val(GetVar(NPCFile, "NPC" & NpcNumber, "DEF"))
NPCList(Npcindex).Flags.Sound = Val(GetVar(NPCFile, "NPC" & NpcNumber, "SOUND"))

'Give NPC gold to use...
NPCList(Npcindex).Gold = 10000

'Get object list
For LoopC = 1 To MAX_NPCINVENTORY_SLOTS
    ln = GetVar(NPCFile, "NPC" & NpcNumber, "Obj" & LoopC)
    NPCList(Npcindex).Object(LoopC).ObjIndex = Val(ReadField(1, ln, 45))
    NPCList(Npcindex).Object(LoopC).Amount = Val(ReadField(2, ln, 45))
    NPCList(Npcindex).Object(LoopC).Equipped = Val(ReadField(3, ln, 45))
Next LoopC

'Setup NPC
NPCList(Npcindex).Flags.NPCActive = 1
NPCList(Npcindex).Flags.UseAINow = 0

'Update NPC counters
If Npcindex > LastNPC Then LastNPC = Npcindex
NumNPCs = NumNPCs + 1

'Return new NPCIndex
OpenNPC = Npcindex

End Function

Sub EraseObj(ByVal sndRoute As Byte, ByVal sndIndex As Integer, ByVal sndMap As Integer, ByVal Num As Integer, ByVal map As Byte, ByVal X As Integer, ByVal Y As Integer)
On Error Resume Next
'*****************************************************************
'Erase a object
'*****************************************************************

MapData(map, X, Y).ObjInfo.Amount = MapData(map, X, Y).ObjInfo.Amount - Num

If MapData(map, X, Y).ObjInfo.Amount <= 0 Then
    MapData(map, X, Y).ObjInfo.ObjIndex = 0
    MapData(map, X, Y).ObjInfo.Amount = 0
    Call SendData(sndRoute, sndIndex, sndMap, "EOB" & X & "," & Y)
End If

End Sub

Sub MakeObj(ByVal sndRoute As Byte, ByVal sndIndex As Integer, ByVal sndMap As Integer, obj As obj, map As Integer, ByVal X As Integer, ByVal Y As Integer)
On Error Resume Next
'*****************************************************************
'Make a object
'*****************************************************************

MapData(map, X, Y).ObjInfo = obj
Call SendData(sndRoute, sndIndex, sndMap, "MOB" & ObjData(obj.ObjIndex).Grhindex & "," & X & "," & Y)

End Sub
Sub GetObj(userindex As Integer)
On Error Resume Next
'*****************************************************************
'Puts a object in a User's slot from the current User's position
'*****************************************************************

Dim X As Integer
Dim Y As Integer
Dim slot As Byte
X = UserList(userindex).Pos.X
Y = UserList(userindex).Pos.Y
Dim obj As ObjData

'check to see if item there
If MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.ObjIndex = 0 Then
Call SendData(ToIndex, userindex, 0, "@Nothing here." & FONTTYPE_INFO)
Exit Sub
End If

'Get obj`s objdata
obj = ObjData(MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.ObjIndex)

'Check for object on ground
If MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.ObjIndex <= 0 Then
    Call SendData(ToIndex, userindex, 0, "@Nothing there." & FONTTYPE_INFO)
    Exit Sub
End If

If obj.Pickable = 0 Then
Call SendData(ToIndex, userindex, 0, "@You cannot pick this item up." & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if User already has object type
slot = 1
Do Until UserList(userindex).Object(slot).ObjIndex = MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.ObjIndex
    slot = slot + 1

    If slot > MAX_INVENTORY_SLOTS Then
        Exit Do
    End If
Loop

'Else check if there is a empty slot
If slot > MAX_INVENTORY_SLOTS Then
        slot = 1
        Do Until UserList(userindex).Object(slot).ObjIndex = 0
            slot = slot + 1

            If slot > MAX_INVENTORY_SLOTS Then
                Call SendData(ToIndex, userindex, 0, "@You cannot hold any more items now !" & FONTTYPE_INFO)
                Exit Sub
                Exit Do
            End If
        Loop
End If

'Fill object slot
If UserList(userindex).Object(slot).Amount + MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.Amount <= MAX_INVENTORY_OBJS Then
    'Under MAX_INV_OBJS
    UserList(userindex).Object(slot).ObjIndex = MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.ObjIndex
    UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount + MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.Amount
    Call EraseObj(ToMap, 0, UserList(userindex).Pos.map, MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.Amount, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
Else
    'Over MAX_INV_OBJS
    If MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.Amount < UserList(userindex).Object(slot).Amount Then
        MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.Amount = Abs(MAX_INVENTORY_OBJS - (UserList(userindex).Object(slot).Amount + MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.Amount))
    Else
        MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.Amount = Abs((MAX_INVENTORY_OBJS + UserList(userindex).Object(slot).Amount) - MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.Amount)
    End If
    UserList(userindex).Object(slot).Amount = MAX_INVENTORY_OBJS
End If

Call UpdateUserInv(False, userindex, slot)
Call UpdateUserSpell(False, userindex, slot)

End Sub

Sub InscribeSpell(userindex As Integer, slot As Byte)
On Error Resume Next
'*****************************************************************
'Puts a Spell in a User's slot from the current User's position
'*****************************************************************

Dim obj As ObjData
obj = ObjData(UserList(userindex).Object(slot).ObjIndex)



'Else check if there is a empty slot
slot = 1
        Do Until UserList(userindex).SpellObj(slot).SpellIndex = 0
           slot = slot + 1

            If slot > MAX_SPELL_SLOTS Then
                Call SendData(ToIndex, userindex, 0, "@Your spell book is full !" & FONTTYPE_INFO)
                Exit Sub
                Exit Do
            End If
        Loop

'Fill spell slot
    'Under MAX_SPELL_SPELLS
        UserList(userindex).SpellObj(slot).SpellIndex = obj.SpellType
        Call SendData(ToIndex, userindex, 0, "@You have inscribed the spell into your spell book." & FONTTYPE_INFO)

Call UpdateUserSpell(False, userindex, slot)


End Sub
Sub UpdateUserInv(updateall As Boolean, userindex As Integer, slot As Byte)
On Error Resume Next
'*****************************************************************
'Updates a User's inventory
'*****************************************************************
Dim NullObj As UserOBJ
Dim LoopC As Byte

'Update one slot
If updateall = False Then

    'Update User inventory
    If UserList(userindex).Object(slot).ObjIndex > 0 Then
        Call ChangeUserInv(userindex, slot, UserList(userindex).Object(slot))
    Else
        Call ChangeUserInv(userindex, slot, NullObj)
    End If

Else

'Update every slot
    For LoopC = 1 To MAX_INVENTORY_SLOTS

        'Update User invetory
        If UserList(userindex).Object(LoopC).ObjIndex > 0 Then
            Call ChangeUserInv(userindex, LoopC, UserList(userindex).Object(LoopC))
        Else
            Call ChangeUserInv(userindex, LoopC, NullObj)
        End If

    Next LoopC

End If

End Sub

Sub UpdateUserSpell(updateall As Boolean, userindex As Integer, slot As Byte)
On Error Resume Next
'*****************************************************************
'Updates a User's spell book
'*****************************************************************
Dim NullSPELL As UserSpell
Dim LoopC As Byte

'Update one slot
If updateall = False Then

    'Update User spell book
    If UserList(userindex).SpellObj(slot).SpellIndex > 0 Then
        Call ChangeUserSpells(userindex, slot, UserList(userindex).SpellObj(slot))
    Else
        Call ChangeUserSpells(userindex, slot, NullSPELL)
    End If

Else

'Update every slot
    For LoopC = 1 To MAX_SPELL_SLOTS

        'Update User spell book
        If UserList(userindex).SpellObj(LoopC).SpellIndex > 0 Then
            Call ChangeUserSpells(userindex, LoopC, UserList(userindex).SpellObj(LoopC))
        Else
            Call ChangeUserSpells(userindex, LoopC, NullSPELL)
        End If

    Next LoopC

End If

End Sub
Sub ChangeUserInv(userindex As Integer, slot As Byte, Object As UserOBJ)
On Error Resume Next
'*****************************************************************
'Changes a user's inventory
'*****************************************************************

UserList(userindex).Object(slot) = Object

If Object.ObjIndex > 0 Then

    Call SendData(ToIndex, userindex, 0, "SIS" & slot & "," & Object.ObjIndex & "," & ObjData(Object.ObjIndex).Name & "," & Object.Amount & "," & Object.Equipped & "," & ObjData(Object.ObjIndex).Grhindex & "," & ObjData(Object.ObjIndex).Value)

Else

    Call SendData(ToIndex, userindex, 0, "SIS" & slot & "," & "0" & "," & "(None)" & "," & "0" & "," & "0")

End If


End Sub
Sub ChangeNPCInv(userindex As Integer, Npcindex As Integer, Object As NPCOBJ, slot As Byte)
On Error Resume Next
'*****************************************************************
'Changes a NPC's inventory
'*****************************************************************
Npcindex = UserList(userindex).Npcindex

NPCList(Npcindex).Object(slot) = Object


If Object.ObjIndex > 0 Then

    Call SendData(ToIndex, userindex, 0, "NIS" & slot & "," & Object.ObjIndex & "," & ObjData(Object.ObjIndex).Name & "," & Object.Amount & "," & Object.Equipped & "," & ObjData(Object.ObjIndex).Grhindex & "," & ObjData(Object.ObjIndex).Value & "," & ObjData(Object.ObjIndex).Level)

Else

    Call SendData(ToIndex, userindex, 0, "NIS" & slot & "," & "0" & "," & "(None)" & "," & "0" & "," & "0")

End If


End Sub
Sub SendGmQue(userindex As Integer)
On Error Resume Next
'*****************************************************************
'Send que info to client
'*****************************************************************
Dim Help As Integer
Dim NumberOfHelps As Integer
Dim Helpmsg As String
Dim Helpindex As Integer
Dim TimeX As String
Dim DateX As String
Dim Name As String
 
'Get Number of Objects
NumberOfHelps = Val(GetVar(IniPath & "Gmque.txt", "INIT", "NumHELPs"))

  
'Fill Object List
For Help = 1 To NumberOfHelps
    
    
    Helpmsg = GetVar(IniPath & "Gmque.txt", "HELP" & Help, "HelpMsg")
    Helpindex = GetVar(IniPath & "Gmque.txt", "HELP" & Help, "Userindex")
    TimeX = GetVar(IniPath & "Gmque.txt", "HELP" & Help, "Time")
    DateX = GetVar(IniPath & "Gmque.txt", "HELP" & Help, "Date")
    Name = GetVar(IniPath & "Gmque.txt", "HELP" & Help, "Name")
    
    Call SendData(ToIndex, userindex, 0, "GMQ" & Help & "," & Helpmsg & "," & Helpindex & "," & TimeX & "," & DateX & "," & Name)

Next Help

End Sub

Sub ChangeUserSpells(userindex As Integer, slot As Byte, Spell As UserSpell)
On Error Resume Next
'*****************************************************************
'Changes a user's spell book
'*****************************************************************

UserList(userindex).SpellObj(slot) = Spell


If Spell.SpellIndex > 0 Then

    Call SendData(ToIndex, userindex, 0, "SPL" & slot & "," & Spell.SpellIndex & "," & SpellData(Spell.SpellIndex).Name & "," & SpellData(Spell.SpellIndex).Grhindex & "," & SpellData(Spell.SpellIndex).Desc & "," & SpellData(Spell.SpellIndex).NeedsMana)

    
Else

    Call SendData(ToIndex, userindex, 0, "SPL" & slot & "," & "0" & "," & "(Empty)")

End If


End Sub
Sub SendPostings(userindex As Integer)
On Error Resume Next
'*****************************************************************
'Opens the messageboard and displays it posts
'*****************************************************************
Dim Post As Integer
Dim NumberOfPosts As Integer
Dim postcontent As String
Dim subject As String
Dim Author As String

'Get Number of Objects
NumberOfPosts = Val(GetVar(IniPath & "msgboard.txt", "INIT", "NumPOSTs"))

  
'Fill Object List
For Post = 1 To NumberOfPosts
    
    
    subject = GetVar(IniPath & "msgboard.txt", "POST" & Post, "Subject")
    postcontent = GetVar(IniPath & "msgboard.txt", "POST" & Post, "Post")
    Author = GetVar(IniPath & "msgboard.txt", "POST" & Post, "Author")


    Call SendData(ToIndex, userindex, 0, "OST" & Post & "," & subject & "," & postcontent & "," & Author)

Next Post

End Sub
Sub PostMessage(subject As String, Content As String, userindex As Integer)
On Error Resume Next

Dim NumPosts As Integer
Dim NewNumPosts As String


'Update number of posts
NumPosts = Val(GetVar(IniPath & "msgboard.txt", "INIT", "NumPOSTs"))
NewNumPosts = NumPosts + 1
Call WriteVar(IniPath & "msgboard.txt", "INIT", "NumPOSTs", NewNumPosts)

'Write post
Call WriteVar(IniPath & "msgboard.txt", "POST" & NewNumPosts, "Subject", subject)
Call WriteVar(IniPath & "msgboard.txt", "POST" & NewNumPosts, "Post", Content)
Call WriteVar(IniPath & "msgboard.txt", "POST" & NewNumPosts, "Author", UserList(userindex).Name)
Call WriteVar(IniPath & "msgboard.txt", "POST" & NewNumPosts, "Date", Date)

End Sub
Sub PostHelp(userindex As Integer, Helpmsg As String)
On Error Resume Next

Dim NumHelps As Integer
Dim NewNumHelps As String
Dim Helpindex As String
Helpindex = UserList(userindex).PlayerIndex

'Update number of helps
NumHelps = Val(GetVar(IniPath & "Gmque.txt", "INIT", "NumHELPs"))
NewNumHelps = NumHelps + 1
Call WriteVar(IniPath & "Gmque.txt", "INIT", "NumHELPs", NewNumHelps)

'Write post
Call WriteVar(IniPath & "Gmque.txt", "HELP" & NewNumHelps, "Helpmsg", Helpmsg)
Call WriteVar(IniPath & "Gmque.txt", "HELP" & NewNumHelps, "Userindex", Helpindex)
Call WriteVar(IniPath & "Gmque.txt", "HELP" & NewNumHelps, "Time", Time)
Call WriteVar(IniPath & "Gmque.txt", "HELP" & NewNumHelps, "Date", Date)
Call WriteVar(IniPath & "Gmque.txt", "HELP" & NewNumHelps, "Name", UserList(userindex).Name)

End Sub

Sub KickBan(userindex As Integer, Target As Integer)
On Error Resume Next

Dim NumBans As Integer
Dim NewNumBans As String
Dim MRID As String
MRID = UserList(Target).theid

'Update number of bans
NumBans = Val(GetVar(IniPath & "banned.txt", "INIT", "NumBANs"))
NewNumBans = NumBans + 1
Call WriteVar(IniPath & "banned.txt", "INIT", "NumBANs", NewNumBans)

'Write post
Call WriteVar(IniPath & "banned.txt", "ID" & NewNumBans, "Password", MRID)
Call WriteVar(IniPath & "banned.txt", "ID" & NewNumBans, "Date", Date)

Call SendData(ToIndex, userindex, 0, "@YOU HAVE NOW BANNED " & UserList(Target).Name & " FROM THE GAME. THE USER WILL NOT ABLE TO LOG ONTO ERA ONLINE UNTIL ADMINISTRATION HAS REMOVED THE BAN FROM THE SERVER. YOU SHOULD REPORT THIS BAN TO ADMIN@ERAONLINE.NET" & FONTTYPE_INFO)

'KICK USER FROM GAME
Call SendData(ToIndex, Target, 0, "!!YOU HAVE BEEN BANNED FROM THE GAME. IF YOU WISH TO COMPLAIN, CONTACT SUPPORT@ERAONLINE.NET")
CloseSocket (Target)

End Sub
Sub DropObj(userindex As Integer, slot As Byte, Num As Integer, map As Integer, X As Integer, Y As Integer)
On Error Resume Next
'*****************************************************************
'Drops a object from a User's slot
'*****************************************************************
Dim obj As obj

UserList(userindex).OBJtarget = 0

'Check amount
If Num <= 0 Then
    Exit Sub
End If

If Num > UserList(userindex).Object(slot).Amount Then
    Num = UserList(userindex).Object(slot).Amount
End If

'Check for object on gorund
If MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.ObjIndex <> 0 Then
    Call SendData(ToIndex, userindex, 0, "@No room on ground." & FONTTYPE_INFO)
    Exit Sub
End If

obj.ObjIndex = UserList(userindex).Object(slot).ObjIndex
obj.Amount = Num
Call MakeObj(ToMap, 0, map, obj, map, X, Y)

'***********If sign, then register sign**********
If obj.ObjIndex = 289 Then

Dim NumSigns As Integer
Dim NewNumSigns As String
Dim Content As String
Content = "Type sign content here..."
'Update number of signs
NumSigns = Val(GetVar(IniPath & "signs.txt", "INIT", "NumSIGNs"))
NewNumSigns = NumSigns + 1
Call WriteVar(IniPath & "signs.txt", "INIT", "NumSIGNs", NewNumSigns)
Call WriteVar(IniPath & "signs.txt", "SIGN" & NewNumSigns, "Content", Content)
MapData(map, X, Y).Sign = NewNumSigns
MapData(map, X, Y).SignOwner = UserList(userindex).Flags.YourID

End If
'************************************************

'Remove object
UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - Num
If UserList(userindex).Object(slot).Amount <= 0 Then
    
    'Unequip is the object is currently equipped
    If UserList(userindex).Object(slot).Equipped = 1 Then
        Call RemoveInvItem(userindex, slot)
    End If
    
    UserList(userindex).Object(slot).ObjIndex = 0
    UserList(userindex).Object(slot).Amount = 0
    UserList(userindex).Object(slot).Equipped = 0
End If


Call UpdateUserInv(False, userindex, slot)
Call UpdateUserSpell(False, userindex, slot)

End Sub

Sub CloseNPC(Npcindex As Integer)
On Error Resume Next
'*****************************************************************
'Closes a NPC
'*****************************************************************

NPCList(Npcindex).Flags.NPCActive = 0

'update last user
If Npcindex = LastNPC Then
    Do Until NPCList(LastNPC).Flags.NPCActive = 1
        LastNPC = LastNPC - 1
        If LastNPC = 0 Then Exit Do
    Loop
End If
  
'update number of users
If NumNPCs <> 0 Then
    NumNPCs = NumNPCs - 1
End If

End Sub

Sub UserAttackNPC(userindex As Integer, Npcindex As Integer)
On Error Resume Next
'*****************************************************************
'Have a User attack a NPC
'*****************************************************************
Dim Hit As Integer
Dim map As Integer
Dim X As Integer
Dim Y As Integer
Dim Raise As Integer
Dim WasNotHostile As Integer
Dim WasNotFollowing As Integer
Dim Luck As Integer
Dim Luck2 As Integer
Dim Chance As Integer
Dim DidHit As Integer

If UserList(userindex).Stats.Skill16 <= 10 And UserList(userindex).Stats.Skill16 >= -1 Then Luck2 = 3
If UserList(userindex).Stats.Skill16 <= 20 And UserList(userindex).Stats.Skill16 >= 9 Then Luck2 = 3
If UserList(userindex).Stats.Skill16 <= 30 And UserList(userindex).Stats.Skill16 >= 19 Then Luck2 = 3
If UserList(userindex).Stats.Skill16 <= 40 And UserList(userindex).Stats.Skill16 >= 29 Then Luck2 = 2
If UserList(userindex).Stats.Skill16 <= 50 And UserList(userindex).Stats.Skill16 >= 39 Then Luck2 = 2
DidHit = RandomNumber(1, Luck2)
If UserList(userindex).Stats.Skill16 > 50 Then DidHit = 1

UserList(userindex).Npcindex = Npcindex
NPCList(Npcindex).Flags.AttackedBy = userindex

'Make NPC hostile if was not hostile.
If NPCList(Npcindex).Hostile = 0 Then
NPCList(Npcindex).Hostile = 1
WasNotHostile = 1
End If

'Make player criminal if attacking guards
If NPCList(Npcindex).Guard = 1 And UserList(userindex).Flags.Criminal = 0 Then
UserList(userindex).Flags.Criminal = 2
UserList(userindex).Flags.CriminalCount = UserList(userindex).Flags.CriminalCount + 60
Call SendData(ToIndex, userindex, 0, "@Attacking guards art we !? Doust art now a criminal !" & FONTTYPE_INFO)
End If

'Make player criminal if attacking guards
If NPCList(Npcindex).Guard = 2 And UserList(userindex).Flags.Criminal = 0 Then
UserList(userindex).Flags.Criminal = 2
UserList(userindex).Flags.CriminalCount = UserList(userindex).Flags.CriminalCount + 60
Call SendData(ToIndex, userindex, 0, "@Attacking guards art we !? Doust art now a criminal !" & FONTTYPE_INFO)
End If

'Make NPC follow player if it wasnt in follow movement
If NPCList(Npcindex).Movement = 1 Then
NPCList(Npcindex).Movement = 3
WasNotFollowing = 1
End If

'Make NPC follow player if it wasnt in follow movement
If NPCList(Npcindex).Movement = 2 Then
NPCList(Npcindex).Movement = 3
WasNotFollowing = 1
End If

Hit = Int(RandomNumber(UserList(userindex).Stats.MinHIT, UserList(userindex).Stats.MaxHIT))
Hit = Hit - (NPCList(Npcindex).Stats.DEF / 2)
If Hit < 1 Then Hit = 1

'Calculate hit
If DidHit = 1 Then
'OK

Else
Call SendData(ToIndex, userindex, 0, "@You miss !" & FONTTYPE_FIGHT)
Exit Sub
End If

If UserList(userindex).Flags.Strike = 0 Then
Call BackstabNPC(userindex, Npcindex)
UserList(userindex).Flags.Strike = 1
End If

'Hit NPC
Call SendData(ToIndex, userindex, 0, "@You strike the " & NPCList(Npcindex).Name & " for " & Hit & " !" & FONTTYPE_FIGHT)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_SWORDHIT2)
NPCList(Npcindex).Stats.MinHP = NPCList(Npcindex).Stats.MinHP - Hit

'NPC Die
If NPCList(Npcindex).Stats.MinHP <= 0 Then



UserList(userindex).Npcindex = 0
UserList(userindex).NPCtarget = 0
UserList(userindex).UserTargetIndex = 0
         
    'Kill it
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " has slain " & NPCList(Npcindex).Name & " !" & FONTTYPE_INFO)
    UserList(userindex).Flags.Strike = 0
    If NPCList(Npcindex).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(Npcindex).Flags.Sound)
 
    'Give EXP
    UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + NPCList(Npcindex).GiveEXP
    UserList(userindex).Flags.LastExp = NPCList(Npcindex).GiveEXP
 
    'Give gold
    UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + NPCList(Npcindex).GiveGLD
    Call SendData(ToIndex, userindex, 0, "@You found " & NPCList(Npcindex).GiveGLD & " gold on the corpse !" & FONTTYPE_INFO)
    
    'Make it non-hostile if it wasnt hostile when attacked
    If WasNotHostile = 1 Then NPCList(Npcindex).Hostile = 0
    If WasNotFollowing = 1 Then NPCList(Npcindex).Movement = 2
            
    'Reduce reputation and make criminal if NPC
    'was a guard. Raise underworld rep.
    If NPCList(Npcindex).Guard = 1 Then
    UserList(userindex).Flags.Criminal = 2
    UserList(userindex).Flags.CriminalCount = UserList(userindex).Flags.CriminalCount + 30
    Call SendData(ToIndex, userindex, 0, "@Killing a guard ?! You are now a criminal !" & FONTTYPE_INFO)
    UserList(userindex).Community.NobleRep = UserList(userindex).Community.NobleRep - 5
    UserList(userindex).Community.BendarrRep = UserList(userindex).Community.BendarrRep + 2
    UserList(userindex).Community.OverallRep = UserList(userindex).Community.OverallRep - 5
    UserList(userindex).Community.UnderRep = UserList(userindex).Community.UnderRep + 3
    UserList(userindex).Community.CommonRep = UserList(userindex).Community.CommonRep - 3
    Call SendData(ToIndex, userindex, 0, "@You lose some reputation with the Nobles and the common people. You gain reputation with Bendarr and the underworld !" & FONTTYPE_INFO)
    Call CheckRep(userindex)
    Else
    'Give positive reputation
    UserList(userindex).Community.CommonRep = UserList(userindex).Community.CommonRep + 1
    UserList(userindex).Community.NobleRep = UserList(userindex).Community.NobleRep + 1
    UserList(userindex).Community.NobleRep = UserList(userindex).Community.OverallRep + 1
    Call SendData(ToIndex, userindex, 0, "@You gain reputation with the Nobles and the common people !" & FONTTYPE_INFO)
    Call CheckRep(userindex)
    End If
    
    Call NPCDie(Npcindex, userindex)
        
    
    End If
        
'Maybe or maybe not raise skill
Raise = Int(RandomNumber(1, 40))
If Raise = 6 And UserList(userindex).Stats.Skill6 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill6 And UserList(userindex).Stats.Skill6 > 9 Then
UserList(userindex).Stats.Skill6 = UserList(userindex).Stats.Skill6 + 1
Call SendData(ToIndex, userindex, 0, "@Your tactics skill has improved (" & UserList(userindex).Stats.Skill6 & ") !" & FONTTYPE_SKILLINFO)
End If

'Maybe or maybe not raise skill
Raise = Int(RandomNumber(1, 40))
If Raise = 6 And UserList(userindex).Stats.Skill16 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill16 And UserList(userindex).Stats.Skill16 > 9 Then
UserList(userindex).Stats.Skill16 = UserList(userindex).Stats.Skill16 + 1
Call SendData(ToIndex, userindex, 0, "@Your swordmanship skill has improved (" & UserList(userindex).Stats.Skill16 & ") !" & FONTTYPE_SKILLINFO)
End If

'Maybe or maybe not raise skill
If UserList(userindex).SHIELDEqpObjindex > 0 Then
Raise = Int(RandomNumber(1, 40))
If Raise = 6 And UserList(userindex).Stats.Skill17 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill17 Then
UserList(userindex).Stats.Skill17 = UserList(userindex).Stats.Skill17 + 1
Call SendData(ToIndex, userindex, 0, "@Your parrying skill has improved (" & UserList(userindex).Stats.Skill17 & ") !" & FONTTYPE_SKILLINFO)
End If
End If



'Check user for level up
CheckUserLevel userindex
CheckRep (userindex)
Call SendUserStatsBox(userindex)

End Sub

Sub NPCAttackUser(Npcindex As Integer, userindex As Integer)
On Error Resume Next
'*****************************************************************
'Have a NPC attack a User
'*****************************************************************
Dim Hit As Integer
Dim spot As Integer
Dim SpotString As String
Dim Luck As Integer
Dim Luck2 As Integer
Dim Chance As Integer
Dim DidHit As Integer

'Check to see if guard and player not criminal
If NPCList(Npcindex).Guard = 1 And UserList(userindex).Flags.Criminal = 0 Then
Exit Sub
End If

'Check to see if chaotic guard attacks own races
If NPCList(Npcindex).Guard = 2 Then
If UserList(userindex).Race = "Dark Elf" Or UserList(userindex).Race = "Haaki" Then Exit Sub
Else
'Do nothing
End If


If UserList(userindex).Stats.Skill6 <= 10 And UserList(userindex).Stats.Skill6 >= -1 Then Luck2 = 1
If UserList(userindex).Stats.Skill6 <= 20 And UserList(userindex).Stats.Skill6 >= 9 Then Luck2 = 1
If UserList(userindex).Stats.Skill6 <= 30 And UserList(userindex).Stats.Skill6 >= 19 Then Luck2 = 3
If UserList(userindex).Stats.Skill6 <= 40 And UserList(userindex).Stats.Skill6 >= 29 Then Luck2 = 3
If UserList(userindex).Stats.Skill6 <= 50 And UserList(userindex).Stats.Skill6 >= 39 Then Luck2 = 2
If UserList(userindex).Stats.Skill6 <= 50 Then Luck2 = 2
DidHit = RandomNumber(1, Luck2)

UserList(userindex).Npcindex = Npcindex


If UserList(userindex).Flags.status = 0 Then
'Proceed
Else
Exit Sub
End If

'Calculate hit
Hit = Int(RandomNumber(NPCList(Npcindex).Stats.MinHIT, NPCList(Npcindex).Stats.MaxHIT))
Hit = Hit - (UserList(userindex).Stats.DEF / 2)
If Hit < 1 Then Hit = 1

'Hit user
If NPCList(Npcindex).CanAttack = 1 Then
'Proceed
Else
Exit Sub
End If


'Make sure its a hit or not
If DidHit = 1 Then
'Do nothing
Else
Call SendData(ToIndex, userindex, 0, "@You evaded " & NPCList(Npcindex).Name & "`s attack !" & FONTTYPE_INFO)
NPCList(Npcindex).CanAttack = 0
Exit Sub
End If

NPCList(Npcindex).CanAttack = 0
If UserList(userindex).Gender = "Male" Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_MALEHURT)
If UserList(userindex).Gender = "Female" Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_FEMALESCREAM)

SendData ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " strikes you for " & Hit & " !" & FONTTYPE_FIGHT
UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MinHP - Hit
SendUserStatsBox userindex
If NPCList(Npcindex).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(Npcindex).Flags.Sound)


'User Die
If UserList(userindex).Stats.MinHP <= 0 Then
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_MALEHURT)
NPCList(Npcindex).Flags.Attacking = 0
'Update user stats
SendUserStatsBox userindex
'Kill user
SendData ToIndex, userindex, 0, "@The " & NPCList(Npcindex).Name & " has slain you!" & FONTTYPE_FIGHT
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " has been slain by " & NPCList(Npcindex).Name & " !")
NPCList(Npcindex).Flags.Attacking = 0
UserDie userindex
'Update user stats
SendUserStatsBox userindex
End If


End Sub
Sub UserAttackUser(attackerindex As Integer, victimindex As Integer)
On Error Resume Next
'*****************************************************************
'Have a user attack a user
'*****************************************************************
Dim Hit As Integer
Dim spot As Integer
Dim SpotString As String
Dim Luck As Integer
Dim Luck2 As Integer
Dim Chance As Integer
Dim DidHit As Integer

 
If UserList(attackerindex).Stats.Skill16 <= 10 And UserList(attackerindex).Stats.Skill16 >= -1 Then Luck2 = 5
If UserList(attackerindex).Stats.Skill16 <= 20 And UserList(attackerindex).Stats.Skill16 >= 9 Then Luck2 = 4
If UserList(attackerindex).Stats.Skill16 <= 30 And UserList(attackerindex).Stats.Skill16 >= 19 Then Luck2 = 3
If UserList(attackerindex).Stats.Skill16 <= 40 And UserList(attackerindex).Stats.Skill16 >= 29 Then Luck2 = 2
If UserList(attackerindex).Stats.Skill16 <= 50 And UserList(attackerindex).Stats.Skill16 >= 39 Then Luck2 = 1
DidHit = Int(RandomNumber(1, Luck2))
If UserList(attackerindex).Stats.Skill16 <= 50 Then DidHit = 1

'Make sure victim is not dead...
If UserList(victimindex).Flags.status = 1 Then
Call SendData(ToIndex, attackerindex, 0, "@You cannot attack the dead !" & FONTTYPE_INFO)
Exit Sub
End If

'Make sure its not a PK freezone
If MapInfo(UserList(attackerindex).Pos.map).PKFREEZONE = 1 Then
If UserList(attackerindex).Flags.Duel = 0 Or UserList(victimindex).Flags.Duel = 0 Then
Call SendData(ToIndex, attackerindex, 0, "@This is a Player Killing free area. Both players must be in duel mode (/DUEL) to fight here !")
Exit Sub
End If
End If

'Check to see if it isnt a immortal flagged gamemaster
If UserList(victimindex).Flags.Immortal = 0 Then
Call SendData(ToIndex, attackerindex, 0, "@Your attack is prevented ! This person is under the protection of the gods !" & FONTTYPE_INFO)
Exit Sub
End If


'Check to see if victim is crminal or not
If UserList(victimindex).Flags.Criminal = 0 And UserList(victimindex).Flags.Duel = 0 And UserList(attackerindex).Flags.Criminal = 0 Then
Call SendData(ToIndex, attackerindex, 0, "@You are attacking a innocent ! You criminal !" & FONTTYPE_INFO)
Call SendData(ToIndex, victimindex, 0, "@Someone attacked you ! Your attacker is now a criminal !" & FONTTYPE_INFO)
UserList(attackerindex).Flags.Criminal = 2
UserList(attackerindex).Flags.CriminalCount = UserList(attackerindex).Flags.CriminalCount + 45
End If

'Calculate hit
Hit = Int(RandomNumber(UserList(attackerindex).Stats.MinHIT, UserList(attackerindex).Stats.MaxHIT))
Hit = Hit - (UserList(victimindex).Stats.DEF / 2)
If Hit < 1 Then Hit = 1

If DidHit = 1 Then
'OK
Else
Call SendData(ToIndex, attackerindex, 0, "@You miss !" & FONTTYPE_INFO)
Exit Sub
End If

UserList(attackerindex).Stats.MinSTA = UserList(attackerindex).Stats.MinSTA - 1

'Calculate out which body part to hit
spot = Int(RandomNumber(1, 4))
If spot = 1 Then SpotString = " in the head !"
If spot = 2 Then SpotString = " on the legs !"
If spot = 3 Then SpotString = " on the hands !"
If spot = 4 Then SpotString = " on the chest !"

SendData ToIndex, attackerindex, 0, "@You strike " & UserList(victimindex).Name & " for " & Hit & SpotString & FONTTYPE_FIGHT
SendData ToIndex, victimindex, 0, "@" & UserList(attackerindex).Name & " hits you for " & Hit & SpotString & FONTTYPE_FIGHT
UserList(victimindex).Stats.MinHP = UserList(victimindex).Stats.MinHP - Hit
Call SendData(ToPCArea, attackerindex, UserList(attackerindex).Pos.map, "PLW" & SOUND_SWORDHIT2)

If UserList(victimindex).Gender = "Male" Then Call SendData(ToPCArea, victimindex, UserList(victimindex).Pos.map, "PLW" & SOUND_MALEHURT)
If UserList(victimindex).Gender = "Female" Then Call SendData(ToPCArea, victimindex, UserList(victimindex).Pos.map, "PLW" & SOUND_FEMALESCREAM)

If UserList(attackerindex).Flags.Strike = 0 Then
Call BackstabPC(attackerindex, victimindex)
UserList(attackerindex).Flags.Strike = 1
End If

'User Die
If UserList(victimindex).Stats.MinHP <= 0 Then

UserList(attackerindex).Npcindex = 0
UserList(attackerindex).NPCtarget = 0
UserList(attackerindex).UserTargetIndex = 0
 
    Call SendData(ToPCArea, attackerindex, UserList(attackerindex).Pos.map, "PLW" & SOUND_MALEHURT2)
    
    'Give EXP and gold
    UserList(attackerindex).Stats.EXP = UserList(attackerindex).Stats.EXP + (UserList(victimindex).Stats.ELV * 20)
    Call SendData(ToIndex, attackerindex, 0, "@You have gained " & UserList(attackerindex).Stats.EXP + (UserList(victimindex).Stats.ELV * 20) & " experience !" & FONTTYPE_INFO)
    Call SendData(ToPCArea, attackerindex, UserList(attackerindex).Pos.map, "@" & UserList(victimindex).Name & " has been slain by " & UserList(attackerindex).Name & " !")

    'Kill user
    UserList(attackerindex).Flags.Strike = 0
    UserDie victimindex

'Checks to see if the victim was a criminal or not
'If the victim wasnt a criminal, then attacker become one.
If UserList(victimindex).Flags.Criminal = 0 And UserList(victimindex).Flags.Duel = 0 Then
UserList(attackerindex).Flags.CriminalCount = UserList(attackerindex).Flags.CriminalCount + 30
'Lower murderers reputation
UserList(attackerindex).Community.CommonRep = UserList(attackerindex).Community.CommonRep - 5
UserList(attackerindex).Community.NobleRep = UserList(attackerindex).Community.NobleRep - 5
UserList(attackerindex).Community.OverallRep = UserList(attackerindex).Community.OverallRep - 20
'Raise underworld rep
UserList(attackerindex).Community.UnderRep = UserList(attackerindex).Community.UnderRep + 3
UserList(attackerindex).Community.BendarrRep = UserList(attackerindex).Community.BendarrRep + 3
UserList(attackerindex).Flags.Criminal = 2
Call SendData(ToIndex, attackerindex, 0, "@You gain reputation with Bendarr and the underworld ! You also lose some reputation with the Nobles and the common people." & FONTTYPE_INFO)
Else
'Rais rep since victim was either criminal or it was a duel
UserList(attackerindex).Community.OverallRep = UserList(attackerindex).Community.OverallRep + 2
UserList(attackerindex).Community.CommonRep = UserList(attackerindex).Community.CommonRep + 2
Call SendData(ToIndex, attackerindex, 0, "@You gain some reputation with common people !" & FONTTYPE_INFO)
End If
End If

'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 40))
If Raise = 5 And UserList(attackerindex).Stats.Skill6 > 9 And LevelSkill(UserList(attackerindex).Stats.ELV).LevelValue > UserList(attackerindex).Stats.Skill6 Then
UserList(attackerindex).Stats.Skill6 = UserList(attackerindex).Stats.Skill6 + 1
Call SendData(ToIndex, attackerindex, 0, "@Your tactics skill has improved (" & UserList(attackerindex).Stats.Skill6 & ") !" & FONTTYPE_SKILLINFO)
End If

'Maybe or maybe not raise skill

Raise = Int(RandomNumber(1, 40))
If Raise = 5 And UserList(attackerindex).Stats.Skill16 > 9 And LevelSkill(UserList(attackerindex).Stats.ELV).LevelValue > UserList(attackerindex).Stats.Skill16 Then
UserList(attackerindex).Stats.Skill16 = UserList(attackerindex).Stats.Skill16 + 1
Call SendData(ToIndex, attackerindex, 0, "@Your swordmanship skill has improved (" & UserList(attackerindex).Stats.Skill16 & ") !" & FONTTYPE_SKILLINFO)
End If

'Maybe or maybe not raise skill
If UserList(attackerindex).SHIELDEqpObjindex > 0 Then
Raise = Int(RandomNumber(1, 40))
If Raise = 5 And UserList(attackerindex).Stats.Skill17 > 9 And LevelSkill(UserList(attackerindex).Stats.ELV).LevelValue > UserList(attackerindex).Stats.Skill27 Then
UserList(attackerindex).Stats.Skill17 = UserList(attackerindex).Stats.Skill17 + 1
Call SendData(ToIndex, attackerindex, 0, "@Your parrying skill has improved (" & UserList(attackerindex).Stats.Skill17 & ") !" & FONTTYPE_SKILLINFO)
End If
End If

'update user level and stats
CheckUserLevel attackerindex
SendUserStatsBox attackerindex
CheckUserLevel victimindex
SendUserStatsBox victimindex
Call CheckRep(attackerindex)



End Sub

Sub UserAttack(userindex As Integer)
On Error Resume Next
'*****************************************************************
'Begin a user attack sequence
'*****************************************************************
Dim AttackPos As WorldPos

If UserList(userindex).Flags.Battlemode = 0 Then Exit Sub

'Get tile user is attacking
AttackPos = UserList(userindex).Pos
HeadtoPos UserList(userindex).Char.Heading, AttackPos

'Play attack sound
SendData ToPCArea, userindex, AttackPos.map, "PLW" & SOUND_SWING

'Exit if not legal
If AttackPos.X < XMinMapSize Or AttackPos.X > XMaxMapSize Or AttackPos.Y <= YMinMapSize Or AttackPos.Y > YMaxMapSize Then
    Exit Sub
End If

'Look for user
If MapData(AttackPos.map, AttackPos.X, AttackPos.Y).userindex > 0 Then
    UserAttackUser userindex, MapData(AttackPos.map, AttackPos.X, AttackPos.Y).userindex
    Exit Sub
End If

'Look for NPC
If MapData(AttackPos.map, AttackPos.X, AttackPos.Y).Npcindex > 0 Then

    If NPCList(MapData(AttackPos.map, AttackPos.X, AttackPos.Y).Npcindex).Attackable Then
        UserAttackNPC userindex, MapData(AttackPos.map, AttackPos.X, AttackPos.Y).Npcindex
    Else
        SendData ToIndex, userindex, 0, "@A mysterious force prevents you from attacking..." & FONTTYPE_FIGHT
    End If

    Exit Sub
End If




End Sub
Function userindex(SocketId As Integer) As Integer
On Error Resume Next
'*****************************************************************
'Finds the User with a certain SocketID
'*****************************************************************
Dim LoopC As Integer
  
LoopC = 1
  
Do Until UserList(LoopC).ConnID = SocketId

    LoopC = LoopC + 1
    
    If LoopC > MaxUsers Then
        userindex = 0
        Exit Function
    End If
    
Loop
  
userindex = LoopC

End Function


Sub HeadtoPos(Head As Byte, ByRef Pos As WorldPos)
On Error Resume Next
'*****************************************************************
'Takes Pos and ad moves it in heading direction
'*****************************************************************
Dim X As Integer
Dim Y As Integer
Dim tempVar As Single
Dim nX As Integer
Dim nY As Integer

X = Pos.X
Y = Pos.Y

If Head = NORTH Then
    nX = X
    nY = Y - 1
End If

If Head = SOUTH Then
    nX = X
    nY = Y + 1
End If

If Head = EAST Then
    nX = X + 1
    nY = Y
End If

If Head = WEST Then
    nX = X - 1
    nY = Y
End If

'return values
Pos.X = nX
Pos.Y = nY

End Sub

Sub SendUserStatsTxt(sendIndex As Integer, userindex As Integer)
On Error Resume Next
'*****************************************************************
'Sends a user's stats to text window
'*****************************************************************

Call SendData(ToIndex, sendIndex, 0, "@Stats for: " & UserList(userindex).Name & FONTTYPE_INFO)
Call SendData(ToIndex, sendIndex, 0, "@Health: " & UserList(userindex).Stats.MinHP & "/" & UserList(userindex).Stats.MaxHP & "  Mana: " & UserList(userindex).Stats.MinMAN & "/" & UserList(userindex).Stats.MaxMAN & "  Stamina: " & UserList(userindex).Stats.MinSTA & "/" & UserList(userindex).Stats.MaxSTA & FONTTYPE_INFO)
Call SendData(ToIndex, sendIndex, 0, "@Min Hit/Max Hit: " & UserList(userindex).Stats.MinHIT & "/" & UserList(userindex).Stats.MaxHIT & "   Defense: " & UserList(userindex).Stats.DEF & FONTTYPE_INFO)
Call SendData(ToIndex, sendIndex, 0, "@Gold: " & UserList(userindex).Stats.GLD & "  Position: " & UserList(userindex).Pos.X & "," & UserList(userindex).Pos.Y & " in map " & UserList(userindex).Pos.map & FONTTYPE_INFO)

End Sub

Sub UpdateUserMap(userindex As Integer)
On Error Resume Next
'*****************************************************************
'Updates a user with the place of all chars in the Map
'*****************************************************************
Dim map As Integer
Dim X As Integer
Dim Y As Integer

map = UserList(userindex).Pos.map

'Place chars
For Y = YMinMapSize To YMaxMapSize
    For X = XMinMapSize To XMaxMapSize

        If MapData(map, X, Y).userindex > 0 Then
            Call MakeUserChar(ToIndex, userindex, 0, MapData(map, X, Y).userindex, map, X, Y)
        End If

        If MapData(map, X, Y).Npcindex > 0 Then
            Call MakeNPCChar(ToIndex, userindex, 0, MapData(map, X, Y).Npcindex, map, X, Y)
        End If

        If MapData(map, X, Y).ObjInfo.ObjIndex > 0 Then
            Call MakeObj(ToIndex, userindex, 0, MapData(map, X, Y).ObjInfo, map, X, Y)
        End If

    Next X
Next Y

End Sub

Sub MoveUserChar(ByVal userindex As Integer, ByVal nHeading As Byte)
On Error Resume Next
'*****************************************************************
'Moves a User from one tile to another
'*****************************************************************
Dim nPos As WorldPos

'Move
nPos = UserList(userindex).Pos
Call HeadtoPos(nHeading, nPos)

 'Check if pos locked.
    If MapData(UserList(userindex).Pos.map, nPos.X, nPos.Y).Locked > 0 Then
    If UserList(userindex).Flags.YourID = MapData(UserList(userindex).Pos.map, nPos.X, nPos.Y).Locked Then
    'Do nothing
    Else
    Call SendData(ToIndex, userindex, 0, "@Closed." & FONTTYPE_INFO)
    Call SendData(ToIndex, userindex, 0, "SUP" & UserList(userindex).Pos.X & "," & UserList(userindex).Pos.Y)
    Exit Sub
    End If
    End If
    
'Move if legal pos
If LegalPos(userindex, UserList(userindex).Pos.map, nPos.X, nPos.Y) = True Then
    Call SendData(ToMapButIndex, userindex, UserList(userindex).Pos.map, "MOC" & UserList(userindex).Char.CharIndex & "," & nPos.X & "," & nPos.Y)

  
    
    'Update map and user pos
    MapData(UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y).userindex = 0
    UserList(userindex).Pos = nPos
    UserList(userindex).Char.Heading = nHeading
    MapData(UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y).userindex = userindex
Else
    'else correct user's pos
    Call SendData(ToIndex, userindex, 0, "SUP" & UserList(userindex).Pos.X & "," & UserList(userindex).Pos.Y)
End If

Call DoTileEvents(userindex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)

End Sub
Sub MoveNPCChar(ByVal Npcindex As Integer, ByVal nHeading As Byte)
On Error Resume Next
'*****************************************************************
'Moves a NPC from one tile to another
'*****************************************************************
Dim nPos As WorldPos

'Move
nPos = NPCList(Npcindex).Pos
Call HeadtoPos(nHeading, nPos)

'Move if legal pos
If LegalPos(Npcindex, NPCList(Npcindex).Pos.map, nPos.X, nPos.Y) = True Then
    Call SendData(ToMap, 0, NPCList(Npcindex).Pos.map, "MOC" & NPCList(Npcindex).Char.CharIndex & "," & nPos.X & "," & nPos.Y)

    'Update map and user pos
    MapData(NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X, NPCList(Npcindex).Pos.Y).Npcindex = 0
    NPCList(Npcindex).Pos = nPos
    NPCList(Npcindex).Char.Heading = nHeading
    MapData(NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X, NPCList(Npcindex).Pos.Y).Npcindex = Npcindex
End If

End Sub

Sub MakeUserChar(sndRoute As Byte, sndIndex As Integer, sndMap As Integer, userindex As Integer, ByVal map As Integer, ByVal X As Integer, ByVal Y As Integer)
On Error Resume Next
'*****************************************************************
'Makes and places a user's character
'*****************************************************************
Dim CharIndex As Integer

'If needed make a new character in list
If UserList(userindex).Char.CharIndex = 0 Then
    CharIndex = NextOpenCharIndex
    UserList(userindex).Char.CharIndex = CharIndex
    CharList(CharIndex) = userindex
End If

'Place character on map
MapData(map, X, Y).userindex = userindex

'Send make character command to clients
Call SendData(sndRoute, sndIndex, sndMap, "MAC" & UserList(userindex).Char.Body & "," & UserList(userindex).Char.Head & "," & UserList(userindex).Char.Heading & "," & UserList(userindex).Char.CharIndex & "," & X & "," & Y & "," & UserList(userindex).Char.WeaponAnim & "," & UserList(userindex).Char.ShieldAnim)

End Sub

Sub MakeNPCChar(sndRoute As Byte, sndIndex As Integer, sndMap As Integer, Npcindex As Integer, ByVal map As Integer, ByVal X As Integer, ByVal Y As Integer)
On Error Resume Next
'*****************************************************************
'Makes and places a NPC character
'*****************************************************************
Dim CharIndex As Integer

'If needed make a new character in list
If NPCList(Npcindex).Char.CharIndex = 0 Then
    CharIndex = NextOpenCharIndex
    NPCList(Npcindex).Char.CharIndex = CharIndex
    CharList(CharIndex) = Npcindex
End If

'Place character on map
MapData(map, X, Y).Npcindex = Npcindex

'Send make character command to clients
Call SendData(sndRoute, sndIndex, sndMap, "MAC" & NPCList(Npcindex).Char.Body & "," & NPCList(Npcindex).Char.Head & "," & NPCList(Npcindex).Char.Heading & "," & NPCList(Npcindex).Char.CharIndex & "," & X & "," & Y & "," & NPCList(Npcindex).Char.WeaponAnim & "," & NPCList(Npcindex).Char.ShieldAnim)

End Sub

Function LegalPos(userindex As Integer, ByVal map As Integer, ByVal X As Integer, ByVal Y As Integer) As Boolean
On Error Resume Next
'*****************************************************************
'Checks to see if a tile position is legal
'*****************************************************************

'Make sure it's a legal map
If map <= 0 Or map > NumMaps Then
    LegalPos = False
    Exit Function
End If

'Check to see if its out of bounds
If X < MinXBorder Or X > MaxXBorder Or Y < MinYBorder Or Y > MaxYBorder Then
    LegalPos = False
    Exit Function
End If

'Check to see if its blocked
If MapData(map, X, Y).Blocked = 1 And UserList(userindex).Flags.status = 0 Then
    LegalPos = False
    Exit Function
End If

'User
If MapData(map, X, Y).userindex > 0 Then
    LegalPos = False
    Exit Function
End If

'NPC
If MapData(map, X, Y).Npcindex > 0 Then
    LegalPos = False
    Exit Function
End If


LegalPos = True

End Function

Sub SendHelp(Index As Integer)
On Error Resume Next
'*****************************************************************
'Sends help strings to Index
'*****************************************************************
Dim NumHelpLines As Integer
Dim LoopC As Integer

NumHelpLines = Val(GetVar(IniPath & "Help.dat", "INIT", "NumLines"))

For LoopC = 1 To NumHelpLines
    Call SendData(ToIndex, Index, 0, "@" & GetVar(IniPath & "Help.dat", "Help", "Line" & LoopC) & FONTTYPE_INFO)
Next LoopC

End Sub
Sub EraseUserChar(sndRoute As Byte, sndIndex As Integer, sndMap As Integer, userindex As Integer)
On Error Resume Next
'*****************************************************************
'Erase a character
'*****************************************************************



'Remove from list
CharList(UserList(userindex).Char.CharIndex) = 0

'Update LsstChar
If UserList(userindex).Char.CharIndex = LastChar Then
    Do Until CharList(LastChar) > 0
        LastChar = LastChar - 1
        If LastChar = 0 Then Exit Do
    Loop
End If

'Remove from map
MapData(UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y).userindex = 0

'Send erase command to clients
Call SendData(ToMap, 0, UserList(userindex).Pos.map, "ERC" & UserList(userindex).Char.CharIndex)

'Update userlist
UserList(userindex).Char.CharIndex = 0

'update NumChars
NumChars = NumChars - 1



End Sub

Sub EraseNPCChar(sndRoute As Byte, sndIndex As Integer, sndMap As Integer, Npcindex As Integer)
On Error Resume Next
'*****************************************************************
'Erase a character
'*****************************************************************

'Remove from list
CharList(NPCList(Npcindex).Char.CharIndex) = 0

'Update LsstChar
If NPCList(Npcindex).Char.CharIndex = LastChar Then
    Do Until CharList(LastChar) > 0
        LastChar = LastChar - 1
        If LastChar = 0 Then Exit Do
    Loop
End If

'Remove from map
MapData(NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X, NPCList(Npcindex).Pos.Y).Npcindex = 0

'Send erase command to clients
Call SendData(ToMap, 0, NPCList(Npcindex).Pos.map, "ERC" & NPCList(Npcindex).Char.CharIndex)

'Update userlist
NPCList(Npcindex).Char.CharIndex = 0

'update NumChars
NumChars = NumChars - 1

End Sub

Sub LookatTile(userindex As Integer, map As Integer, X As Integer, Y As Integer)
On Error Resume Next
'*****************************************************************
'Responds to the user clicking on a square
'*****************************************************************
Dim FoundChar As Byte
Dim FoundSomething As Byte
Dim Tempcharindex As Integer
Dim obj As ObjData

Dim slot As Byte

'Check if legal
If InMapBounds(map, X, Y) = False Then
    Exit Sub
End If


'*** Check for object ***
If MapData(map, X, Y).ObjInfo.ObjIndex > 0 Then
    Call SendData(ToIndex, userindex, 0, "@You see a " & ObjData(MapData(map, X, Y).ObjInfo.ObjIndex).Name & FONTTYPE_TALK)
    FoundSomething = 1
If MapData(map, X, Y).ObjInfo.ObjIndex = 114 Then
MapData(map, X, Y).ObjInfo.Amount = 0
MapData(map, X, Y).ObjInfo.ObjIndex = 0
Call UpdateUserMap(userindex)
Call SetCamp(userindex, map, X, Y)
End If
End If

'Check to see messageboard
If MapData(map, X, Y).ObjInfo.ObjIndex = 4 Then
Call SendPostings(userindex)
Exit Sub
End If

'Roast meat
If MapData(map, X, Y).ObjInfo.ObjIndex = 155 Then
obj = ObjData(UserList(userindex).WeaponEqpObjIndex)
If obj.ObjType = 39 Then
Call RoastMeat(userindex, slot)
End If
End If

'Roast meat
If MapData(map, X, Y).ObjInfo.ObjIndex = 135 Then
obj = ObjData(UserList(userindex).WeaponEqpObjIndex)
If obj.ObjType = 39 Then
Call RoastMeat(userindex, slot)
End If
End If

'**************************
'Check to see if sign
If MapData(map, X, Y).ObjInfo.ObjIndex = 289 Then
Dim Content As String
Dim Sign As Long
Sign = MapData(map, X, Y).Sign
Content = GetVar(IniPath & "signs.txt", "SIGN" & Sign, "Content")
'If owner
If UserList(userindex).Flags.YourID = MapData(map, X, Y).SignOwner Then
Call SendData(ToIndex, userindex, 0, "SII" & Content)
UserList(userindex).Flags.Sign = MapData(map, X, Y).Sign
Else 'if not
Call SendData(ToIndex, userindex, 0, "SGN" & Content)
End If
End If
'***************************

'*** Check for Characters ***
If Y + 1 <= YMaxMapSize Then
    If MapData(map, X, Y + 1).userindex > 0 Then
        Tempcharindex = MapData(map, X, Y + 1).userindex
        FoundChar = 1
    End If
    If MapData(map, X, Y + 1).Npcindex > 0 Then
        Tempcharindex = MapData(map, X, Y + 1).Npcindex
        FoundChar = 2
    End If
End If

'Check for Character
If FoundChar = 0 Then
    If MapData(map, X, Y).userindex > 0 Then
        Tempcharindex = MapData(map, X, Y).userindex
        FoundChar = 1
        UserList(userindex).UserTargetIndex = Tempcharindex
    End If
    If MapData(map, X, Y).Npcindex > 0 Then
        Tempcharindex = MapData(map, X, Y).Npcindex
        FoundChar = 2
    End If
End If

'React to character
If FoundChar = 2 Then
Call SendData(ToIndex, userindex, 0, "TGT" & NPCList(Tempcharindex).Name)
Call SendData(ToIndex, userindex, 0, "@You target " & NPCList(Tempcharindex).Name & " (" & Tempcharindex & ").")
'Makes the current NPC clicked on the target
UserList(userindex).Npcindex = Tempcharindex
UserList(userindex).NPCtarget = NPCList(Tempcharindex).NPCtype
UserList(userindex).UserTargetIndex = Tempcharindex
FoundSomething = 1
End If

If FoundChar = 1 Then
Call SendData(ToIndex, userindex, 0, "TGT" & UserList(Tempcharindex).Name)
        
        If UserList(Tempcharindex).Flags.Morphed = 1 Then
        Call SendData(ToIndex, userindex, 0, "@You see " & UserList(Tempcharindex).Name)
        ElseIf UserList(Tempcharindex).Flags.Criminal = 2 Then
         Call SendData(ToIndex, userindex, 0, "@You see " & UserList(Tempcharindex).modName & " " & UserList(Tempcharindex).Community.RepRank & " " & UserList(Tempcharindex).class & FONTTYPE_FIGHT)
        ElseIf Len(UserList(Tempcharindex).Desc) > 1 Then
            Call SendData(ToIndex, userindex, 0, "@You see " & UserList(Tempcharindex).modName & " " & UserList(Tempcharindex).Community.RepRank & " " & UserList(Tempcharindex).class & " - " & UserList(Tempcharindex).Desc)
        UserList(userindex).UserTargetIndex = Tempcharindex
        Else
        Call SendData(ToIndex, userindex, 0, "@You see " & UserList(Tempcharindex).modName & " " & UserList(Tempcharindex).Community.RepRank & " " & UserList(Tempcharindex).class)
        UserList(userindex).UserTargetIndex = Tempcharindex
        End If
        
        'Show clan if in clan
        If UserList(Tempcharindex).Clan = "" Then
        'Do nothing
        Else
        Call SendData(ToIndex, userindex, 0, "@Member of the " & UserList(Tempcharindex).Clan & " clan." & FONTTYPE_INFO)
        End If
        
If UserList(userindex).Flags.Pickpocket = 1 Then
Call Pickpocket(userindex, UserList(userindex).UserTargetIndex)
End If
FoundSomething = 1
End If


'*** Didn't find anything ***
If FoundSomething = 0 Then
Call SendData(ToIndex, userindex, 0, "@You see nothing of interest.")
End If

End Sub

Sub WarpUserChar(ByVal userindex As Integer, ByVal map As Integer, ByVal X As Integer, ByVal Y As Integer)
On Error Resume Next
'*****************************************************************
'Warps user to another spot
'*****************************************************************
Dim OldMap As Integer
Dim OldX As Integer
Dim OldY As Integer
Dim animal As Integer
animal = UserList(userindex).Stats.OwnAnimal

OldMap = UserList(userindex).Pos.map
OldX = UserList(userindex).Pos.X
OldY = UserList(userindex).Pos.Y

Call EraseUserChar(ToMap, 0, OldMap, userindex)

UserList(userindex).Pos.X = X
UserList(userindex).Pos.Y = Y
UserList(userindex).Pos.map = map

'Check to see if legal map
If MapInfo(map).StartPos.map = 0 Then
Call SendData(ToIndex, userindex, 0, "@Cannot enter next map. It is defect." & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if legal map
If MapInfo(map).StartPos.X = 0 Then
Call SendData(ToIndex, userindex, 0, "@Cannot enter next map. It is defect." & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if legal map
If MapInfo(map).StartPos.Y = 0 Then
Call SendData(ToIndex, userindex, 0, "@Cannot enter next map. It is defect." & FONTTYPE_INFO)
Exit Sub
End If


If OldMap <> map Then
    If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Body = 16
    If UserList(userindex).Flags.Hiding = 1 Then UserList(userindex).Char.Body = 53

    Call SendData(ToIndex, userindex, 0, "SCM" & map)
        
    If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Body = 16
    If UserList(userindex).Flags.Hiding = 1 Then UserList(userindex).Char.Body = 53

    Call MakeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
    Call UpdateUserMap(userindex)
    Call SendData(ToIndex, userindex, 0, "SUC" & UserList(userindex).Char.CharIndex)

    'Update new Map Users
    MapInfo(map).NumUsers = MapInfo(map).NumUsers + 1

    'Update old Map Users
    MapInfo(OldMap).NumUsers = MapInfo(OldMap).NumUsers - 1
    If MapInfo(OldMap).NumUsers < 0 Then
        MapInfo(OldMap).NumUsers = 0
    End If
    
    If UserList(userindex).Stats.OwnAnimal > 0 Then
    If LegalPos(animal, map, X + 1, Y) Then
    Call WarpNPCChar(animal, map, X + 1, Y)
    Else
    If LegalPos(animal, map, X, Y + 1) Then
    Call WarpNPCChar(animal, map, X, Y + 1)
    Else
    If LegalPos(animal, map, X, Y - 1) Then
    Call WarpNPCChar(animal, map, X, Y - 1)
    End If
    End If
    End If
    End If
        
    'Start NEW MIDI if not the same as last map
    If MapInfo(OldMap).Music = MapInfo(map).Music Then
    'Do nothing
    Else
    Call SendData(ToIndex, userindex, 0, "PLM" & MapInfo(map).Music)
    End If
    
Else


    If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Body = 16
    If UserList(userindex).Flags.Hiding = 1 Then UserList(userindex).Char.Body = 53
    Call MakeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
    Call SendData(ToIndex, userindex, 0, "SUC" & UserList(userindex).Char.CharIndex)

    'Warp users animal as well
    
    If UserList(userindex).Stats.OwnAnimal > 0 Then
    If LegalPos(animal, map, X + 1, Y) Then
    Call WarpNPCChar(animal, map, X + 1, Y)
    Else
    If LegalPos(animal, map, X, Y + 1) Then
    Call WarpNPCChar(animal, map, X, Y + 1)
    Else
    If LegalPos(animal, map, X, Y - 1) Then
    Call WarpNPCChar(animal, map, X, Y - 1)
    End If
    End If
    End If
    End If
    
    'Start NEW MIDI if not the same as last map
    If MapInfo(OldMap).Music = MapInfo(map).Music Then
    'Do nothing
    Else
    Call SendData(ToIndex, userindex, 0, "PLM" & MapInfo(map).Music)
    End If
    
    Call WriteVar(CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr", "INIT", "Position", UserList(userindex).Pos.map & "-" & UserList(userindex).Pos.X & "-" & UserList(userindex).Pos.Y)
    
End If

End Sub
Sub WarpNPCChar(ByVal Npcindex As Integer, ByVal map As Integer, ByVal X As Integer, ByVal Y As Integer)
On Error Resume Next
'*****************************************************************
'Warps npc to another spot
'*****************************************************************
Dim OldMap As Integer
Dim OldX As Integer
Dim OldY As Integer

OldMap = NPCList(Npcindex).Pos.map
OldX = NPCList(Npcindex).Pos.X
OldY = NPCList(Npcindex).Pos.Y

Call EraseNPCChar(ToMap, 0, OldMap, Npcindex)

NPCList(Npcindex).Pos.X = X
NPCList(Npcindex).Pos.Y = Y
NPCList(Npcindex).Pos.map = map

If OldMap <> map Then
    Call MakeNPCChar(ToMap, 0, NPCList(Npcindex).Pos.map, Npcindex, NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X, NPCList(Npcindex).Pos.Y)
Else
    Call MakeNPCChar(ToMap, 0, NPCList(Npcindex).Pos.map, Npcindex, NPCList(Npcindex).Pos.map, NPCList(Npcindex).Pos.X, NPCList(Npcindex).Pos.Y)
End If

End Sub
Sub SendUserStatsBox(userindex As Integer)
On Error Resume Next
'*****************************************************************
'Updates a User's stat box
'*****************************************************************

Call SendData(ToIndex, userindex, 0, "SST" & UserList(userindex).Stats.MaxHP & "," & UserList(userindex).Stats.MinHP & "," & UserList(userindex).Stats.MaxMAN & "," & UserList(userindex).Stats.MinMAN & "," & UserList(userindex).Stats.MaxSTA & "," & UserList(userindex).Stats.MinSTA & "," & UserList(userindex).Stats.GLD & "," & UserList(userindex).Stats.ELV & "," & UserList(userindex).Stats.Skill1 & "," & UserList(userindex).Stats.Skill2 & "," & UserList(userindex).Stats.Skill3 & "," & UserList(userindex).Stats.Skill4 & "," & UserList(userindex).Stats.Skill5 & "," & UserList(userindex).Stats.Skill6 & "," & UserList(userindex).Stats.Skill7 & "," & UserList(userindex).Stats.Skill8 & "," & UserList(userindex).Stats.Skill9 & "," & UserList(userindex).Stats.Skill10 & "," & UserList(userindex).Stats.Skill11 & "," & UserList(userindex).Stats.Skill12 & "," & UserList(userindex).Stats.Skill13 & "," & UserList(userindex).Stats.Skill14 & "," & UserList(userindex).Stats.Skill15 _
& "," & UserList(userindex).Stats.Skill16 & "," & UserList(userindex).Stats.Skill17 & "," & UserList(userindex).Stats.Skill18 & "," & UserList(userindex).Stats.Skill19 & "," & UserList(userindex).Stats.Skill20 & "," & UserList(userindex).Stats.Skill21 & "," & UserList(userindex).Stats.Skill22 & "," & UserList(userindex).Stats.Skill23 & "," & UserList(userindex).Stats.Skill24 & "," & UserList(userindex).Stats.Skill25 & "," & UserList(userindex).Stats.Skill26 & "," & UserList(userindex).Stats.Skill27 & "," & UserList(userindex).Stats.Skill28 & "," & UserList(userindex).Stats.Drink & "," & UserList(userindex).Stats.Food & "," & UserList(userindex).Stats.PracticePoints & "," & UserList(userindex).Char.Body & "," & UserList(userindex).Char.Head & "," & UserList(userindex).Stats.BANKGLD & "," & UserList(userindex).Char.WeaponAnim & "," & UserList(userindex).class & "," & UserList(userindex).Race & "," & UserList(userindex).Char.ShieldAnim & "," & UserList(userindex).Community.RepRank _
& "," & UserList(userindex).Flags.Criminal & "," & UserList(userindex).Flags.SpecSkill1 & "," & UserList(userindex).Flags.SpecSkill2 & "," & UserList(userindex).Flags.SpecSkill3 & "," & UserList(userindex).Stats.EXP & "," & UserList(userindex).Stats.ELU & "," & UserList(userindex).Flags.CriminalCount)

End Sub
Sub NpcTrade(updateall As Boolean, Npcindex As Integer, userindex As Integer, slot As Byte)
On Error Resume Next
'*********************************************************************
'Asks if a NPC wants to TRADE. NPC responds with words and/or actions
'*********************************************************************
Dim NullObj As NPCOBJ
Dim LoopC As Integer

Npcindex = UserList(userindex).Npcindex

Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(1), 1)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(2), 2)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(3), 3)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(4), 4)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(5), 5)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(6), 6)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(7), 7)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(8), 8)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(9), 9)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(10), 10)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(11), 11)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(12), 12)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(13), 13)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(14), 14)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(15), 15)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(16), 16)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(17), 17)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(18), 18)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(19), 19)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(20), 20)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(21), 21)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(22), 22)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(23), 23)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(24), 24)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(25), 25)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(26), 26)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(27), 27)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(28), 28)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(29), 29)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(30), 30)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(31), 31)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(32), 32)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(33), 33)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(34), 34)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(35), 35)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(36), 36)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(37), 37)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(38), 38)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(39), 39)
Call ChangeNPCInv(userindex, Npcindex, NPCList(Npcindex).Object(40), 40)




End Sub
Sub NpcGive(userindex As Integer, slot As Byte)
On Error Resume Next
'****************************************************************************
'Try to give the object you clicked on last to a NPC *Mostly used for quests*
'****************************************************************************
Select Case UserList(userindex).NPCtarget
Dim Chance


Case 2 'Beggar
Call SendData(ToIndex, userindex, 0, "@The beggar says, Oh thank ye ! Thank ye ! Im forever grateful !" & FONTTYPE_TALK)
UserList(userindex).Community.CommonRep = UserList(userindex).Community.CommonRep + 1
UserList(userindex).Flags.Giving = 1
UserList(userindex).Object(slot).ObjIndex = 0
UserList(userindex).Object(slot).Amount = 0
'MAYBE raise reputation
Randomize
Chance = Int((10 * Rnd) + 1)
If Chance = 10 Then UserList(userindex).Community.OverallRep = UserList(userindex).Community.OverallRep + 1


End Select
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, 0)
Call CheckRep(userindex)






End Sub
Sub NpcHeal(userindex As Integer, slot As Byte)
On Error Resume Next
'*********************************************************************
'Asks a NPC to heal the player
'*********************************************************************
Dim Charge As Long

If UserList(userindex).Stats.ELV = 1 Then Charge = 10
If UserList(userindex).Stats.ELV = 2 Then Charge = 20
If UserList(userindex).Stats.ELV = 3 Then Charge = 30
If UserList(userindex).Stats.ELV = 4 Then Charge = 40
If UserList(userindex).Stats.ELV = 5 Then Charge = 50
If UserList(userindex).Stats.ELV = 6 Then Charge = 60
If UserList(userindex).Stats.ELV = 7 Then Charge = 70
If UserList(userindex).Stats.ELV = 8 Then Charge = 80
If UserList(userindex).Stats.ELV = 9 Then Charge = 90
If UserList(userindex).Stats.ELV = 10 Then Charge = 100
If UserList(userindex).Stats.ELV = 11 Then Charge = 110
If UserList(userindex).Stats.ELV = 12 Then Charge = 120
If UserList(userindex).Stats.ELV = 13 Then Charge = 130
If UserList(userindex).Stats.ELV = 14 Then Charge = 140
If UserList(userindex).Stats.ELV = 15 Then Charge = 150
If UserList(userindex).Stats.ELV = 16 Then Charge = 160
If UserList(userindex).Stats.ELV = 17 Then Charge = 170
If UserList(userindex).Stats.ELV = 18 Then Charge = 180
If UserList(userindex).Stats.ELV = 19 Then Charge = 190
If UserList(userindex).Stats.ELV = 20 Then Charge = 200
If UserList(userindex).Stats.ELV > 20 Then Charge = 200


If UserList(userindex).Stats.GLD < Charge Then
Call SendData(ToIndex, userindex, 0, "@Sorry, you do not have enough gold ! Healing for you costs " & Charge & " gold !" & FONTTYPE_INFO)
Exit Sub
End If

Select Case UserList(userindex).NPCtarget

Case 5 'Healer
UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MaxHP
Call SendData(ToIndex, userindex, 0, "@That`ll be " & Charge & " gold, now you are fully healed !" & FONTTYPE_INFO)
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - Charge

End Select

Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, 0)







End Sub
Sub NpcRessurect(userindex As Integer, slot As Byte)
On Error Resume Next
'*********************************************************************
'Asks a NPC to ressurect the player
'*********************************************************************
Dim obj As ObjData
obj = ObjData(UserList(userindex).Object(UserList(userindex).ClothingEqpSlot).ObjIndex)

Select Case UserList(userindex).NPCtarget

Case 5 'Healer
If UserList(userindex).Flags.status = 1 Then
Call SendData(ToIndex, userindex, 0, "@The healer says, You are ressurected. Welcome to the side of the living." & FONTTYPE_TALK)
UserList(userindex).Flags.status = 0
UserList(userindex).Char.Body = obj.ClothingType
UserList(userindex).Char.Head = UserList(userindex).Flags.StartHead
Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_CHORUS)
Call SendData(ToIndex, userindex, 0, "DEN")
Else
Call SendData(ToIndex, userindex, 0, "@ARE DOUST PLAYING TRICKS ON ME ? YOU ARE NOT DEAD !" & FONTTYPE_TALK)
End If

Case 61 'Priest Of Life
If UserList(userindex).Flags.status = 1 Then
Call SendData(ToIndex, userindex, 0, "@The priest of life says, You are ressurected. Welcome to the side of the living." & FONTTYPE_TALK)
UserList(userindex).Flags.status = 0
UserList(userindex).Char.Body = obj.ClothingType
UserList(userindex).Char.Head = UserList(userindex).Flags.StartHead
Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_CHORUS)
Call SendData(ToIndex, userindex, 0, "DEN")
Else
Call SendData(ToIndex, userindex, 0, "@ARE DOUST PLAYING TRICKS ON ME ? YOU ARE NOT DEAD !" & FONTTYPE_TALK)
End If


End Select
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, 0)






End Sub
Sub Donate(userindex As Integer)
On Error Resume Next
'*********************************************************************
'Donate money to a temple priest
'*********************************************************************



Dim Chance
Chance = Int(RandomNumber(1, 10))

Select Case UserList(userindex).NPCtarget

Case 63 'Hyliios Priest
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - UserList(userindex).Throw.Donategold
Call SendData(ToIndex, userindex, 0, "@The priest of Hyliios tells you, The temple of Hyliios thanks your genorosity. You will not regret." & FONTTYPE_TALK)
If Chance = 9 Then
UserList(userindex).Community.HyliiosRep = UserList(userindex).Community.HyliiosRep + 1
End If

Case 64 'Griigo Priest
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - UserList(userindex).Throw.Donategold
Call SendData(ToIndex, userindex, 0, "@The priest of Griigo tells you, The temple of Griigo thanks your genorosity. You will not regret." & FONTTYPE_TALK)
If Chance = 9 Then
UserList(userindex).Community.GriigoRep = UserList(userindex).Community.GriigoRep + 1
End If

Case 65 'Bendarr priest
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - UserList(userindex).Throw.Donategold
Call SendData(ToIndex, userindex, 0, "@The priest of Bendarr tells you, The temple of Bendarr thanks your genorosity. You will not regret." & FONTTYPE_TALK)
If Chance = 9 Then
UserList(userindex).Community.BendarrRep = UserList(userindex).Community.BendarrRep + 1
End If

Case 66 'Veega priest
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - UserList(userindex).Throw.Donategold
Call SendData(ToIndex, userindex, 0, "@The priest of Veega tells you, The temple of Veega thanks your genorosity. You will not regret." & FONTTYPE_TALK)
If Chance = 9 Then
UserList(userindex).Community.VeegaRep = UserList(userindex).Community.VeegaRep + 1
End If

Case 67 'Zeendic Priest
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - UserList(userindex).Throw.Donategold
Call SendData(ToIndex, userindex, 0, "@The priest of Zeendic tells you, The temple of Zeendic thanks your genorosity. You will not regret." & FONTTYPE_TALK)
If Chance = 9 Then
UserList(userindex).Community.ZeendicRep = UserList(userindex).Community.ZeendicRep + 1
End If

End Select


If UserList(userindex).Stats.GLD < 0 Then UserList(userindex).Stats.GLD = 0
SendUserStatsBox (userindex)









End Sub
Sub NpcTrain(userindex As Integer, slot As Byte)
On Error Resume Next
'*********************************************************************
'Asks a NPC to train the player
'*********************************************************************

'Check to see if user is morphed
If UserList(userindex).Flags.Morphed = 1 Then
Call SendData(ToIndex, userindex, 0, "@You cannot do this when you are morphed." & FONTTYPE_INFO)
Exit Sub
End If


Select Case UserList(userindex).NPCtarget

Case 62 'Trainer
If UserList(userindex).Stats.PracticePoints > 0 Then
Call SendUserStatsBox(userindex)
Call SendData(ToIndex, userindex, 0, "@Sure. I guess i can teach ya a few tricks of the trade." & FONTTYPE_TALK)
Call SendData(ToIndex, userindex, 0, "TRA")
Else
Call SendData(ToIndex, userindex, 0, "@Come back when you have some training points." & FONTTYPE_TALK)
End If

End Select
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, 0)






End Sub
Sub Pray(userindex As Integer, slot As Byte)
On Error Resume Next
'*********************************************************************
'Asks a NPC to train the player
'*********************************************************************
Dim Luck
Dim Luck2
Dim Chance
Dim Miracle
Dim GiveStrenght As Integer
Dim GiveEXP As Integer
Dim GiveGold As Integer

'Check to see if player has already prayed today
If UserList(userindex).Stats.LastPray = Date Then
Call SendData(ToIndex, userindex, 0, "@You have already prayed today. The gods won't listen to you..." & FONTTYPE_INFO)
Exit Sub
Else
UserList(userindex).Stats.LastPray = Date
End If

' Set limits
If UserList(userindex).Stats.GLD > 500 Or UserList(userindex).Stats.EXP > 5000 Then
Call SendData(ToIndex, userindex, 0, "The gods will no longer grant you any miracles." & FONTTYPE_INFO)
Exit Sub
End If

'Maybe or maybe not raise skill
Dim Raise
Raise = RandomNumber(1, 3)
If Raise = 5 And UserList(userindex).Stats.Skill19 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill19 Then
UserList(userindex).Stats.Skill19 = UserList(userindex).Stats.Skill19 + 1
Call SendData(ToIndex, userindex, 0, "@Your religion skill has improved (" & UserList(userindex).Stats.Skill19 & ") !" & FONTTYPE_SKILLINFO)
End If

Randomize
Luck = UserList(userindex).Stats.Skill19
If Luck <= 10 And Luck >= -1 Then Luck2 = 50
If Luck <= 20 And Luck >= 9 Then Luck2 = 45
If Luck <= 30 And Luck >= 19 Then Luck2 = 40
If Luck <= 40 And Luck >= 29 Then Luck2 = 35
If Luck <= 50 And Luck >= 39 Then Luck2 = 30
If Luck <= 60 And Luck >= 49 Then Luck2 = 25
If Luck <= 70 And Luck >= 59 Then Luck2 = 20
If Luck <= 80 And Luck >= 69 Then Luck2 = 15
If Luck <= 90 And Luck >= 79 Then Luck2 = 10
If Luck <= 999999 And Luck >= 89 Then Luck2 = 3
Chance = Int(RandomNumber(1, Luck2))

If Chance = Luck2 Then
'Continue
Else
Call SendData(ToIndex, userindex, 0, "@You pray your deepest prayer, but it is not heard..." & FONTTYPE_INFO)
Exit Sub
End If


Select Case UserList(userindex).NPCtarget

'Case 63 = Hyliios Priest
'Case 64 = Griigo Priest
'Case 65 = Bendarr Priest
'Case 66 = Veega Priest
'Case 67 = Zeendic Priest


Case 63 'Hyliios Priest
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_CHORUS)
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@And your prayers are heard !" & FONTTYPE_INFO)
'Raise reputation at Hyliios deity
UserList(userindex).Community.HyliiosRep = UserList(userindex).Community.HyliiosRep + 1

'Randomize what miracle to happen
Randomize
Miracle = Int((2 * Rnd) + 1)


'Mirace 2 (Give more exp)
If Miracle = 1 Then
Call SendData(ToIndex, userindex, 0, "@The goddess of Hyliios has granted you 10 experience !" & FONTTYPE_INFO)
UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 10
End If

'Miracle 3 (Give 5 gold)
If Miracle = 2 Then
Call SendData(ToIndex, userindex, 0, "@The goddess of Hyliios has granted you 5 gold pieces !" & FONTTYPE_INFO)
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + 5
End If

Case 64 'Griigo
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_CHORUS)
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@And your prayers are heard !" & FONTTYPE_INFO)
'Raise reputation at deity
UserList(userindex).Community.GriigoRep = UserList(userindex).Community.GriigoRep + 1

'Randomize what miracle to happen
Randomize
Miracle = Int((2 * Rnd) + 1)

'Mirace 2 (Give more exp)
If Miracle = 1 Then
Call SendData(ToIndex, userindex, 0, "@The god of Griigo has granted you 10 experience !" & FONTTYPE_INFO)
UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 10
End If

'Miracle 3 (Give 5 gold)
If Miracle = 2 Then
Call SendData(ToIndex, userindex, 0, "@The god of Griigo has granted you 5 gold pieces !" & FONTTYPE_INFO)
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + 5
End If

Case 65 'Bendarr Priest
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_CHORUS)
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@And your prayers are heard !" & FONTTYPE_INFO)
'Raise reputation at deity
UserList(userindex).Community.BendarrRep = UserList(userindex).Community.BendarrRep + 1

'Randomize what miracle to happen
Randomize
Miracle = Int((2 * Rnd) + 1)

'Mirace 2 (Give more exp)
If Miracle = 1 Then
Call SendData(ToIndex, userindex, 0, "@The god Bendarr has granted you 10 experience !" & FONTTYPE_INFO)
UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 10
End If

'Miracle 3 (Give 5 gold)
If Miracle = 2 Then
Call SendData(ToIndex, userindex, 0, "@The god Bendarr has granted you 5 gold pieces !" & FONTTYPE_INFO)
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + 5
End If

Case 66 'Veega Priest
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_CHORUS)
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@And your prayers are heard !" & FONTTYPE_INFO)
'Raise reputation at deity
UserList(userindex).Community.VeegaRep = UserList(userindex).Community.VeegaRep + 1

'Randomize what miracle to happen
Randomize
Miracle = Int((2 * Rnd) + 1)

'Mirace 2 (Give more exp)
If Miracle = 1 Then
Call SendData(ToIndex, userindex, 0, "@The godess Veega has granted you 10 experience !" & FONTTYPE_INFO)
UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 10
End If

'Miracle 3 (Give 5 gold)
If Miracle = 2 Then
Call SendData(ToIndex, userindex, 0, "@The godess Veega has granted you 5 gold pieces !" & FONTTYPE_INFO)
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + 5
End If

Case 67 'Zeendic Priest
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_CHORUS)
Call SendData(ToIndex, userindex, 0, "@You start to pray..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@And your prayers are heard !" & FONTTYPE_INFO)
'Raise reputation at deity
UserList(userindex).Community.ZeendicRep = UserList(userindex).Community.ZeendicRep + 1

'Randomize what miracle to happen
Randomize
Miracle = Int((2 * Rnd) + 1)


'Mirace 2 (Give more exp)
If Miracle = 1 Then
Call SendData(ToIndex, userindex, 0, "@The god Zeendic has granted you 10 experience !" & FONTTYPE_INFO)
UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 10
End If

'Miracle 3 (Give 5 gold)
If Miracle = 2 Then
Call SendData(ToIndex, userindex, 0, "@The god Zeendic has granted you 5 gold pieces !" & FONTTYPE_INFO)
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + 5
End If
End Select

Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, 0)
Call SendUserStatsBox(userindex)

End Sub
Sub Duel(userindex As Integer, slot As Byte)
On Error Resume Next

If UserList(userindex).Flags.Duel = 0 Then
Call SendData(ToIndex, userindex, 0, "@You go into duelling mode. Any player over level 5 can kill you now and vice versa." & FONTTYPE_INFO)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " goes into duel !" & FONTTYPE_INFO)
UserList(userindex).Flags.Duel = 1
Else
Call SendData(ToIndex, userindex, 0, "@You have left duel mode." & FONTTYPE_INFO)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " has ended duel." & FONTTYPE_INFO)
UserList(userindex).Flags.Duel = 0
End If


End Sub
Sub Fish(userindex As Integer, slot As Byte)
On Error Resume Next

Dim WhatFish As Integer
WhatFish = Int(RandomNumber(308, 317))


'Check to see if rod is equipped. If not, abort.
If UserList(userindex).OBJtarget > 16 Or UserList(userindex).OBJtarget < 16 Then
Exit Sub
End If

'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 7
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill20 & "," & 7)
Call SendData(ToIndex, userindex, 0, "@You throw the line into the water and wait... The blue bar represent how much time left before you are are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff
Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_FISHINGPOLE)

'Sucessfully
Call SendData(ToIndex, userindex, 0, "@You pull up a nice fish !" & FONTTYPE_INFO)

obj.ObjIndex = WhatFish
obj.Amount = 1
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(userindex).Stats.Skill20 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill20 Then
UserList(userindex).Stats.Skill20 = UserList(userindex).Stats.Skill20 + 1
Call SendData(ToIndex, userindex, 0, "@Your fishing skill has improved (" & UserList(userindex).Stats.Skill20 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)



'****-********************


End Sub
Sub Mine(userindex As Integer, slot As Byte)
On Error Resume Next

'Check to see if pickaxe is equipped. If not, abort.
If UserList(userindex).OBJtarget > 48 Or UserList(userindex).OBJtarget < 48 Then
Exit Sub
End If

'Begin chopping process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 15
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill20 & "," & 7)
Call SendData(ToIndex, userindex, 0, "@You begin mining after ore... The blue bar represent how much time left before you are are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff
Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_FISHINGPOLE)

'Sucessfully
Call SendData(ToIndex, userindex, 0, "@You manage to mine some fine ore !" & FONTTYPE_INFO)
 
obj.ObjIndex = 154
obj.Amount = 4
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(userindex).Stats.Skill21 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill21 Then
UserList(userindex).Stats.Skill21 = UserList(userindex).Stats.Skill21 + 1
Call SendData(ToIndex, userindex, 0, "@Your mining skill has improved (" & UserList(userindex).Stats.Skill21 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)



'****-********************


End Sub
Sub Pickpocket(userindex As Integer, UserTargetIndex As Integer)
On Error Resume Next

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer


Dim Luck
Dim Luck2
Dim Chance
Dim PickObj As Integer
Dim PickObj2 As Integer
Dim HaveFound As Integer

'Error trap. Dont pickpocket yourself
If UserList(userindex).UserTargetIndex = userindex Then
Call SendData(ToIndex, userindex, 0, "@You cannot pickpocket yourself !" & FONTTYPE_INFO)
Exit Sub
End If


'Dont pickpocket if your dead !
If UserList(userindex).Flags.status = 1 Then
Call SendData(ToIndex, userindex, 0, "@You`re dead and cannot do that." & FONTTYPE_INFO)
Exit Sub
End If

'Newbie protection
If UserList(UserTargetIndex).Stats.ELV < 5 Then
Call SendData(ToIndex, userindex, 0, "@This player is under level 5 and cannot be pickpocked until more experienced." & FONTTYPE_INFO)
Exit Sub
End If

For PickObj = 1 To 20

If HaveFound = 0 And UserList(UserTargetIndex).Object(PickObj).Equipped = 0 And UserList(UserTargetIndex).Object(PickObj).ObjIndex > 0 Then
PickObj2 = UserList(UserTargetIndex).Object(PickObj).ObjIndex
HaveFound = 1
End If

Next PickObj

Randomize
Luck = UserList(userindex).Stats.Skill13
If Luck <= 10 And Luck >= -1 Then Luck2 = 50
If Luck <= 20 And Luck >= 9 Then Luck2 = 45
If Luck <= 30 And Luck >= 19 Then Luck2 = 40
If Luck <= 40 And Luck >= 29 Then Luck2 = 35
If Luck <= 50 And Luck >= 39 Then Luck2 = 30
If Luck <= 60 And Luck >= 49 Then Luck2 = 25
If Luck <= 70 And Luck >= 59 Then Luck2 = 20
If Luck <= 80 And Luck >= 69 Then Luck2 = 15
If Luck <= 90 And Luck >= 79 Then Luck2 = 10
If Luck <= 999999 And Luck >= 89 Then Luck2 = 3
Chance = Int(RandomNumber(1, Luck2 - 1))

'Pickpocket the player...
If Chance = Luck2 Then
Call SendData(ToIndex, userindex, 0, "@You try to pick the person`s pocket..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@And you manage to pick an item from the person`s pocket !" & FONTTYPE_INFO)
Call SendData(ToIndex, UserTargetIndex, 0, "@You have been stolen from !" & FONTTYPE_INFO)

'Give exp
UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 2

'Remove the object from the targets backpack
UserList(UserTargetIndex).Object(PickObj).ObjIndex = 0
UserList(UserTargetIndex).Object(PickObj).Amount = 0
Call SendData(ToIndex, UserList(userindex).UserTargetIndex, 0, "PIC" & PickObj)

UserList(userindex).Community.UnderRep = UserList(userindex).Community.UnderRep + 1
UserList(userindex).Community.UnderRep = UserList(userindex).Community.CommonRep - 1
UserList(userindex).Community.UnderRep = UserList(userindex).Community.OverallRep - 1

'Check for another object on ground
If MapData(UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y).ObjInfo.ObjIndex <> 0 Then
Call SendData(ToIndex, userindex, 0, "@There is already another object at your feet." & FONTTYPE_TALK)
    Exit Sub
End If
 
 
obj.ObjIndex = PickObj2
obj.Amount = 1
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)

Else

'Dont pickpocket
Call SendData(ToIndex, userindex, 0, "@You try to pick the persons pocket..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@But you arnt sucessful ! You are cought !" & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@You are now a criminal !" & FONTTYPE_INFO)
Call SendData(ToIndex, UserTargetIndex, 0, "@Some just tried to pickpocket you but didnt succeed." & FONTTYPE_INFO)

'lower reputation
UserList(userindex).Community.OverallRep = UserList(userindex).Community.OverallRep - 2
If UserList(userindex).Community.OverallRep < 0 Then UserList(userindex).Community.OverallRep = 0
UserList(userindex).Community.NobleRep = UserList(userindex).Community.NobleRep - 2
If UserList(userindex).Community.NobleRep < 0 Then UserList(userindex).Community.NobleRep = 0
UserList(userindex).Community.CommonRep = UserList(userindex).Community.CommonRep - 2
If UserList(userindex).Community.CommonRep < 0 Then UserList(userindex).Community.CommonRep = 0

UserList(userindex).Flags.Criminal = 2
UserList(userindex).Flags.CriminalCount = UserList(userindex).Flags.CriminalCount + 20

End If


SendUserStatsBox userindex
UpdateUserInv True, userindex, 0
Call CheckRep(userindex)

'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(userindex).Stats.Skill13 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill13 Then
UserList(userindex).Stats.Skill13 = UserList(userindex).Stats.Skill13 + 1
Call SendData(ToIndex, userindex, 0, "@Your pickpocketing skill has improved (" & UserList(userindex).Stats.Skill13 & ") !" & FONTTYPE_SKILLINFO)
End If

CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)


End Sub
Sub RoastMeat(userindex As Integer, slot As Byte)
On Error Resume Next
'Begin cprocess if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 11
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill1 & "," & 11)
Call SendData(ToIndex, userindex, 0, "@You begin cooking... The blue bar represent how much time left before you are are done." & FONTTYPE_INFO)
Exit Sub
End If

Dim Raise
Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer
slot = UserList(userindex).WeaponEqpSlot

Call SendData(ToIndex, userindex, 0, "@And you manage to cook it !" & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "UWP")

'Check for another roast meat
If MapData(UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y).ObjInfo.ObjIndex <> 0 Then
Call SendData(ToIndex, userindex, 0, "@There is already something on the ground." & FONTTYPE_TALK)
Exit Sub
End If
  
If UserList(userindex).WeaponEqpObjIndex = 135 Then obj.ObjIndex = 307
If UserList(userindex).WeaponEqpObjIndex = 117 Then obj.ObjIndex = 156
obj.Amount = UserList(userindex).Object(UserList(userindex).WeaponEqpSlot).Amount
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Object(slot).ObjIndex = 0
UserList(userindex).WeaponEqpObjIndex = 0
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0

'Maybe or maybe not raise skill
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(userindex).Stats.Skill1 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill1 Then
UserList(userindex).Stats.Skill1 = UserList(userindex).Stats.Skill1 + 1
Call SendData(ToIndex, userindex, 0, "@Your cooking skill has improved (" & UserList(userindex).Stats.Skill1 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 5
CheckUserLevel (userindex)
SendUserStatsBox userindex
UpdateUserInv True, userindex, 0

End Sub

Sub Evaluate(userindex As Integer, slot As Byte)
On Error Resume Next

Dim obj As ObjData
obj = ObjData(UserList(userindex).Object(slot).ObjIndex)
Dim X As Integer
Dim Y As Integer
Dim map As Integer


Call SendData(ToIndex, userindex, 0, "@Its called " & obj.Name & " and i would assume the value is about " & obj.Value & " gold." & FONTTYPE_INFO)

'If it is clothing or armor, then tell player if it
'protects from rain (is warm)
'*CLOTHING*
If obj.ObjType = 15 Then
If obj.HandleRain > 1 Then
Call SendData(ToIndex, userindex, 0, "@Wearing this will also keep you warm, and you will not be fatigued in rain/snow." & FONTTYPE_INFO)
End If
End If

'ARMOR
If obj.ObjType = 3 Then
Call SendData(ToIndex, userindex, 0, "@The armor will add " & obj.DEF & " to your defence." & FONTTYPE_INFO)
End If


'*ARMOR*
If obj.ObjType = 3 Then
If obj.HandleRain > 1 Then
Call SendData(ToIndex, userindex, 0, "@Wearing this will also keep you warm, and you will not be fatigued in rain." & FONTTYPE_INFO)
End If
End If

'SHIELDS
If obj.ObjType = 23 Then
Call SendData(ToIndex, userindex, 0, "@The shield will add around " & obj.DEF & " to your defence." & FONTTYPE_INFO)
End If

'Weapon
If obj.ObjType = 2 Then
Call SendData(ToIndex, userindex, 0, "@The weapon will add around " & obj.MaxHIT & " to your hit power." & FONTTYPE_INFO)
End If
SendUserStatsBox userindex
UpdateUserInv True, userindex, 0



End Sub
Sub OpenBattlemode(userindex As Integer)
On Error Resume Next

UserList(userindex).Flags.Battlemode = 1
Call SendData(ToIndex, userindex, 0, "@You prepear for attack !" & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@If you seem to be unable to hit your opponent, hold in ALT and press any cursor then opposite cursor afterwards to turn back to the opponent." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "PLM" & "5")






End Sub
Sub EndBattlemode(userindex As Integer)
On Error Resume Next

Dim map As Integer
map = UserList(userindex).Pos.map

UserList(userindex).Flags.Battlemode = 0
Call SendData(ToIndex, userindex, 0, "PLM" & MapInfo(map).Music)
Call SendData(ToIndex, userindex, 0, "@You have left battlemode." & FONTTYPE_INFO)






End Sub

Sub SetCamp(userindex As Integer, map As Integer, X As Integer, Y As Integer)
On Error Resume Next

'Begin cprocess if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 13
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill24 & "," & 13)
Call SendData(ToIndex, userindex, 0, "@You begin setting the camp... The blue bar represent how much time left before you are are done." & FONTTYPE_INFO)
Exit Sub
End If

On Error Resume Next


Dim obj As obj

Dim Luck
Dim Luck2
Dim Chance


Call SendData(ToIndex, userindex, 0, "@And it ignite !" & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "TEN")

obj.ObjIndex = 155
obj.Amount = 1
Call MakeObj(ToMap, 0, map, obj, map, X, Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0



SendUserStatsBox userindex

'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 30))
If Raise = 5 And UserList(userindex).Stats.Skill24 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill24 Then
UserList(userindex).Stats.Skill24 = UserList(userindex).Stats.Skill24 + 1
Call SendData(ToIndex, userindex, 0, "@Your surviving skill has improved (" & UserList(userindex).Stats.Skill24 & ") !" & FONTTYPE_SKILLINFO)
End If

UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)


End Sub
Sub CampHeal(userindex As Integer)
On Error Resume Next

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

If UserList(userindex).Stats.MinHP < UserList(userindex).Stats.MaxHP Then
Call SendData(ToIndex, userindex, 0, "@You regain some health by sitting with the camp fire !" & FONTTYPE_INFO)
UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MinHP + UserList(userindex).Stats.MaxHP / 5
Else
Call SendData(ToIndex, userindex, 0, "@You sit by the campfire, but cannot seem to heal." & FONTTYPE_INFO)
End If

If UserList(userindex).Stats.MinSTA < UserList(userindex).Stats.MaxSTA Then
Call SendData(ToIndex, userindex, 0, "@You regain some stamina by sitting with the camp fire !" & FONTTYPE_INFO)
UserList(userindex).Stats.MinSTA = UserList(userindex).Stats.MinSTA + UserList(userindex).Stats.MaxSTA / 5
Else
Call SendData(ToIndex, userindex, 0, "@You sit by the campfire, but cannot seem to regain any stamina." & FONTTYPE_INFO)
End If

'Check to see if not get too much health and stamina
If UserList(userindex).Stats.MinHP > UserList(userindex).Stats.MaxHP Then UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MaxHP
If UserList(userindex).Stats.MinSTA > UserList(userindex).Stats.MaxSTA Then UserList(userindex).Stats.MinSTA = UserList(userindex).Stats.MaxSTA

SendUserStatsBox userindex


End Sub
Sub Chop(userindex As Integer, slot As Byte)
On Error Resume Next

'Check to see if lumberjack axe is equipped. If not, abort.
If UserList(userindex).OBJtarget > 17 Or UserList(userindex).OBJtarget < 17 Then
Exit Sub
End If

'Begin chopping process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 2
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill5 & "," & 2)
Call SendData(ToIndex, userindex, 0, "@You begin chopping on the tree. The blue bar represent how much time left before you have chopped off a log." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_CHOPPING)

'Sucessfully cut logs !
Call SendData(ToIndex, userindex, 0, "@And you manage to chop of a log !" & FONTTYPE_INFO)
 
obj.ObjIndex = 114
obj.Amount = 1
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(userindex).Stats.Skill5 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill5 Then
UserList(userindex).Stats.Skill5 = UserList(userindex).Stats.Skill5 + 1
Call SendData(ToIndex, userindex, 0, "@Your lumberjacking skill has improved (" & UserList(userindex).Stats.Skill5 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)

End Sub
Function FindDirection(Pos As WorldPos, Target As WorldPos) As Byte
On Error Resume Next
'*****************************************************************
'Returns the direction in which the Target is from the Pos, 0 if equal
'*****************************************************************
Dim X As Integer
Dim Y As Integer
 
X = Pos.X - Target.X
Y = Pos.Y - Target.Y
 
'NE
If Sgn(X) = -1 And Sgn(Y) = 1 Then
    FindDirection = NORTH
    Exit Function
End If
 
'NW
If Sgn(X) = 1 And Sgn(Y) = 1 Then
    FindDirection = WEST
    Exit Function
End If
 
'SW
If Sgn(X) = 1 And Sgn(Y) = -1 Then
    FindDirection = WEST
    Exit Function
End If
 
'SE
If Sgn(X) = -1 And Sgn(Y) = -1 Then
    FindDirection = SOUTH
    Exit Function
End If
 
'South
If Sgn(X) = 0 And Sgn(Y) = -1 Then
    FindDirection = SOUTH
    Exit Function
End If
 
'north
If Sgn(X) = 0 And Sgn(Y) = 1 Then
    FindDirection = NORTH
    Exit Function
End If
 
'West
If Sgn(X) = 1 And Sgn(Y) = 0 Then
    FindDirection = WEST
    Exit Function
End If
 
'East
If Sgn(X) = -1 And Sgn(Y) = 0 Then
    FindDirection = EAST
    Exit Function
End If
 
'Same spot
If Sgn(X) = 0 And Sgn(Y) = 0 Then
    FindDirection = 0
    Exit Function
End If
 
End Function

Sub BankWithdraw(userindex As Integer)
On Error Resume Next


Select Case UserList(userindex).NPCtarget
Case 48  'Banker
Call SendData(ToIndex, userindex, 0, "BN2")
Call SendData(ToIndex, userindex, 0, "@The banker responds, Ok. Here ye go." & FONTTYPE_TALK)
End Select







End Sub

Sub BankDeposit(userindex As Integer)
On Error Resume Next

Select Case UserList(userindex).NPCtarget
Case 48  'Banker
Call SendData(ToIndex, userindex, 0, "BN1")
Call SendData(ToIndex, userindex, 0, "@The banker responds, Ok. Here ye go." & FONTTYPE_TALK)
End Select







End Sub
Sub BankBalance(userindex As Integer)
On Error Resume Next

Select Case UserList(userindex).NPCtarget
Case 48  'Banker
Call SendData(ToIndex, userindex, 0, "@The banker responds, Thee have " & UserList(userindex).Stats.BANKGLD & " gold in the bank !" & FONTTYPE_TALK)
End Select

End Sub
Sub CreatePlanks(userindex As Integer, slot As Byte)
On Error Resume Next

'Check to see if have enough ore
If UserList(userindex).Object(slot).Amount < 2 Then
Call SendData(ToIndex, userindex, 0, "@You do not have enough logs to make this." & FONTTYPE_INFO)
Exit Sub
End If

'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 4
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill4 & "," & 4)
Call SendData(ToIndex, userindex, 0, "@You begin sawing to make planks. The blue bar represent how much time left before you are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_SAW)

'Sucessfull !
Call SendData(ToIndex, userindex, 0, "@And you manage to create planks !" & FONTTYPE_INFO)
 
 
obj.ObjIndex = 148
obj.Amount = 4
UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - 2
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(userindex).Stats.Skill4 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill4 Then
UserList(userindex).Stats.Skill4 = UserList(userindex).Stats.Skill4 + 1
Call SendData(ToIndex, userindex, 0, "@Your carpenting skill has improved (" & UserList(userindex).Stats.Skill4 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, slot)


End Sub

Sub CreateFoldedCloth(userindex As Integer, slot As Byte)
On Error Resume Next

'Check to see if have enough material
If UserList(userindex).Object(slot).Amount < 2 Then
Call SendData(ToIndex, userindex, 0, "@You do not have enough hide to make this." & FONTTYPE_INFO)
Exit Sub
End If

'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 3
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill3 & "," & 3)
Call SendData(ToIndex, userindex, 0, "@You begin creating foldec cloth. The blue bar represent how much time left before you are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff

Open App.Path & "\Log.txt" For Append Shared As #5
Print #5, "tailor"
Close #5

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_FOLDCLOTHING)

'Sucessfull !
Call SendData(ToIndex, userindex, 0, "@And you manage to create some folded cloth !" & FONTTYPE_INFO)
 
 
obj.ObjIndex = 151
obj.Amount = 4
UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - 2
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(userindex).Stats.Skill3 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill3 Then
UserList(userindex).Stats.Skill3 = UserList(userindex).Stats.Skill3 + 1
Call SendData(ToIndex, userindex, 0, "@Your tailoring skill has improved (" & UserList(userindex).Stats.Skill3 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, slot)

End Sub

Sub CreateSteel(userindex As Integer, slot As Byte)
On Error Resume Next

'Check to see if have enough ore
If UserList(userindex).Object(slot).Amount < 2 Then
Call SendData(ToIndex, userindex, 0, "@You do not have enough ore to make this." & FONTTYPE_INFO)
Exit Sub
End If

'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 5
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill9 & "," & 5)
Call SendData(ToIndex, userindex, 0, "@You begin smithing to make steel out of the ore. The blue bar represent how much time left before you are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_SMITHING)

'Sucessfull !
Call SendData(ToIndex, userindex, 0, "@And you manage to create steel !" & FONTTYPE_INFO)
 
 
obj.ObjIndex = 153
obj.Amount = 4
UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - 2
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(userindex).Stats.Skill9 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill9 Then
UserList(userindex).Stats.Skill9 = UserList(userindex).Stats.Skill9 + 1
Call SendData(ToIndex, userindex, 0, "@Your blacksmithing skill has improved (" & UserList(userindex).Stats.Skill9 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, slot)

End Sub

Sub MakeCarpentryObj(userindex As Integer, slot As Byte)

'Check if skill to make this item is good enough
'(to prevent the newbie make golden sword syndrome)
If UserList(userindex).Throw.skill > UserList(userindex).Stats.Skill4 Then
Call SendData(ToIndex, userindex, 0, "@Your do not have enough carpenting skill to make this item. You need atleast " & UserList(userindex).Throw.skill & " skill points to make this item." & FONTTYPE_INFO)
Exit Sub
End If

On Error Resume Next

If UserList(userindex).Object(slot).Amount < UserList(userindex).Throw.NeedPlanks Then
Call SendData(ToIndex, userindex, 0, "@You do not have enough planks to make this object." & FONTTYPE_INFO)
Exit Sub
End If


'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 9
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill4 & "," & 9)
Call SendData(ToIndex, userindex, 0, "@You begin making the object. The blue bar represent how much time left before you are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_SAW)

'Sucessfull !
Call SendData(ToIndex, userindex, 0, "@And you manage to create it!" & FONTTYPE_INFO)
 
UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - UserList(userindex).Throw.NeedPlanks
obj.ObjIndex = UserList(userindex).Throw.MakeItem
obj.Amount = 1
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 4))
If Raise = 5 And UserList(userindex).Stats.Skill4 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill4 Then
UserList(userindex).Stats.Skill4 = UserList(userindex).Stats.Skill4 + 1
Call SendData(ToIndex, userindex, 0, "@Your carpenting skill has improved (" & UserList(userindex).Stats.Skill4 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, slot)


End Sub

Sub MakeTailoringObj(userindex As Integer, slot As Byte)
On Error Resume Next

'Check if skill to make this item is good enough
'(to prevent the newbie make golden sword syndrome)
If UserList(userindex).Throw.skill > UserList(userindex).Stats.Skill3 Then
Call SendData(ToIndex, userindex, 0, "@Your do not have enough tailoring skill to make this item. You need atleast " & UserList(userindex).Throw.skill & " skill points to make this item." & FONTTYPE_INFO)
Exit Sub
End If

If UserList(userindex).Object(slot).Amount < UserList(userindex).Throw.NeedFoldedCloth Then
Call SendData(ToIndex, userindex, 0, "@You do not have enough folded cloth to make this object." & FONTTYPE_INFO)
Exit Sub
End If


'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 10
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill3 & "," & 10)
Call SendData(ToIndex, userindex, 0, "@You begin making the object. The blue bar represent how much time left before you are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_FOLDCLOTHING)

'Sucessfull !
Call SendData(ToIndex, userindex, 0, "@And you manage to create it!" & FONTTYPE_INFO)
 
UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - UserList(userindex).Throw.NeedFoldedCloth
obj.ObjIndex = UserList(userindex).Throw.MakeItem
obj.Amount = 1
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 4))
If Raise = 5 And UserList(userindex).Stats.Skill3 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill3 Then
UserList(userindex).Stats.Skill3 = UserList(userindex).Stats.Skill3 + 1
Call SendData(ToIndex, userindex, 0, "@Your tailoring skill has improved (" & UserList(userindex).Stats.Skill3 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, slot)


End Sub

Sub MakeBlacksmithingObj(userindex As Integer, slot As Byte)

'Check if skill to make this item is good enough
'(to prevent the newbie make golden sword syndrome)
If UserList(userindex).Throw.skill > UserList(userindex).Stats.Skill9 Then
Call SendData(ToIndex, userindex, 0, "@Your do not have enough blacksmithing skill to make this item. You need atleast " & UserList(userindex).Throw.skill & " skill points to make this item." & FONTTYPE_INFO)
Exit Sub
End If

On Error Resume Next

'Check to see if have enough steel
If UserList(userindex).Object(slot).Amount < UserList(userindex).Throw.NeedSteel Then
Call SendData(ToIndex, userindex, 0, "@You do not have enough steel to make this object." & FONTTYPE_INFO)
Exit Sub
End If


'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 8
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill9 & "," & 8)
Call SendData(ToIndex, userindex, 0, "@You begin smithing. The blue bar represent how much time left before you are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_SMITHING)

'Sucessfull !
Call SendData(ToIndex, userindex, 0, "@And you manage to create it !" & FONTTYPE_INFO)
 
 
UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - UserList(userindex).Throw.NeedSteel
obj.ObjIndex = UserList(userindex).Throw.MakeItem
obj.Amount = 1
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 4))
If Raise = 5 And UserList(userindex).Stats.Skill9 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill9 Then
UserList(userindex).Stats.Skill9 = UserList(userindex).Stats.Skill9 + 1
Call SendData(ToIndex, userindex, 0, "@Your blacksmithing skill has improved (" & UserList(userindex).Stats.Skill9 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, slot)


End Sub

Sub CastSpellAtPC(userindex As Integer, slot As Byte)


Dim CanCast As Integer

Open App.Path & "\Log.txt" For Append Shared As #5
Print #5, "castspellatpc"
Close #5

On Error Resume Next
Call UpdateUserSpell(True, userindex, 1)

'First of all check to see if have target so
'there is no server crash
If UserList(userindex).UserTargetIndex = 0 Then
Call SendData(ToIndex, userindex, 0, "@You have no target !" & FONTTYPE_INFO)
Exit Sub
End If

'Initialize the spell thats marked
Dim Spell As SpellData
Dim UserTargetIndex As Integer
Dim obj As obj
Spell = SpellData(UserList(userindex).SpellObj(slot).SpellIndex)
UserTargetIndex = UserList(userindex).UserTargetIndex
Dim obj2 As ObjData
obj2 = ObjData(UserList(UserTargetIndex).Object(UserList(UserTargetIndex).ClothingEqpSlot).ObjIndex)

'Check to see if it isnt a gamemaster
If Spell.Destruction = 1 And UserList(UserList(userindex).UserTargetIndex).Flags.Immortal = 0 Then
Call SendData(ToIndex, userindex, 0, "@Your attack is prevented ! This person is under the protection of the gods !" & FONTTYPE_INFO)
Exit Sub
End If

'Make sure its not a PK freezone
If MapInfo(UserList(userindex).Pos.map).PKFREEZONE = 1 Then
If UserList(userindex).Flags.Duel = 0 Or UserList(UserList(userindex).UserTargetIndex).Flags.Duel = 0 Then
Call SendData(ToIndex, userindex, 0, "@This is a Player Killing free area. Both players must be in duel mode (/DUEL) to fight here !")
Exit Sub
End If
End If

'Make sure player is alive if spell is destructive
If Spell.Destruction = 1 And UserList(userindex).Flags.status = 1 Then
Call SendData(ToIndex, userindex, 0, "@You cannot cast destruction spells when dead." & FONTTYPE_INFO)
Exit Sub
End If

'Check if right school of magic
If UserList(userindex).MagicSchool = Spell.School1 Then CanCast = 1
If UserList(userindex).MagicSchool = Spell.School2 Then CanCast = 1
If UserList(userindex).MagicSchool = Spell.School3 Then CanCast = 1

If CanCast = 0 Then
Call SendData(ToIndex, userindex, 0, "@You cannot cast this spell because it's not in your school of magic !" & FONTTYPE_INFO)
Exit Sub
End If

CanCast = 0

'Check if player has enough mana to cast the spell
If Spell.NeedsMana > UserList(userindex).Stats.MinMAN Then
Call SendData(ToIndex, userindex, 0, "@You dont have enough mana to cast the spell." & FONTTYPE_INFO)
Exit Sub
End If

'Substract spell mana need from players mana
UserList(userindex).Stats.MinMAN = UserList(userindex).Stats.MinMAN - Spell.NeedsMana

'Do spell sound
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & Spell.Sound)

'Give HP
If Spell.GiveHp > 0 Then
UserList(UserTargetIndex).Stats.MaxHP = UserList(UserTargetIndex).Stats.MaxHP + Spell.GiveHp
End If

'Give MANA
If Spell.GiveMan > 0 Then
UserList(UserTargetIndex).Stats.MaxMAN = UserList(UserTargetIndex).Stats.MaxMAN + Spell.GiveMan
End If

'Give Fatigue
If Spell.GiveFat > 0 Then
UserList(UserTargetIndex).Stats.MaxSTA = UserList(UserTargetIndex).Stats.MaxSTA + Spell.GiveFat
End If

'Give Money
If Spell.GiveMoney > 0 Then
UserList(UserTargetIndex).Stats.GLD = UserList(UserTargetIndex).Stats.GLD + Spell.GiveMoney
End If

'Give Food
If Spell.GiveFood > 0 Then
UserList(UserTargetIndex).Stats.Food = UserList(UserTargetIndex).Stats.Food + Spell.GiveFood
End If

'Give Drink
If Spell.GiveDrink > 0 Then
UserList(UserTargetIndex).Stats.Drink = UserList(UserTargetIndex).Stats.Drink + Spell.GiveDrink
End If

'Give EXP
If Spell.GiveEXP > 0 Then
UserList(UserTargetIndex).Stats.EXP = UserList(UserTargetIndex).Stats.EXP + Spell.GiveEXP
End If

'Heal HP
If Spell.HealHP > 0 Then
UserList(UserTargetIndex).Stats.MinHP = UserList(UserTargetIndex).Stats.MaxHP
End If

'Heal Mana
If Spell.HealMan > 0 Then
UserList(UserTargetIndex).Stats.MinMAN = UserList(UserTargetIndex).Stats.MaxMAN
End If

'Heal fatigue
If Spell.HealFat > 0 Then
UserList(UserTargetIndex).Stats.MinSTA = UserList(UserTargetIndex).Stats.MaxSTA
End If

'Damage HP
If Spell.DamageHp > 0 Then
UserList(UserTargetIndex).Stats.MinHP = UserList(UserTargetIndex).Stats.MinHP - Spell.DamageHp
End If

'Damage Mana
If Spell.DamageMan > 0 Then
UserList(UserTargetIndex).Stats.MinMAN = UserList(UserTargetIndex).Stats.MinMAN - Spell.DamageMan
End If

'Damage Fatigue
If Spell.DamageFat > 0 Then
UserList(UserTargetIndex).Stats.MinSTA = UserList(UserTargetIndex).Stats.MinSTA - Spell.DamageFat
End If

'Create object
If Spell.CreateObj > 0 Then
obj.ObjIndex = Spell.CreateObj
obj.Amount = 1
Call MakeObj(ToMap, 0, UserList(UserTargetIndex).Pos.map, obj, UserList(UserTargetIndex).Pos.map, UserList(UserTargetIndex).Pos.X, UserList(UserTargetIndex).Pos.Y)
End If

'Teleporting/Anchoring
If Spell.Teleport = 1 Then

If UserList(UserTargetIndex).Stats.Anchor = 0 Then
Call SendData(ToIndex, UserTargetIndex, 0, "@You are anchored here. To teleport back to here, recast the teleport spell." & FONTTYPE_INFO)
UserList(UserTargetIndex).Stats.Telemap = UserList(UserTargetIndex).Pos.map
UserList(UserTargetIndex).Stats.TeleX = UserList(UserTargetIndex).Pos.X
UserList(UserTargetIndex).Stats.TeleY = UserList(UserTargetIndex).Pos.Y
Else
Call SendData(ToIndex, UserTargetIndex, 0, "@You teleport back to the anchored position. You will not have to reset an anchor." & FONTTYPE_INFO)
Call WarpUserChar(UserTargetIndex, UserList(UserTargetIndex).Stats.Telemap, UserList(UserTargetIndex).Stats.TeleX, UserList(UserTargetIndex).Stats.TeleY)
UserList(UserTargetIndex).Stats.Anchor = 0
End If

End If

'RESSURECTION

If Spell.Ressurection = 1 Then
UserList(UserTargetIndex).Flags.status = 0
UserList(UserTargetIndex).Char.Body = obj2.ClothingType
UserList(UserTargetIndex).Char.Head = UserList(UserTargetIndex).Flags.StartHead
Call ChangeUserChar(ToMap, 0, UserList(UserTargetIndex).Pos.map, UserTargetIndex, UserList(UserTargetIndex).Char.Body, UserList(UserTargetIndex).Char.Head, UserList(UserTargetIndex).Char.Heading, UserList(UserTargetIndex).Char.WeaponAnim, UserList(UserTargetIndex).Char.ShieldAnim)
Call SendData(ToPCArea, UserTargetIndex, UserList(UserTargetIndex).Pos.map, "PLW" & SOUND_CHORUS)
End If

'Send message to caster
Call SendData(ToIndex, userindex, 0, "@" & Spell.CasterMessage & FONTTYPE_INFO)

'Send message to target
Call SendData(ToIndex, UserTargetIndex, 0, "@" & Spell.TargetMessage & FONTTYPE_INFO)

'User Die
If UserList(UserTargetIndex).Stats.MinHP <= 0 Then
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_MALEHURT2)

'Checks to see if the victim was a criminal or not
'If the victim wasnt a criminal, then attacker become one.
If UserList(UserTargetIndex).Flags.Criminal = 0 And UserList(UserTargetIndex).Flags.Duel = 0 Then
UserList(userindex).Flags.CriminalCount = UserList(userindex).Flags.CriminalCount + 30
Call SendData(ToIndex, userindex, 0, "@You have killed another person which was not a criminal ! You are now a criminal !" & FONTTYPE_INFO)
Call SendData(ToIndex, UserTargetIndex, 0, "@You have been killed by another player unrightfully ! You was not a criminal, and therefore your murderer is now a criminal !" & FONTTYPE_INFO)
'Lower murderers reputation
UserList(userindex).Community.CommonRep = UserList(userindex).Community.CommonRep - 5
UserList(userindex).Community.NobleRep = UserList(userindex).Community.NobleRep - 5
UserList(userindex).Community.OverallRep = UserList(userindex).Community.OverallRep - 5
'Raise underworld rep
UserList(userindex).Community.UnderRep = UserList(userindex).Community.UnderRep + 3
UserList(userindex).Community.BendarrRep = UserList(userindex).Community.BendarrRep + 3
UserList(userindex).Flags.Criminal = 2
UserList(userindex).Flags.CriminalCount = UserList(userindex).Flags.CriminalCount + 45
Call SendData(ToIndex, userindex, 0, "@You gain reputation with Bendarr and the underworld ! You also lose some reputation with the Nobles and the common people." & FONTTYPE_INFO)
Else
'Rais rep since victim was either criminal or it was a duel
UserList(userindex).Community.OverallRep = UserList(userindex).Community.OverallRep + 2
UserList(userindex).Community.CommonRep = UserList(userindex).Community.CommonRep + 2
Call SendData(ToIndex, userindex, 0, "@You gain some reputation with common people !" & FONTTYPE_INFO)
End If

    'Give EXP and gold
    UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + (UserList(UserTargetIndex).Stats.ELV * 20)
    Call SendData(ToIndex, userindex, 0, "@You have gained " & UserList(userindex).Stats.EXP + (UserList(UserTargetIndex).Stats.ELV * 20) & " experience !" & FONTTYPE_INFO)
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(UserTargetIndex).Name & " has been slain by " & UserList(userindex).Name & " !")

    'Kill user
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " has slain " & UserList(UserTargetIndex).Name & " !" & FONTTYPE_INFO)
    UserList(userindex).Flags.Strike = 0
    
UserList(userindex).Npcindex = 0
UserList(userindex).NPCtarget = 0
UserList(userindex).UserTargetIndex = 0

    UserDie UserTargetIndex

End If

UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 2
CheckUserLevel (userindex)
SendUserStatsBox (userindex)
Call UpdateUserSpell(True, userindex, 1)

End Sub
Sub CastSpellAtNPC(userindex As Integer, slot As Byte)
Dim CanCast As Integer

On Error Resume Next

Call UpdateUserSpell(True, userindex, 1)

'First of all check to see if have target so
'there is no server crash
If UserList(userindex).UserTargetIndex = 0 Then
Call SendData(ToIndex, userindex, 0, "@You have no target !" & FONTTYPE_INFO)
Exit Sub
End If

'Initialize the spell thats marked
Dim Spell As SpellData
Dim UserTargetIndex As Integer
Dim obj As obj
Spell = SpellData(UserList(userindex).SpellObj(slot).SpellIndex)
UserTargetIndex = UserList(userindex).UserTargetIndex

'Dont cast of non-attackable
If NPCList(UserTargetIndex).Attackable = 0 Then
Call SendData(ToIndex, userindex, 0, "@A mysterious force prevents you from casting a spell at " & NPCList(UserTargetIndex).Name & " !" & FONTTYPE_INFO)
Exit Sub
End If

'Make sure player is alive if spell is destructive
If Spell.Destruction = 1 And UserList(userindex).Flags.status = 1 Then
Call SendData(ToIndex, userindex, 0, "@You cannot cast destruction spells when dead." & FONTTYPE_INFO)
Exit Sub
End If


'Check if right school of magic
If UserList(userindex).MagicSchool = Spell.School1 Then CanCast = 1
If UserList(userindex).MagicSchool = Spell.School2 Then CanCast = 1
If UserList(userindex).MagicSchool = Spell.School3 Then CanCast = 1

If CanCast = 0 Then
Call SendData(ToIndex, userindex, 0, "@You cannot cast this spell because it's not in your school of magic !" & FONTTYPE_INFO)
Exit Sub
End If

CanCast = 0

'Check if player has enough mana to cast the spell
If Spell.NeedsMana > UserList(userindex).Stats.MinMAN Then
Call SendData(ToIndex, userindex, 0, "@You dont have enough mana to cast the spell." & FONTTYPE_INFO)
Exit Sub
End If

'substract mana from players mana pool...
UserList(userindex).Stats.MinMAN = UserList(userindex).Stats.MinMAN - Spell.NeedsMana


'Make NPC hostile
NPCList(UserTargetIndex).Hostile = 1
If NPCList(UserTargetIndex).Guard = 1 Then
UserList(userindex).Flags.Criminal = 2
Call SendData(ToIndex, userindex, 0, "@You are now a criminal !" & FONTTYPE_INFO)
NPCList(UserTargetIndex).Hostile = 0
End If

'Do spell sound
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & Spell.Sound)


'Give HP
If Spell.GiveHp > 0 Then
NPCList(UserTargetIndex).Stats.MaxHP = NPCList(UserTargetIndex).Stats.MaxHP + Spell.GiveHp
End If

'Heal HP
If Spell.HealHP > 0 Then
NPCList(UserTargetIndex).Stats.MinHP = NPCList(UserTargetIndex).Stats.MaxHP
End If

'Damage HP
If Spell.DamageHp > 0 Then
NPCList(UserTargetIndex).Stats.MinHP = NPCList(UserTargetIndex).Stats.MinHP - Spell.DamageHp
End If

'Send message to caster
Call SendData(ToIndex, userindex, 0, "@" & Spell.CasterMessage & FONTTYPE_INFO)


'NPC Die
If NPCList(UserTargetIndex).Stats.MinHP <= 0 Then
  
  
UserList(userindex).Npcindex = 0
UserList(userindex).NPCtarget = 0
UserList(userindex).UserTargetIndex = 0
  
    'Kill it
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " has slain " & NPCList(UserTargetIndex).Name & " !" & FONTTYPE_INFO)
    UserList(userindex).Flags.Strike = 0
    If NPCList(UserTargetIndex).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(UserTargetIndex).Flags.Sound)
 
 'Give EXP
    UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + NPCList(UserTargetIndex).GiveEXP
    UserList(userindex).Flags.LastExp = NPCList(UserTargetIndex).GiveEXP
 
    'Give gold
    UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + NPCList(UserTargetIndex).GiveGLD
    Call SendData(ToIndex, userindex, 0, "@You found " & NPCList(UserTargetIndex).GiveGLD & " gold on the corpse !" & FONTTYPE_INFO)
            
    'Reduce reputation and make criminal if NPC
    'was a guard. Raise underworld rep.
    If NPCList(UserTargetIndex).Guard = 1 And Spell.Destruction = 1 Then
    UserList(userindex).Flags.Criminal = 2
    Call SendData(ToIndex, userindex, 0, "@Killing a guard ?! You are now a criminal !" & FONTTYPE_INFO)
    UserList(userindex).Community.NobleRep = UserList(userindex).Community.NobleRep - 5
    UserList(userindex).Community.BendarrRep = UserList(userindex).Community.BendarrRep + 2
    UserList(userindex).Community.OverallRep = UserList(userindex).Community.OverallRep - 5
    UserList(userindex).Community.UnderRep = UserList(userindex).Community.UnderRep + 3
    UserList(userindex).Community.CommonRep = UserList(userindex).Community.CommonRep - 3
    Call SendData(ToIndex, userindex, 0, "@You lose some reputation with the Nobles and the common people. You gain reputation with Bendarr and the underworld !" & FONTTYPE_INFO)
    Call CheckRep(userindex)
    Else
    'Give positive reputation
    UserList(userindex).Community.CommonRep = UserList(userindex).Community.CommonRep + 1
    UserList(userindex).Community.NobleRep = UserList(userindex).Community.NobleRep + 1
    UserList(userindex).Community.NobleRep = UserList(userindex).Community.OverallRep + 1
    Call SendData(ToIndex, userindex, 0, "@You gain reputation with the Nobles and the common people !" & FONTTYPE_INFO)
    Call CheckRep(userindex)
    End If
        
    
    Call NPCDie(UserTargetIndex, userindex)
    
    
    End If

UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 2
CheckUserLevel (userindex)
SendUserStatsBox (userindex)
Call UpdateUserSpell(True, userindex, 1)

End Sub


Sub NPCSellItem(userindex As Integer, Npcindex As Integer, slot As Byte)
On Error Resume Next

'Make some stuff clear...
Npcindex = UserList(userindex).Npcindex
Dim obj As ObjData
Dim objo As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer
Dim sloto As Byte
Dim NpcWillTake As Long
Dim RepGold As Integer

obj = ObjData(NPCList(Npcindex).Object(slot).ObjIndex)

Dim Luck As Integer
Dim Luck2 As String

Luck = UserList(userindex).Stats.Skill8
If Luck <= 10 And Luck >= -1 Then Luck2 = 5
If Luck <= 20 And Luck >= 9 Then Luck2 = 5
If Luck <= 30 And Luck >= 19 Then Luck2 = 4.5
If Luck <= 40 And Luck >= 29 Then Luck2 = 4
If Luck <= 50 And Luck >= 39 Then Luck2 = 3.5
If Luck <= 60 And Luck >= 49 Then Luck2 = 3
If Luck <= 70 And Luck >= 59 Then Luck2 = 2.5
If Luck <= 80 And Luck >= 69 Then Luck2 = 2
If Luck <= 99 And Luck >= 79 Then Luck2 = 1.5
If Luck <= 999999 And Luck >= 99 Then Luck2 = 1

If obj.Value > 20 Then
NpcWillTake = obj.Value * Luck2
Else
NpcWillTake = obj.Value
End If


'Check to see if user is morphed
If UserList(userindex).Flags.Morphed = 1 Then
Call SendData(ToIndex, userindex, 0, "@You cannot do this when you are morphed." & FONTTYPE_INFO)
Exit Sub
End If

'Error trap
If NPCList(Npcindex).Object(slot).ObjIndex = 0 Then
Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " says, Err...what do you want to buy again ?" & FONTTYPE_TALK)
Exit Sub
End If

If UserList(userindex).Stats.GLD < NpcWillTake Then
Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " says, You do not have enough gold !" & FONTTYPE_TALK)
Exit Sub
End If

'NPC SELL ITEM TO PLAYER NOW
sloto = 1
Do Until UserList(userindex).Object(sloto).ObjIndex = NPCList(Npcindex).Object(slot).ObjIndex
    sloto = sloto + 1

    If sloto > MAX_INVENTORY_SLOTS Then
        Exit Do
    End If
Loop

'Else check if there is a empty slot
If sloto > MAX_INVENTORY_SLOTS Then
        sloto = 1
        Do Until UserList(userindex).Object(sloto).ObjIndex = 0
            sloto = sloto + 1

            If sloto > MAX_INVENTORY_SLOTS Then
                Call SendData(ToIndex, userindex, 0, "@You cannot hold any more items now !" & FONTTYPE_INFO)
                Exit Sub
                Exit Do
            End If
        Loop
End If

'HAND OBJECT TO PLAYER

UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - NpcWillTake

Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " says, you want this fine item ! Deal !" & FONTTYPE_TALK)
Call SendData(ToIndex, userindex, 0, "@You pay " & NpcWillTake & " gold." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "PLW" & SOUND_COINS)

UserList(userindex).Object(sloto).ObjIndex = NPCList(Npcindex).Object(slot).ObjIndex
UserList(userindex).Object(sloto).Amount = UserList(userindex).Object(sloto).Amount + 1
  
'Add to NPC gold pile
NPCList(Npcindex).Gold = NPCList(Npcindex).Gold + NpcWillTake


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 30))
If Raise = 5 And UserList(userindex).Stats.Skill8 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill8 Then
UserList(userindex).Stats.Skill8 = UserList(userindex).Stats.Skill8 + 1
Call SendData(ToIndex, userindex, 0, "@Your merchant skill has improved (" & UserList(userindex).Stats.Skill8 & ") !" & FONTTYPE_SKILLINFO)
End If

CheckUserLevel (userindex)
Call UpdateUserInv(True, userindex, sloto)
SendUserStatsBox userindex






End Sub

Sub NPCBuyItem(userindex As Integer, Npcindex As Integer, slot As Byte)
On Error Resume Next

'Make some stuff clear...
Npcindex = UserList(userindex).Npcindex
Dim obj As ObjData
Dim X As Integer
Dim Y As Integer
Dim map As Integer
Dim NpcWillTake As Long
Dim WillBuy As Integer

obj = ObjData(UserList(userindex).Object(slot).ObjIndex)

Dim Luck
Dim Luck2 As String

'The ALL category
If NPCList(Npcindex).Flags.Category1 = "All" Then
WillBuy = 1
End If

'The NOTHING category
If NPCList(Npcindex).Flags.Category1 = "Nothing" Then
Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " says, Im not interested in any trading." & FONTTYPE_TALK)
Exit Sub
End If

'Check if NPC buy such item
If obj.Category = NPCList(Npcindex).Flags.Category1 Then
WillBuy = 1
Else
If obj.Category = NPCList(Npcindex).Flags.Category2 Then
WillBuy = 1
Else
If obj.Category = NPCList(Npcindex).Flags.Category3 Then
WillBuy = 1
Else
If obj.Category = NPCList(Npcindex).Flags.Category4 Then
WillBuy = 1
Else
If obj.Category = NPCList(Npcindex).Flags.Category5 Then
WillBuy = 1
End If
End If
End If
End If
End If

If WillBuy = 0 Then
Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " says, I have no interest in an item of such type." & FONTTYPE_TALK)
Exit Sub
End If

Randomize
Luck = UserList(userindex).Stats.Skill8
If Luck <= 10 And Luck >= -1 Then Luck2 = 5
If Luck <= 20 And Luck >= 9 Then Luck2 = 5
If Luck <= 30 And Luck >= 19 Then Luck2 = 4.5
If Luck <= 40 And Luck >= 29 Then Luck2 = 4
If Luck <= 50 And Luck >= 39 Then Luck2 = 3.5
If Luck <= 60 And Luck >= 49 Then Luck2 = 3
If Luck <= 70 And Luck >= 59 Then Luck2 = 2.5
If Luck <= 80 And Luck >= 69 Then Luck2 = 2
If Luck <= 99 And Luck >= 79 Then Luck2 = 1.5
If Luck <= 999999 And Luck >= 99 Then Luck2 = 1

If obj.Value > 20 Then
NpcWillTake = obj.Value / Luck2
Else
NpcWillTake = obj.Value
End If

'Check to see if user is morphed
If UserList(userindex).Flags.Morphed = 1 Then
Call SendData(ToIndex, userindex, 0, "@You cannot do this when you are morphed." & FONTTYPE_INFO)
Exit Sub
End If

'Error trap
If UserList(userindex).Object(slot).ObjIndex = 0 Then
Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " says, Buy what ?!" & FONTTYPE_TALK)
Exit Sub
End If

'Check to see if NPC has enough gold
If NPCList(Npcindex).Gold < NpcWillTake Then
Call SendData(ToIndex, userindex, 0, "@I cannot afford this im afraid !" & FONTTYPE_INFO)
Exit Sub
End If

'NPC DONT BUY IF NO VALUE IN IT
If obj.Value = 0 Then
Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " says, I have no need for this item." & FONTTYPE_TALK)
Exit Sub
End If

'NPC dont buy if not sellable
If obj.Sellable = 1 Then
Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " says, i have no interest in this item." & FONTTYPE_TALK)
Exit Sub
End If

If UserList(userindex).Object(slot).Amount > 1 Then
UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - 1
UserList(userindex).Object(slot).Equipped = 0
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + NpcWillTake
Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " gives you " & NpcWillTake & " gold for the " & obj.Name & FONTTYPE_TALK)
Call SendData(ToIndex, userindex, 0, "PLW" & SOUND_COINS)
Else
UserList(userindex).Object(slot).ObjIndex = 0
UserList(userindex).Object(slot).Amount = 0
UserList(userindex).Object(slot).Equipped = 0
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + NpcWillTake
Call SendData(ToIndex, userindex, 0, "@" & NPCList(Npcindex).Name & " gives you " & NpcWillTake & " gold for the " & obj.Name & FONTTYPE_TALK)
Call SendData(ToIndex, userindex, 0, "PLW" & SOUND_COINS)
End If

'Substract gold from NPC`s gold pile
NPCList(Npcindex).Gold = NPCList(Npcindex).Gold - NpcWillTake

'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 150))
If Raise = 5 And UserList(userindex).Stats.Skill8 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill8 Then
UserList(userindex).Stats.Skill8 = UserList(userindex).Stats.Skill8 + 1
Call SendData(ToIndex, userindex, 0, "@Your merchant skill has improved (" & UserList(userindex).Stats.Skill8 & ") !" & FONTTYPE_SKILLINFO)
End If


CheckUserLevel (userindex)
Call UpdateUserInv(True, userindex, 0)
SendUserStatsBox userindex






End Sub
Sub DropGold(userindex As Integer, Gold As Long)
On Error Resume Next

Dim obj As obj

If Gold > 0 Then
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - Gold
obj.ObjIndex = 193
obj.Amount = Gold
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
End If

SendUserStatsBox (userindex)

End Sub

Sub BackstabPC(attackerindex As Integer, victimindex As Integer)
On Error Resume Next

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Dim Luck
Dim Luck2
Dim Chance

Randomize
Luck = UserList(attackerindex).Stats.Skill22
If Luck <= 10 And Luck >= -1 Then Luck2 = 50
If Luck <= 20 And Luck >= 9 Then Luck2 = 45
If Luck <= 30 And Luck >= 19 Then Luck2 = 40
If Luck <= 40 And Luck >= 29 Then Luck2 = 35
If Luck <= 50 And Luck >= 39 Then Luck2 = 30
If Luck <= 60 And Luck >= 49 Then Luck2 = 25
If Luck <= 70 And Luck >= 59 Then Luck2 = 20
If Luck <= 80 And Luck >= 69 Then Luck2 = 15
If Luck <= 90 And Luck >= 79 Then Luck2 = 10
If Luck <= 999999 And Luck >= 89 Then Luck2 = 3
Chance = Int(RandomNumber(1, Luck2))

'Backstab !
If Chance = Luck2 Then
Call SendData(ToIndex, attackerindex, 0, "@You successfully backstabbed your vitim !" & FONTTYPE_FIGHT)
Call SendData(ToIndex, victimindex, 0, "@You were backstabbed !" & FONTTYPE_FIGHT)
'Cause victim hurt
NPCList(victimindex).Stats.MinHP = NPCList(victimindex).Stats.MinHP - 5
Else

'Dont backstab

End If



'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(attackerindex).Stats.Skill22 > 9 And LevelSkill(UserList(attackerindex).Stats.ELV).LevelValue > UserList(attackerindex).Stats.Skill22 Then
UserList(attackerindex).Stats.Skill22 = UserList(attackerindex).Stats.Skill22 + 1
Call SendData(ToIndex, attackerindex, 0, "@Your backstabbing skill has improved (" & UserList(attackerindex).Stats.Skill22 & ") !" & FONTTYPE_SKILLINFO)
End If

SendUserStatsBox (attackerindex)
SendUserStatsBox (victimindex)




End Sub

Sub BackstabNPC(userindex As Integer, Npcindex As Integer)
On Error Resume Next


Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Dim Luck
Dim Luck2
Dim Chance

Randomize
Luck = UserList(userindex).Stats.Skill22
If Luck <= 10 And Luck >= -1 Then Luck2 = 30
If Luck <= 20 And Luck >= 9 Then Luck2 = 25
If Luck <= 30 And Luck >= 19 Then Luck2 = 22
If Luck <= 40 And Luck >= 29 Then Luck2 = 20
If Luck <= 50 And Luck >= 39 Then Luck2 = 17
If Luck <= 60 And Luck >= 49 Then Luck2 = 15
If Luck <= 70 And Luck >= 59 Then Luck2 = 12
If Luck <= 80 And Luck >= 69 Then Luck2 = 10
If Luck <= 90 And Luck >= 79 Then Luck2 = 6
If Luck <= 999999 And Luck >= 89 Then Luck2 = 3
Chance = Int(RandomNumber(1, Luck2))

'Backstab !
If Chance = Luck2 Then

'Cause victim hurt
NPCList(Npcindex).Stats.MinHP = NPCList(Npcindex).Stats.MinHP - 8
Call SendData(ToIndex, userindex, 0, "@You backstab " & NPCList(Npcindex).Name & " for 8 points of damage !" & FONTTYPE_INFO)

Else

'Dont backstab
Call SendData(ToIndex, userindex, 0, "@You fail in backstabbing " & NPCList(Npcindex).Name & FONTTYPE_INFO)

End If
    
'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 7))
If Raise = 5 And UserList(userindex).Stats.Skill22 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill22 Then
UserList(userindex).Stats.Skill22 = UserList(userindex).Stats.Skill22 + 1
Call SendData(ToIndex, userindex, 0, "@Your backstabbing skill has improved (" & UserList(userindex).Stats.Skill22 & ") !" & FONTTYPE_SKILLINFO)
End If

Call SendUserStatsBox(userindex)


End Sub

Sub Meditate(userindex As Integer)
On Error Resume Next

Dim X As Integer
Dim Y As Integer
Dim map As Integer
Dim obj As obj

X = UserList(userindex).Pos.X
Y = UserList(userindex).Pos.Y

'Check to see if you can meditate here.
If MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.ObjIndex = 289 Then
Call SendData(ToIndex, userindex, 0, "@You cannot meditate on signs !" & FONTTYPE_INFO)
Exit Sub
End If


'Snap out of meditation trance if already meditating
If UserList(userindex).Flags.Meditate = 1 Then
Call EraseObj(ToMap, 0, UserList(userindex).Pos.map, MapData(UserList(userindex).Pos.map, X, Y).ObjInfo.Amount, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
UserList(userindex).Flags.Meditate = 0
Call SendData(ToIndex, userindex, 0, "ME2")
Call SendData(ToIndex, userindex, 0, "@You snap out of the meditation trance." & FONTTYPE_INFO)

Else

UserList(userindex).Flags.Meditate = 1
'Begin meditate if wasnt meditating already
obj.ObjIndex = 231
obj.Amount = 1
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
Call SendData(ToIndex, userindex, 0, "@You are surrounded by a meditation aura and you start to meditate..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "ME1")

End If

End Sub

Sub RegainMana(userindex As Integer)
On Error Resume Next




Dim Luck2 As Long
Dim Chance
Randomize


If UserList(userindex).Stats.Skill27 <= 10 And UserList(userindex).Stats.Skill27 >= -100 Then Luck2 = 30
If UserList(userindex).Stats.Skill27 <= 20 And UserList(userindex).Stats.Skill27 >= 9 Then Luck2 = 26
If UserList(userindex).Stats.Skill27 <= 30 And UserList(userindex).Stats.Skill27 >= 19 Then Luck2 = 24
If UserList(userindex).Stats.Skill27 <= 40 And UserList(userindex).Stats.Skill27 >= 29 Then Luck2 = 20
If UserList(userindex).Stats.Skill27 <= 50 And UserList(userindex).Stats.Skill27 >= 39 Then Luck2 = 17
If UserList(userindex).Stats.Skill27 <= 60 And UserList(userindex).Stats.Skill27 >= 49 Then Luck2 = 15
If UserList(userindex).Stats.Skill27 <= 70 And UserList(userindex).Stats.Skill27 >= 59 Then Luck2 = 13
If UserList(userindex).Stats.Skill27 <= 80 And UserList(userindex).Stats.Skill27 >= 69 Then Luck2 = 10
If UserList(userindex).Stats.Skill27 <= 90 And UserList(userindex).Stats.Skill27 >= 79 Then Luck2 = 7
If UserList(userindex).Stats.Skill27 <= 999999 And UserList(userindex).Stats.Skill27 >= 89 Then Luck2 = 5


'Check to see if already fully regained
 If UserList(userindex).Stats.MinMAN >= UserList(userindex).Stats.MaxMAN Then
 Call SendData(ToIndex, userindex, 0, "@Your mana is fully regained and you cannot regain more." & FONTTYPE_INFO)
 Exit Sub
 End If


'If very low mana, regain at another basis
If UserList(userindex).Stats.MaxMAN < 61 And UserList(userindex).Stats.MinMAN < UserList(userindex).Stats.MaxMAN Then
Call SendData(ToIndex, userindex, 0, "@You regain a little mana, and continue to meditate..." & FONTTYPE_INFO)
UserList(userindex).Stats.MinMAN = UserList(userindex).Stats.MinMAN + UserList(userindex).Stats.MaxMAN + 5
UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 1
SendUserStatsBox (userindex)
Exit Sub
End If

'Ordinary regain
Call SendData(ToIndex, userindex, 0, "@You regain a little mana, and continue to meditate..." & FONTTYPE_INFO)
UserList(userindex).Stats.MinMAN = UserList(userindex).Stats.MinMAN + UserList(userindex).Stats.MaxMAN / Luck2



End Sub



Sub Hide(userindex As Integer)
On Error Resume Next

'Dont hide if already hided
If UserList(userindex).Flags.Hiding = 1 Then
Call SendData(ToIndex, userindex, 0, "@You are already hidden. You will now unhide..." & FONTTYPE_INFO)
Call Unhide(userindex)
Exit Sub
End If

'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 12
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill10 & "," & 12)
Call SendData(ToIndex, userindex, 0, "@You begin hiding... The blue bar represent how much time left before you are are done." & FONTTYPE_INFO)
Exit Sub
End If

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer
Dim Raise As Integer

'Hide !
Call SendData(ToIndex, userindex, 0, "@You successfully hide..." & FONTTYPE_INFO)

UserList(userindex).Char.Body = 53
UserList(userindex).Char.Head = 2
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0
Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)

UserList(userindex).Flags.Hiding = 1
Call SendData(ToIndex, userindex, 0, "HID")

'Maybe or maybe not raise skill

Raise = Int(RandomNumber(1, 10))
If Raise = 5 And UserList(userindex).Stats.Skill10 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill10 Then
UserList(userindex).Stats.Skill10 = UserList(userindex).Stats.Skill10 + 1
Call SendData(ToIndex, userindex, 0, "@Your hiding skill has improved (" & UserList(userindex).Stats.Skill10 & ") !" & FONTTYPE_SKILLINFO)
SendUserStatsBox (userindex)
End If

UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
SendUserStatsBox (userindex)

End Sub

Sub Unhide(userindex As Integer)
On Error Resume Next

Dim obj As ObjData
obj = ObjData(UserList(userindex).ClothingEqpObjindex)

UserList(userindex).Char.Body = obj.ClothingType
UserList(userindex).Char.Head = UserList(userindex).Flags.StartHead
UserList(userindex).Flags.Hiding = 0
Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)

Call SendData(ToIndex, userindex, 0, "UNH")






End Sub

Sub TameAnimal(userindex As Integer)
On Error Resume Next


Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer
Dim Target
Target = UserList(userindex).Npcindex


'Check to see if your dead
If UserList(userindex).Flags.status = 1 Then
Call SendData(ToIndex, userindex, 0, "@The animal cannot see your ghostly movments !" & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if a NPC is targeted
If Target = 0 Then
Call SendData(ToIndex, userindex, 0, "@First target an animal !" & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if NPC is tameable
If NPCList(Target).Tameable = 0 Then
Call SendData(ToIndex, userindex, 0, "@This cannot be tamed." & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if have enough skill ot tame
If UserList(userindex).Stats.Skill18 < NPCList(Target).SkillNeeded Then
Call SendData(ToIndex, userindex, 0, "@You do not have enough taming skill to tame this creature ! You need " & NPCList(Target).SkillNeeded & " ." & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if animal already got an owner
If NPCList(Target).Owner > 0 Then
Call SendData(ToIndex, userindex, 0, "@The animal is already tamed." & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if player already has a tamed animal
If UserList(userindex).Stats.OwnAnimal > 0 Then
Call SendData(ToIndex, userindex, 0, "@You already own an animal. Discard the other first !" & FONTTYPE_INFO)
Exit Sub
End If


'Begin cprocess if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 14
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill18 & "," & 14)
Call SendData(ToIndex, userindex, 0, "@You begin taming the creature... The blue bar represent how much time left before you are done." & FONTTYPE_INFO)
Exit Sub
End If


'Tame animal !
Call SendData(ToIndex, userindex, 0, "@The animal accepts you as its master !" & FONTTYPE_INFO)

UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.Working = 0

'Make the targeted NPC yours and make it tamed
UserList(userindex).Stats.OwnAnimal = Target
UserList(userindex).Stats.AnimalIndex = Target
NPCList(Target).Owner = userindex
NPCList(Target).Tamed = 1
'Make it follow owner
NPCList(Target).Movement = 6
'Make it NON-hostile and NON-attackable
NPCList(Target).Hostile = 0
NPCList(Target).Attackable = 0
If NPCList(Target).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(Target).Flags.Sound)


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 25))
If Raise = 5 And UserList(userindex).Stats.Skill18 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill18 Then
UserList(userindex).Stats.Skill18 = UserList(userindex).Stats.Skill18 + 1
Call SendData(ToIndex, userindex, 0, "@Your animal taming skill has improved (" & UserList(userindex).Stats.Skill18 & ") !" & FONTTYPE_SKILLINFO)
End If

UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 30
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)







End Sub

Sub Gossip(userindex As Integer)
On Error Resume Next

Open App.Path & "\Log.txt" For Append Shared As #5
Print #5, "Gossip"
Close #5

Dim Luck As Integer
Dim NumberOfGossips As Integer
Dim NumGossip As Integer
Dim Gossip As String
Dim Raise As Integer
Dim Luck2 As Integer
Dim Chance As Integer

'Make clear players target
Dim NPC As Integer
NPC = UserList(userindex).Npcindex

'Error handeling
If NPC = 0 Then
Call SendData(ToIndex, userindex, 0, "@You must target a NPC before asking for gossip !" & FONTTYPE_TALK)
Exit Sub
End If

If NPC = UserList(userindex).Stats.OwnAnimal Then
Call SendData(ToIndex, userindex, 0, "@I do not think your creature is very much into the gossip of Menath." & FONTTYPE_TALK)
Exit Sub
End If

If NPCList(NPC).Tradeable = 1 Then
Call SendData(ToIndex, userindex, 0, "@I doubt the there is gossip to get here." & FONTTYPE_TALK)
Exit Sub
End If

'If all error handlers passed, go onto giving gossip...
'First find out if NPC want to give you gossip. This
'is based on the streetwise skill.

Luck = UserList(userindex).Stats.Skill26
If Luck <= 10 And Luck >= -1 Then Luck2 = 999999
If Luck <= 20 And Luck >= 9 Then Luck2 = 30
If Luck <= 30 And Luck >= 19 Then Luck2 = 25
If Luck <= 40 And Luck >= 29 Then Luck2 = 15
If Luck <= 50 And Luck >= 39 Then Luck2 = 10
If Luck <= 60 And Luck >= 49 Then Luck2 = 7
If Luck <= 70 And Luck >= 59 Then Luck2 = 6
If Luck <= 80 And Luck >= 69 Then Luck2 = 5
If Luck <= 90 And Luck >= 79 Then Luck2 = 2
If Luck <= 999999 And Luck >= 89 Then Luck2 = 1
Chance = Int(RandomNumber(1, Luck2))

'Tell GOSSIP
If Chance = Luck2 Then

NumberOfGossips = Val(GetVar(IniPath & "gossip.txt", "INIT", "NumGOSSIPs"))
NumGossip = Int(RandomNumber(1, NumberOfGossips))
'Tell the gossip
Gossip = GetVar(IniPath & "gossip.txt", "GOSSIP" & NumGossip, "Gossip")
Call SendData(ToIndex, userindex, 0, "@" & NPCList(NPC).Name & " tells you, " & Gossip & FONTTYPE_INFO)
Else
'Dont tell gossip
Call SendData(ToIndex, userindex, 0, "@" & NPCList(NPC).Name & " says, I try not to spread any rumors." & FONTTYPE_INFO)
End If


'Maybe or maybe not raise skill
Raise = Int(RandomNumber(1, 10))
If Raise = 5 And UserList(userindex).Stats.Skill26 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill26 Then
UserList(userindex).Stats.Skill26 = UserList(userindex).Stats.Skill26 + 1
Call SendData(ToIndex, userindex, 0, "@Your streetwise skill has improved (" & UserList(userindex).Stats.Skill26 & ") !" & FONTTYPE_SKILLINFO)
SendUserStatsBox (userindex)
End If

CheckUserLevel (userindex)
SendUserStatsBox (userindex)






End Sub

Sub Disguise(userindex As Integer)
On Error Resume Next


'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 6
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill7 & "," & 6)
Call SendData(ToIndex, userindex, 0, "@You start trying to disguise. The blue bar represent how much time left before you are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToIndex, userindex, 0, "@You manage to disguise ! Your name is now simply: a peasant !" & FONTTYPE_INFO)
UserList(userindex).Name = "a peasant"
Call SendData(ToIndex, userindex, 0, "DIS")
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 15))
If Raise = 5 And UserList(userindex).Stats.Skill7 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill7 Then
UserList(userindex).Stats.Skill7 = UserList(userindex).Stats.Skill7 + 1
Call SendData(ToIndex, userindex, 0, "@Your hiding skill has improved (" & UserList(userindex).Stats.Skill7 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 3
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)
End Sub
Sub Transfer(userindex As Integer)
On Error Resume Next


'Dim stuff
Dim AniTarget As Integer
Dim TargetPlayer As Integer
AniTarget = UserList(userindex).Stats.OwnAnimal
TargetPlayer = UserList(userindex).UserTargetIndex

'Check to see if player target. If not exit sub.
If TargetPlayer = UserList(userindex).Npcindex Then
Call SendData(ToIndex, userindex, 0, "@You cannot transfer ownership of animals to NPC`s." & FONTTYPE_INFO)
Exit Sub
End If

UserList(userindex).Stats.AnimalIndex = 0
UserList(TargetPlayer).Stats.OwnAnimal = UserList(userindex).Stats.OwnAnimal
UserList(userindex).Stats.OwnAnimal = 0
NPCList(AniTarget).Owner = TargetPlayer
NPCList(AniTarget).Tamed = 1
Call SendData(ToIndex, UserList(userindex).UserTargetIndex, 0, "@The ownership of an animal has just been transfered to you." & FONTTYPE_INFO)
If NPCList(AniTarget).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(AniTarget).Flags.Sound)



End Sub

Sub DiscardAnimal(userindex As Integer)
On Error Resume Next

Dim target4
target4 = UserList(userindex).Stats.OwnAnimal
    
    If target4 > 0 Then
    NPCList(target4).Tamed = 0
    NPCList(target4).Owner = 0
    NPCList(target4).Movement = 2
    NPCList(target4).Attackable = 1
    UserList(userindex).Stats.OwnAnimal = 0
    UserList(userindex).Stats.AnimalIndex = 0
    Call SendData(ToIndex, userindex, 0, "@You are no longer the owner of the animal." & FONTTYPE_INFO)
    If NPCList(target4).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(target4).Flags.Sound)

    Exit Sub
    Else
    Call SendData(ToIndex, userindex, 0, "@You dont have an animal to discard !" & FONTTYPE_INFO)
 End If
 





End Sub

Sub GiveSkills(userindex As Integer)
On Error Resume Next


If UserList(userindex).class = "Warrior" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 0    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 8    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 0    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 12  'Swordmanship
UserList(userindex).Stats.Skill17 = 9   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 1   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 2   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 5   'Surviving
UserList(userindex).Stats.Skill25 = 0   'Etiquette
UserList(userindex).Stats.Skill26 = 2   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0

UserList(userindex).Stats.MaxHP = 50
UserList(userindex).Stats.MinHP = 50

UserList(userindex).Stats.MaxHIT = 5
UserList(userindex).Stats.MinHIT = 4

Call UpdateUserInv(True, userindex, 0)
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If

If UserList(userindex).class = "Druid" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 0    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 2    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 4    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 4   'Hiding
UserList(userindex).Stats.Skill11 = 12   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 3   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 0   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 15   'Animal Taming
UserList(userindex).Stats.Skill19 = 4   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 2   'Backstabbing
UserList(userindex).Stats.Skill23 = 7   'Healing
UserList(userindex).Stats.Skill24 = 0   'Surviving
UserList(userindex).Stats.Skill25 = 11   'Etiquette
UserList(userindex).Stats.Skill26 = 2   'Streetwise
UserList(userindex).Stats.Skill27 = 13   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 190
UserList(userindex).Stats.MinMAN = 190




'Add a few spells to its spell book
UserList(userindex).SpellObj(1).SpellIndex = 1
UserList(userindex).SpellObj(2).SpellIndex = 2
UserList(userindex).SpellObj(3).SpellIndex = 5

UserList(userindex).MagicSchool = "Nature"
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If


If UserList(userindex).class = "Healer" Then
UserList(userindex).Stats.Skill1 = 8    'Cooking
UserList(userindex).Stats.Skill2 = 2    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 0    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 0    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 2   'Poinsoning
UserList(userindex).Stats.Skill16 = 0   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 3   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 12   'Healing
UserList(userindex).Stats.Skill24 = 0   'Surviving
UserList(userindex).Stats.Skill25 = 4   'Etiquette
UserList(userindex).Stats.Skill26 = 1   'Streetwise
UserList(userindex).Stats.Skill27 = 5   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 100
UserList(userindex).Stats.MinMAN = 100
'Add a few spells to its spell book
UserList(userindex).SpellObj(1).SpellIndex = 1
UserList(userindex).SpellObj(2).SpellIndex = 2
UserList(userindex).SpellObj(3).SpellIndex = 5


UserList(userindex).MagicSchool = "Nature"
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If


If UserList(userindex).class = "Cleric" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 2    'Musicanship
UserList(userindex).Stats.Skill3 = 4    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 8    'Tactics
UserList(userindex).Stats.Skill7 = 1    'disguise
UserList(userindex).Stats.Skill8 = 3    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 2   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 0   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 14  'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 4   'Healing
UserList(userindex).Stats.Skill24 = 0   'Surviving
UserList(userindex).Stats.Skill25 = 10   'Etiquette
UserList(userindex).Stats.Skill26 = 3   'Streetwise
UserList(userindex).Stats.Skill27 = 4   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 120
UserList(userindex).Stats.MinMAN = 120

UserList(userindex).SpellObj(1).SpellIndex = 2

UserList(userindex).MagicSchool = "Nature"
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If


If UserList(userindex).class = "Thief" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 2    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 3    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 4    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 12   'Lockpicking
UserList(userindex).Stats.Skill13 = 14   'Pickpocket
UserList(userindex).Stats.Skill14 = 7   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 0   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 5   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 2   'Surviving
UserList(userindex).Stats.Skill25 = 0   'Etiquette
UserList(userindex).Stats.Skill26 = 10   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If


If UserList(userindex).class = "Paladin" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 3    'Musicanship
UserList(userindex).Stats.Skill3 = 2    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 7    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 4    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 16   'Swordmanship
UserList(userindex).Stats.Skill17 = 11   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 4   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 2   'Healing
UserList(userindex).Stats.Skill24 = 1   'Surviving
UserList(userindex).Stats.Skill25 = 20   'Etiquette
UserList(userindex).Stats.Skill26 = 0   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 110
UserList(userindex).Stats.MinMAN = 110

UserList(userindex).Stats.MaxHP = 40
UserList(userindex).Stats.MinHP = 40

UserList(userindex).Stats.MaxHIT = 4
UserList(userindex).Stats.MinHIT = 3

UserList(userindex).SpellObj(1).SpellIndex = 1
UserList(userindex).SpellObj(2).SpellIndex = 4

UserList(userindex).MagicSchool = "Enchanting"
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If

If UserList(userindex).class = "Bandit" Then
UserList(userindex).Stats.Skill1 = 3    'Cooking
UserList(userindex).Stats.Skill2 = 1    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 2    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 0    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 13   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 2   'Pickpocket
UserList(userindex).Stats.Skill14 = 8   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 5   'Swordmanship
UserList(userindex).Stats.Skill17 = 3   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 6   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 5   'Surviving
UserList(userindex).Stats.Skill25 = 0   'Etiquette
UserList(userindex).Stats.Skill26 = 0   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 3   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0

UserList(userindex).Stats.MaxHP = 30
UserList(userindex).Stats.MinHP = 30

UserList(userindex).Stats.MaxHIT = 4
UserList(userindex).Stats.MinHIT = 4
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If

If UserList(userindex).class = "Woodworker" Then
UserList(userindex).Stats.Skill1 = 3    'Cooking
UserList(userindex).Stats.Skill2 = 0    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 20    'Carpenting
UserList(userindex).Stats.Skill5 = 20    'Lumberjacking
UserList(userindex).Stats.Skill6 = 0    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 2    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 3   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 3   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 5   'Surviving
UserList(userindex).Stats.Skill25 = 0   'Etiquette
UserList(userindex).Stats.Skill26 = 0   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 5   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0

UserList(userindex).Object(6).ObjIndex = 7
UserList(userindex).Object(6).Amount = 1

UserList(userindex).Object(7).ObjIndex = 128
UserList(userindex).Object(7).Amount = 1

UserList(userindex).Object(8).ObjIndex = 255
UserList(userindex).Object(8).Amount = 1

UserList(userindex).Object(9).ObjIndex = 257
UserList(userindex).Object(9).Amount = 1

Call UpdateUserInv(True, userindex, 6)
Call UpdateUserInv(True, userindex, 7)
Call UpdateUserInv(True, userindex, 8)
Call UpdateUserInv(True, userindex, 9)
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If


If UserList(userindex).class = "Blacksmith" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 0    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 2    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 0    'Merchant
UserList(userindex).Stats.Skill9 = 19    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 5   'Swordmanship
UserList(userindex).Stats.Skill17 = 5   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 7   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 0   'Surviving
UserList(userindex).Stats.Skill25 = 0   'Etiquette
UserList(userindex).Stats.Skill26 = 7   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0

UserList(userindex).Object(6).ObjIndex = 38
UserList(userindex).Object(6).Amount = 1

UserList(userindex).Object(7).ObjIndex = 154
UserList(userindex).Object(7).Amount = 50

UserList(userindex).Object(8).ObjIndex = 178
UserList(userindex).Object(8).Amount = 1

UserList(userindex).Object(9).ObjIndex = 306
UserList(userindex).Object(9).Amount = 1

Call UpdateUserInv(True, userindex, 6)
Call UpdateUserInv(True, userindex, 7)
Call UpdateUserInv(True, userindex, 8)
Call UpdateUserInv(True, userindex, 9)

Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If


If UserList(userindex).class = "Tailor" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 0    'Musicanship
UserList(userindex).Stats.Skill3 = 19    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 0    'Tactics
UserList(userindex).Stats.Skill7 = 2    'disguise
UserList(userindex).Stats.Skill8 = 9    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 0   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 2   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 2   'Healing
UserList(userindex).Stats.Skill24 = 0   'Surviving
UserList(userindex).Stats.Skill25 = 12   'Etiquette
UserList(userindex).Stats.Skill26 = 2   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0

UserList(userindex).Object(6).ObjIndex = 149
UserList(userindex).Object(6).Amount = 1

UserList(userindex).Object(7).ObjIndex = 151
UserList(userindex).Object(7).Amount = 50

UserList(userindex).Object(8).ObjIndex = 158
UserList(userindex).Object(8).Amount = 1

UserList(userindex).Object(9).ObjIndex = 161
UserList(userindex).Object(9).Amount = 1

Call UpdateUserInv(True, userindex, 6)
Call UpdateUserInv(True, userindex, 7)
Call UpdateUserInv(True, userindex, 8)
Call UpdateUserInv(True, userindex, 9)


Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")


Exit Sub
End If


If UserList(userindex).class = "Fisher" Then
UserList(userindex).Stats.Skill1 = 10    'Cooking
UserList(userindex).Stats.Skill2 = 2    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 0    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 3    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 0   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 20   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 5   'Surviving
UserList(userindex).Stats.Skill25 = 0   'Etiquette
UserList(userindex).Stats.Skill26 = 2   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0

UserList(userindex).Object(6).ObjIndex = 80
UserList(userindex).Object(6).Amount = 1

Call UpdateUserInv(True, userindex, 6)
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")


Exit Sub
End If


If UserList(userindex).class = "Animal Tamer" Then
UserList(userindex).Stats.Skill1 = 15    'Cooking
UserList(userindex).Stats.Skill2 = 2    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 5    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 0    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 4   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 25   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 2   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 13   'Surviving
UserList(userindex).Stats.Skill25 = 0   'Etiquette
UserList(userindex).Stats.Skill26 = 0   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 12   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If


If UserList(userindex).class = "Merchant" Then
UserList(userindex).Stats.Skill1 = 2    'Cooking
UserList(userindex).Stats.Skill2 = 1    'Musicanship
UserList(userindex).Stats.Skill3 = 2    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 0    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 22    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 2   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 2   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 2   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 2   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 12   'Surviving
UserList(userindex).Stats.Skill25 = 15   'Etiquette
UserList(userindex).Stats.Skill26 = 15   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If


If UserList(userindex).class = "Bard" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 20    'Musicanship
UserList(userindex).Stats.Skill3 = 2    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 0    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 10    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 5   'Lockpicking
UserList(userindex).Stats.Skill13 = 5   'Pickpocket
UserList(userindex).Stats.Skill14 = 5   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 2   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 3   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 5   'Surviving
UserList(userindex).Stats.Skill25 = 8   'Etiquette
UserList(userindex).Stats.Skill26 = 14   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 90
UserList(userindex).Stats.MinMAN = 90
'Add a few spells to its spell book
UserList(userindex).SpellObj(1).SpellIndex = 1
UserList(userindex).SpellObj(2).SpellIndex = 2


UserList(userindex).Object(6).ObjIndex = 35
UserList(userindex).Object(6).Amount = 1
Call UpdateUserInv(True, userindex, 6)

UserList(userindex).MagicSchool = "Nature"

Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If

If UserList(userindex).class = "Miner" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 0    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 2    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 0    'Merchant
UserList(userindex).Stats.Skill9 = 5    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 3   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 30   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 2   'Surviving
UserList(userindex).Stats.Skill25 = 0   'Etiquette
UserList(userindex).Stats.Skill26 = 0   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0

UserList(userindex).Object(6).ObjIndex = 181
UserList(userindex).Object(6).Amount = 1
Call UpdateUserInv(True, userindex, 6)
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If

If UserList(userindex).class = "Pirate" Then
UserList(userindex).Stats.Skill1 = 4    'Cooking
UserList(userindex).Stats.Skill2 = 4    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 5    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 3    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 7   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 3   'Lockpicking
UserList(userindex).Stats.Skill13 = 3   'Pickpocket
UserList(userindex).Stats.Skill14 = 7   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 5   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 9   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 4   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 5   'Surviving
UserList(userindex).Stats.Skill25 = 0   'Etiquette
UserList(userindex).Stats.Skill26 = 5   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If

If UserList(userindex).class = "Cook" Then
UserList(userindex).Stats.Skill1 = 20    'Cooking
UserList(userindex).Stats.Skill2 = 0    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 0    'Tactics
UserList(userindex).Stats.Skill7 = 20    'disguise
UserList(userindex).Stats.Skill8 = 5    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 0   'Stealth
UserList(userindex).Stats.Skill15 = 2   'Poinsoning
UserList(userindex).Stats.Skill16 = 0   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 4   'Religion Lore
UserList(userindex).Stats.Skill20 = 5   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 0   'Surviving
UserList(userindex).Stats.Skill25 = 5   'Etiquette
UserList(userindex).Stats.Skill26 = 0   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0


UserList(userindex).Object(6).ObjIndex = 118
UserList(userindex).Object(6).Amount = 5

UserList(userindex).Object(7).ObjIndex = 108
UserList(userindex).Object(7).Amount = 5

UserList(userindex).Object(8).ObjIndex = 107
UserList(userindex).Object(8).Amount = 5

Call UpdateUserInv(True, userindex, 6)
Call UpdateUserInv(True, userindex, 7)
Call UpdateUserInv(True, userindex, 8)


Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If


If UserList(userindex).class = "Assasin" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 3    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 7    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 2    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 18   'Hiding
UserList(userindex).Stats.Skill11 = 0   'Magery
UserList(userindex).Stats.Skill12 = 7   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 13   'Stealth
UserList(userindex).Stats.Skill15 = 15   'Poinsoning
UserList(userindex).Stats.Skill16 = 0   'Swordmanship
UserList(userindex).Stats.Skill17 = 0   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 5   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 0   'Surviving
UserList(userindex).Stats.Skill25 = 5   'Etiquette
UserList(userindex).Stats.Skill26 = 5   'Streetwise
UserList(userindex).Stats.Skill27 = 0   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 0
UserList(userindex).Stats.MinMAN = 0
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If

If UserList(userindex).class = "Wizard" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 0    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 5    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 0    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 15   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 5   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 2   'Swordmanship
UserList(userindex).Stats.Skill17 = 9   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 0   'Surviving
UserList(userindex).Stats.Skill25 = 5   'Etiquette
UserList(userindex).Stats.Skill26 = 8   'Streetwise
UserList(userindex).Stats.Skill27 = 10   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 220
UserList(userindex).Stats.MinMAN = 220

'Add a few spells to its spell book
UserList(userindex).SpellObj(1).SpellIndex = 3
UserList(userindex).SpellObj(2).SpellIndex = 7


UserList(userindex).MagicSchool = "Destruction"
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If

If UserList(userindex).class = "Enchanter" Then
UserList(userindex).Stats.Skill1 = 0    'Cooking
UserList(userindex).Stats.Skill2 = 0    'Musicanship
UserList(userindex).Stats.Skill3 = 0    'Tailoring
UserList(userindex).Stats.Skill4 = 0    'Carpenting
UserList(userindex).Stats.Skill5 = 0    'Lumberjacking
UserList(userindex).Stats.Skill6 = 5    'Tactics
UserList(userindex).Stats.Skill7 = 0    'disguise
UserList(userindex).Stats.Skill8 = 0    'Merchant
UserList(userindex).Stats.Skill9 = 0    'Blacksmithing
UserList(userindex).Stats.Skill10 = 0   'Hiding
UserList(userindex).Stats.Skill11 = 15   'Magery
UserList(userindex).Stats.Skill12 = 0   'Lockpicking
UserList(userindex).Stats.Skill13 = 0   'Pickpocket
UserList(userindex).Stats.Skill14 = 5   'Stealth
UserList(userindex).Stats.Skill15 = 0   'Poinsoning
UserList(userindex).Stats.Skill16 = 2   'Swordmanship
UserList(userindex).Stats.Skill17 = 9   'Parrying
UserList(userindex).Stats.Skill18 = 0   'Animal Taming
UserList(userindex).Stats.Skill19 = 0   'Religion Lore
UserList(userindex).Stats.Skill20 = 0   'Fishing
UserList(userindex).Stats.Skill21 = 0   'Mining
UserList(userindex).Stats.Skill22 = 0   'Backstabbing
UserList(userindex).Stats.Skill23 = 0   'Healing
UserList(userindex).Stats.Skill24 = 0   'Surviving
UserList(userindex).Stats.Skill25 = 5   'Etiquette
UserList(userindex).Stats.Skill26 = 8   'Streetwise
UserList(userindex).Stats.Skill27 = 15   'Meditating
UserList(userindex).Stats.Skill28 = 0   'Archery

UserList(userindex).Stats.MaxMAN = 180
UserList(userindex).Stats.MinMAN = 180

'Add a few spells to its spell book
UserList(userindex).SpellObj(1).SpellIndex = 3
UserList(userindex).SpellObj(2).SpellIndex = 5
UserList(userindex).SpellObj(3).SpellIndex = 7

UserList(userindex).MagicSchool = "Enchanter"
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

Exit Sub
End If

End Sub

Sub Beat()

End Sub

Sub Consider(userindex As Integer)
On Error Resume Next


Dim USERTARGET As Integer
Dim NPCtarget As Integer

USERTARGET = UserList(userindex).UserTargetIndex
NPCtarget = UserList(userindex).Npcindex

'Consider NPC
If NPCtarget > 0 Then
Call SendData(ToIndex, userindex, 0, "@You look at " & NPCList(NPCtarget).Name & "..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@You assume the health of your target is " & NPCList(NPCtarget).Stats.MinHP & "/" & NPCList(NPCtarget).Stats.MaxHP & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@You assume its hit power would be about " & NPCList(NPCtarget).Stats.MaxHIT & " points..." & FONTTYPE_INFO)
Exit Sub
End If

'Consider player
If USERTARGET > 0 Then
Call SendData(ToIndex, userindex, 0, "@You look at " & UserList(USERTARGET).Name & "..." & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@You assume the health of your target is " & UserList(USERTARGET).Stats.MinHP & "/" & UserList(USERTARGET).Stats.MaxHP & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@You assume its hit power would be about " & UserList(USERTARGET).Stats.MaxHIT & " points." & FONTTYPE_INFO)
Exit Sub
End If

End Sub

Sub ReportBug(message As String, sender As Integer)
On Error Resume Next

Dim NumBugs As Integer
Dim NewNumBugs As String


'Update number of bugs
NumBugs = Val(GetVar(IniPath & "bugs.txt", "INIT", "NumBUGs"))
NewNumBugs = NumBugs + 1
Call WriteVar(IniPath & "bugs.txt", "INIT", "NumBUGs", NewNumBugs)

'Write post
Call WriteVar(IniPath & "bugs.txt", "BUG" & NewNumBugs, "Description", message)
Call WriteVar(IniPath & "bugs.txt", "BUG" & NewNumBugs, "Reported By", UserList(sender).Name)

End Sub


Sub Bandage(userindex As Integer, slot As Byte)
On Error Resume Next

Dim Target As Integer
Target = UserList(userindex).UserTargetIndex

If UserList(Target).Stats.MinHP >= UserList(Target).Stats.MaxHP Then
Call SendData(ToIndex, userindex, 0, "@Your target is fully healed." & FONTTYPE_INFO)
Exit Sub
End If

'Begin process if not done
If UserList(userindex).Flags.SkillFinished = 0 Then
UserList(userindex).Flags.whatjob = 1
UserList(userindex).Flags.Working = 1
Call SendData(ToIndex, userindex, 0, "DOS" & UserList(userindex).Stats.Skill23 & "," & 1)
Call SendData(ToIndex, userindex, 0, "@You begin bandaging... The blue bar represent how much time left before you are done." & FONTTYPE_INFO)
Exit Sub
End If

'If the skill is done do the stuff

Dim obj As obj
Dim X As Integer
Dim Y As Integer
Dim map As Integer

Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_FOLDCLOTHING)

'Sucessfull !
Call SendData(ToIndex, userindex, 0, "@Your done laying the bandages." & FONTTYPE_INFO)
Call SendData(ToIndex, Target, 0, "@You have been healed abit." & FONTTYPE_INFO)
 
UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MinHP + 15
If UserList(userindex).Stats.MinHP > UserList(userindex).Stats.MaxHP Then UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MaxHP
UserList(userindex).Object(slot).Amount = UserList(userindex).Object(slot).Amount - 1
If UserList(userindex).Object(slot).Amount < 1 Then UserList(userindex).Object(slot).ObjIndex = 0
UserList(userindex).Flags.Attack = 0
UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0


'Maybe or maybe not raise skill
Dim Raise
Raise = Int(RandomNumber(1, 4))
If Raise = 5 And UserList(userindex).Stats.Skill23 > 9 And LevelSkill(UserList(userindex).Stats.ELV).LevelValue > UserList(userindex).Stats.Skill23 Then
UserList(userindex).Stats.Skill23 = UserList(userindex).Stats.Skill23 + 1
Call SendData(ToIndex, userindex, 0, "@Your tailoring skill has improved (" & UserList(userindex).Stats.Skill23 & ") !" & FONTTYPE_SKILLINFO)
End If


UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 5
CheckUserLevel (userindex)
Call SendUserStatsBox(userindex)
Call SendUserStatsBox(Target)
Call UpdateUserInv(True, userindex, slot)


End Sub

Sub MakeClan(userindex As Integer, ClanName As String)

On Error Resume Next

Dim NumClans As Integer
Dim NewNumClans As String


'Update number of bugs
NumClans = Val(GetVar(IniPath & "clans.txt", "INIT", "NumCLANs"))
NewNumClans = NumClans + 1

'Set up clan

'Init
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "INIT", "Name", ClanName)
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "INIT", "Members", "1")
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "INIT", "Allies", "0")
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "INIT", "Enemies", "0")
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "INIT", "Gold", "0")
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "INIT", "Experience", "0")
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "INIT", "Monarch", UserList(userindex).Name)
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "INIT", "ClanNum", NewNumClans)


'Members
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "MEMBERS", "Member" & "1", UserList(userindex).Name)
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "MEMBERS", "MemberRank" & "1", "Monarch")

'Allies
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "ALLIES", "Ally" & "1", "None")

'Enemies
Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "ENEMIES", "Enemy" & "1", "None")



End Sub

Function Distance(X1 As Variant, Y1 As Variant, X2 As Variant, Y2 As Variant) As Double
On Error Resume Next
'*****************************************************************
'Finds the distance between two points
'*****************************************************************

Distance = Sqr(((Y1 - Y2) ^ 2 + (X1 - X2) ^ 2))

End Function

Function RandomNumber(ByVal LowerBound As Variant, ByVal UpperBound As Variant) As Single
On Error Resume Next
'*****************************************************************
'Find a Random number between a range
'*****************************************************************

Randomize Timer

RandomNumber = (UpperBound - LowerBound + 1) * Rnd + LowerBound

End Function


Sub Delay(Cycles As Integer)
On Error Resume Next
'*****************************************************************
'Delay Loop
'*****************************************************************
Dim LoopC As Integer
  
For LoopC = 1 To Cycles
Next LoopC
  
End Sub


Sub RefreshUserListBox()
On Error Resume Next
'*****************************************************************
'Refreshes the User list box on the frmMain
'*****************************************************************

End Sub

Sub Restart()
On Error Resume Next
'*****************************************************************
'Restarts the server
'*****************************************************************

'ensure that the sockets are closed, ignore any errors

Dim LoopC As Integer
  
frmMain.Socket1.Cleanup
frmMain.Socket1.Startup
  
frmMain.Socket2(0).Cleanup
frmMain.Socket2(0).Startup

For LoopC = 1 To MaxUsers
    CloseSocket (LoopC)
Next
  
'Init vars
LastUser = 0
NumUsers = 0

'*****************Load data text data
Call LoadSini
Call LoadMapData
Call LoadOBJData
Call LoadSpellData



'*****************Setup socket
frmMain.Socket1.AddressFamily = AF_INET
frmMain.Socket1.Protocol = IPPROTO_IP
frmMain.Socket1.SocketType = SOCK_STREAM
frmMain.Socket1.Binary = False
frmMain.Socket1.Blocking = False
frmMain.Socket1.BufferSize = 1024

frmMain.Socket2(0).AddressFamily = AF_INET
frmMain.Socket2(0).Protocol = IPPROTO_IP
frmMain.Socket2(0).SocketType = SOCK_STREAM
frmMain.Socket2(0).Blocking = False
frmMain.Socket2(0).BufferSize = 2048

'Listen
frmMain.Socket1.LocalPort = Val(frmMain.txPortNumber.Text)
frmMain.Socket1.Listen
frmMain.txStatus.Text = "Listening for connection ..."
Call RefreshUserListBox
  
'Misc
  
'Hide
If HideMe = 1 Then
    frmMain.Hide
End If

'Show local IP
frmMain.LocalAdd.Text = frmMain.Socket1.LocalAddress
  
'Log it
Open App.Path & "\Main.log" For Append Shared As #5
Print #5, "**** Server restarted. " & Time & " " & Date
Close #5
  
End Sub

Function SpecializedSkill(skill As String)
On Error Resume Next


Dim userindex As Integer


If skill = UserList(userindex).Flags.SpecSkill1 Then
SpecializedSkill = True
Exit Function
End If

If skill = UserList(userindex).Flags.SpecSkill2 Then
SpecializedSkill = True
Exit Function
End If

If skill = UserList(userindex).Flags.SpecSkill3 Then
SpecializedSkill = True
Exit Function
End If

SpecializedSkill = False

End Function
Function SameTitle(userindex As Integer, title As String)
On Error Resume Next


If UserList(userindex).class = title Then
SameTitle = True
Else
SameTitle = False
End If


End Function

Function WizCheck(Name As String) As Boolean
On Error Resume Next



'*****************************************************************
'Checks to see if Name is a wizard
'*****************************************************************
Dim NumWizs As Integer
Dim WizNum As Integer

NumWizs = Val(GetVar(IniPath & "Server.ini", "INIT", "NumWizs"))
For WizNum = 1 To NumWizs
    If UCase(Name) = UCase(GetVar(IniPath & "Server.ini", "WizList", "wiz" & WizNum)) Then
        WizCheck = True
        Exit Function
    End If
Next WizNum

WizCheck = False


End Function

