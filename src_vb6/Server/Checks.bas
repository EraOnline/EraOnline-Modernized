Attribute VB_Name = "Checks"

Function CheckID(userindex As Integer, theid As Long)
On Error Resume Next

Dim NumPass As Integer
Dim NumAccount As Integer
Dim Password As String

'get number of account ID`s
NumPass = Val(GetVar(IniPath & "banned.txt", "INIT", "NumBANs"))

'If defect ID, then abort.
If theid < 99 Then
Exit Function
End If

For NumAccount = 1 To NumPass

'Load ID into memory and check if match, if not resume
Password = GetVar(IniPath & "banned.txt", "ID" & NumAccount, "Password")

If Password = theid Then
Call SendData(ToIndex, userindex, 0, "!!You are currently banned from Era Online. You may not enter with this or anyother old/new character. If you wish to complain, contact support@eraonline.net")
CloseSocket (userindex)
Exit Function
End If

'Goto next ID
Next NumAccount

End Function

Function CheckIfAttack(Npcindex As Integer, userindex As Integer)
On Error Resume Next


CheckIfAttack = True

If UserList(userindex).Stats.ELV > NPCList(Npcindex).Level + 4 Then
CheckIfAttack = False
End If

If userindex = NPCList(Npcindex).Flags.AttackedBy Then
CheckIfAttack = True
End If


End Function


Function CheckForSameIP(userindex As Integer, UserIP As String) As Boolean
On Error Resume Next
'*****************************************************************
'Checks for a user with the same IP
'*****************************************************************
Dim LoopC As Integer

For LoopC = 1 To LastUser

    If UserList(LoopC).Flags.UserLogged = True Then
        If UserList(LoopC).IP = UserIP And userindex <> LoopC Then
            CheckForSameIP = True
            Exit Function
        End If
    End If

Next LoopC

CheckForSameIP = False

End Function
Function CheckForSameName(ByVal userindex As Integer, ByVal Name As String) As Boolean
On Error Resume Next
'*****************************************************************
'Checks for a user with the same Name
'*****************************************************************
Dim LoopC As Integer

For LoopC = 1 To LastUser

    If UserList(LoopC).Flags.UserLogged = True Then
        If UCase$(UserList(LoopC).Name) = UCase$(Name) And userindex <> LoopC Then
            CheckForSameName = True
            Exit Function
        End If
    End If

Next LoopC

CheckForSameName = False

End Function

Sub CheckRep(userindex As Integer)
On Error Resume Next

If UserList(userindex).Community.OverallRep > 499 Then
UserList(userindex).Community.RepRank = ""
End If

If UserList(userindex).Community.OverallRep > 600 Then
UserList(userindex).Community.RepRank = "The Respectable"
End If

If UserList(userindex).Community.OverallRep > 700 Then
UserList(userindex).Community.RepRank = "The Honorable"
End If

If UserList(userindex).Community.OverallRep > 800 Then
UserList(userindex).Community.RepRank = "The Fameous"
End If

If UserList(userindex).Community.OverallRep > 900 Then
If UserList(userindex).Gender = "Male" Then UserList(userindex).Community.RepRank = "The Lord"
If UserList(userindex).Gender = "Female" Then UserList(userindex).Community.RepRank = "The Lady"
End If

If UserList(userindex).Community.OverallRep > 1000 Then
If UserList(userindex).Gender = "Male" Then UserList(userindex).Community.RepRank = "The Great Lord"
If UserList(userindex).Gender = "Female" Then UserList(userindex).Community.RepRank = "The Great Lady"
End If

If UserList(userindex).Community.OverallRep > 1500 Then
If UserList(userindex).Gender = "Male" Then UserList(userindex).Community.RepRank = "The High Sir"
If UserList(userindex).Gender = "Female" Then UserList(userindex).Community.RepRank = "The High Madam"
End If

If UserList(userindex).Community.OverallRep < 400 Then
UserList(userindex).Community.RepRank = "The Disrespected"
End If

If UserList(userindex).Community.OverallRep < 300 Then
UserList(userindex).Community.RepRank = "The Scum"
End If

If UserList(userindex).Community.OverallRep < 200 Then
UserList(userindex).Community.RepRank = "The Hated"
End If

If UserList(userindex).Community.OverallRep < 100 Then
If UserList(userindex).Gender = "Male" Then UserList(userindex).Community.RepRank = "The Dark Lord"
If UserList(userindex).Gender = "Female" Then UserList(userindex).Community.RepRank = "The Dark Lady"
End If

If UserList(userindex).Community.OverallRep < 0 Then
If UserList(userindex).Gender = "Male" Then UserList(userindex).Community.RepRank = "The Dreaded Lord"
If UserList(userindex).Gender = "Female" Then UserList(userindex).Community.RepRank = "The Dreaded Lady"
End If


SendUserStatsBox (userindex)


End Sub

Sub CheckTitle(userindex As Integer)
On Error Resume Next

Dim Skill1 As Integer
Dim Skill2 As Integer
Dim Skill3 As Integer
Dim Skill4 As Integer
Dim Skill5 As Integer
Dim Skill6 As Integer
Dim Skill7 As Integer
Dim Skill8 As Integer
Dim Skill9 As Integer
Dim Skill10 As Integer
Dim Skill11 As Integer
Dim Skill12 As Integer
Dim Skill13 As Integer
Dim Skill14 As Integer
Dim Skill15 As Integer
Dim Skill16 As Integer
Dim Skill17 As Integer
Dim Skill18 As Integer
Dim Skill19 As Integer
Dim Skill20 As Integer
Dim Skill21 As Integer
Dim Skill22 As Integer
Dim Skill23 As Integer
Dim Skill24 As Integer
Dim Skill25 As Integer
Dim Skill26 As Integer
Dim Skill27 As Integer
Dim Skill28 As Integer
Dim skill29 As Integer

Skill1 = UserList(userindex).Stats.Skill1
Skill2 = UserList(userindex).Stats.Skill2
Skill3 = UserList(userindex).Stats.Skill3
Skill4 = UserList(userindex).Stats.Skill4
Skill5 = UserList(userindex).Stats.Skill5
Skill6 = UserList(userindex).Stats.Skill6
Skill7 = UserList(userindex).Stats.Skill7
Skill8 = UserList(userindex).Stats.Skill8
Skill9 = UserList(userindex).Stats.Skill9
Skill10 = UserList(userindex).Stats.Skill10
Skill11 = UserList(userindex).Stats.Skill11
Skill12 = UserList(userindex).Stats.Skill12
Skill13 = UserList(userindex).Stats.Skill13
Skill14 = UserList(userindex).Stats.Skill14
Skill15 = UserList(userindex).Stats.Skill15
Skill16 = UserList(userindex).Stats.Skill16
Skill17 = UserList(userindex).Stats.Skill17
Skill18 = UserList(userindex).Stats.Skill18
Skill19 = UserList(userindex).Stats.Skill19
Skill20 = UserList(userindex).Stats.Skill20
Skill21 = UserList(userindex).Stats.Skill21
Skill22 = UserList(userindex).Stats.Skill22
Skill23 = UserList(userindex).Stats.Skill23
Skill24 = UserList(userindex).Stats.Skill24
Skill25 = UserList(userindex).Stats.Skill25
Skill26 = UserList(userindex).Stats.Skill26
Skill27 = UserList(userindex).Stats.Skill27
Skill28 = UserList(userindex).Stats.Skill28


If Skill1 > Skill2 And Skill1 > Skill3 And Skill1 > Skill4 And Skill1 > Skill5 And Skill1 > Skill6 And Skill1 > Skill7 And Skill1 > Skill8 And Skill1 > Skill9 And Skill1 > Skill10 And Skill1 > Skill11 And Skill1 > Skill12 And Skill1 > Skill13 And Skill1 > Skill14 And Skill1 > Skill15 And Skill1 > Skill16 And Skill1 > Skill17 And Skill1 > Skill18 And Skill1 > Skill19 And Skill1 > Skill20 And Skill1 > Skill21 And Skill1 > Skill22 And Skill1 > Skill23 And Skill1 > Skill24 And Skill1 > Skill25 And Skill1 > Skill26 And Skill1 > Skill27 And Skill1 > Skill28 And SameTitle(userindex, "Cook") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to Cook due to your high cooking skill!" & FONTTYPE_INFO)
UserList(userindex).class = "Cook"
End If

If Skill2 > Skill1 And Skill2 > Skill3 And Skill2 > Skill4 And Skill2 > Skill5 And Skill2 > Skill6 And Skill2 > Skill7 And Skill2 > Skill8 And Skill2 > Skill10 And Skill2 > Skill10 And Skill2 > Skill11 And Skill12 And Skill2 > Skill13 And Skill2 > Skill14 And Skill2 > Skill15 And Skill2 > Skill16 And Skill2 > Skill17 And Skill2 > Skill18 And Skill2 > Skill19 And Skill2 > Skill20 And Skill2 > Skill21 And Skill2 > Skill22 And Skill2 > Skill23 And Skill2 > Skill24 And Skill2 > Skill25 And Skill2 > Skill26 And Skill2 > Skill27 And Skill2 > Skill28 And SameTitle(userindex, "Bard") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to Bard due to your high musicanship skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Bard"
End If

If Skill3 > Skill1 And Skill3 > Skill2 And Skill3 > Skill4 And Skill3 > Skill5 And Skill3 > Skill6 And Skill3 > Skill7 And Skill3 > Skill8 And Skill3 > Skill9 And Skill3 > Skill10 And Skill3 > Skill11 And Skill3 > Skill12 And Skill3 > Skill13 And Skill3 > Skill14 And Skill3 > Skill15 And Skill3 > Skill16 And Skill3 > Skill17 And Skill3 > Skill18 And Skill3 > Skill19 And Skill3 > Skill20 And Skill3 > Skill21 And Skill3 > Skill22 And Skill3 > Skill23 And Skill3 > Skill24 And Skill3 > Skill25 And Skill3 > Skill26 And Skill3 > Skill27 And Skill3 > Skill28 And SameTitle(userindex, "Tailor") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to tailor due to your high tailoring skill!" & FONTTYPE_INFO)
UserList(userindex).class = "Tailor"
End If

If Skill4 > Skill1 And Skill4 > Skill3 And Skill4 > Skill2 And Skill4 > Skill5 And Skill4 > Skill6 And Skill4 > Skill7 And Skill4 > Skill8 And Skill4 > Skill9 And Skill4 > Skill10 And Skill4 > Skill11 And Skill4 > Skill12 And Skill4 > Skill13 And Skill4 > Skill14 And Skill4 > Skill15 And Skill4 > Skill16 And Skill4 > Skill17 And Skill4 > Skill18 And Skill4 > Skill19 And Skill4 > Skill20 And Skill4 > Skill21 And Skill4 > Skill22 And Skill4 > Skill23 And Skill4 > Skill24 And Skill4 > Skill25 And Skill4 > Skill26 And Skill4 > Skill27 And Skill4 > Skill28 And SameTitle(userindex, "Woodworker") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to woodworker due to your high carpenting skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Woodworker"
End If

If Skill5 > Skill1 And Skill5 > Skill3 And Skill5 > Skill4 And Skill5 > Skill2 And Skill5 > Skill6 And Skill5 > Skill7 And Skill5 > Skill8 And Skill5 > Skill9 And Skill5 > Skill10 And Skill5 > Skill11 And Skill5 > Skill12 And Skill5 > Skill13 And Skill5 > Skill14 And Skill5 > Skill15 And Skill5 > Skill16 And Skill5 > Skill17 And Skill5 > Skill18 And Skill5 > Skill19 And Skill5 > Skill20 And Skill5 > Skill21 And Skill5 > Skill22 And Skill5 > Skill23 And Skill5 > Skill24 And Skill5 > Skill25 And Skill5 > Skill26 And Skill5 > Skill27 And Skill5 > Skill28 And SameTitle(userindex, "Woodworker") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to woodworker due to your high lumberjacking skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Woodworker"
End If

If Skill8 > Skill1 And Skill8 > Skill3 And Skill8 > Skill4 And Skill8 > Skill5 And Skill8 > Skill6 And Skill8 > Skill7 And Skill8 > Skill2 And Skill8 > Skill9 And Skill8 > Skill10 And Skill8 > Skill11 And Skill8 > Skill12 And Skill8 > Skill13 And Skill8 > Skill14 And Skill8 > Skill15 And Skill8 > Skill16 And Skill8 > Skill17 And Skill8 > Skill18 And Skill8 > Skill19 And Skill8 > Skill20 And Skill8 > Skill21 And Skill8 > Skill22 And Skill8 > Skill23 And Skill8 > Skill24 And Skill8 > Skill25 And Skill8 > Skill26 And Skill8 > Skill27 And Skill8 > Skill28 And SameTitle(userindex, "Merchant") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to merchant due to your high merchant skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Merchant"
End If

If Skill9 > Skill1 And Skill9 > Skill3 And Skill9 > Skill4 And Skill9 > Skill5 And Skill9 > Skill6 And Skill9 > Skill7 And Skill9 > Skill8 And Skill9 > Skill2 And Skill9 > Skill10 And Skill9 > Skill11 And Skill9 > Skill12 And Skill9 > Skill13 And Skill9 > Skill14 And Skill9 > Skill15 And Skill9 > Skill16 And Skill9 > Skill17 And Skill9 > Skill18 And Skill9 > Skill19 And Skill9 > Skill20 And Skill9 > Skill21 And Skill9 > Skill22 And Skill9 > Skill23 And Skill9 > Skill24 And Skill9 > Skill25 And Skill9 > Skill26 And Skill9 > Skill27 And Skill9 > Skill28 And SameTitle(userindex, "Blacksmith") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to blacksmith due to your high blacksmithing skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Blacksmith"
End If

If Skill11 > Skill1 And Skill11 > Skill3 And Skill11 > Skill4 And Skill11 > Skill5 And Skill11 > Skill6 And Skill11 > Skill7 And Skill11 > Skill8 And Skill11 > Skill9 And Skill11 > Skill10 And Skill11 > Skill2 And Skill11 > Skill12 And Skill11 > Skill13 And Skill11 > Skill14 And Skill11 > Skill15 And Skill11 > Skill16 And Skill11 > Skill17 And Skill11 > Skill18 And Skill11 > Skill19 And Skill11 > Skill20 And Skill11 > Skill21 And Skill11 > Skill22 And Skill11 > Skill23 And Skill11 > Skill24 And Skill11 > Skill25 And Skill11 > Skill26 And Skill11 > Skill27 And Skill11 > Skill28 And SameTitle(userindex, "Mage") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to mage do to your high magery skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Mage"
End If

If Skill12 > Skill1 And Skill12 > Skill3 And Skill12 > Skill4 And Skill12 > Skill5 And Skill12 > Skill6 And Skill12 > Skill7 And Skill12 > Skill8 And Skill12 > Skill9 And Skill12 > Skill10 And Skill12 > Skill11 And Skill12 > Skill2 And Skill12 > Skill13 And Skill12 > Skill14 And Skill12 > Skill15 And Skill12 > Skill16 And Skill12 > Skill17 And Skill12 > Skill18 And Skill12 > Skill19 And Skill12 > Skill20 And Skill12 > Skill21 And Skill12 > Skill22 And Skill12 > Skill23 And Skill12 > Skill24 And Skill12 > Skill25 And Skill12 > Skill26 And Skill12 > Skill27 And Skill12 > Skill28 And SameTitle(userindex, "Thief") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to thief due to your high lockpicking skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Thief"
End If

If Skill13 > Skill1 And Skill13 > Skill3 And Skill13 > Skill4 And Skill13 > Skill5 And Skill13 > Skill6 And Skill13 > Skill7 And Skill13 > Skill8 And Skill13 > Skill9 And Skill13 > Skill10 And Skill13 > Skill2 And Skill13 > Skill12 And Skill13 > Skill2 And Skill13 > Skill14 And Skill13 > Skill15 And Skill13 > Skill16 And Skill13 > Skill17 And Skill13 > Skill18 And Skill13 > Skill19 And Skill13 > Skill20 And Skill13 > Skill21 And Skill13 > Skill22 And Skill13 > Skill23 And Skill13 > Skill24 And Skill13 > Skill25 And Skill13 > Skill26 And Skill13 > Skill27 And Skill13 > Skill28 And SameTitle(userindex, "Thief") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to theif due to your high pickpocketing skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Thief"
End If

If Skill16 > Skill1 And Skill16 > Skill3 And Skill16 > Skill4 And Skill16 > Skill5 And Skill16 > Skill6 And Skill16 > Skill7 And Skill16 > Skill8 And Skill16 > Skill9 And Skill16 > Skill10 And Skill16 > Skill2 And Skill16 > Skill12 And Skill16 > Skill13 And Skill16 > Skill14 And Skill16 > Skill15 And Skill16 > Skill2 And Skill16 > Skill17 And Skill16 > Skill18 And Skill16 > Skill19 And Skill16 > Skill20 And Skill16 > Skill21 And Skill16 > Skill22 And Skill16 > Skill23 And Skill16 > Skill24 And Skill16 > Skill25 And Skill16 > Skill26 And Skill16 > Skill27 And Skill16 > Skill28 And SameTitle(userindex, "Warrior") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to warrior due to your high swordmanship skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Warrior"
End If

If Skill17 > Skill1 And Skill17 > Skill3 And Skill17 > Skill4 And Skill17 > Skill5 And Skill17 > Skill6 And Skill17 > Skill7 And Skill17 > Skill8 And Skill17 > Skill9 And Skill17 > Skill10 And Skill17 > Skill2 And Skill17 > Skill12 And Skill17 > Skill13 And Skill17 > Skill14 And Skill17 > Skill15 And Skill17 > Skill16 And Skill17 > Skill2 And Skill17 > Skill18 And Skill17 > Skill19 And Skill17 > Skill20 And Skill17 > Skill21 And Skill17 > Skill22 And Skill17 > Skill23 And Skill17 > Skill24 And Skill17 > Skill25 And Skill17 > Skill26 And Skill17 > Skill27 And Skill17 > Skill28 And SameTitle(userindex, "Warrior") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to warrior due to your high parrying skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Warrior"
End If

If Skill18 > Skill1 And Skill18 > Skill3 And Skill18 > Skill4 And Skill18 > Skill5 And Skill18 > Skill6 And Skill18 > Skill7 And Skill18 > Skill8 And Skill18 > Skill9 And Skill18 > Skill10 And Skill18 > Skill2 And Skill18 > Skill12 And Skill18 > Skill13 And Skill18 > Skill14 And Skill18 > Skill15 And Skill18 > Skill16 And Skill18 > Skill17 And Skill18 > Skill2 And Skill18 > Skill19 And Skill18 > Skill20 And Skill18 > Skill21 And Skill18 > Skill22 And Skill18 > Skill23 And Skill18 > Skill24 And Skill18 > Skill25 And Skill18 > Skill26 And Skill18 > Skill27 And Skill18 > Skill28 And SameTitle(userindex, "Animal Tamer") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to animal tamer due to your high animal taming skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Animal Tamer"
End If

If Skill19 > Skill1 And Skill19 > Skill3 And Skill19 > Skill4 And Skill19 > Skill5 And Skill19 > Skill6 And Skill19 > Skill7 And Skill19 > Skill8 And Skill19 > Skill2 And Skill19 > Skill10 And Skill19 > Skill2 And Skill19 > Skill12 And Skill19 > Skill13 And Skill19 > Skill14 And Skill19 > Skill15 And Skill19 > Skill16 And Skill19 > Skill17 And Skill19 > Skill18 And Skill19 > Skill19 And Skill19 > Skill20 And Skill19 > Skill21 And Skill19 > Skill22 And Skill19 > Skill23 And Skill19 > Skill24 And Skill19 > Skill25 And Skill19 > Skill26 And Skill19 > Skill27 And Skill19 > Skill28 And SameTitle(userindex, "Cleric") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to cleric due to your high religion lore skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Cleric"
End If

If Skill21 > Skill1 And Skill21 > Skill3 And Skill21 > Skill4 And Skill21 > Skill5 And Skill21 > Skill6 And Skill21 > Skill7 And Skill21 > Skill8 And Skill21 > Skill9 And Skill21 > Skill10 And Skill21 > Skill2 And Skill21 > Skill12 And Skill21 > Skill13 And Skill21 > Skill14 And Skill21 > Skill15 And Skill21 > Skill16 And Skill21 > Skill17 And Skill21 > Skill18 And Skill21 > Skill19 And Skill21 > Skill20 And Skill21 > Skill2 And Skill21 > Skill22 And Skill21 > Skill23 And Skill21 > Skill24 And Skill21 > Skill25 And Skill21 > Skill26 And Skill21 > Skill27 And Skill21 > Skill28 And SameTitle(userindex, "Miner") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to miner due to your high mining skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Miner"
End If

If Skill23 > Skill1 And Skill23 > Skill3 And Skill23 > Skill4 And Skill23 > Skill5 And Skill23 > Skill6 And Skill23 > Skill7 And Skill23 > Skill8 And Skill23 > Skill9 And Skill23 > Skill10 And Skill23 > Skill2 And Skill23 > Skill12 And Skill23 > Skill13 And Skill23 > Skill14 And Skill23 > Skill15 And Skill23 > Skill16 And Skill23 > Skill17 And Skill23 > Skill18 And Skill23 > Skill19 And Skill23 > Skill20 And Skill23 > Skill21 And Skill23 > Skill22 And Skill23 > Skill2 And Skill23 > Skill24 And Skill23 > Skill25 And Skill23 > Skill26 And Skill23 > Skill27 And Skill23 > Skill28 And SameTitle(userindex, "Healer") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to healer due to your high healing skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Healer"
End If

If Skill28 > Skill1 And Skill28 > Skill3 And Skill28 > Skill4 And Skill28 > Skill5 And Skill28 > Skill6 And Skill28 > Skill7 And Skill28 > Skill8 And Skill28 > Skill9 And Skill28 > Skill10 And Skill28 > Skill2 And Skill28 > Skill12 And Skill28 > Skill13 And Skill28 > Skill14 And Skill28 > Skill15 And Skill28 > Skill16 And Skill28 > Skill17 And Skill28 > Skill18 And Skill28 > Skill19 And Skill28 > Skill20 And Skill28 > Skill21 And Skill28 > Skill22 And Skill28 > Skill23 And Skill28 > Skill24 And Skill28 > Skill25 And Skill28 > Skill26 And Skill28 > Skill27 And Skill28 > Skill2 And SameTitle(userindex, "Archer") = False Then
Call SendData(ToIndex, userindex, 0, "@Your class has changed to archer due to your high archery skill !" & FONTTYPE_INFO)
UserList(userindex).class = "Archer"
End If

Call SendUserStatsBox(userindex)

End Sub

Sub CheckUserLevel(userindex As Integer)
On Error Resume Next
'*****************************************************************
'Checks user's exp and levels user up
'*****************************************************************

'Make sure user hasn't reached max level
If UserList(userindex).Stats.ELV = STAT_MAXELV Then
    UserList(userindex).Stats.EXP = 0
    UserList(userindex).Stats.ELU = 0
    Exit Sub
End If

'If exp >= then elu then level up user
If UserList(userindex).Stats.EXP >= UserList(userindex).Stats.ELU Then

    UserList(userindex).Stats.ELV = UserList(userindex).Stats.ELV + 1
    UserList(userindex).Stats.EXP = 0
    
    If UserList(userindex).Stats.ELV < 5 And UserList(userindex).Stats.ELV > 0 Then UserList(userindex).Stats.ELU = UserList(userindex).Stats.ELU * 2
    If UserList(userindex).Stats.ELV < 10 And UserList(userindex).Stats.ELV > 4 Then UserList(userindex).Stats.ELU = UserList(userindex).Stats.ELU * 1.9
    If UserList(userindex).Stats.ELV < 15 And UserList(userindex).Stats.ELV > 9 Then UserList(userindex).Stats.ELU = UserList(userindex).Stats.ELU * 1.8
    If UserList(userindex).Stats.ELV < 20 And UserList(userindex).Stats.ELV > 14 Then UserList(userindex).Stats.ELU = UserList(userindex).Stats.ELU * 1.7
    If UserList(userindex).Stats.ELV < 25 And UserList(userindex).Stats.ELV > 19 Then UserList(userindex).Stats.ELU = UserList(userindex).Stats.ELU * 1.6
    If UserList(userindex).Stats.ELV < 30 And UserList(userindex).Stats.ELV > 24 Then UserList(userindex).Stats.ELU = UserList(userindex).Stats.ELU * 1.5
    If UserList(userindex).Stats.ELV > 29 Then UserList(userindex).Stats.ELU = UserList(userindex).Stats.ELU * 1.4


    UserList(userindex).Stats.MaxHP = UserList(userindex).Stats.MaxHP + 1
    UserList(userindex).Stats.MaxSTA = UserList(userindex).Stats.MaxSTA + 2
    UserList(userindex).Stats.MaxMAN = UserList(userindex).Stats.MaxMAN + 15
    
    UserList(userindex).Stats.MaxHIT = UserList(userindex).Stats.MaxHIT + 1
    UserList(userindex).Stats.MinHIT = UserList(userindex).Stats.MinHIT + 1
        
    SendData ToIndex, userindex, 0, "@You gained 5 training points, and your attributes has gone up !" & FONTTYPE_INFO
    SendData ToIndex, userindex, 0, "PLW" & SOUND_SPELLEFFECT1
    UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints + 5
    SendUserStatsBox userindex

Call SendData(ToIndex, userindex, 0, "PL3" & 11)

End If

    SendUserStatsBox userindex

End Sub

