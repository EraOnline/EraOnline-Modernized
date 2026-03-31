Attribute VB_Name = "General"
Option Explicit

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
Function ReadField(ByVal Pos As Integer, ByVal Text As String, ByVal SepASCII As Integer) As String
On Error Resume Next
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



