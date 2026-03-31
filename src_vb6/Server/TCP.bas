Attribute VB_Name = "TCP"
Option Explicit


'Constants used in the SendData sub
Public Const ToIndex = 0 'Send data to a single User index
Public Const ToAll = 1 'Send it to all User indexa
Public Const ToMap = 2 'Send it to all users in a map
Public Const ToPCArea = 3 'Send to all users in a user's area
Public Const ToNone = 4 'Send to none
Public Const ToAllButIndex = 5 'Send to all but the index
Public Const ToMapButIndex = 6 'Send to all on a map but the index
Public Const ToGM = 7 'Send to a random GM


' General constants used with most of the controls
Public Const INVALID_HANDLE = -1
Public Const CONTROL_ERRIGNORE = 0
Public Const CONTROL_ERRDISPLAY = 1


' SocketWrench Control Actions
Public Const SOCKET_OPEN = 1
Public Const SOCKET_CONNECT = 2
Public Const SOCKET_LISTEN = 3
Public Const SOCKET_ACCEPT = 4
Public Const SOCKET_CANCEL = 5
Public Const SOCKET_FLUSH = 6
Public Const SOCKET_CLOSE = 7
Public Const SOCKET_DISCONNECT = 7
Public Const SOCKET_ABORT = 8

' SocketWrench Control States
Public Const SOCKET_NONE = 0
Public Const SOCKET_IDLE = 1
Public Const SOCKET_LISTENING = 2
Public Const SOCKET_CONNECTING = 3
Public Const SOCKET_ACCEPTING = 4
Public Const SOCKET_RECEIVING = 5
Public Const SOCKET_SENDING = 6
Public Const SOCKET_CLOSING = 7

' Socket Address Families
Public Const AF_UNSPEC = 0
Public Const AF_UNIX = 1
Public Const AF_INET = 2

' Socket Types
Public Const SOCK_STREAM = 1
Public Const SOCK_DGRAM = 2
Public Const SOCK_RAW = 3
Public Const SOCK_RDM = 4
Public Const SOCK_SEQPACKET = 5

' Protocol Types
Public Const IPPROTO_IP = 0
Public Const IPPROTO_ICMP = 1
Public Const IPPROTO_GGP = 2
Public Const IPPROTO_TCP = 6
Public Const IPPROTO_PUP = 12
Public Const IPPROTO_UDP = 17
Public Const IPPROTO_IDP = 22
Public Const IPPROTO_ND = 77
Public Const IPPROTO_RAW = 255
Public Const IPPROTO_MAX = 256


' Network Addresses
Public Const INADDR_ANY = "0.0.0.0"
Public Const INADDR_LOOPBACK = "127.0.0.1"
Public Const INADDR_NONE = "255.255.255.255"

' Shutdown Values
Public Const SOCKET_READ = 0
Public Const SOCKET_WRITE = 1
Public Const SOCKET_READWRITE = 2

' SocketWrench Error Response
Public Const SOCKET_ERRIGNORE = 0
Public Const SOCKET_ERRDISPLAY = 1

' SocketWrench Error Codes
Public Const WSABASEERR = 24000
Public Const WSAEINTR = 24004
Public Const WSAEBADF = 24009
Public Const WSAEACCES = 24013
Public Const WSAEFAULT = 24014
Public Const WSAEINVAL = 24022
Public Const WSAEMFILE = 24024
Public Const WSAEWOULDBLOCK = 24035
Public Const WSAEINPROGRESS = 24036
Public Const WSAEALREADY = 24037
Public Const WSAENOTSOCK = 24038
Public Const WSAEDESTADDRREQ = 24039
Public Const WSAEMSGSIZE = 24040
Public Const WSAEPROTOTYPE = 24041
Public Const WSAENOPROTOOPT = 24042
Public Const WSAEPROTONOSUPPORT = 24043
Public Const WSAESOCKTNOSUPPORT = 24044
Public Const WSAEOPNOTSUPP = 24045
Public Const WSAEPFNOSUPPORT = 24046
Public Const WSAEAFNOSUPPORT = 24047
Public Const WSAEADDRINUSE = 24048
Public Const WSAEADDRNOTAVAIL = 24049
Public Const WSAENETDOWN = 24050
Public Const WSAENETUNREACH = 24051
Public Const WSAENETRESET = 24052
Public Const WSAECONNABORTED = 24053
Public Const WSAECONNRESET = 24054
Public Const WSAENOBUFS = 24055
Public Const WSAEISCONN = 24056
Public Const WSAENOTCONN = 24057
Public Const WSAESHUTDOWN = 24058
Public Const WSAETOOMANYREFS = 24059
Public Const WSAETIMEDOUT = 24060
Public Const WSAECONNREFUSED = 24061
Public Const WSAELOOP = 24062
Public Const WSAENAMETOOLONG = 24063
Public Const WSAEHOSTDOWN = 24064
Public Const WSAEHOSTUNREACH = 24065
Public Const WSAENOTEMPTY = 24066
Public Const WSAEPROCLIM = 24067
Public Const WSAEUSERS = 24068
Public Const WSAEDQUOT = 24069
Public Const WSAESTALE = 24070
Public Const WSAEREMOTE = 24071
Public Const WSASYSNOTREADY = 24091
Public Const WSAVERNOTSUPPORTED = 24092
Public Const WSANOTINITIALISED = 24093
Public Const WSAHOST_NOT_FOUND = 25001
Public Const WSATRY_AGAIN = 25002
Public Const WSANO_RECOVERY = 25003
Public Const WSANO_DATA = 25004
Public Const WSANO_ADDRESS = 2500

Sub ConnectNewUser(userindex As Integer, Name As String, Password As String, Body As Integer, Head As Integer, Town As String, WeaponAnim As Integer, Race As String, class As String, ShieldAnim As Integer, Gender As String, Email As String, betapass As String, SpecSkill1 As String, SpecSkill2 As String, SpecSkill3 As String, theid As Long)
'*****************************************************************
'Opens a new user. Loads default vars, saves then calls connectuser
'*****************************************************************
Dim LoopC As Integer
On Error Resume Next


'Check for Character file
If FileExist(CharPath & UCase(Name) & ".chr", vbNormal) = True Then
    Call SendData(ToIndex, userindex, 0, "!!Character name already exist. Try another name.")
   CloseSocket (userindex)
    Exit Sub
End If
  
  
  
'create file
UserList(userindex).Name = Name
UserList(userindex).Password = Password
UserList(userindex).Char.Heading = SOUTH
UserList(userindex).Desc = "The Brave Adventurer"
UserList(userindex).Race = Race
UserList(userindex).Gender = Gender
UserList(userindex).Char.Body = Body
UserList(userindex).Town = Town
UserList(userindex).Email = Email
UserList(userindex).theid = theid

UserList(userindex).Flags.SpecSkill1 = SpecSkill1
UserList(userindex).Flags.SpecSkill2 = SpecSkill2
UserList(userindex).Flags.SpecSkill3 = SpecSkill3

UserList(userindex).Flags.YourID = RandomNumber(100, 99999)

'Human faces random
If Race = "Human" Then
If Gender = "Male" Then
UserList(userindex).Char.Head = Int(RandomNumber(6, 15))
Else
UserList(userindex).Char.Head = Int(RandomNumber(16, 25))
End If
End If
'End human faces random

'haaki random
If Race = "Haaki" Then
If Gender = "Male" Then
UserList(userindex).Char.Head = Int(RandomNumber(26, 35))
Else
UserList(userindex).Char.Head = Int(RandomNumber(36, 45))
End If
End If
'End haaki faces random

'wood elf random
If Race = "Wood Elf" Then
If Gender = "Male" Then
UserList(userindex).Char.Head = Int(RandomNumber(46, 55))
Else
UserList(userindex).Char.Head = Int(RandomNumber(56, 65))
End If
End If
'End wood elf faces random

'dark elf random
If Race = "Dark Elf" Then
If Gender = "Male" Then
UserList(userindex).Char.Head = Int(RandomNumber(66, 74))
Else
UserList(userindex).Char.Head = Int(RandomNumber(75, 84))
End If
End If
'End dark elf faces random

UserList(userindex).Stats.MET = 1
UserList(userindex).Stats.MaxHP = 30
UserList(userindex).Stats.MinHP = 30

UserList(userindex).Stats.FIT = 1
UserList(userindex).Stats.MaxSTA = 5
UserList(userindex).Stats.MinSTA = 5

UserList(userindex).Stats.MaxHIT = 4
UserList(userindex).Stats.MinHIT = 2

UserList(userindex).Stats.GLD = 0
UserList(userindex).Stats.BANKGLD = 0
UserList(userindex).Stats.Food = 0
UserList(userindex).Stats.PracticePoints = 0
UserList(userindex).Stats.Drink = 0

UserList(userindex).Stats.EXP = 0
UserList(userindex).Stats.ELU = 300
UserList(userindex).Stats.ELV = 1

UserList(userindex).Flags.StartHead = UserList(userindex).Char.Head
UserList(userindex).Flags.StartName = UserList(userindex).Name


UserList(userindex).Char.WeaponAnim = WeaponAnim
UserList(userindex).Char.ShieldAnim = ShieldAnim

UserList(userindex).class = class

UserList(userindex).Stats.Anchor = 0
UserList(userindex).Flags.Criminal = 0
UserList(userindex).Flags.status = 0
UserList(userindex).Flags.Battlemode = 0

UserList(userindex).Community.NobleRep = 0
UserList(userindex).Community.UnderRep = 0
UserList(userindex).Community.CommonRep = 0
UserList(userindex).Community.BendarrRep = 0
UserList(userindex).Community.VeegaRep = 0
UserList(userindex).Community.ZeendicRep = 0
UserList(userindex).Community.GriigoRep = 0
UserList(userindex).Community.HyliiosRep = 0
UserList(userindex).Community.OverallRep = 500
UserList(userindex).Community.RepRank = "Unknown"

UserList(userindex).Flags.Strike = 0

UserList(userindex).Object(1).ObjIndex = 0
UserList(userindex).Object(2).ObjIndex = 0
UserList(userindex).Object(3).ObjIndex = 0
UserList(userindex).Object(4).ObjIndex = 0
UserList(userindex).Object(5).ObjIndex = 0
UserList(userindex).Object(6).ObjIndex = 0
UserList(userindex).Object(7).ObjIndex = 0
UserList(userindex).Object(8).ObjIndex = 0
UserList(userindex).Object(9).ObjIndex = 0
UserList(userindex).Object(10).ObjIndex = 0
UserList(userindex).Object(11).ObjIndex = 0
UserList(userindex).Object(12).ObjIndex = 0
UserList(userindex).Object(13).ObjIndex = 0
UserList(userindex).Object(14).ObjIndex = 0
UserList(userindex).Object(15).ObjIndex = 0
UserList(userindex).Object(16).ObjIndex = 0
UserList(userindex).Object(17).ObjIndex = 0
UserList(userindex).Object(18).ObjIndex = 0
UserList(userindex).Object(19).ObjIndex = 0
UserList(userindex).Object(20).ObjIndex = 0


'Give one rusty dagger
UserList(userindex).Object(3).ObjIndex = 33
UserList(userindex).Object(3).Amount = 1

'Give 5 water flasks
UserList(userindex).Object(4).ObjIndex = 22
UserList(userindex).Object(4).Amount = 5

'Give 5 breads
UserList(userindex).Object(5).ObjIndex = 95
UserList(userindex).Object(5).Amount = 5

'Give a starting suit
UserList(userindex).Object(2).ObjIndex = 145
UserList(userindex).Object(2).Amount = 1
UserList(userindex).ClothingEqpObjindex = 145
UserList(userindex).ClothingEqpSlot = 2


Call GiveSkills(userindex)


UserList(userindex).Object(UserList(userindex).ClothingEqpSlot).Equipped = 1

Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Name) & ".chr")
Call ConnectUser(userindex, Name, Password, UserList(userindex).Town, UserList(userindex).theid)
Call CheckID(userindex, theid)


End Sub

Sub CloseSocket(userindex As Integer)
On Error Resume Next

'*****************************************************************
'Close the users socket
'*****************************************************************

  
If userindex > 0 Then

    frmMain.Socket2(userindex).Disconnect

    If UserList(userindex).Flags.UserLogged = True Then
        Call CloseUser(userindex)
    End If

    UserList(userindex).ConnID = -1
    frmMain.Socket2(userindex).Cleanup
    Unload frmMain.Socket2(userindex)

End If

End Sub
Sub SendData(sndRoute As Byte, sndIndex As Integer, sndMap As Integer, sndData As String)
'****************************************************************
'Sends data to sendRoute
'*****************************************************************
Dim LoopC As Integer
Dim X As Integer
Dim Y As Integer
Dim TheGM As Integer
On Error Resume Next

'Add End character
sndData = sndData & ENDC
  
'send NONE
If sndRoute = ToNone Then
    Exit Sub
End If
  
  
'Send to All
If sndRoute = ToAll Then
    For LoopC = 1 To LastUser

        frmMain.Socket2(LoopC).Write sndData, Len(sndData)
      
    Next LoopC
    Exit Sub
End If

'Send to a GM
If sndRoute = ToGM Then

For LoopC = 1 To LastUser
If WizCheck(UserList(LoopC).Flags.StartName) = True Then frmMain.Socket2(LoopC).Write sndData, Len(sndData)
Next LoopC
          
Exit Sub
End If

'Send to everyone but the sndindex
If sndRoute = ToAllButIndex Then
    For LoopC = 1 To LastUser
              
      If (UserList(LoopC).ConnID > -1) And (LoopC <> sndIndex) Then
            frmMain.Socket2(LoopC).Write sndData, Len(sndData)
      End If
      
    Next LoopC
    Exit Sub
End If

'Send to Map
If sndRoute = ToMap Then

    For LoopC = 1 To LastUser

        If (UserList(LoopC).ConnID > -1) Then
            If UserList(LoopC).Pos.map = sndMap Then
                frmMain.Socket2(LoopC).Write sndData, Len(sndData)
            End If
        End If
      
    Next LoopC
    
    Exit Sub
End If


'Send to everone on map but sndIndex
If sndRoute = ToMapButIndex Then

    For LoopC = 1 To LastUser

        If (UserList(LoopC).ConnID > -1) And LoopC <> sndIndex Then
            If UserList(LoopC).Pos.map = sndMap Then
                frmMain.Socket2(LoopC).Write sndData, Len(sndData)
             End If
        End If
  
    Next LoopC
    
    Exit Sub
End If

'Send to PC Area
If sndRoute = ToPCArea Then
    
    For Y = UserList(sndIndex).Pos.Y - MinYBorder + 1 To UserList(sndIndex).Pos.Y + MinYBorder - 1
        For X = UserList(sndIndex).Pos.X - MinXBorder + 1 To UserList(sndIndex).Pos.X + MinXBorder - 1

            If MapData(sndMap, X, Y).userindex > 0 Then

                frmMain.Socket2(MapData(sndMap, X, Y).userindex).Write sndData, Len(sndData)

            End If
        
        Next X
    Next Y
    
    Exit Sub
End If

'Send to the UserIndex
If sndRoute = ToIndex Then
    frmMain.Socket2(sndIndex).Write sndData, Len(sndData)
    Exit Sub
End If



End Sub
Sub ConnectUser(userindex As Integer, Name As String, Password As String, Town As String, theid As Long)
'*****************************************************************
'Reads the users .chr file and loads into Userlist array
'*****************************************************************
On Error Resume Next

'Check for max users
If NumUsers >= MaxUsers Then
    Call SendData(ToIndex, userindex, 0, "!!Too many users logged on. Please report this to Spotlight Studios so they may see if another server is needed.")

    CloseSocket (userindex)
    Exit Sub
End If
    
'Check to see is user already logged with IP
If AllowMultiLogins = 0 Then
    If CheckForSameIP(userindex, frmMain.Socket2(userindex).PeerAddress) = True Then
        Call SendData(ToIndex, userindex, 0, "!!Sorry, your IP address is already logged on to the server. Please only use one character at a time.")

        CloseSocket (userindex)
        Exit Sub
    End If
End If


'Check to see is user already logged with Name
If CheckForSameName(userindex, Name) = True Then
    Call SendData(ToIndex, userindex, 0, "!!Sorry, a user with the same name is already logged on.")
    CloseSocket (userindex)
    Exit Sub
End If

'Check for Character file
If FileExist(CharPath & UCase(Name) & ".chr", vbNormal) = False Then
Call SendData(ToIndex, userindex, 0, "WR2")
  Call SendData(ToIndex, userindex, 0, "!!Character does not exist.")
    CloseSocket (userindex)
    Exit Sub
End If

'Check to see if "" password
If GetVar(CharPath & UCase(Name) & ".chr", "INIT", "Password") = "" Then
Call WriteVar(CharPath & UCase(Name) & ".chr", "INIT", "Password", Password)
End If

'Check Password
If Password <> GetVar(CharPath & UCase(Name) & ".chr", "INIT", "Password") Then
    Call SendData(ToIndex, userindex, 0, "WR1")
    Call SendData(ToIndex, userindex, 0, "!!Wrong Password.")
    CloseSocket (userindex)
    Exit Sub
End If

UserList(userindex).Desc = ""

'Load init vars from file
Call LoadUserInit(userindex, CharPath & UCase(Name) & ".chr")
Call LoadUserStats(userindex, CharPath & UCase(Name) & ".chr")
UserList(userindex).Flags.Pickpocket = 0
Call SendData(ToIndex, userindex, 0, "SUI" & userindex) 'Send User index

If UserList(userindex).Pos.map > 0 Then
 UserList(userindex).Pos.map = UserList(userindex).Pos.map
 UserList(userindex).Pos.X = UserList(userindex).Pos.X
 UserList(userindex).Pos.Y = UserList(userindex).Pos.Y
Else
If UserList(userindex).Town = "CastleFall" Then UserList(userindex).Pos = CastleFallStartPos
If UserList(userindex).Town = "Bernvillage" Then UserList(userindex).Pos = BernVillageStartPos
If UserList(userindex).Town = "Gorth" Then UserList(userindex).Pos = GorthStartPos
If UserList(userindex).Town = "Angelmoor" Then UserList(userindex).Pos = AngelmoorStartPos
If UserList(userindex).Town = "Jemhoo" Then UserList(userindex).Pos = JemhooStartPos
If UserList(userindex).Town = "Denc" Then UserList(userindex).Pos = DencStartPos
If UserList(userindex).Town = "Valen" Then UserList(userindex).Pos = ValenStartPos
If UserList(userindex).Town = "Valenfall" Then UserList(userindex).Pos = ValenfallStartPos
If UserList(userindex).Town = "Molg" Then UserList(userindex).Pos = MolgStartPos
If UserList(userindex).Town = "Ug" Then UserList(userindex).Pos = UgStartPos
End If


'Defect character
If UserList(userindex).Pos.map = 0 Then
Call SendData(ToIndex, userindex, 0, "!!The character had a bad world position. You will be put in Castlefall city. Sorry for the inconvinience.")
UserList(userindex).Pos = CastleFallStartPos
End If

'Check to see if defect character
If UserList(userindex).Stats.MaxHP < 5 Then
Call SendData(ToIndex, userindex, 0, "!!Your character are defect. Please erase your character before proceeding in making a new one or a new one with the same name. This one cannot be played.")
CloseUser (userindex)
Exit Sub
End If

'Check to see if defect character
If UserList(userindex).Stats.ELU < 5 Then
Call SendData(ToIndex, userindex, 0, "!!Your character are defect. Please erase your character before proceeding in making a new one or a new one with the same name. This one cannot be played.")
CloseUser (userindex)
Exit Sub
End If

'Get closest legal pos
Call ClosestLegalPos(userindex, UserList(userindex).Pos, UserList(userindex).Pos)
If LegalPos(userindex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y) = False Then
    Call SendData(ToIndex, userindex, 0, "!!No legal position found to put character: Please try logging in again.")
    CloseUser (userindex)
    Exit Sub
End If

'Get mod name
UserList(userindex).Name = Name
If WizCheck(UserList(userindex).Name) Then
    UserList(userindex).modName = Name & " <GameMaster>"
Else
    UserList(userindex).modName = Name
End If

'************** Initialize variables
UserList(userindex).Password = Password
UserList(userindex).IP = frmMain.Socket2(userindex).PeerAddress
UserList(userindex).Flags.UserLogged = True
  
 
'Update users' client
Call SendData(ToIndex, userindex, 0, "SUI" & userindex) 'Send User index
Call SendData(ToIndex, userindex, 0, "SCM" & UserList(userindex).Pos.map) 'Load map
Call SendData(ToIndex, userindex, 0, "SMN" & MapInfo(UserList(userindex).Pos.map).Name) 'Change map name
Call SendData(ToIndex, userindex, 0, "PLM" & MapInfo(UserList(userindex).Pos.map).Music) 'Set music
Call SendData(ToIndex, userindex, 0, "@LOADING PLEASE WAIT. DONT PRESS ANY KEYS..." & FONTTYPE_INFO)

'Update...
Call UpdateUserMap(userindex)
Call SendUserStatsBox(userindex)
Call UpdateUserInv(True, userindex, 0)
Call UpdateUserSpell(True, userindex, 0)
Call CheckUserLevel(userindex)
Call CheckRep(userindex)
UserList(userindex).Flags.Pickpocket = 0

'update Num of Users
If userindex > LastUser Then LastUser = userindex
NumUsers = NumUsers + 1
frmMain.txStatus.Text = "Total Users= " & NumUsers
MapInfo(UserList(userindex).Pos.map).NumUsers = MapInfo(UserList(userindex).Pos.map).NumUsers + 1
  
'Make user's Char
Call MakeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
Call SendData(ToIndex, userindex, 0, "SUC" & UserList(userindex).Char.CharIndex)

'Refresh list box and send log on string
Call RefreshUserListBox
  
Call SendData(ToIndex, userindex, 0, "@Done loading !" & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@Welcome to Era Online ! Type /HELP for beginner`s tips or Press F2 to start VOICE tutorial !" & FONTTYPE_INFO)
Call SendData(ToIndex, userindex, 0, "@Report a bug or map error by typing /BUG then a short description." & FONTTYPE_SKILLINFO)

'Check to see if clan is active or disbanded
If UserList(userindex).Clan = "" Then
'Do nothing
Else
If FileExist(ClanPath & UCase(UserList(userindex).Clan) & ".txt", vbNormal) = True Then
'Do nothing
Else
Call SendData(ToIndex, userindex, 0, "@The clan you were once a member of, has been disbanded, and you are no longer a member of any clan." & FONTTYPE_INFO)
UserList(userindex).Clan = ""
UserList(userindex).ClanMember = ""
UserList(userindex).ClanRank = ""
End If
End If

'If it rains/snows, send rain command to client
If Raining = 1 Then
Call SendData(ToIndex, userindex, 0, "RAI")
End If

'If user has tamed animal, warp tamed animal to user
If GetVar(CharPath & UCase(Name) & ".chr", "STATS", "AnimalIndex") > 0 Then
UserList(userindex).Stats.OwnAnimal = UserList(userindex).Stats.AnimalIndex
Call WarpNPCChar(UserList(userindex).Stats.AnimalIndex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y + 1)
Call SendData(ToIndex, userindex, 0, "@Your tamed animal looks happy to see you !" & FONTTYPE_INFO)
NPCList(UserList(userindex).Stats.AnimalIndex).Owner = userindex
NPCList(UserList(userindex).Stats.AnimalIndex).Tamed = 1
NPCList(UserList(userindex).Stats.AnimalIndex).Movement = 6
NPCList(UserList(userindex).Stats.AnimalIndex).Hostile = 0
NPCList(UserList(userindex).Stats.AnimalIndex).Attackable = 0
End If

'Log it-
Open App.Path & "\Connect.log" For Append Shared As #5
Print #5, UserList(userindex).Name & " logged in. UserIndex:" & userindex & " " & Time & " " & Date
Close #5

Call SendData(ToIndex, userindex, 0, "TIP")
Call CheckID(userindex, theid)

End Sub
Sub EraseChar(userindex As Integer, Name As String, Password As String, Town As String, theid As Long)
On Error Resume Next

'Check to see is user already logged with Name
If CheckForSameName(userindex, Name) = True Then
    Call SendData(ToIndex, userindex, 0, "!!Sorry, the character is being used right now.")
    CloseSocket (userindex)
    Exit Sub
End If

'Check for Character file
If FileExist(CharPath & UCase(Name) & ".chr", vbNormal) = False Then
Call SendData(ToIndex, userindex, 0, "WR2")
Call SendData(ToIndex, userindex, 0, "!!Character does not exist.")
CloseSocket (userindex)
Exit Sub
End If

'Check to see if "" password
If GetVar(CharPath & UCase(Name) & ".chr", "INIT", "Password") = "" Then
Call WriteVar(CharPath & UCase(Name) & ".chr", "INIT", "Password", Password)
End If

'Check Password
If Password <> GetVar(CharPath & UCase(Name) & ".chr", "INIT", "Password") Then
    Call SendData(ToIndex, userindex, 0, "WR1")
    Call SendData(ToIndex, userindex, 0, "!!Wrong Password.")
    CloseSocket (userindex)
Exit Sub
End If

'Else if everything went ok, erase character
Kill (CharPath & UCase(Name) & ".chr")
Call SendData(ToIndex, userindex, 0, "!!The character has been erased.")
CloseSocket (userindex)

End Sub
Sub CloseUser(userindex As Integer)

On Error Resume Next

'*****************************************************************
'save user then reset user's slot
'*****************************************************************
Dim X As Integer
Dim Y As Integer
Dim LoopC As Integer
Dim map As Integer
Dim Name As String



'Save temps
map = UserList(userindex).Pos.map
X = UserList(userindex).Pos.X
Y = UserList(userindex).Pos.Y
Name = UserList(userindex).Name

    'If player got a tamed animal
    If UserList(userindex).Stats.OwnAnimal > 0 Then
    NPCList(UserList(userindex).Stats.OwnAnimal).Tamed = 1
    NPCList(UserList(userindex).Stats.OwnAnimal).Movement = 1
    NPCList(UserList(userindex).Stats.OwnAnimal).Attackable = 0
    NPCList(UserList(userindex).Stats.OwnAnimal).Owner = userindex
    End If

'Set logged to false
UserList(userindex).Flags.UserLogged = False

'Save user
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")


'reset user vars
UserList(userindex).Char.Body = 0
UserList(userindex).Char.Head = 0
UserList(userindex).Char.Heading = 0
UserList(userindex).Char.WeaponAnim = 0
UserList(userindex).Char.ShieldAnim = 0

 
If UserList(userindex).Char.CharIndex > 0 Then
    Call EraseUserChar(ToMap, 0, map, userindex)
End If


UserList(userindex).Name = ""
UserList(userindex).modName = ""
UserList(userindex).Password = ""
UserList(userindex).Pos.map = 0
UserList(userindex).Pos.X = 0
UserList(userindex).Pos.Y = 0
UserList(userindex).IP = ""
UserList(userindex).RDBuffer = ""
  
UserList(userindex).Counters.IdleCount = 0
  

  
'update last user
If userindex = LastUser Then
    Do Until UserList(LastUser).Flags.UserLogged = True
        LastUser = LastUser - 1
        If LastUser = 0 Then Exit Do
    Loop
End If
  
'update number of users
If NumUsers <> 0 Then
    NumUsers = NumUsers - 1
End If
frmMain.txStatus.Text = "Total Users= " & NumUsers
Call RefreshUserListBox

'Update Map Users
MapInfo(map).NumUsers = MapInfo(map).NumUsers - 1
If MapInfo(map).NumUsers < 0 Then
    MapInfo(map).NumUsers = 0
End If


'Log it-
Open App.Path & "\Connect.log" For Append Shared As #5
Print #5, Name & " logged off. " & "User Index:" & userindex & " " & Time & " " & Date
Close #5
  
End Sub

Sub HandleData(userindex As Integer, rdata As String)
'*****************************************************************
'Handles all data from the clients
'*****************************************************************
On Error Resume Next

Dim obj1 As ObjData
obj1 = ObjData(UserList(userindex).Object(UserList(userindex).ClothingEqpSlot).ObjIndex)

'If UserList(userindex).Flags.Morphed = 0 Then UserList(userindex).Char.Body = obj1.ClothingType
If UserList(userindex).Flags.Morphed = 1 Then UserList(userindex).Char.Body = UserList(userindex).Char.Body

If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Body = 16
If UserList(userindex).Flags.Hiding = 1 Then UserList(userindex).Char.Body = 53

'Disspear BODY! NO!
If UserList(userindex).Char.Body = 53 And UserList(userindex).Flags.Hiding = 0 And UserList(userindex).Flags.Morphed = 0 Then UserList(userindex).Char.Body = obj1.ClothingType

Dim sndData As String
Dim LoopC As Integer
Dim nPos As WorldPos
Dim tStr As String
Dim tInt As Integer
Dim tLong As Long
Dim tIndex As Integer
Dim tName As String
Dim tMessage As String
Dim Arg1 As String
Dim Arg2 As String
Dim Arg3 As String
Dim Arg4 As String
Dim Stat1 As Long
Dim Stat2 As Long
Dim Stat3 As Long
Dim Stat4 As Long
Dim NumClans As Integer
Dim NewGold As String
Dim ClanGold As String
Dim ClanName As String
ClanName = UserList(userindex).Clan
NumClans = Val(GetVar(IniPath & "clans.txt", "INIT", "NumCLANs"))

Dim slot As Integer
Dim UserTargetIndex As Integer
Dim Npcindex As Integer

Npcindex = UserList(userindex).Npcindex

'Check to see if user has a valid UserIndex
If userindex < 0 Then
Exit Sub
End If



'ERASE CHARACTER
If Left$(rdata, 5) = "ERASE" Then
    rdata = Right$(rdata, Len(rdata) - 5)
       
    'Check to see if have newest version
    If ReadField(3, rdata, 44) = ClientVersion Then
    Else
    Call SendData(ToIndex, userindex, 0, "!!You do not have the newest version of EO.EXE and cannot play, please quit Era Online and get it at www.eraonline.net now under the download section.")
    CloseSocket (userindex)
    Exit Sub
    End If
       
    Call EraseChar(userindex, ReadField(1, rdata, 44), ReadField(2, rdata, 44), ReadField(3, rdata, 44), ReadField(4, rdata, 44))

    Exit Sub
End If
   
   
'Logon on existing character
If Left$(rdata, 5) = "LOGIN" Then
    rdata = Right$(rdata, Len(rdata) - 5)
       
    'Check to see if have newest version
    If ReadField(3, rdata, 44) = ClientVersion Then
    Call SendData(ToIndex, userindex, 0, "PL3" & 7)
    Else
    Call SendData(ToIndex, userindex, 0, "!!You do not have the newest version of EO.EXE and cannot play, please quit Era Online and get it at www.eraonline.net now under the download section.")
    CloseSocket (userindex)
    Exit Sub
    End If
       
    Call ConnectUser(userindex, ReadField(1, rdata, 44), ReadField(2, rdata, 44), ReadField(3, rdata, 44), ReadField(4, rdata, 44))

Exit Sub
End If
  
'Make a new character
If Left$(rdata, 6) = "NLOGIN" Then
    rdata = Right$(rdata, Len(rdata) - 6)
          
    'Check to see if have newest version
    If ReadField(12, rdata, 44) = ClientVersion Then
    Call SendData(ToIndex, userindex, 0, "PL3" & 15)
    Else
    Call SendData(ToIndex, userindex, 0, "!!You do not have the newest version of EO.EXE and cannot play, please quit Era Online and get it at www.eraonline.net now.")
    CloseSocket (userindex)
    Exit Sub
    End If
       
    Call ConnectNewUser(userindex, ReadField(1, rdata, 44), ReadField(2, rdata, 44), Val(ReadField(3, rdata, 44)), ReadField(4, rdata, 44), ReadField(5, rdata, 44), ReadField(6, rdata, 44), ReadField(7, rdata, 44), ReadField(8, rdata, 44), ReadField(9, rdata, 44), ReadField(10, rdata, 44), ReadField(11, rdata, 44), ReadField(13, rdata, 44), ReadField(14, rdata, 44), ReadField(15, rdata, 44), ReadField(16, rdata, 44), ReadField(17, rdata, 44))
    
    Exit Sub
End If

'If not trying to log on must not be a client so log it off
If UserList(userindex).Flags.UserLogged = False Then
    CloseSocket (userindex)
    Exit Sub
End If

'Player unflag criminal
If Left$(rdata, 3) = "CRM" Then
    rdata = Right$(rdata, Len(rdata) - 3)

If UserList(userindex).Flags.Criminal = 0 Then Exit Sub

UserList(userindex).Flags.Criminal = 0
UserList(userindex).Flags.CriminalCount = 0
Call SendData(ToIndex, userindex, 0, "@The knowledge of your criminal deeds fades out with the people and you are no longer marked as a criminal." & FONTTYPE_INFO)
SendUserStatsBox (userindex)


Exit Sub
End If


'Player wanted to quit playing
If Left$(rdata, 3) = "QIT" Then
    rdata = Right$(rdata, Len(rdata) - 3)


'Save user
Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

    If UserList(userindex).Flags.Meditate = 1 Then
    Call SendData(ToIndex, userindex, 0, "@Exit the trance of meditation by typing /MEDITATE before quitting the game." & FONTTYPE_INFO)
    Exit Sub
    End If
    

    UserList(userindex).Char.Body = obj1.ClothingType
    If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Body = 16
    If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Head = 5
    Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
           

    
CloseSocket (userindex)

Exit Sub
End If

  
'Left Click
If Left$(rdata, 2) = "LC" Then
    rdata = Right$(rdata, Len(rdata) - 2)
    Call LookatTile(userindex, UserList(userindex).Pos.map, ReadField(1, rdata, 44), ReadField(2, rdata, 44))
    Exit Sub
End If

'Right Click
If Left$(rdata, 2) = "RC" Then
    Exit Sub
End If
  

'Move
If Left$(rdata, 1) = "M" Then
rdata = Right$(rdata, Len(rdata) - 1)

'Erase target data

UserList(userindex).Npcindex = 0
UserList(userindex).NPCtarget = 0
UserList(userindex).UserTargetIndex = 0
If UserList(userindex).Flags.Hiding = 1 Then Call Unhide(userindex)

Call MoveUserChar(userindex, Val(rdata))

Exit Sub
End If


'Request Pos update
If rdata = "RPU" Then
    Call SendData(ToIndex, userindex, 0, "SUP" & UserList(userindex).Pos.X & "," & UserList(userindex).Pos.Y)
    Exit Sub
End If

'Request Pos update
If rdata = "/REFRESH" Then
    Call SendData(ToIndex, userindex, 0, "SUP" & UserList(userindex).Pos.X & "," & UserList(userindex).Pos.Y)
    Exit Sub
End If
  
'RR
If rdata = ">" Then
    UserList(userindex).Char.Heading = UserList(userindex).Char.Heading + 1
    If UserList(userindex).Char.Heading > WEST Then UserList(userindex).Char.Heading = NORTH
    Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
    Exit Sub
End If
  
'RL
If rdata = "<" Then
    UserList(userindex).Char.Heading = UserList(userindex).Char.Heading - 1
    If UserList(userindex).Char.Heading < NORTH Then UserList(userindex).Char.Heading = WEST
    Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
End If


'Reset Idle
UserList(userindex).Counters.IdleCount = 0
  
  
 
'******************* General Commands ****************************
'Say
If Left$(rdata, 1) = ";" Then

'Check if moderated
If MapInfo(UserList(userindex).Pos.map).Moderated = 1 Then
Call SendData(ToIndex, userindex, 0, "@The map is moderated by a gamemaster and nothing can be said on this map until a gamemaster has removed the moderation." & FONTTYPE_INFO)
Exit Sub
End If

If UserList(userindex).Flags.status = 0 Then
    rdata = Right$(rdata, Len(rdata) - 1)
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & ": " & rdata & FONTTYPE_TALK)
    Open "Logs\" & "Zone" & UserList(userindex).Pos.map & ".log" For Append Shared As #5
    Print #5, UserList(userindex).Name & ":" & rdata & " (" & Time & " " & Date & ")"
    Close #5
    Else
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & ": " & "oooOO OOoo oOO OOooo" & FONTTYPE_TALK)
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_HEART)
    Exit Sub
End If
End If

'GAMEMASTER HELP
If Left$(rdata, 1) = "^" Then
   rdata = Right$(rdata, Len(rdata) - 1)
   Call SendData(ToGM, 0, 0, "@HELP MESSAGE ADDED TO QUE ! TYPE /GMTOOL TO ACCESS THE QUE." & FONTTYPE_SKILLINFO)
   Call PostHelp(userindex, ReadField(1, rdata, 44))
   
Exit Sub
End If

'Shout
If Left$(rdata, 1) = "-" Then

'Check if moderated
If MapInfo(UserList(userindex).Pos.map).Moderated = 1 Then
Call SendData(ToIndex, userindex, 0, "@The map is moderated by a gamemaster and nothing can be said on this map until a gamemaster has removed the moderation." & FONTTYPE_INFO)
Exit Sub
End If


If UserList(userindex).Flags.status = 0 Then
    rdata = Right$(rdata, Len(rdata) - 1)
    Call SendData(ToMap, 0, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " shouts: " & rdata & FONTTYPE_TALK)
     Open "Logs\" & "Zone" & UserList(userindex).Pos.map & ".log" For Append Shared As #5
    Print #5, UserList(userindex).Name & ":" & rdata & " (" & Time & " " & Date & ")"
    Close #5
    Else
    Call SendData(ToMap, 0, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " shouts: " & "oooOOOOo OOOOOooo Ooooo" & FONTTYPE_TALK)
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_HEART)
    Exit Sub
End If
End If

'Emote
If Left$(rdata, 1) = ":" Then


'Check if moderated
If MapInfo(UserList(userindex).Pos.map).Moderated = 1 Then
Call SendData(ToIndex, userindex, 0, "@The map is moderated by a gamemaster and nothing can be said on this map until a gamemaster has removed the moderation." & FONTTYPE_INFO)
Exit Sub
End If


If UserList(userindex).Flags.status = 0 Then
    rdata = Right$(rdata, Len(rdata) - 1)
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " " & rdata & FONTTYPE_TALK)
     Open "Logs\" & "Zone" & UserList(userindex).Pos.map & ".log" For Append Shared As #5
    Print #5, UserList(userindex).Name & " " & rdata & " (" & Time & " " & Date & ")"
    Close #5
    Else
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "@" & UserList(userindex).Name & " seems to try to express something. But noone can understand the ghostly movements." & FONTTYPE_TALK)
    Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_HEART)
    Exit Sub
End If
End If

'Tell
If Left$(rdata, 1) = "\" Then
    rdata = Right$(rdata, Len(rdata) - 1)
    
    tName = ReadField(1, rdata, 32)
    tIndex = NameIndex(tName)
    
    If tIndex <> 0 Then
    
        If Len(rdata) <> Len(tName) Then
            tMessage = Right$(rdata, Len(rdata) - (1 + Len(tName)))
        Else
            tMessage = " "
        End If
        
        Call SendData(ToIndex, tIndex, 0, "@" & UserList(userindex).Name & " tells, " & Chr(34) & tMessage & Chr(34) & " to you." & FONTTYPE_TALK)
        Call SendData(ToIndex, userindex, 0, "@You tell, " & Chr(34) & tMessage & Chr(34) & " to " & UserList(tIndex).Name & "." & FONTTYPE_TALK)
    
    Open "Logs\" & "Zone" & UserList(userindex).Pos.map & ".log" For Append Shared As #5
    Print #5, UserList(userindex).Name & ":" & tMessage & " (" & Time & " " & Date & ")"
    Close #5
        Exit Sub
    End If
    
    Call SendData(ToIndex, userindex, 0, "@User not online. " & FONTTYPE_INFO)
    Exit Sub
End If

'Get
If rdata = "GET" Then
If UserList(userindex).Flags.status = 0 Then
    Call GetObj(userindex)
    Exit Sub
    Else
    Call SendData(ToIndex, userindex, 0, "@Your dead and cannot do that." & FONTTYPE_TALK)
    Exit Sub
End If

Exit Sub
End If

'Regain mana by meditating
If Left$(rdata, 3) = "REG" Then
rdata = Right$(rdata, Len(rdata) - 3)
Call RegainMana(userindex)
Exit Sub
End If

'Substract some stamina OR health if rain
If Left$(rdata, 3) = "STA" Then
rdata = Right$(rdata, Len(rdata) - 3)

'Check to see if dead first
If UserList(userindex).Flags.status = 1 Then Exit Sub

'Check to see if warm clothing first.
If obj1.HandleRain = 1 Then Exit Sub

'Substract stamina if over 0
If UserList(userindex).Stats.MinSTA > 0 Then
UserList(userindex).Stats.MinSTA = UserList(userindex).Stats.MinSTA - 1
Call SendData(ToIndex, userindex, 0, "@You feel cold and lose some stamina ! Try finding shelter in a house or get yourself some warm clothing !" & FONTTYPE_INFO)
Call SendUserStatsBox(userindex)
End If

'substract HEALTH if no stamina left !
If UserList(userindex).Stats.MinSTA < 2 And UserList(userindex).Stats.MinHP > 2 Then
UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MinHP - 1
Call SendData(ToIndex, userindex, 0, "@You feel cold and exhausted ! You are loosing health ! Try finding shelter in a house or get yourself some warm clothing !" & FONTTYPE_INFO)
Call SendUserStatsBox(userindex)
End If

Exit Sub
End If


'Drop

If Left$(rdata, 3) = "DRP" Then
If UserList(userindex).Flags.status = 0 Then
    rdata = Right$(rdata, Len(rdata) - 3)
    
    If UserList(userindex).Object(ReadField(1, rdata, 44)).ObjIndex = 0 Then Exit Sub
    Call DropObj(userindex, Val(ReadField(1, rdata, 44)), Val(ReadField(2, rdata, 44)), UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
    Else
    Call SendData(ToIndex, userindex, 0, "@Your dead and cannot do that." & FONTTYPE_TALK)
    Exit Sub
    End If
    
Exit Sub
End If

'DISCARD ITEM

If Left$(rdata, 3) = "DIS" Then
rdata = Right$(rdata, Len(rdata) - 3)
    If UserList(userindex).Object(Val(rdata)).ObjIndex = 0 Then
    Exit Sub
    End If
    
    Call SendData(ToIndex, userindex, 0, "@You have discarded the item." & FONTTYPE_INFO)
    UserList(userindex).Object(Val(rdata)).ObjIndex = 0
    UserList(userindex).Object(Val(rdata)).Equipped = 0
    UserList(userindex).Object(Val(rdata)).Amount = 0
    Call UpdateUserInv(True, userindex, (Val(rdata)))
    Exit Sub
End If


'Teleport back to home.
'If Left$(rdata, 3) = "FMO" Then
'rdata = Right$(rdata, Len(rdata) - 3)

'Call SendData(ToIndex, userindex, 0, "!!The map you entered was defect, and you will now be teleported to your home city." & FONTTYPE_INFO)
'If UserList(userindex).Race = "Human" Then Call WarpUserChar(userindex, CastleFallStartPos)
'If UserList(userindex).Race = "Dark Elf" Then Call WarpUserChar(userindex, UgStartPos)
'If UserList(userindex).Race = "Wood Elf" Then Call WarpUserChar(userindex, ValenStartPos)
'If UserList(userindex).Race = "Haaki" Then Call WarpUserChar(userindex, DencStartPos)


'Exit Sub
'End If

'USE

If Left$(rdata, 3) = "USE" Then
rdata = Right$(rdata, Len(rdata) - 3)
    
If UserList(userindex).Object(Val(rdata)).ObjIndex = 0 Then Exit Sub
    
If UserList(userindex).Flags.status = 0 Then
Call UseInvItem(userindex, Val(rdata))
Else
Call SendData(ToIndex, userindex, 0, "@Your dead and cannot do that." & FONTTYPE_TALK)
Exit Sub
End If

End If

'CAST SPELL

If Left$(rdata, 3) = "CST" Then
rdata = Right$(rdata, Len(rdata) - 3)


If UserList(userindex).SpellObj(Val(rdata)).SpellIndex = 0 Then Exit Sub
    
If UserList(userindex).UserTargetIndex = UserList(userindex).Npcindex Then
Call CastSpellAtNPC(userindex, Val(rdata))
Call UpdateUserSpell(True, userindex, 1)
Else
Call CastSpellAtPC(userindex, Val(rdata))
Call UpdateUserSpell(True, userindex, 1)
End If

Exit Sub
End If

'Unequip

If Left$(rdata, 3) = "UNQ" Then
If UserList(userindex).Flags.status = 0 Then
    rdata = Right$(rdata, Len(rdata) - 3)
    If UserList(userindex).Object(Val(rdata)).ObjIndex = 0 Then
        Exit Sub
    End If
    Call RemoveInvItem(userindex, Val(rdata))
    Else
    Call SendData(ToIndex, userindex, 0, "@Your dead and cannot do that." & FONTTYPE_TALK)
    Exit Sub
End If

Exit Sub
End If

'TRAIN POINT RAISE

If Left$(rdata, 3) = "T01" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill1 = UserList(userindex).Stats.Skill1 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T02" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill2 = UserList(userindex).Stats.Skill2 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T03" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill3 = UserList(userindex).Stats.Skill3 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T04" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill4 = UserList(userindex).Stats.Skill4 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T05" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill5 = UserList(userindex).Stats.Skill5 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T06" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill6 = UserList(userindex).Stats.Skill6 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T07" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill7 = UserList(userindex).Stats.Skill7 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T08" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill8 = UserList(userindex).Stats.Skill8 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T09" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill9 = UserList(userindex).Stats.Skill9 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T10" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill10 = UserList(userindex).Stats.Skill10 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T11" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill11 = UserList(userindex).Stats.Skill11 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1

If UserList(userindex).Stats.MaxMAN < STAT_MAXMAN Then
Call SendData(ToIndex, userindex, 0, "@You gain 3 more mana points !" & FONTTYPE_INFO)
UserList(userindex).Stats.MaxMAN = UserList(userindex).Stats.MaxMAN + 3
UserList(userindex).Stats.MinMAN = UserList(userindex).Stats.MinMAN + 3
End If

SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T12" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill12 = UserList(userindex).Stats.Skill12 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T13" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill13 = UserList(userindex).Stats.Skill13 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T14" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill14 = UserList(userindex).Stats.Skill14 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T15" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill15 = UserList(userindex).Stats.Skill15 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T16" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill16 = UserList(userindex).Stats.Skill16 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T17" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill17 = UserList(userindex).Stats.Skill17 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T18" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill18 = UserList(userindex).Stats.Skill18 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T19" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill19 = UserList(userindex).Stats.Skill19 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T20" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill20 = UserList(userindex).Stats.Skill20 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T21" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill21 = UserList(userindex).Stats.Skill21 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T22" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill22 = UserList(userindex).Stats.Skill22 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T23" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill23 = UserList(userindex).Stats.Skill23 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T24" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill24 = UserList(userindex).Stats.Skill24 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T25" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill25 = UserList(userindex).Stats.Skill25 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T26" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill26 = UserList(userindex).Stats.Skill26 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T27" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill27 = UserList(userindex).Stats.Skill27 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

If Left$(rdata, 3) = "T28" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.Skill28 = UserList(userindex).Stats.Skill28 + 1
UserList(userindex).Stats.PracticePoints = UserList(userindex).Stats.PracticePoints - 1
SendUserStatsBox (userindex)
Exit Sub
End If

'Enable pickpocket flag
If Left$(rdata, 3) = "PI1" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Flags.Pickpocket = 1
Call SendData(ToIndex, userindex, 0, "@You are now in pickpocket mode." & FONTTYPE_INFO)
Exit Sub
End If

'Disable pickpocket flag
If Left$(rdata, 3) = "PI2" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Flags.Pickpocket = 0
Call SendData(ToIndex, userindex, 0, "@You are no longer in pickpocket mode..." & FONTTYPE_INFO)
Exit Sub
End If

'GIVE

If Left$(rdata, 3) = "GIV" Then
rdata = Right$(rdata, Len(rdata) - 3)

If UserList(userindex).Flags.status = 0 Then
Call NpcGive(userindex, Val(rdata))
Else
Call SendData(ToIndex, userindex, 0, "@Your dead and cannot do that" & FONTTYPE_TALK)
Exit Sub
End If
   
Exit Sub
End If

'EVALUATE ITEM

If Left$(rdata, 3) = "EVA" Then

If UserList(userindex).Flags.status = 0 Then
rdata = Right$(rdata, Len(rdata) - 3)
    Call Evaluate(userindex, Val(rdata))
    Else
    Call SendData(ToIndex, userindex, 0, "@Your dead and cannot do that" & FONTTYPE_TALK)
    Exit Sub
End If

Exit Sub
End If

'Drop gold
If Left$(rdata, 3) = "DRG" Then
rdata = Right$(rdata, Len(rdata) - 3)
Call DropGold(userindex, Val(rdata))
Exit Sub
End If

'*******NPC TRADE*********
If Left$(rdata, 3) = "BUY" Then
If UserList(userindex).Flags.status = 0 Then
    rdata = Right$(rdata, Len(rdata) - 3)
    Call NPCSellItem(userindex, Npcindex, Val(rdata))
    Else
    Call SendData(ToIndex, userindex, 0, "@You are dead and cannot communicate with the world." & FONTTYPE_TALK)
    Exit Sub
End If
Exit Sub
End If

If Left$(rdata, 3) = "SLL" Then
rdata = Right$(rdata, Len(rdata) - 3)
If rdata = 0 Then
Else
Call NPCBuyItem(userindex, Npcindex, Val(rdata))
Exit Sub
End If
Exit Sub
End If
'**********END NPC TRADE*********


'Stats
If UCase(rdata) = "/STATS" Then
    SendUserStatsTxt userindex, userindex
    Exit Sub
End If

'Attack
If rdata = "ATT" Then

If UserList(userindex).Flags.status = 0 Then
If UserList(userindex).Flags.Battlemode = 1 Then
    Call UserAttack(userindex)
    Else
    Call SendData(ToIndex, userindex, 0, "@Go into battle mode first !" & FONTTYPE_TALK)
    Exit Sub
End If
End If

Exit Sub
End If

'STOP SKILL NOW
If Left$(rdata, 3) = "STP" Then
    rdata = Right$(rdata, Len(rdata) - 3)

UserList(userindex).Flags.SkillFinished = 0
UserList(userindex).Flags.whatjob = 0
UserList(userindex).Flags.Working = 0

Exit Sub
End If

'PLAY SOUND FROM CLIENT TO ALL IN AREA
If Left$(rdata, 3) = "PLY" Then
    rdata = Right$(rdata, Len(rdata) - 3)
     
     Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & rdata)
    
Exit Sub
End If

'PERFORM SKILL NOW
If Left$(rdata, 3) = "XBX" Then
    rdata = Right$(rdata, Len(rdata) - 3)


UserList(userindex).Flags.SkillFinished = 1

If rdata = 1 Then Call Bandage(userindex, UserList(userindex).Flags.LastSlot)
If rdata = 2 Then Call Chop(userindex, 1)
If rdata = 3 Then Call CreateFoldedCloth(userindex, UserList(userindex).Flags.LastSlot)
If rdata = 4 Then Call CreatePlanks(userindex, UserList(userindex).Flags.LastSlot)
If rdata = 5 Then Call CreateSteel(userindex, UserList(userindex).Flags.LastSlot)
If rdata = 6 Then Call Disguise(userindex)
If rdata = 7 Then Call Fish(userindex, 1)
If rdata = 8 Then Call MakeBlacksmithingObj(userindex, UserList(userindex).Flags.LastSlot)
If rdata = 9 Then Call MakeCarpentryObj(userindex, UserList(userindex).Flags.LastSlot)
If rdata = 10 Then Call MakeTailoringObj(userindex, UserList(userindex).Flags.LastSlot)
If rdata = 11 Then Call RoastMeat(userindex, UserList(userindex).Flags.LastSlot)
If rdata = 12 Then Call Hide(userindex)
If rdata = 13 Then Call SetCamp(userindex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)
If rdata = 14 Then Call TameAnimal(userindex)
If rdata = 15 Then Call Mine(userindex, 1)

Exit Sub
End If

'Quit
If UCase$(rdata) = "/QUIT" Then

Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")

If UserList(userindex).Flags.Meditate = 1 Then
    Call SendData(ToIndex, userindex, 0, "@Exit the trance of meditation by typing /MEDITATE before quitting the game." & FONTTYPE_INFO)
    Exit Sub
    End If
        
    UserList(userindex).Char.Body = obj1.ClothingType
    If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Body = 16
    If UserList(userindex).Flags.status = 1 Then UserList(userindex).Char.Head = 5
    Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
       
    Call CloseSocket(userindex)
    Exit Sub
End If



'Report bug
If UCase$(Left$(rdata, 5)) = "/BUG " Then
    rdata = Right$(rdata, Len(rdata) - 5)

Call ReportBug(rdata, userindex)
Call SendData(ToIndex, userindex, 0, "@Thanks for reporting the bug ! You may just made Era Online a better game !" & FONTTYPE_INFO)



Exit Sub
End If

'Meditate
If UCase$(rdata) = "/MEDITATE" Then
    Call Meditate(userindex)
    Exit Sub
End If

'Who
If UCase$(rdata) = "/WHO" Then
    Call SendData(ToIndex, userindex, 0, "@Total Users: " & NumUsers & FONTTYPE_INFO)
    
    For LoopC = 1 To LastUser
        If (UserList(LoopC).Name <> "") Then
            tStr = tStr & UserList(LoopC).modName & ", "
        End If
    Next LoopC
    tStr = Left$(tStr, Len(tStr) - 2)
    
    Call SendData(ToIndex, userindex, 0, "@" & tStr & FONTTYPE_INFO)
    
    Exit Sub
End If

'Get number of players
If UCase$(rdata) = "/PLAYERS" Then
Call SendData(ToIndex, userindex, 0, "@Players playing Era Online: " & NumUsers & FONTTYPE_INFO)
Exit Sub
End If

'HELP
If UCase$(rdata) = "/HELP" Then
    Call SendHelp(userindex)
    Exit Sub
End If


'Save
If UCase$(rdata) = "/SAVE" Then
    Call SaveUser(userindex, CharPath & UCase(UserList(userindex).Flags.StartName) & ".chr")
    Call SendData(ToIndex, userindex, 0, "@Character saved." & FONTTYPE_INFO)
    Exit Sub
End If



'Change Desc
If UCase$(Left$(rdata, 6)) = "/DESC " Then

    If UserList(userindex).Flags.status = 0 Then
    rdata = Right$(rdata, Len(rdata) - 6)
    UserList(userindex).Desc = rdata
    Call SendData(ToIndex, userindex, 0, "@Description changed." & FONTTYPE_INFO)
    Else
    Call SendData(ToIndex, userindex, 0, "@You cannot change your description when your dead." & FONTTYPE_TALK)
    Exit Sub
    End If
    
Exit Sub
End If


'msgboard
If Left$(rdata, 3) = "BOO" Then
rdata = Right$(rdata, Len(rdata) - 3)
    
    If rdata = 1 Then
    Call SendPostings(userindex)
    End If
    
Exit Sub
End If

'Mine
If Left$(rdata, 3) = "MIN" Then

If UserList(userindex).Flags.status = 0 Then
    rdata = Right$(rdata, Len(rdata) - 3)
    Call SendData(ToIndex, userindex, 0, "AT1")
    Call Mine(userindex, 1)
    Else
    Call SendData(ToIndex, userindex, 0, "@You are dead and cannot do that." & FONTTYPE_TALK)
Exit Sub
End If

Exit Sub
End If



'Fish
If Left$(rdata, 3) = "FSH" Then

If UserList(userindex).Flags.status = 0 Then
    rdata = Right$(rdata, Len(rdata) - 3)
    Call SendData(ToIndex, userindex, 0, "AT1")
    Call Fish(userindex, Val(rdata))
    Else
    Call SendData(ToIndex, userindex, 0, "@You are dead and cannot do that." & FONTTYPE_TALK)
Exit Sub
End If

Exit Sub
End If

'Chop tree
If rdata = "CHP" Then
If UserList(userindex).Flags.status = 0 Then
Call SendData(ToIndex, userindex, 0, "AT1")
    Call Chop(userindex, Val(rdata))
    Else
    Call SendData(ToIndex, userindex, 0, "@Your dead and cannot do that." & FONTTYPE_TALK)
Exit Sub
End If

Exit Sub
End If


'Asks NPC if want to trade
If UCase$(rdata) = "/TRADE" Then
'check to see if you are dead
If UserList(userindex).Flags.status = 1 Then
Call SendData(ToIndex, userindex, 0, "@You are dead and cannot do that." & FONTTYPE_INFO)
Exit Sub
End If


'Check to see if NPC can trade
If NPCList(Npcindex).Tradeable = 1 Then
Call SendData(ToIndex, userindex, 0, "@You cannot trade with this NPC." & FONTTYPE_INFO)
Exit Sub
End If

'If can trade, then begin trading
  If Npcindex > 0 Then
  Call NpcTrade(True, Npcindex, userindex, 0)
  Else
  Call SendData(ToIndex, userindex, 0, "@Trade with who ?" & FONTTYPE_INFO)
  Exit Sub
  End If
  
Exit Sub
End If

'Train with a trainer
If UCase$(rdata) = "/TRAIN" Then
Call NpcTrain(userindex, Val(rdata))
Exit Sub
End If

'Pray at a cleric
If UCase$(rdata) = "/PRAY" Then
Call Pray(userindex, Val(rdata))
Exit Sub
End If

'Pray at a cleric
If UCase$(rdata) = "/DUEL" Then
Call Duel(userindex, Val(rdata))
Exit Sub
End If


'Asks HEALER to heal the player
If UCase$(rdata) = "/HEAL" Then
If UserList(userindex).Flags.status = 0 Then
     Call NpcHeal(userindex, Val(rdata))
     Else
     Call SendData(ToIndex, userindex, 0, "@You are dead and must be ressurected. No healer can heal your fatal wounds." & FONTTYPE_TALK)
     Exit Sub
End If

Exit Sub
End If

'Heal with camp fire
If rdata = "CMP" Then
If UserList(userindex).Flags.status = 0 Then
    Call CampHeal(userindex)
    Else
    Call SendData(ToIndex, userindex, 0, "@Your dead and cannot do that." & FONTTYPE_TALK)
Exit Sub
End If

Exit Sub
End If


'Flag npc as CAN ATTACK
If rdata = "AT4" Then
UserList(userindex).Flags.NpcAttack = 1
Exit Sub
End If


'Consider target
If rdata = "COO" Then
Call Consider(userindex)
Exit Sub
End If

'Update spell book
If rdata = "UPS" Then
Call UpdateUserSpell(True, userindex, 1)
Exit Sub
End If

'Update character sheet
If rdata = "UCS" Then

If UserList(userindex).WeaponEqpSlot > 0 Then Call SendData(ToIndex, userindex, 0, "PC2" & UserList(userindex).WeaponEqpSlot)
If UserList(userindex).ClothingEqpSlot > 0 Then Call SendData(ToIndex, userindex, 0, "PIC" & UserList(userindex).ClothingEqpSlot)
If UserList(userindex).SHIELDEqpSlot > 0 Then Call SendData(ToIndex, userindex, 0, "PC3" & UserList(userindex).SHIELDEqpSlot)
If UserList(userindex).HEADEqpSlot > 0 Then Call SendData(ToIndex, userindex, 0, "PC4" & UserList(userindex).HEADEqpSlot)

Exit Sub
End If

'Ask a NPC to ressurect the player
If UCase$(rdata) = "/RESSURECT" Then
     Call NpcRessurect(userindex, Val(rdata))
Exit Sub
End If

'Ask a NPC to ressurect the player
If UCase$(rdata) = "/RESURRECT" Then
     Call NpcRessurect(userindex, Val(rdata))
Exit Sub
End If

'Hail NPC
If UCase$(rdata) = "/HAIL" Then
     
     If UserList(userindex).Npcindex = 0 Then
     Exit Sub
     End If
     
     If NPCList(UserList(userindex).Npcindex).Tameable = 1 Then
     Call SendData(ToIndex, userindex, 0, "@I dont think your target would be very talkative." & FONTTYPE_INFO)
     Exit Sub
     End If
     
     Call SendData(ToIndex, userindex, 0, "@" & NPCList(UserList(userindex).Npcindex).Name & " says," & NPCList(UserList(userindex).Npcindex).Hail & FONTTYPE_TALK)
     
     
Exit Sub
End If

'UNLOCK TILE
If UCase$(rdata) = "/UNLOCK" Then

If MapData(UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y).Locked = UserList(userindex).Flags.YourID Then
MapData(UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y).Locked = 0
UserList(userindex).Flags.Locks = UserList(userindex).Flags.Locks + 1
Call SendData(ToIndex, userindex, 0, "@You unlock the position. Anyone can walk here now. You have one " & UserList(userindex).Flags.Locks & " lock(s) to spend." & FONTTYPE_INFO)
Else
Call SendData(ToIndex, userindex, 0, "@The position isn`t locked !" & FONTTYPE_INFO)
Exit Sub
End If

Exit Sub
End If

'LOCK TILE
If UCase$(rdata) = "/LOCK" Then

If UserList(userindex).Flags.Locks > 0 Then
MapData(UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y).Locked = UserList(userindex).Flags.YourID
Call SendData(ToIndex, userindex, 0, "@The position is now locked. Type /UNLOCK to unlock the position. Only you may move at this position now." & FONTTYPE_INFO)
UserList(userindex).Flags.Locks = UserList(userindex).Flags.Locks - 1
Else
Call SendData(ToIndex, userindex, 0, "@You don`t have any locks left." & FONTTYPE_INFO)
Exit Sub
End If

Exit Sub
End If

'Test
If UCase$(rdata) = "/TEST" Then


Exit Sub
End If



'Disguise
If Left$(rdata, 3) = "DGU" Then
rdata = Right$(rdata, Len(rdata) - 3)
Call Disguise(userindex)
Exit Sub
End If

'Write sign
If Left$(rdata, 3) = "WRI" Then
rdata = Right$(rdata, Len(rdata) - 3)
Dim Sign As Long
Sign = UserList(userindex).Flags.Sign
Call WriteVar(IniPath & "signs.txt", "SIGN" & Sign, "Content", rdata)
Exit Sub
End If

'Disguise
If Left$(rdata, 3) = "UGU" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Name = UserList(userindex).Flags.StartName
Call SendData(ToIndex, userindex, 0, "@You are no longer disguised." & FONTTYPE_INFO)
Call SendUserStatsBox(userindex)
Exit Sub
End If

'Hide
If Left$(rdata, 3) = "HHH" Then
rdata = Right$(rdata, Len(rdata) - 3)
Call Hide(userindex)
Exit Sub
End If

'Unhide
If Left$(rdata, 3) = "UHD" Then
rdata = Right$(rdata, Len(rdata) - 3)
Call Unhide(userindex)
Exit Sub
End If

'Enter battlemode
If rdata = "BTL" Then

If UserList(userindex).Flags.Battlemode = 0 Then
Call OpenBattlemode(userindex)
Else
Call EndBattlemode(userindex)
End If

Exit Sub
End If

'Post on messageboard
If Left$(rdata, 3) = "YUP" Then
rdata = Right$(rdata, Len(rdata) - 3)
Call PostMessage(ReadField(1, rdata, 44), ReadField(2, rdata, 44), userindex)
Exit Sub
End If

'Deposit money in bank
If UCase$(rdata) = "/DEPOSIT" Then
Call BankDeposit(userindex)
Exit Sub
End If

'Ask for bank balance
If UCase$(rdata) = "/BALANCE" Then
Call BankBalance(userindex)
Exit Sub
End If

'Withdraw money in bank
If UCase$(rdata) = "/WITHDRAW" Then
Call BankWithdraw(userindex)
Exit Sub
End If


If Left$(rdata, 3) = "DPT" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - rdata
UserList(userindex).Stats.BANKGLD = UserList(userindex).Stats.BANKGLD + rdata
SendUserStatsBox userindex
Exit Sub
End If

If Left$(rdata, 3) = "WTH" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + rdata
UserList(userindex).Stats.BANKGLD = UserList(userindex).Stats.BANKGLD - rdata
SendUserStatsBox userindex
Exit Sub
End If

'Drink
If Left$(rdata, 3) = "DRN" Then

If UserList(userindex).Stats.MinHP < UserList(userindex).Stats.MaxHP Then
Call SendData(ToIndex, userindex, 0, "@You drink and heal abit." & FONTTYPE_INFO)
UserList(userindex).Stats.Drink = UserList(userindex).Stats.Drink - 1
UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MinHP + UserList(userindex).Stats.MaxHP / 15
End If

If UserList(userindex).Stats.MinSTA < UserList(userindex).Stats.MaxSTA Then
UserList(userindex).Stats.Drink = UserList(userindex).Stats.Drink - 1
UserList(userindex).Stats.MinSTA = UserList(userindex).Stats.MinSTA + UserList(userindex).Stats.MaxSTA / 5
End If

SendUserStatsBox userindex
Exit Sub
End If

'Eat
If Left$(rdata, 3) = "EAT" Then

If UserList(userindex).Stats.MinHP < UserList(userindex).Stats.MaxHP Then
Call SendData(ToIndex, userindex, 0, "@You eat and heal abit." & FONTTYPE_INFO)
UserList(userindex).Stats.Food = UserList(userindex).Stats.Food - 1
UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MinHP + UserList(userindex).Stats.MaxHP / 15
End If

If UserList(userindex).Stats.MinSTA < UserList(userindex).Stats.MaxSTA Then
UserList(userindex).Stats.Food = UserList(userindex).Stats.Food - 1
UserList(userindex).Stats.MinSTA = UserList(userindex).Stats.MinSTA + UserList(userindex).Stats.MaxSTA / 5
End If

SendUserStatsBox userindex
Exit Sub
End If

'Initialize donate to temple proccess
If UCase$(rdata) = "/DONATE" Then
Call SendData(ToIndex, userindex, 0, "DOT")
Exit Sub
End If

If Left$(rdata, 3) = "DON" Then
rdata = Right$(rdata, Len(rdata) - 3)
UserList(userindex).Throw.Donategold = rdata
Call Donate(userindex)
Exit Sub
End If

If Left$(rdata, 3) = "PIC" Then
rdata = Right$(rdata, Len(rdata) - 3)
Call UpdateUserInv(True, userindex, Val(rdata))
Exit Sub
End If

'ASK NPC for gossip
If UCase$(rdata) = "/GOSSIP" Then
    Call Gossip(userindex)
    Exit Sub
End If

'ASK NPC for gossip (same as above)
If UCase$(rdata) = "/NEWS" Then
    Call Gossip(userindex)
    Exit Sub
End If


'*******ANIMAL OWNERSHIP AND TAMING COMMANDS*********

'Tame animal
If UCase$(rdata) = "/TAME" Then
    Call TameAnimal(userindex)
    Exit Sub
End If

'Transfer ownership of animal to player
If UCase$(rdata) = "/TRANSFER" Then

Call Transfer(userindex)

Exit Sub
End If


'Discard your animal
If UCase$(rdata) = "/DISCARD" Then

Call DiscardAnimal(userindex)

Exit Sub
End If


'Tame animal
If UCase$(Left$(rdata, 6)) = "/NAME " Then
rdata = Right$(rdata, Len(rdata) - 6)
Dim target3
target3 = UserList(userindex).Stats.OwnAnimal

    'Change the animals name
    If NPCList(target3).Owner = userindex Then
    NPCList(target3).Name = rdata
    Call SendData(ToIndex, userindex, 0, "@You have renamed the animal to " & rdata & FONTTYPE_INFO)
    If NPCList(target3).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(target3).Flags.Sound)
    Exit Sub
    Else
    Call SendData(ToIndex, userindex, 0, "@You dont own an animal so you cannot rename it !" & FONTTYPE_INFO)
Exit Sub
End If

Exit Sub
End If

'Tell animal to attack
'If UCase$(rdata) = "/ATTACK" Then
'Dim MyAnimal As Integer
'Dim AttackUser As Integer
'MyAnimal = UserList(userindex).Stats.OwnAnimal
'AttackTarget = UserList(userindex).NPCtarget

'Make sure its not a player
'If AttackTarget = UserList(userindex).UserTargetIndex Then
'Call SendData(ToIndex, userindex, 0, "@Pets cannot attack other players." & FONTTYPE_INFO)
'Exit Sub
'End If

'Make sure NPC can be attacked
'If NPCList(AttackTarget).Attackable = 0 Then
'Call SendData(ToIndex, userindex, 0, "@This cannot be attacked." & FONTTYPE_INFO)
'Exit Sub
'End If

'NPCList(MyAnimal).Target = AttackTarget
'Call SendData(ToIndex, 0, "@Your pet attacks your target !" & FONTTYPE_INFO)

'Exit Sub
'End If

'Tell animal to settle and stop attacking
'If UCase$(rdata) = "/SETTLE" Then
'Dim MyAnima1l As Integer
'Dim AttackUser1 As Integer
'MyAnimal1 = UserList(userindex).Stats.OwnAnimal
'AttackTarget1 = UserList(userindex).NPCtarget

'NPCList(MyAnimal).Target = 0
'Call SendData(ToIndex, 0, "@Your pet settles..." & FONTTYPE_INFO)

'Exit Sub
'End If

'Stop animal
If UCase$(rdata) = "/STOP" Then
Dim target1
target1 = UserList(userindex).Stats.OwnAnimal
    
'check to see if own animal at all
If target1 = 0 Then
Call SendData(ToIndex, userindex, 0, "@You dont own an animal !" & FONTTYPE_INFO)
Exit Sub
End If

'If so, make animal stand there
NPCList(target1).Movement = 1
If NPCList(target1).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(target1).Flags.Sound)

Exit Sub
End If

'Follow command for animal
If UCase$(rdata) = "/FOLLOW" Then
Dim target2
target2 = UserList(userindex).Stats.OwnAnimal
    
'check to see if own animal at all
If target2 = 0 Then
Call SendData(ToIndex, userindex, 0, "@You dont own an animal !" & FONTTYPE_INFO)
Exit Sub
End If

'If so, make animal follow
NPCList(target2).Movement = 6
If NPCList(target2).Flags.Sound > 0 Then Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & NPCList(target2).Flags.Sound)

Exit Sub
End If

'*************** CLAN CONTROLS ***********************************

On Error Resume Next

'Make clan
If UCase$(Left$(rdata, 10)) = "/MAKECLAN " Then
rdata = Right$(rdata, Len(rdata) - 10)

'Make sure user got enough money
If UserList(userindex).Stats.GLD < 10000 Then
Call SendData(ToIndex, userindex, 0, "@You need 10 000 gold to start a clan. You dont got that much." & FONTTYPE_INFO)
Exit Sub
End If

'Make sure user is not in a clan
If UserList(userindex).Clan = "" Then
'Do nothing here
Else
Call SendData(ToIndex, userindex, 0, "@You are already in a clan !" & FONTTYPE_INFO)
Exit Sub
End If

'Check to see if there is a clan by the same name
If FileExist(ClanPath & UCase(rdata) & ".txt", vbNormal) = True Then
Call SendData(ToIndex, userindex, 0, "@Clan name already exist !" & FONTTYPE_INFO)
Exit Sub
Else
End If

'Make clan
Call MakeClan(userindex, rdata)
Call SendData(ToIndex, userindex, 0, "@Clan created !" & FONTTYPE_INFO)
UserList(userindex).Clan = rdata
UserList(userindex).ClanMember = 1
UserList(userindex).ClanRank = "Monarch"

Exit Sub
End If

'Info
If UCase(rdata) = "/CLANINFO" Then
    
    'Check to see if in clan
    If UserList(userindex).Clan = "" Then
    Call SendData(ToIndex, userindex, 0, "@You are not in a clan !" & FONTTYPE_INFO)
    Exit Sub
    End If
    
    Call SendData(ToIndex, userindex, 0, "@Members: " & GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Members") & FONTTYPE_INFO)
    Call SendData(ToIndex, userindex, 0, "@Monarch: " & GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Monarch") & FONTTYPE_INFO)
    Call SendData(ToIndex, userindex, 0, "@Value: " & GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Gold") & FONTTYPE_INFO)
    Call SendData(ToIndex, userindex, 0, "@To find information about allies and enemies of the clan. Find a clan board in any town." & FONTTYPE_INFO)
    
    Exit Sub
End If

'Disband clan
If UCase(rdata) = "/DISBANDCLAN" Then

    'Check to see if in clan
    If UserList(userindex).Clan = "" Then
    Call SendData(ToIndex, userindex, 0, "@You are not in a clan !" & FONTTYPE_INFO)
    Exit Sub
    End If
    
    'Check to see if monarch
    If UserList(userindex).Name = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Monarch") Then
    'Do nothing here
    Else
    Call SendData(ToIndex, userindex, 0, "@You are not the monarch of this clan so you cannot do this." & FONTTYPE_INFO)
    Exit Sub
    End If

    Dim ClanNum As Integer
    ClanNum = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "ClanNum")

    'Erase the clan
    Kill (ClanPath & UCase(UserList(userindex).Clan) & ".txt")
    Call WriteVar(IniPath & "clans.txt", "CLAN" & ClanNum, "Name", "DISBANDED")
    Call SendData(ToIndex, userindex, 0, "@Your clan has been disbanded..." & FONTTYPE_INFO)

Exit Sub
End If

'Withdraw clan gold
If UCase$(Left$(rdata, 14)) = "/WITHDRAWGOLD " Then
rdata = Right$(rdata, Len(rdata) - 14)


    'Check to see if in clan
    If UserList(userindex).Clan = "" Then
    Call SendData(ToIndex, userindex, 0, "@You are not in a clan !" & FONTTYPE_INFO)
    Exit Sub
    End If
    
    'Check to see if monarch
    If UserList(userindex).Name = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Monarch") Then
    'Do nothing here
    Else
    Call SendData(ToIndex, userindex, 0, "@You are not the monarch of this clan so you cannot do this." & FONTTYPE_INFO)
    Exit Sub
    End If
    
    ClanGold = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Gold")
    NewGold = ClanGold - rdata

    'Withdraw gold
    If GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Gold") < rdata Then
    Call SendData(ToIndex, userindex, 0, "@Your clan does not have this much gold !" & FONTTYPE_INFO)
    Else
    Call SendData(ToIndex, userindex, 0, "@You withdrawed " & rdata & " gold from my the clan gold pile." & FONTTYPE_INFO)
    Call WriteVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Gold", NewGold)
    UserList(userindex).Stats.GLD = rdata
    End If
  
Exit Sub
End If

'deposit clan gold
If UCase$(Left$(rdata, 13)) = "/DEPOSITGOLD " Then
rdata = Right$(rdata, Len(rdata) - 13)

    'Check to see if in clan
    If UserList(userindex).Clan = "" Then
    Call SendData(ToIndex, userindex, 0, "@You are not in a clan !" & FONTTYPE_INFO)
    Exit Sub
    End If
    
    'Check to see if monarch
    If UserList(userindex).Name = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Monarch") Then
    'Do nothing here
    Else
    Call SendData(ToIndex, userindex, 0, "@You are not the monarch of this clan so you cannot do this." & FONTTYPE_INFO)
    Exit Sub
    End If
    
    
    ClanGold = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Gold")
    NewGold = ClanGold + rdata

    'Deposit gold
    If UserList(userindex).Stats.GLD < rdata Then
    Call SendData(ToIndex, userindex, 0, "@You dont have this much gold !" & FONTTYPE_INFO)
    Else
    Call SendData(ToIndex, userindex, 0, "@You deposited " & rdata & " gold to your clan gold pile." & FONTTYPE_INFO)
    Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "INIT", "Gold", NewGold)
    UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD - rdata
    End If
  
Exit Sub
End If
    
'Grant player 1 more rank
If UCase(rdata) = "/ADDRANK" Then
    
   
    'Check to see if monarch or noble
    If UserList(userindex).Name = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Monarch") Or UserList(userindex).Name = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Noble") Then
    'Do nothing here
    Else
    Call SendData(ToIndex, userindex, 0, "@You are not the monarch nor a noble of this clan so you cannot do this." & FONTTYPE_INFO)
    Exit Sub
    End If
    
    'Check to see if in clan
    If UserList(userindex).Clan = "" Then
    Call SendData(ToIndex, userindex, 0, "@You are not in a clan !" & FONTTYPE_INFO)
    Exit Sub
    End If
    
    'Check to see target is in in the clan
    If UserList(UserList(userindex).UserTargetIndex).Clan = UserList(userindex).Clan Then
    'Do nothing here
    Else
    Call SendData(ToIndex, userindex, 0, "@That person is not even in your clan !" & FONTTYPE_INFO)
    Exit Sub
    End If
    
    'Add rank
    If UserList(UserList(userindex).UserTargetIndex).ClanRank = "Peasant" Then
    UserList(UserList(userindex).UserTargetIndex).ClanRank = "Journeyman"
    Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "MEMBERS", "MemberRank" & UserList(UserList(userindex).UserTargetIndex).ClanMember, "Journeyman")
    Call SendData(ToIndex, UserList(userindex).UserTargetIndex, 0, "@You have been promoted to Journeyman in your clan !" & FONTTYPE_INFO)
    Else
    If UserList(UserList(userindex).UserTargetIndex).ClanRank = "Journeyman" Then
    UserList(UserList(userindex).UserTargetIndex).ClanRank = "Knight"
    Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "MEMBERS", "MemberRank" & UserList(UserList(userindex).UserTargetIndex).ClanMember, "Knight")
    Call SendData(ToIndex, UserList(userindex).UserTargetIndex, 0, "@You have been promoted to Knight in your clan !" & FONTTYPE_INFO)
    Else
    If UserList(UserList(userindex).UserTargetIndex).ClanRank = "Knight" Then
    UserList(UserList(userindex).UserTargetIndex).ClanRank = "Noble"
    Call WriteVar(ClanPath & UCase(ClanName) & ".txt", "MEMBERS", "MemberRank" & UserList(UserList(userindex).UserTargetIndex).ClanMember, "Noble")
    Call SendData(ToIndex, UserList(userindex).UserTargetIndex, 0, "@You have been promoted to Noble in your clan ! You are now right beneath the monarch, the leader of the clan." & FONTTYPE_INFO)
    Else
    Call SendData(ToIndex, userindex, 0, "@The player is already a noble in this clan. There can only be one monarch." & FONTTYPE_INFO)
    End If
    End If
    End If
    
    
Exit Sub
End If
    
'Invite Player To Join Clan
If UCase(rdata) = "/INVITE" Then
      
    'Check to see if monarch or noble
    If UserList(userindex).Name = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Monarch") Or UserList(userindex).Name = GetVar(ClanPath & UCase(UserList(userindex).Clan) & ".txt", "INIT", "Noble") Then
    'Do nothing here
    Else
    Call SendData(ToIndex, userindex, 0, "@Only the Monarch and Nobles of the clan can invite other people into the clan." & FONTTYPE_INFO)
    Exit Sub
    End If
      
    If UserList(userindex).UserTargetIndex = UserList(userindex).Npcindex Then
    Call SendData(ToIndex, userindex, 0, "@You cannot invite NPC's to join your guild." & FONTTYPE_INFO)
    Exit Sub
    End If
    
    UserList(UserList(userindex).UserTargetIndex).Invite = UserList(userindex).Clan
    Call SendData(ToIndex, UserList(userindex).UserTargetIndex, 0, "@You have been invited by " & UserList(userindex).Name & " to join the " & UserList(userindex).Clan & " clan. Type /JOIN to join the clan." & FONTTYPE_INFO)
    
      
Exit Sub
End If

'Join the clan
If UCase(rdata) = "/JOIN" Then
 
  'Check to see if member of other clan
  If UserList(userindex).Clan = "" Then
  'Do nothing
  Else
  Call SendData(ToIndex, userindex, 0, "@You are already a member of another clan. Seek out the monarch or a noble of your clan, so they can eject you from the clan before entering a new clan." & FONTTYPE_INFO)
  Exit Sub
  End If
  
 'NOT COMPLETED YET
Exit Sub
End If

'*****************************************************************
'*************** GameMaster commands *****************************
'*****************************************************************

If WizCheck(UserList(userindex).Flags.StartName) = False Then
Exit Sub
End If

'Open the GM tool
If UCase$(rdata) = "/GMTOOL" And WizCheck(UserList(userindex).Flags.StartName) = True Then
Call SendData(ToIndex, userindex, 0, "GTO")
Exit Sub
End If

'Change NPC`s hail
If Left$(rdata, 3) = "HAI" Then
rdata = Right$(rdata, Len(rdata) - 3)

Dim TargetedNpc As Long
TargetedNpc = UserList(userindex).Npcindex

If UserList(userindex).Npcindex = 0 Then
Exit Sub
End If



NPCList(TargetedNpc).Hail = rdata

Exit Sub
End If

'Give lock
If Left$(rdata, 3) = "GIL" Then
rdata = Right$(rdata, Len(rdata) - 3)

UserList(userindex).Flags.Locks = UserList(userindex).Flags.Locks + 1
Call SendData(ToIndex, userindex, 0, "@You have been given one more lock." & FONTTYPE_INFO)

Exit Sub
End If

'Change NPC`s name
If Left$(rdata, 3) = "NAA" Then
rdata = Right$(rdata, Len(rdata) - 3)

Dim TargeteddNpc As Long
TargeteddNpc = UserList(userindex).Npcindex

If UserList(userindex).Npcindex = 0 Then
Exit Sub
End If



NPCList(TargeteddNpc).Name = rdata
Call SendData(ToIndex, userindex, 0, "@NPC name has been changed." & FONTTYPE_INFO)

Exit Sub
End If

'Morph into something
If Left$(rdata, 3) = "TRO" Then
rdata = Right$(rdata, Len(rdata) - 3)


UserList(userindex).Flags.Morphed = 1
UserList(userindex).Char.Body = rdata
UserList(userindex).Char.Head = 2
UserList(userindex).Char.WeaponAnim = 2
UserList(userindex).Char.ShieldAnim = 2
UserList(userindex).Name = "a creature"


Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
Call SendUserStatsBox(userindex)


Exit Sub
End If

'Morph back to normal
If Left$(rdata, 3) = "NOR" Then
rdata = Right$(rdata, Len(rdata) - 3)

Dim ClothingBeforeMorph As Integer
ClothingBeforeMorph = ObjData(UserList(userindex).ClothingEqpObjindex).ClothingType

UserList(userindex).Flags.Morphed = 0
UserList(userindex).Char.Head = UserList(userindex).Flags.StartHead
UserList(userindex).Char.Body = ClothingBeforeMorph
UserList(userindex).Name = UserList(userindex).Flags.StartName
Call ChangeUserChar(ToMap, 0, UserList(userindex).Pos.map, userindex, UserList(userindex).Char.Body, UserList(userindex).Char.Head, UserList(userindex).Char.Heading, UserList(userindex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
SendUserStatsBox (userindex)

Exit Sub
End If

'Teleport GM to Gm meeting place
If Left$(rdata, 3) = "TGM" Then
rdata = Right$(rdata, Len(rdata) - 3)


If LegalPos(userindex, 142, 70, 68) Then
Call WarpUserChar(userindex, 142, 70, 68)
Else
If LegalPos(userindex, 142, 70, 67) Then
Call WarpUserChar(userindex, 142, 70, 67)
Else
If LegalPos(userindex, 142, 70, 66) Then
Call WarpUserChar(userindex, 142, 70, 66)
Else
If LegalPos(userindex, 142, 70, 65) Then
Call WarpUserChar(userindex, 142, 70, 65)
Else
If LegalPos(userindex, 142, 70, 64) Then
Call WarpUserChar(userindex, 142, 70, 64)
Else
If LegalPos(userindex, 142, 70, 63) Then
Call WarpUserChar(userindex, 142, 70, 63)
Else
If LegalPos(userindex, 142, 77, 73) Then
Call WarpUserChar(userindex, 142, 77, 73)
Else
If LegalPos(userindex, 142, 77, 72) Then
Call WarpUserChar(userindex, 142, 77, 72)
Else
If LegalPos(userindex, 142, 77, 71) Then
Call WarpUserChar(userindex, 142, 77, 71)
Else
If LegalPos(userindex, 142, 77, 70) Then
Call WarpUserChar(userindex, 142, 77, 70)
End If
End If
End If
End If
End If
End If
End If
End If
End If
End If

Exit Sub
End If


'TELEPORT TARGET

If Left$(rdata, 3) = "TEL" Then
rdata = Right$(rdata, Len(rdata) - 3)

UserTargetIndex = UserList(userindex).UserTargetIndex

If UserTargetIndex = UserList(userindex).Npcindex Then
Call SendData(ToIndex, userindex, 0, "@You cannot teleport NPC`s !" & FONTTYPE_INFO)
Exit Sub
End If

If LegalPos(userindex, ReadField(1, rdata, 44), ReadField(2, rdata, 44), ReadField(3, rdata, 44)) Then
Call WarpUserChar(UserList(userindex).UserTargetIndex, ReadField(1, rdata, 44), ReadField(2, rdata, 44), ReadField(3, rdata, 44))

'Log it-
Open App.Path & "\GMActions.log" For Append Shared As #5
Print #5, "****" & (UserList(userindex).Name) & " teleported " & UserList(UserTargetIndex).Name; " at" & Time & " " & Date
Close #5

Else
Call SendData(ToIndex, userindex, 0, "@Your target cannot be teleported to that place cause the place isnt not a legal position or its blocked." & FONTTYPE_INFO)
End If

Exit Sub
End If

'Update Que
If Left$(rdata, 3) = "QUE" Then
rdata = Right$(rdata, Len(rdata) - 3)

Call SendGmQue(userindex)

Exit Sub
End If


'KICK AND BAN PLAYER
If Left$(rdata, 3) = "BAN" Then
rdata = Right$(rdata, Len(rdata) - 3)

UserTargetIndex = UserList(userindex).UserTargetIndex

If UserTargetIndex = UserList(userindex).Npcindex Then
Call SendData(ToIndex, userindex, 0, "@You cannot kick or ban NPC`s !" & FONTTYPE_INFO)
Exit Sub
End If

Call KickBan(userindex, UserList(userindex).UserTargetIndex)

Exit Sub
End If

'RESSURECT TARGET

If Left$(rdata, 3) = "RET" Then
rdata = Right$(rdata, Len(rdata) - 3)

UserTargetIndex = UserList(userindex).UserTargetIndex

If UserTargetIndex = UserList(userindex).Npcindex Then
Call SendData(ToIndex, userindex, 0, "@You cannot ressurect NPC`s !" & FONTTYPE_INFO)
Exit Sub
End If

tIndex = UserTargetIndex

Dim OBJtarget As ObjData
OBJtarget = ObjData(UserList(tIndex).Object(UserList(tIndex).ClothingEqpSlot).ObjIndex)

If UserList(tIndex).Flags.status = 1 Then
UserList(tIndex).Flags.status = 0
UserList(tIndex).Char.Body = OBJtarget.ClothingType
UserList(tIndex).Char.Head = UserList(tIndex).Flags.StartHead
Call ChangeUserChar(ToMap, 0, UserList(tIndex).Pos.map, tIndex, UserList(tIndex).Char.Body, UserList(tIndex).Char.Head, UserList(tIndex).Char.Heading, UserList(tIndex).Char.WeaponAnim, UserList(tIndex).Char.ShieldAnim)
Call SendData(ToIndex, tIndex, 0, "@You have been ressurected by " & UserList(userindex).Name & " !" & FONTTYPE_INFO)
Call SendData(ToPCArea, userindex, UserList(userindex).Pos.map, "PLW" & SOUND_CHORUS)
Else
Call SendData(ToIndex, tIndex, 0, "@Target is not dead and can therefor not be ressurected." & FONTTYPE_INFO)
End If

Exit Sub
End If

'Boost all stats by 10
If Left$(rdata, 3) = "BOS" Then
rdata = Right$(rdata, Len(rdata) - 3)

'Boost HP
UserList(userindex).Stats.MaxHP = UserList(userindex).Stats.MaxHP + 10
UserList(userindex).Stats.MinHP = UserList(userindex).Stats.MinHP + 10
'Boost MANA
UserList(userindex).Stats.MaxMAN = UserList(userindex).Stats.MaxMAN + 10
UserList(userindex).Stats.MinMAN = UserList(userindex).Stats.MinMAN + 10
Call SendUserStatsBox(userindex)

Call SendData(ToIndex, userindex, 0, "@Your mana and HP was boosted by 10 !" & FONTTYPE_INFO)

Exit Sub
End If

'Boost hit points by 2
If Left$(rdata, 3) = "BOP" Then
rdata = Right$(rdata, Len(rdata) - 3)

'Boost hit points by 2
UserList(userindex).Stats.MaxHIT = UserList(userindex).Stats.MaxHIT + 2
UserList(userindex).Stats.MinHIT = UserList(userindex).Stats.MinHIT + 2
Call SendUserStatsBox(userindex)

Call SendData(ToIndex, userindex, 0, "@Your hit points was boosted by 2 !" & FONTTYPE_INFO)

Exit Sub
End If

'Boost experience by 100
If Left$(rdata, 3) = "BOE" Then
rdata = Right$(rdata, Len(rdata) - 3)

UserList(userindex).Stats.EXP = UserList(userindex).Stats.EXP + 100
Call SendUserStatsBox(userindex)
Call CheckUserLevel(userindex)

Call SendData(ToIndex, userindex, 0, "@Your experience was boosted by 100 !" & FONTTYPE_INFO)

Exit Sub
End If

'Help player
If Left$(rdata, 3) = "GMH" Then
rdata = Right$(rdata, Len(rdata) - 3)
Dim Helpindex As Integer
Dim LoggedOn As Integer

Helpindex = GetVar(IniPath & "Gmque.txt", "HELP" & rdata, "Userindex")

'Check if user still is logged on
If GetVar(IniPath & "Gmque.txt", "HELP" & rdata, "Name") = UserList(Helpindex).Name Then
LoggedOn = 1
'Remove HELP from que
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Helpmsg", "")
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Name", "")
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Time", "")
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Date", "")
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Userindex", "")
Else
Call SendData(ToIndex, userindex, 0, "!User no longer logged on.")
'Remove HELP from que
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Helpmsg", "")
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Name", "")
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Time", "")
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Date", "")
Call WriteVar(IniPath & "Gmque.txt", "HELP" & rdata, "Userindex", "")
Exit Sub
End If

'Teleport to player
Call WarpUserChar(userindex, UserList(Helpindex).Pos.map, UserList(Helpindex).Pos.X, UserList(Helpindex).Pos.Y + 1)
Call SendData(ToIndex, Helpindex, 0, "@A Gamemaster is here to help you !" & FONTTYPE_INFO)


Exit Sub
End If


'CREATE OBJECT

If Left$(rdata, 3) = "CRE" Then
rdata = Right$(rdata, Len(rdata) - 3)
Dim obj As obj

obj.ObjIndex = ReadField(1, rdata, 44)
obj.Amount = 1
Call MakeObj(ToMap, 0, UserList(userindex).Pos.map, obj, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y)

    'Log it-
    Open App.Path & "\GMActions.log" For Append Shared As #5
    Print #5, "****" & (UserList(userindex).Name) & "created object " & ReadField(1, rdata, 44) & " at" & Time & " " & Date
    Close #5

Exit Sub
End If

'Give yourself 1000 gold
If Left$(rdata, 3) = "GVG" Then
rdata = Right$(rdata, Len(rdata) - 3)

Call SendData(ToIndex, userindex, 0, "@You gave yourself 1000 gold." & FONTTYPE_INFO)
UserList(userindex).Stats.GLD = UserList(userindex).Stats.GLD + 1000

SendUserStatsBox (userindex)
Exit Sub
End If

'Make immortal
If Left$(rdata, 3) = "IMM" Then
rdata = Right$(rdata, Len(rdata) - 3)

UserList(userindex).Flags.Immortal = 1
Call SendData(ToIndex, userindex, 0, "@You are now immortal against other players attacks !" & FONTTYPE_INFO)

Exit Sub
End If

'Make mortal
    If Left$(rdata, 3) = "MMM" Then
rdata = Right$(rdata, Len(rdata) - 3)

UserList(userindex).Flags.Immortal = 0
Call SendData(ToIndex, userindex, 0, "@You are no longer immortal against other players attacks !" & FONTTYPE_INFO)

Exit Sub
End If

'Change Target`s stats
If Left$(rdata, 3) = "CH1" Then
rdata = Right$(rdata, Len(rdata) - 3)


'Check to see if target is a NPC
If UserList(userindex).UserTargetIndex = UserList(userindex).Npcindex Then
Call SendData(ToIndex, userindex, 0, "@You cannot change NPC`S stats." & FONTTYPE_INFO)
Exit Sub
End If

'Change stats
UserList(UserList(userindex).UserTargetIndex).Stats.MaxHP = rdata
UserList(UserList(userindex).UserTargetIndex).Stats.MinHP = rdata
Call SendData(ToIndex, UserList(userindex).UserTargetIndex, 0, "@Your stats was changed by " & UserList(userindex).Name & "." & FONTTYPE_INFO)
Call SendUserStatsBox(UserList(userindex).UserTargetIndex)
  
  'Log it-
   Open App.Path & "\GMActions.log" For Append Shared As #5
   Print #5, "****" & (UserList(userindex).Name) & "changed " & UserList(UserList(userindex).UserTargetIndex).Name & " statestics" & " at " & Time & "; " & Date; ""
   Close #5

Exit Sub
End If

'Change Target`s stats
If Left$(rdata, 3) = "CH2" Then
rdata = Right$(rdata, Len(rdata) - 3)


'Check to see if target is a NPC
If UserList(userindex).UserTargetIndex = UserList(userindex).Npcindex Then
Call SendData(ToIndex, userindex, 0, "@You cannot change NPC`S stats." & FONTTYPE_INFO)
Exit Sub
End If

'Change stats
UserList(UserList(userindex).UserTargetIndex).Stats.MaxMAN = rdata
UserList(UserList(userindex).UserTargetIndex).Stats.MinMAN = rdata
Call SendUserStatsBox(UserList(userindex).UserTargetIndex)

Exit Sub
End If

'Change Target`s stats
If Left$(rdata, 3) = "CH3" Then
rdata = Right$(rdata, Len(rdata) - 3)


'Check to see if target is a NPC
If UserList(userindex).UserTargetIndex = UserList(userindex).Npcindex Then
Call SendData(ToIndex, userindex, 0, "@You cannot change NPC`S stats." & FONTTYPE_INFO)
Exit Sub
End If

'Change stats
UserList(UserList(userindex).UserTargetIndex).Stats.MaxHIT = rdata
UserList(UserList(userindex).UserTargetIndex).Stats.MinHIT = rdata
Call SendUserStatsBox(UserList(userindex).UserTargetIndex)

Exit Sub
End If

'Change Target`s stats
If Left$(rdata, 3) = "CH4" Then
rdata = Right$(rdata, Len(rdata) - 3)


'Check to see if target is a NPC
If UserList(userindex).UserTargetIndex = UserList(userindex).Npcindex Then
Call SendData(ToIndex, userindex, 0, "@You cannot change NPC`S stats." & FONTTYPE_INFO)
Exit Sub
End If

'Change stats
UserList(UserList(userindex).UserTargetIndex).Stats.MaxSTA = rdata
UserList(UserList(userindex).UserTargetIndex).Stats.MinSTA = rdata
Call SendUserStatsBox(UserList(userindex).UserTargetIndex)

Exit Sub
End If

'Reset
If UCase$(rdata) = "/RESET" Then
    
Dim playeruser As Integer
For playeruser = 1 To LastUser

Call SaveUser(playeruser, CharPath & UCase(UserList(playeruser).Flags.StartName) & ".chr")

Next playeruser
    
    'Log it-
    Open App.Path & "\Main.log" For Append Shared As #5
    Print #5, "!Reset started by " & UserList(userindex).Name & ". " & Time & " " & Date
    Close #5
    
        'Log it-
    Open App.Path & "\GMActions.log" For Append Shared As #5
    Print #5, "****" & (UserList(userindex).Name) & "Has restarted the server at" & " at" & Time & " " & Date
    Close #5
    
    Call Restart
    Exit Sub
End If
  

 
'Shutdown
If UCase$(rdata) = "/SHUTDOWN" Then
Dim playeruser2 As Integer
    
For playeruser2 = 1 To LastUser

Call SaveUser(playeruser, CharPath & UCase(UserList(playeruser).Flags.StartName) & ".chr")

Next playeruser2

    'Log it-
    Open App.Path & "\Main.log" For Append Shared As #5
    Print #5, "!Shutdown started by " & UserList(userindex).Name & ". " & Time & " " & Date
    Close #5
    
        'Log it-
    Open App.Path & "\GMActions.log" For Append Shared As #5
    Print #5, "****" & (UserList(userindex).Name) & "Has shutdown the server" & " at" & Time & " " & Date
    Close #5
    
    Unload frmMain
    Exit Sub
End If

'Erase GM que
If UCase$(rdata) = "/ERASEQUE" Then

Kill IniPath & "Gmque.txt"

Exit Sub
End If

'Moderate map
If UCase$(rdata) = "/MODERATE" Then

If MapInfo(UserList(userindex).Pos.map).Moderated = 0 Then
MapInfo(UserList(userindex).Pos.map).Moderated = 1
Else
MapInfo(UserList(userindex).Pos.map).Moderated = 0
End If

Exit Sub
End If


'Erase MSG board
If UCase$(rdata) = "/ERASEBOARD" Then

Call WriteVar(IniPath & "msgboard.txt", "INIT", "NumPOSTs", "1")


Exit Sub
End If

'Reset NPC's gold
If UCase$(rdata) = "/RESETNPCGOLD" Then

Dim NPC As Integer

For NPC = 1 To LastNPC
If NPCList(NPC).NpcNumber < 499 Then NPCList(NPC).Gold = 100000
Next NPC

Exit Sub
End If

'Rain/snow
If UCase$(rdata) = "/WEATHER" Then

If Raining = 1 Then
Raining = 0
Call SendData(ToAll, 0, 0, "PLW" & SOUND_BIRDS)
Call SendData(ToAll, 0, 0, "SAI")
Call SendData(ToAll, 0, 0, "@The weather quiets..." & FONTTYPE_INFO)
frmMain.weather = "Sunny"
Else
Call SendData(ToAll, 0, 0, "RAI")
Call SendData(ToAll, 0, 0, "@A storm is brewing..." & FONTTYPE_INFO)
frmMain.weather = "Raining"
Call SendData(ToAll, 0, 0, "PLW" & SOUND_THUNDER)
Raining = 1
End If

Exit Sub
End If

'Spoof
If UCase$(Left$(rdata, 7)) = "/SPOOF " Then
    rdata = Right$(rdata, Len(rdata) - 7)
    
    tIndex = NameIndex(ReadField(1, rdata, 32))
    If tIndex <= 0 Then
        Call SendData(ToIndex, userindex, 0, "@User not online." & FONTTYPE_INFO)
        Exit Sub
    End If
    Call SendData(ToPCArea, tIndex, UserList(tIndex).Pos.map, "@" & rdata & FONTTYPE_TALK)
    Exit Sub
End If
  


'Control Code (send a command to all the clients)
If UCase$(Left$(rdata, 4)) = "/CC " Then
    rdata = Right$(rdata, Len(rdata) - 4)
    
    If rdata <> "" Then
        Call SendData(ToAll, 0, 0, rdata)
    End If
    
        'Log it-
    Open App.Path & "\GMActions.log" For Append Shared As #5
    Print #5, "****" & (UserList(userindex).Name) & "Sent out a control code " & " at" & Time & " " & Date
    Close #5
    
    Exit Sub
End If


'Where is
If UCase$(Left$(rdata, 9)) = "/WHEREIS " Then
    rdata = Right$(rdata, Len(rdata) - 9)
    
    tIndex = NameIndex(rdata)
    If tIndex <= 0 Then
        Call SendData(ToIndex, userindex, 0, "@User not online." & FONTTYPE_INFO)
        Exit Sub
    End If
        Call SendData(ToIndex, userindex, 0, "@Loc for " & UserList(tIndex).Name & ": " & UserList(tIndex).Pos.map & ", " & UserList(tIndex).Pos.X & ", " & UserList(tIndex).Pos.Y & "." & FONTTYPE_INFO)

    'Log it-
    Open App.Path & "\GMActions.log" For Append Shared As #5
    Print #5, "****" & (UserList(userindex).Name) & "Did a whois on " & UserList(tIndex).Name & " at" & Time & " " & Date
    Close #5
Exit Sub
End If

'Approach
If UCase$(Left$(rdata, 10)) = "/APPROACH " Then
    rdata = Right$(rdata, Len(rdata) - 10)
    
    tIndex = NameIndex(rdata)
    If tIndex <= 0 Then
        Call SendData(ToIndex, userindex, 0, "@User not online." & FONTTYPE_INFO)
        Exit Sub
    End If
        Call WarpUserChar(userindex, UserList(tIndex).Pos.map, UserList(tIndex).Pos.X, UserList(tIndex).Pos.Y + 1)
        Call SendData(ToIndex, tIndex, 0, "@" & UserList(userindex).Name & " approached you." & FONTTYPE_INFO)

    'Log it-
    Open App.Path & "\GMActions.log" For Append Shared As #5
    Print #5, "****" & (UserList(userindex).Name) & "Approached " & UserList(tIndex).Name & " at" & Time & " " & Date
    Close #5
Exit Sub
End If


'Broadcast
If UCase$(Left$(rdata, 11)) = "/BROADCAST " Then
    rdata = Right$(rdata, Len(rdata) - 11)
Call SendData(ToAll, 0, 0, "!" & rdata)
Exit Sub
End If

'Summon
If UCase$(Left$(rdata, 8)) = "/SUMMON " Then
    rdata = Right$(rdata, Len(rdata) - 8)
    
    tIndex = NameIndex(rdata)
    If tIndex <= 0 Then
        Call SendData(ToIndex, userindex, 0, "@User not online." & FONTTYPE_INFO)
        Exit Sub
    End If
    Call SendUserStatsBox(userindex)
    Call SendUserStatsBox(tIndex)
    
        Call SendData(ToIndex, tIndex, 0, "@" & UserList(userindex).Name & " has summoned you." & FONTTYPE_INFO)
        Call WarpUserChar(tIndex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y + 1)

    'Log it-
    Open App.Path & "\GMActions.log" For Append Shared As #5
    Print #5, "****" & (UserList(userindex).Name) & "summoned " & UserList(tIndex).Name & " at" & Time & " " & Date
    Close #5
    
Exit Sub
End If


'Summon NPC
If UCase$(Left$(rdata, 11)) = "/SUMMONNPC " Then
    rdata = Right$(rdata, Len(rdata) - 11)
    
    tIndex = rdata
    
    'Check to see if target is player, if so, abort
    If UserList(userindex).UserTargetIndex = tIndex Then
    Call SendData(ToIndex, userindex, 0, "@You cannot use SUMMON NPC command to summon players. To summon players, use the /SUMMON command." & FONTTYPE_INFO)
    Exit Sub
    End If
    
    'Warp NPC
    Call WarpNPCChar(tIndex, UserList(userindex).Pos.map, UserList(userindex).Pos.X, UserList(userindex).Pos.Y + 1)
    
Exit Sub
End If



'Kick user
If UCase$(Left$(rdata, 6)) = "/KICK " Then
    rdata = Right$(rdata, Len(rdata) - 6)
    
    tIndex = NameIndex(rdata)
    
    If tIndex <= 0 Then
        Call SendData(ToIndex, userindex, 0, "@User not online." & FONTTYPE_INFO)
        Exit Sub
    End If
    
    Call SendData(ToIndex, tIndex, 0, "!!You were kicked from the game by a gamemaster." & FONTTYPE_INFO)
    
    'Log it-
    Open App.Path & "\GMactions.log" For Append Shared As #5
    Print #5, "" & UserList(userindex).Name & " kicked " & UserList(tIndex).Name & " at " & Time & " " & Date
    Close #5
    
    CloseSocket (tIndex)
    Exit Sub
End If

'Junk WIPE
If UCase(Left(rdata, 9)) = "/JUNKWIPE" Then
    rdata = Right$(rdata, Len(rdata) - 9)
    Call SendData(ToAll, 0, 0, "@SERVER IS CLEANING WORLD FOR JUNK...PLEASE EXCUSE ANY POSSIBLE LAG FOR THE NEXT FEW MINUTES." & FONTTYPE_INFO)
    Call SendData(ToAll, 0, 0, "@SERVER IS CLEANING WORLD FOR JUNK...PLEASE EXCUSE ANY POSSIBLE LAG FOR THE NEXT FEW MINUTES." & FONTTYPE_INFO)
    Call SendData(ToAll, 0, 0, "@SERVER IS CLEANING WORLD FOR JUNK...PLEASE EXCUSE ANY POSSIBLE LAG FOR THE NEXT FEW MINUTES." & FONTTYPE_INFO)
Call WipeJunk
Exit Sub
End If

'Character modify
If UCase(Left(rdata, 9)) = "/CHARMOD " Then
    rdata = Right$(rdata, Len(rdata) - 9)
    
    tIndex = NameIndex(ReadField(1, rdata, 32))
    Arg1 = ReadField(2, rdata, 32)
    Arg2 = ReadField(3, rdata, 32)
    Arg3 = ReadField(4, rdata, 32)
    Arg4 = ReadField(5, rdata, 32)

    If tIndex <= 0 Then
        Call SendData(ToIndex, userindex, 0, "@User not online." & FONTTYPE_INFO)
        Exit Sub
    End If
    
    Select Case UCase(Arg1)

    
        Case "GLD"
            UserList(tIndex).Stats.GLD = Val(Arg2)
            Call SendUserStatsBox(tIndex)

        Case "LVL"
            UserList(tIndex).Stats.ELV = Val(Arg2)
            Call SendUserStatsBox(tIndex)
    
        Case "BODY"
            Call ChangeUserChar(ToMap, 0, UserList(tIndex).Pos.map, tIndex, Val(Arg2), UserList(tIndex).Char.Head, UserList(tIndex).Char.Heading, UserList(tIndex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)

        Case "HEAD"
            Call ChangeUserChar(ToMap, 0, UserList(tIndex).Pos.map, tIndex, UserList(tIndex).Char.Body, Val(Arg2), UserList(tIndex).Char.Heading, UserList(tIndex).Char.WeaponAnim, UserList(userindex).Char.ShieldAnim)
        
        Case "WARP"
            If LegalPos(userindex, Val(Arg2), Val(Arg3), Val(Arg4)) Then
                Call WarpUserChar(tIndex, Val(Arg2), Val(Arg3), Val(Arg4))
                'Log it--
    Open App.Path & "\GMActions.log" For Append Shared As #5
    Print #5, "****" & (UserList(userindex).Name) & "Altered this character: " & UserList(tIndex).Name & " at" & Time & " " & Date
    Close #5
            Else
                Call SendData(ToIndex, userindex, 0, "@Not a legal position." & FONTTYPE_INFO)
            End If
        
        
        
        Case Else
            Call SendData(ToIndex, userindex, 0, "@Not a charmod command." & FONTTYPE_INFO)
    
    End Select

    Exit Sub
End If


'**************************************



End Sub



