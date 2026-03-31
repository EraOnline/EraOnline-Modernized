VERSION 5.00
Begin VB.Form toolbox 
   AutoRedraw      =   -1  'True
   BackColor       =   &H00004080&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Toolbox"
   ClientHeight    =   8385
   ClientLeft      =   7830
   ClientTop       =   330
   ClientWidth     =   3795
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8385
   ScaleWidth      =   3795
   Begin VB.CommandButton Command5 
      Caption         =   "Place Grh Random"
      Height          =   255
      Left            =   2040
      TabIndex        =   33
      Top             =   3360
      Width           =   1575
   End
   Begin VB.TextBox grhrandom 
      BackColor       =   &H00004080&
      ForeColor       =   &H80000005&
      Height          =   285
      Left            =   2040
      TabIndex        =   32
      Top             =   2880
      Width           =   1575
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Proceed"
      Height          =   255
      Left            =   840
      TabIndex        =   31
      Top             =   7920
      Width           =   1935
   End
   Begin VB.TextBox blockgrh 
      BackColor       =   &H00004080&
      ForeColor       =   &H80000009&
      Height          =   285
      Left            =   1440
      TabIndex        =   30
      Top             =   7560
      Width           =   735
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Place It Randomly"
      Height          =   255
      Left            =   1920
      TabIndex        =   28
      Top             =   6840
      Width           =   1575
   End
   Begin VB.CheckBox Erasechk 
      BackColor       =   &H00004080&
      Caption         =   "Erase Layer"
      ForeColor       =   &H80000005&
      Height          =   255
      Left            =   2400
      TabIndex        =   20
      TabStop         =   0   'False
      Top             =   1080
      Width           =   1215
   End
   Begin VB.CheckBox EraseAllchk 
      BackColor       =   &H00004080&
      Caption         =   "Erase All"
      ForeColor       =   &H80000005&
      Height          =   255
      Left            =   2400
      TabIndex        =   19
      TabStop         =   0   'False
      Top             =   840
      Width           =   975
   End
   Begin VB.CheckBox Blockedchk 
      BackColor       =   &H00004080&
      Caption         =   "Blocked"
      ForeColor       =   &H80000005&
      Height          =   195
      Left            =   2040
      TabIndex        =   18
      TabStop         =   0   'False
      Top             =   3840
      Width           =   915
   End
   Begin VB.TextBox Layertxt 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   405
      Left            =   1920
      TabIndex        =   17
      Text            =   "1"
      Top             =   840
      Width           =   435
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Down"
      Height          =   255
      Left            =   1080
      TabIndex        =   16
      TabStop         =   0   'False
      Top             =   960
      Width           =   615
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Up"
      Height          =   255
      Left            =   1080
      TabIndex        =   15
      TabStop         =   0   'False
      Top             =   720
      Width           =   615
   End
   Begin VB.TextBox Grhtxt 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   390
      Left            =   240
      TabIndex        =   14
      Text            =   "1"
      Top             =   840
      Width           =   795
   End
   Begin VB.CommandButton PlaceBlockCmd 
      Caption         =   "Change Blocked"
      Height          =   255
      Left            =   2040
      TabIndex        =   13
      Top             =   4200
      Width           =   1515
   End
   Begin VB.CommandButton PlaceGrhCmd 
      Caption         =   "Place Grh"
      Enabled         =   0   'False
      Height          =   255
      Left            =   240
      TabIndex        =   12
      Top             =   1440
      Width           =   1515
   End
   Begin VB.CommandButton PlaceExitCmd 
      Caption         =   "Place Exit"
      Height          =   255
      Left            =   180
      TabIndex        =   11
      Top             =   4200
      Width           =   1515
   End
   Begin VB.CheckBox EraseExitChk 
      BackColor       =   &H00004080&
      Caption         =   "Erase Exit"
      ForeColor       =   &H80000005&
      Height          =   315
      Left            =   180
      TabIndex        =   10
      TabStop         =   0   'False
      Top             =   3840
      Width           =   1215
   End
   Begin VB.TextBox MapExitTxt 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   405
      Left            =   900
      TabIndex        =   9
      Text            =   "1"
      Top             =   2460
      Width           =   795
   End
   Begin VB.TextBox XExitTxt 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   405
      Left            =   900
      TabIndex        =   8
      Text            =   "1"
      Top             =   2880
      Width           =   795
   End
   Begin VB.TextBox YExitTxt 
      Appearance      =   0  'Flat
      BackColor       =   &H00004080&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   405
      Left            =   900
      TabIndex        =   7
      Text            =   "1"
      Top             =   3360
      Width           =   795
   End
   Begin VB.ListBox NPCLst 
      BackColor       =   &H00004080&
      ForeColor       =   &H80000005&
      Height          =   1230
      Left            =   1920
      TabIndex        =   6
      Top             =   4680
      Width           =   1575
   End
   Begin VB.CommandButton PlaceNPCCmd 
      Caption         =   "Place NPC"
      Height          =   255
      Left            =   1920
      TabIndex        =   5
      Top             =   6480
      Width           =   1575
   End
   Begin VB.CheckBox EraseNPCChk 
      BackColor       =   &H00004080&
      Caption         =   "Erase NPC"
      ForeColor       =   &H80000005&
      Height          =   195
      Left            =   1950
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   6120
      Width           =   1215
   End
   Begin VB.ListBox ObjLst 
      BackColor       =   &H00004080&
      ForeColor       =   &H80000005&
      Height          =   1230
      Left            =   180
      TabIndex        =   3
      Top             =   4740
      Width           =   1575
   End
   Begin VB.CommandButton PlaceObjCmd 
      Caption         =   "Place OBJ"
      Height          =   255
      Left            =   180
      TabIndex        =   2
      Top             =   6600
      Width           =   1515
   End
   Begin VB.CheckBox EraseObjChk 
      BackColor       =   &H00004080&
      Caption         =   "Erase OBJ"
      ForeColor       =   &H80000005&
      Height          =   195
      Left            =   180
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   6300
      Width           =   1215
   End
   Begin VB.TextBox OBJAmountTxt 
      BackColor       =   &H00004080&
      ForeColor       =   &H80000005&
      Height          =   285
      Left            =   1080
      TabIndex        =   0
      Text            =   "1"
      Top             =   6000
      Width           =   555
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   "How Many:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2400
      TabIndex        =   34
      Top             =   2520
      Width           =   855
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Block ALL Tiles with this GRH on map:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   480
      TabIndex        =   29
      Top             =   7320
      Width           =   2775
   End
   Begin VB.Shape Shape6 
      BorderWidth     =   2
      Height          =   1095
      Left            =   120
      Top             =   7200
      Width           =   3615
   End
   Begin VB.Label RoomLbl 
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
      Height          =   360
      Left            =   240
      TabIndex        =   27
      Top             =   120
      Width           =   3285
   End
   Begin VB.Label Label3 
      AutoSize        =   -1  'True
      BackColor       =   &H00000040&
      BackStyle       =   0  'Transparent
      Caption         =   "Grh"
      ForeColor       =   &H80000005&
      Height          =   195
      Left            =   240
      TabIndex        =   26
      Top             =   600
      Width           =   255
   End
   Begin VB.Label Label2 
      AutoSize        =   -1  'True
      BackColor       =   &H00000040&
      BackStyle       =   0  'Transparent
      Caption         =   "Layer"
      ForeColor       =   &H80000005&
      Height          =   195
      Left            =   1920
      TabIndex        =   25
      Top             =   600
      Width           =   390
   End
   Begin VB.Label Label6 
      AutoSize        =   -1  'True
      BackColor       =   &H00000040&
      BackStyle       =   0  'Transparent
      Caption         =   "X:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   300
      Left            =   210
      TabIndex        =   24
      Top             =   2880
      Width           =   225
   End
   Begin VB.Label Label7 
      AutoSize        =   -1  'True
      BackColor       =   &H00000040&
      BackStyle       =   0  'Transparent
      Caption         =   "Y:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   300
      Left            =   210
      TabIndex        =   23
      Top             =   3360
      Width           =   225
   End
   Begin VB.Label Label8 
      AutoSize        =   -1  'True
      BackColor       =   &H00000040&
      BackStyle       =   0  'Transparent
      Caption         =   "MAP:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   300
      Left            =   180
      TabIndex        =   22
      Top             =   2520
      Width           =   570
   End
   Begin VB.Shape Shape2 
      BorderWidth     =   2
      Height          =   2175
      Left            =   120
      Top             =   0
      Width           =   3615
   End
   Begin VB.Shape Shape3 
      BorderWidth     =   2
      Height          =   2295
      Left            =   120
      Top             =   2280
      Width           =   1695
   End
   Begin VB.Shape Shape4 
      BorderWidth     =   2
      Height          =   2655
      Left            =   1800
      Top             =   4560
      Width           =   1935
   End
   Begin VB.Shape Shape5 
      BorderWidth     =   2
      Height          =   2655
      Left            =   120
      Top             =   4560
      Width           =   1695
   End
   Begin VB.Label Label9 
      AutoSize        =   -1  'True
      BackColor       =   &H00000040&
      BackStyle       =   0  'Transparent
      Caption         =   "Amount"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   240
      Left            =   240
      TabIndex        =   21
      Top             =   6000
      Width           =   675
   End
   Begin VB.Shape Shape1 
      BorderWidth     =   2
      Height          =   2295
      Left            =   1800
      Top             =   2280
      Width           =   1935
   End
End
Attribute VB_Name = "toolbox"
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

Private Sub Command1_Click()
Grhtxt = Grhtxt + 1


End Sub

Private Sub Command2_Click()
Grhtxt = Grhtxt - 1


End Sub

Private Sub Command3_Click()

Dim NPCIndex As Integer
Dim Head As Integer
Dim Body As Integer
Dim Heading As Byte
Dim yer As Integer
Dim xer As Integer

NPCIndex = toolbox.NPCLst.ListIndex + 1
Body = Val(GetVar(IniPath & "NPC.dat", "NPC" & NPCIndex, "Body"))
Head = Val(GetVar(IniPath & "NPC.dat", "NPC" & NPCIndex, "Head"))
Heading = Val(GetVar(IniPath & "NPC.dat", "NPC" & NPCIndex, "Heading"))

looper:
yer = RandomNumber(YMinMapSize, YMaxMapSize)
xer = RandomNumber(XMinMapSize, XMaxMapSize)

If LegalPos(xer, yer) Then
Call MakeChar(Body, Head, Heading, xer, yer)
MapData(xer, yer).NPCIndex = NPCIndex
Else
GoTo looper
End If

MapInfo.Changed = 1

End Sub

Private Sub Command4_Click()
Dim map
Dim xer
Dim yer

For xer = XMinMapSize To XMaxMapSize
For yer = YMinMapSize To XMaxMapSize

'layer 1
If MapData(xer, yer).Graphic(1).GrhIndex = blockgrh.Text Then
MapData(xer, yer).Blocked = 1
End If

'layer2
If MapData(xer, yer).Graphic(2).GrhIndex = blockgrh.Text Then
MapData(xer, yer).Blocked = 1
End If

'layer3
If MapData(xer, yer).Graphic(3).GrhIndex = blockgrh.Text Then
MapData(xer, yer).Blocked = 1
End If

Next yer
Next xer

MapInfo.Changed = 1

End Sub

Private Sub Command5_Click()
Dim xer As Integer
Dim yer As Integer

looper:
yer = RandomNumber(YMinMapSize, YMaxMapSize)
xer = RandomNumber(XMinMapSize, XMaxMapSize)

If LegalPos(xer, yer) Then
 MapData(xer, yer).Graphic(Val(toolbox.Layertxt.Text)).GrhIndex = Val(toolbox.Grhtxt)
 InitGrh MapData(xer, yer).Graphic(Val(toolbox.Layertxt.Text)), Val(toolbox.Grhtxt.Text)
 MapData(xer, yer).Blocked = toolbox.Blockedchk.value
Else
GoTo looper
End If

grhrandom.Text = grhrandom.Text - 1
If grhrandom.Text > 0 Then
GoTo looper
Else
MsgBox "Finished placing GRH randomly."
End If

MapInfo.Changed = 1

End Sub

Private Sub Command6_Click()
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


End Sub

Private Sub Erasechk_Click()
'Set Place GRh mode
Call PlaceGrhCmd_Click


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

Private Sub fishzonechk_Click()

End Sub

Private Sub Grhtxt_Change()

If Val(Grhtxt.Text) < 1 Then
  Grhtxt.Text = NumGrhs
  Exit Sub
End If

If Val(Grhtxt.Text) > NumGrhs Then
  Grhtxt.Text = 1
  Exit Sub
End If

'Change CurrentGrh
CurrentGrh.GrhIndex = Val(toolbox.Grhtxt.Text)
CurrentGrh.Started = 1
CurrentGrh.FrameCounter = 1
CurrentGrh.SpeedCounter = GrhData(CurrentGrh.GrhIndex).Speed
End Sub

Private Sub Layertxt_Change()

If Val(Layertxt.Text) < 1 Then
  Layertxt.Text = 1
End If

If Val(Layertxt.Text) > 2 Then
  Layertxt.Text = 2
End If

Call PlaceGrhCmd_Click
End Sub

Private Sub MapExitTxt_Change()

If Val(MapExitTxt.Text) < 1 Then
  MapExitTxt.Text = 1
End If

If Val(MapExitTxt.Text) > NumMaps Then
  MapExitTxt.Text = NumMaps
End If

Call PlaceExitCmd_Click

End Sub

Private Sub NPCLst_Click()
Call PlaceNPCCmd_Click
End Sub

Private Sub OBJAmountTxt_Change()
If Val(OBJAmountTxt.Text) > MAX_INVENORY_OBJS Then
    OBJAmountTxt.Text = 0
End If

If Val(OBJAmountTxt.Text) < 1 Then
    OBJAmountTxt.Text = MAX_INVENORY_OBJS
End If
End Sub

Private Sub ObjLst_Click()
Call PlaceObjCmd_Click
End Sub

Private Sub PlaceBlockCmd_Click()

PlaceGrhCmd.Enabled = True
PlaceBlockCmd.Enabled = False
PlaceExitCmd.Enabled = True
PlaceNPCCmd.Enabled = True
PlaceObjCmd.Enabled = True


End Sub

Private Sub PlaceExitCmd_Click()

PlaceGrhCmd.Enabled = True
PlaceBlockCmd.Enabled = True
PlaceExitCmd.Enabled = False
PlaceNPCCmd.Enabled = True
PlaceObjCmd.Enabled = True


End Sub

Private Sub PlaceFishZoneCMD_Click()



End Sub

Private Sub PlaceGrhCmd_Click()
PlaceGrhCmd.Enabled = False
PlaceBlockCmd.Enabled = True
PlaceExitCmd.Enabled = True
PlaceNPCCmd.Enabled = True
PlaceObjCmd.Enabled = True


End Sub

Private Sub PlaceNPCCmd_Click()

PlaceGrhCmd.Enabled = True
PlaceBlockCmd.Enabled = True
PlaceExitCmd.Enabled = True
PlaceNPCCmd.Enabled = False
PlaceObjCmd.Enabled = True

End Sub

Private Sub PlaceObjCmd_Click()

PlaceGrhCmd.Enabled = True
PlaceBlockCmd.Enabled = True
PlaceExitCmd.Enabled = True
PlaceNPCCmd.Enabled = True
PlaceObjCmd.Enabled = False


End Sub


Private Sub XExitTxt_Change()
If Val(XExitTxt.Text) < XMinMapSize Then
  XExitTxt.Text = XMinMapSize
End If

If Val(XExitTxt.Text) > XMaxMapSize Then
  XExitTxt.Text = XMaxMapSize
End If

Call PlaceExitCmd_Click
End Sub

Private Sub YExitTxt_Change()
If Val(YExitTxt.Text) < YMinMapSize Then
  YExitTxt.Text = YMinMapSize
End If

If Val(YExitTxt.Text) > YMaxMapSize Then
  YExitTxt.Text = YMaxMapSize
End If

Call PlaceExitCmd_Click

End Sub
