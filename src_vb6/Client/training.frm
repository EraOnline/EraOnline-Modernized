VERSION 5.00
Begin VB.Form training 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   8280
   ClientLeft      =   1350
   ClientTop       =   15
   ClientWidth     =   9180
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8280
   ScaleWidth      =   9180
   Begin VB.Label etiquette 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   59
      Top             =   3720
      Width           =   855
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "Close"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   7320
      TabIndex        =   58
      Top             =   7800
      Width           =   1695
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Training"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   26.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   735
      Left            =   1320
      TabIndex        =   57
      Top             =   0
      Width           =   6255
   End
   Begin VB.Label trainingpoints 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   4320
      TabIndex        =   56
      Top             =   5760
      Width           =   2415
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "Training Points Left:"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   4440
      TabIndex        =   55
      Top             =   5400
      Width           =   3135
   End
   Begin VB.Label cooking 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   54
      Top             =   840
      Width           =   735
   End
   Begin VB.Label musicanship 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   53
      Top             =   1200
      Width           =   615
   End
   Begin VB.Label tailoring 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   52
      Top             =   1680
      Width           =   615
   End
   Begin VB.Label carpenting 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   51
      Top             =   2040
      Width           =   735
   End
   Begin VB.Label lumberjacking 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   50
      Top             =   2400
      Width           =   735
   End
   Begin VB.Label tactics 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   49
      Top             =   2760
      Width           =   735
   End
   Begin VB.Label disguise 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   48
      Top             =   3120
      Width           =   735
   End
   Begin VB.Label merchant 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   47
      Top             =   3480
      Width           =   735
   End
   Begin VB.Label blacksmithing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   46
      Top             =   3840
      Width           =   735
   End
   Begin VB.Label hiding 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   45
      Top             =   4200
      Width           =   735
   End
   Begin VB.Label magery 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   44
      Top             =   4560
      Width           =   735
   End
   Begin VB.Label lockpicking 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   43
      Top             =   4920
      Width           =   735
   End
   Begin VB.Label pickpocket 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   42
      Top             =   5280
      Width           =   735
   End
   Begin VB.Label stealth 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   41
      Top             =   5640
      Width           =   735
   End
   Begin VB.Label poisoning 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   40
      Top             =   6000
      Width           =   735
   End
   Begin VB.Label swordmanship 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   3240
      TabIndex        =   39
      Top             =   6360
      Width           =   1095
   End
   Begin VB.Label parrying 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   38
      Top             =   840
      Width           =   855
   End
   Begin VB.Label AnimalTaming 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   37
      Top             =   1200
      Width           =   495
   End
   Begin VB.Label religionlore 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   36
      Top             =   1560
      Width           =   615
   End
   Begin VB.Label fishing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   35
      Top             =   1920
      Width           =   615
   End
   Begin VB.Label mining 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   34
      Top             =   2280
      Width           =   615
   End
   Begin VB.Label backstabbing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   33
      Top             =   2640
      Width           =   615
   End
   Begin VB.Label healing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   32
      Top             =   3000
      Width           =   735
   End
   Begin VB.Label surviving 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   31
      Top             =   3360
      Width           =   735
   End
   Begin VB.Label streetwise 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   30
      Top             =   4080
      Width           =   735
   End
   Begin VB.Label meditating 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   29
      Top             =   4440
      Width           =   735
   End
   Begin VB.Label archery 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   5640
      TabIndex        =   28
      Top             =   4800
      Width           =   855
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Pickpocket:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   24
      Left            =   2160
      TabIndex        =   27
      Top             =   5280
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Lockpicking:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   23
      Left            =   2160
      TabIndex        =   26
      Top             =   4920
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Backstabbing:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   22
      Left            =   4560
      TabIndex        =   25
      Top             =   2640
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Etiquette:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   21
      Left            =   4560
      TabIndex        =   24
      Top             =   3720
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Religion Lore:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   20
      Left            =   4560
      TabIndex        =   23
      Top             =   1560
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Magery:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   19
      Left            =   2160
      TabIndex        =   22
      Top             =   4560
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Healing:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   18
      Left            =   4560
      TabIndex        =   21
      Top             =   3000
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Parrying:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   17
      Left            =   4560
      TabIndex        =   20
      Top             =   840
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Tactics:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   16
      Left            =   2160
      TabIndex        =   19
      Top             =   2760
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Swordmanship:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   15
      Left            =   2160
      TabIndex        =   18
      Top             =   6360
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Stealth:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   14
      Left            =   2160
      TabIndex        =   17
      Top             =   5640
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Hiding:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   13
      Left            =   2160
      TabIndex        =   16
      Top             =   4200
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Carpetning:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   12
      Left            =   2160
      TabIndex        =   15
      Top             =   2040
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Lumberjacking:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   11
      Left            =   2160
      TabIndex        =   14
      Top             =   2400
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Poisoning:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   10
      Left            =   2160
      TabIndex        =   13
      Top             =   6000
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "BlackSmithing:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   9
      Left            =   2160
      TabIndex        =   12
      Top             =   3840
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Tailoring:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   8
      Left            =   2160
      TabIndex        =   11
      Top             =   1680
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Fishing:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   7
      Left            =   4560
      TabIndex        =   10
      Top             =   1920
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Animal Taming:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   6
      Left            =   4560
      TabIndex        =   9
      Top             =   1200
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Mechant:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   5
      Left            =   2160
      TabIndex        =   8
      Top             =   3480
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Musicanship:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   4
      Left            =   2160
      TabIndex        =   7
      Top             =   1200
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Mining:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   3
      Left            =   4560
      TabIndex        =   6
      Top             =   2280
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Surviving:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   2
      Left            =   4560
      TabIndex        =   5
      Top             =   3360
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Disguise:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   1
      Left            =   2160
      TabIndex        =   4
      Top             =   3120
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Cooking:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   25
      Left            =   2160
      TabIndex        =   3
      Top             =   840
      Width           =   1335
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   "Streetwise:"
      Height          =   255
      Left            =   4560
      TabIndex        =   2
      Top             =   4080
      Width           =   855
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Caption         =   "Meditating:"
      Height          =   255
      Left            =   4560
      TabIndex        =   1
      Top             =   4440
      Width           =   975
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Archery:"
      Height          =   255
      Left            =   4560
      TabIndex        =   0
      Top             =   4800
      Width           =   975
   End
End
Attribute VB_Name = "training"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub archery_Click()
On Error Resume Next

If SpecializedSkill("Archery") = False And archery > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
archery = archery + 1
SendData "T28"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub backstabbing_Click()

On Error Resume Next

If SpecializedSkill("Backstabbing") = False And backstabbing > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
backstabbing = backstabbing + 1
SendData "T22"
trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub disguise_Click()


If SpecializedSkill("Disguise") = False And disguise > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
disguise = disguise + 1
SendData "T07"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub blacksmithing_Click()


If SpecializedSkill("Blacksmithing") = False And blacksmithing > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
blacksmithing = blacksmithing + 1
SendData "T09"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub carpenting_Click()


If SpecializedSkill("Carpenting") = False And carpenting > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
carpenting = carpenting + 1
SendData "T04"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub cooking_Click()



Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Cooking") = False And cooking > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If



If trainingpoints > 0 Then
cooking = cooking + 1
SendData "T01"
trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub etiquette_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Etiquette") = False And etiquette > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
etiquette = etiquette + 1
SendData "T25"
trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub fishing_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Fishing") = False And fishing > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
fishing = fishing + 1
SendData "T20"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub Form_Load()
training.Picture = LoadPicture(IniPath & "Grh\msgboard.jpg")

trainingpoints.Caption = UserPracticePoints
cooking.Caption = UserSkill1
musicanship.Caption = UserSkill2
tailoring.Caption = UserSkill3
carpenting.Caption = UserSkill4
lumberjacking.Caption = UserSkill5
tactics.Caption = UserSkill6
disguise.Caption = UserSkill7
merchant.Caption = UserSkill8
blacksmithing.Caption = UserSkill9
hiding.Caption = UserSkill10
magery.Caption = UserSkill11
lockpicking.Caption = UserSkill12
pickpocket.Caption = UserSkill13
stealth.Caption = UserSkill14
poisoning.Caption = UserSkill15
swordmanship.Caption = UserSkill16
parrying.Caption = UserSkill17
AnimalTaming.Caption = UserSkill18
religionlore.Caption = UserSkill19
fishing.Caption = UserSkill20
mining.Caption = UserSkill21
backstabbing.Caption = UserSkill22
healing.Caption = UserSkill23
surviving.Caption = UserSkill24
etiquette.Caption = UserSkill25
streetwise.Caption = UserSkill26
meditating.Caption = UserSkill27
archery.Caption = UserSkill28

If SpecSkill1 = "Cooking" Then cooking.ForeColor = &HFF&
If SpecSkill1 = "Musicanship" Then musicanship.ForeColor = &HFF&
If SpecSkill1 = "Tailoring" Then tailoring.ForeColor = &HFF&
If SpecSkill1 = "Carpenting" Then carpenting.ForeColor = &HFF&
If SpecSkill1 = "Lumberjacking" Then lumberjacking.ForeColor = &HFF&
If SpecSkill1 = "Tactics" Then tactics.ForeColor = &HFF&
If SpecSkill1 = "Disguise" Then disguise.ForeColor = &HFF&
If SpecSkill1 = "Merchant" Then merchant.ForeColor = &HFF&
If SpecSkill1 = "Blacksmithing" Then blacksmithing.ForeColor = &HFF&
If SpecSkill1 = "Hiding" Then hiding.ForeColor = &HFF&
If SpecSkill1 = "Magery" Then magery.ForeColor = &HFF&
If SpecSkill1 = "Lockpicking" Then lockpicking.ForeColor = &HFF&
If SpecSkill1 = "Pickpocket" Then pickpocket.ForeColor = &HFF&
If SpecSkill1 = "Stealth" Then stealth.ForeColor = &HFF&
If SpecSkill1 = "Poisoning" Then poisoning.ForeColor = &HFF&
If SpecSkill1 = "Swordmanship" Then swordmanship.ForeColor = &HFF&
If SpecSkill1 = "Parrying" Then parrying.ForeColor = &HFF&
If SpecSkill1 = "Animal Taming" Then AnimalTaming.ForeColor = &HFF&
If SpecSkill1 = "Religion Lore" Then religionlore.ForeColor = &HFF&
If SpecSkill1 = "Fishing" Then fishing.ForeColor = &HFF&
If SpecSkill1 = "Mining" Then mining.ForeColor = &HFF&
If SpecSkill1 = "Backstabbing" Then backstabbing.ForeColor = &HFF&
If SpecSkill1 = "Healing" Then healing.ForeColor = &HFF&
If SpecSkill1 = "Surviving" Then surviving.ForeColor = &HFF&
If SpecSkill1 = "Etiquette" Then etiquette.ForeColor = &HFF&
If SpecSkill1 = "Streetwise" Then streetwise.ForeColor = &HFF&
If SpecSkill1 = "Meditating" Then meditating.ForeColor = &HFF&
If SpecSkill1 = "Archery" Then archery.ForeColor = &HFF&

If SpecSkill2 = "Cooking" Then cooking.ForeColor = &HFF&
If SpecSkill2 = "Musicanship" Then musicanship.ForeColor = &HFF&
If SpecSkill2 = "Tailoring" Then tailoring.ForeColor = &HFF&
If SpecSkill2 = "Carpenting" Then carpenting.ForeColor = &HFF&
If SpecSkill2 = "Lumberjacking" Then lumberjacking.ForeColor = &HFF&
If SpecSkill2 = "Tactics" Then tactics.ForeColor = &HFF&
If SpecSkill2 = "Disguise" Then disguise.ForeColor = &HFF&
If SpecSkill2 = "Merchant" Then merchant.ForeColor = &HFF&
If SpecSkill2 = "Blacksmithing" Then blacksmithing.ForeColor = &HFF&
If SpecSkill2 = "Hiding" Then hiding.ForeColor = &HFF&
If SpecSkill2 = "Magery" Then magery.ForeColor = &HFF&
If SpecSkill2 = "Lockpicking" Then lockpicking.ForeColor = &HFF&
If SpecSkill2 = "Pickpocket" Then pickpocket.ForeColor = &HFF&
If SpecSkill2 = "Stealth" Then stealth.ForeColor = &HFF&
If SpecSkill2 = "Poisoning" Then poisoning.ForeColor = &HFF&
If SpecSkill2 = "Swordmanship" Then swordmanship.ForeColor = &HFF&
If SpecSkill2 = "Parrying" Then parrying.ForeColor = &HFF&
If SpecSkill2 = "Animal Taming" Then AnimalTaming.ForeColor = &HFF&
If SpecSkill2 = "Religion Lore" Then religionlore.ForeColor = &HFF&
If SpecSkill2 = "Fishing" Then fishing.ForeColor = &HFF&
If SpecSkill2 = "Mining" Then mining.ForeColor = &HFF&
If SpecSkill2 = "Backstabbing" Then backstabbing.ForeColor = &HFF&
If SpecSkill2 = "Healing" Then healing.ForeColor = &HFF&
If SpecSkill2 = "Surviving" Then surviving.ForeColor = &HFF&
If SpecSkill2 = "Etiquette" Then etiquette.ForeColor = &HFF&
If SpecSkill2 = "Streetwise" Then streetwise.ForeColor = &HFF&
If SpecSkill2 = "Meditating" Then meditating.ForeColor = &HFF&
If SpecSkill2 = "Archery" Then archery.ForeColor = &HFF&

If SpecSkill3 = "Cooking" Then cooking.ForeColor = &HFF&
If SpecSkill3 = "Musicanship" Then musicanship.ForeColor = &HFF&
If SpecSkill3 = "Tailoring" Then tailoring.ForeColor = &HFF&
If SpecSkill3 = "Carpenting" Then carpenting.ForeColor = &HFF&
If SpecSkill3 = "Lumberjacking" Then lumberjacking.ForeColor = &HFF&
If SpecSkill3 = "Tactics" Then tactics.ForeColor = &HFF&
If SpecSkill3 = "Disguise" Then disguise.ForeColor = &HFF&
If SpecSkill3 = "Merchant" Then merchant.ForeColor = &HFF&
If SpecSkill3 = "Blacksmithing" Then blacksmithing.ForeColor = &HFF&
If SpecSkill3 = "Hiding" Then hiding.ForeColor = &HFF&
If SpecSkill3 = "Magery" Then magery.ForeColor = &HFF&
If SpecSkill3 = "Lockpicking" Then lockpicking.ForeColor = &HFF&
If SpecSkill3 = "Pickpocket" Then pickpocket.ForeColor = &HFF&
If SpecSkill3 = "Stealth" Then stealth.ForeColor = &HFF&
If SpecSkill3 = "Poisoning" Then poisoning.ForeColor = &HFF&
If SpecSkill3 = "Swordmanship" Then swordmanship.ForeColor = &HFF&
If SpecSkill3 = "Parrying" Then parrying.ForeColor = &HFF&
If SpecSkill3 = "Animal Taming" Then AnimalTaming.ForeColor = &HFF&
If SpecSkill3 = "Religion Lore" Then religionlore.ForeColor = &HFF&
If SpecSkill3 = "Fishing" Then fishing.ForeColor = &HFF&
If SpecSkill3 = "Mining" Then mining.ForeColor = &HFF&
If SpecSkill3 = "Backstabbing" Then backstabbing.ForeColor = &HFF&
If SpecSkill3 = "Healing" Then healing.ForeColor = &HFF&
If SpecSkill3 = "Surviving" Then surviving.ForeColor = &HFF&
If SpecSkill3 = "Etiquette" Then etiquette.ForeColor = &HFF&
If SpecSkill3 = "Streetwise" Then streetwise.ForeColor = &HFF&
If SpecSkill3 = "Meditating" Then meditating.ForeColor = &HFF&
If SpecSkill3 = "Archery" Then archery.ForeColor = &HFF&


End Sub

Private Sub healing_Click()



Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Healing") = False And healing > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If



If trainingpoints > 0 Then
healing = healing + 1
SendData "T23"
trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub hiding_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Hiding") = False And hiding > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
hiding = hiding + 1
SendData "T10"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub AnimalTaming_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Animal Taming") = False And AnimalTaming > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
AnimalTaming = AnimalTaming + 1
SendData "T18"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub Label7_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me

End Sub

Private Sub lockpicking_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Lockpicking") = False And lockpicking > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
lockpicking = lockpicking + 1
SendData "T12"
trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub lumberjacking_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Lumberjacking") = False And lumberjacking > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
lumberjacking = lumberjacking + 1
SendData "T05"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub magery_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
If trainingpoints > 0 Then


If SpecializedSkill("Magery") = False And magery > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


magery = magery + 1
SendData "T11"
trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub meditating_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Meditating") = False And meditating > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
meditating = meditating + 1
SendData "T27"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub merchant_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Merchant") = False And merchant > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
merchant = merchant + 1
SendData "T08"
trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub mining_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Mining") = False And mining > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
mining = mining + 1
SendData "T21"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub musicanship_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Musicanship") = False And musicanship > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
musicanship = musicanship + 1
SendData "T02"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub parrying_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Parrying") = False And parrying > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
parrying = parrying + 1
SendData "T17"

trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub pickpocket_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Pickpocket") = False And pickpocket > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
pickpocket = pickpocket + 1
SendData "T13"
trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub poisoning_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Poisoning") = False And poisoning > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
poisoning = poisoning + 1
SendData "T15"
trainingpoints = trainingpoints - 1
End If

End Sub

Private Sub religionlore_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Religion Lore") = False And religionlore > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
religionlore = religionlore + 1
SendData "T19"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub stealth_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Stealth") = False And stealth > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
stealth = stealth + 1
SendData "T14"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub streetwise_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Streetwise") = False And streetwise > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
streetwise = streetwise + 1
SendData "T26"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub surviving_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Surviving") = False And surviving > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
surviving = surviving + 1
SendData "T24"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub swordmanship_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Swordmanship") = False And swordmanship > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
swordmanship = swordmanship + 1
SendData "T16"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub tactics_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Tactics") = False And tactics > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If



If trainingpoints > 0 Then
tactics = tactics + 1
SendData "T06"
trainingpoints = trainingpoints - 1

End If

End Sub

Private Sub tailoring_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")


If SpecializedSkill("Tailoring") = False And tailoring > 48 Then
MsgBox "ONLY SPECIALIZED SKILLS MAY SURPASS 50 SKILL POINTS."
Exit Sub
End If


If trainingpoints > 0 Then
tailoring = tailoring + 1
SendData "T03"
trainingpoints = trainingpoints - 1

End If

End Sub

