VERSION 5.00
Begin VB.Form skills 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   7440
   ClientLeft      =   1380
   ClientTop       =   690
   ClientWidth     =   9525
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   LinkTopic       =   "Form9"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7440
   ScaleWidth      =   9525
   ShowInTaskbar   =   0   'False
   Begin VB.Image Image3 
      Height          =   240
      Left            =   840
      Picture         =   "skills.frx":0000
      Tag             =   "0"
      Top             =   3000
      Width           =   180
   End
   Begin VB.Image Image2 
      Height          =   240
      Left            =   840
      Picture         =   "skills.frx":0282
      Tag             =   "0"
      Top             =   4080
      Width           =   180
   End
   Begin VB.Image Image1 
      Height          =   240
      Left            =   840
      Picture         =   "skills.frx":0504
      Tag             =   "0"
      Top             =   5160
      Width           =   180
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Archery:"
      Height          =   255
      Left            =   3000
      TabIndex        =   58
      Top             =   4680
      Width           =   975
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Caption         =   "Meditating:"
      Height          =   255
      Left            =   3000
      TabIndex        =   57
      Top             =   4320
      Width           =   975
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   "Streetwise:"
      Height          =   255
      Left            =   3000
      TabIndex        =   56
      Top             =   3960
      Width           =   855
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Cooking:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   25
      Left            =   1080
      TabIndex        =   55
      Top             =   720
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Disguise:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   1
      Left            =   1080
      TabIndex        =   54
      Top             =   3000
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Surviving:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   2
      Left            =   3000
      TabIndex        =   53
      Top             =   3240
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Mining:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   3
      Left            =   3000
      TabIndex        =   52
      Top             =   2160
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Musicanship:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   4
      Left            =   1080
      TabIndex        =   51
      Top             =   1080
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Mechant:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   5
      Left            =   1080
      TabIndex        =   50
      Top             =   3360
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Animal Taming:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   6
      Left            =   3000
      TabIndex        =   49
      Top             =   1080
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Fishing:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   7
      Left            =   3000
      TabIndex        =   48
      Top             =   1800
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Tailoring:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   8
      Left            =   1080
      TabIndex        =   47
      Top             =   1560
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "BlackSmithing:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   9
      Left            =   1080
      TabIndex        =   46
      Top             =   3720
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Poisoning:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   10
      Left            =   1080
      TabIndex        =   45
      Top             =   5880
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Lumberjacking:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   11
      Left            =   1080
      TabIndex        =   44
      Top             =   2280
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Carpetning:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   12
      Left            =   1080
      TabIndex        =   43
      Top             =   1920
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Hiding:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   13
      Left            =   1080
      TabIndex        =   42
      Top             =   4080
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Stealth:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   14
      Left            =   1080
      TabIndex        =   41
      Top             =   5520
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Swordmanship:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   15
      Left            =   1080
      TabIndex        =   40
      Top             =   6240
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Tactics:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   16
      Left            =   1080
      TabIndex        =   39
      Top             =   2640
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Parrying:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   17
      Left            =   3000
      TabIndex        =   38
      Top             =   720
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Healing:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   18
      Left            =   3000
      TabIndex        =   37
      Top             =   2880
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Magery:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   19
      Left            =   1080
      TabIndex        =   36
      Top             =   4440
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Religion Lore:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   20
      Left            =   3000
      TabIndex        =   35
      Top             =   1440
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Etiquette:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   21
      Left            =   3000
      TabIndex        =   34
      Top             =   3600
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Backstabbing:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   22
      Left            =   3000
      TabIndex        =   33
      Top             =   2520
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Lockpicking:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   23
      Left            =   1080
      TabIndex        =   32
      Top             =   4800
      Width           =   1335
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Pickpocket:"
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   24
      Left            =   1080
      TabIndex        =   31
      Top             =   5160
      Width           =   1335
   End
   Begin VB.Label archery 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   30
      Top             =   4680
      Width           =   855
   End
   Begin VB.Label meditating 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   29
      Top             =   4320
      Width           =   735
   End
   Begin VB.Label streetwise 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   28
      Top             =   3960
      Width           =   735
   End
   Begin VB.Label etiquette 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   27
      Top             =   3600
      Width           =   1335
   End
   Begin VB.Label surviving 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   26
      Top             =   3240
      Width           =   735
   End
   Begin VB.Label healing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   25
      Top             =   2880
      Width           =   735
   End
   Begin VB.Label backstabbing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   24
      Top             =   2520
      Width           =   615
   End
   Begin VB.Label mining 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   23
      Top             =   2160
      Width           =   615
   End
   Begin VB.Label fishing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   22
      Top             =   1800
      Width           =   615
   End
   Begin VB.Label religionlore 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   21
      Top             =   1440
      Width           =   615
   End
   Begin VB.Label AnimalTaming 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   20
      Top             =   1080
      Width           =   495
   End
   Begin VB.Label parrying 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   4080
      TabIndex        =   19
      Top             =   720
      Width           =   855
   End
   Begin VB.Label swordmanship 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   18
      Top             =   6240
      Width           =   1095
   End
   Begin VB.Label poisoning 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   17
      Top             =   5880
      Width           =   735
   End
   Begin VB.Label stealth 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   16
      Top             =   5520
      Width           =   735
   End
   Begin VB.Label pickpocket 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   15
      Top             =   5160
      Width           =   735
   End
   Begin VB.Label lockpicking 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   14
      Top             =   4800
      Width           =   735
   End
   Begin VB.Label magery 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   13
      Top             =   4440
      Width           =   735
   End
   Begin VB.Label hiding 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   12
      Top             =   4080
      Width           =   735
   End
   Begin VB.Label blacksmithing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   11
      Top             =   3720
      Width           =   735
   End
   Begin VB.Label merchant 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   10
      Top             =   3360
      Width           =   735
   End
   Begin VB.Label disguise 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   9
      Top             =   3000
      Width           =   735
   End
   Begin VB.Label tactics 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      ForeColor       =   &H00000000&
      Height          =   255
      Left            =   2160
      TabIndex        =   8
      Top             =   2640
      Width           =   735
   End
   Begin VB.Label lumberjacking 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   7
      Top             =   2280
      Width           =   735
   End
   Begin VB.Label carpenting 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   6
      Top             =   1920
      Width           =   735
   End
   Begin VB.Label tailoring 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   5
      Top             =   1560
      Width           =   615
   End
   Begin VB.Label musicanship 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   4
      Top             =   1080
      Width           =   615
   End
   Begin VB.Label cooking 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   255
      Left            =   2160
      TabIndex        =   3
      Top             =   720
      Width           =   735
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Close"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   8040
      TabIndex        =   2
      Top             =   6600
      Width           =   735
   End
   Begin VB.Label skillname 
      BackStyle       =   0  'Transparent
      Caption         =   "Skills"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   15.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   735
      Left            =   5400
      TabIndex        =   1
      Top             =   720
      Width           =   3375
   End
   Begin VB.Label skilldesc 
      BackStyle       =   0  'Transparent
      Caption         =   $"skills.frx":0786
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4455
      Left            =   5280
      TabIndex        =   0
      Top             =   1680
      Width           =   3375
   End
End
Attribute VB_Name = "skills"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
skills.Picture = LoadPicture(IniPath & "Grh\book.jpg")

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

Private Sub Image1_Click()
On Error Resume Next

If AllowClick = 0 Then
AddtoRichTextBox frmMain.RecTxt, "Spam detected. Wait.", 0, 255, 0, 0, 0
Exit Sub
End If

If UserPickPocketing = 0 Then
SendData "PI1"
UserPickPocketing = 1
Else
Image1.Picture = LoadPicture(IniPath & "Grh\diamond.bmp")
UserPickPocketing = 0
SendData "PI2"
End If

End Sub

Private Sub Image2_Click()
On Error Resume Next

If AllowClick = 0 Then
AddtoRichTextBox frmMain.RecTxt, "Spam detected. Wait.", 0, 255, 0, 0, 0
Exit Sub
End If

If UserHiding = 0 Then
UserHiding = 1
SendData "HHH"
Else
Image2.Picture = LoadPicture(IniPath & "Grh\diamond.bmp")
SendData "UHD"
UserHiding = 0
End If

End Sub

Private Sub Image3_Click()
On Error Resume Next

If AllowClick = 0 Then
AddtoRichTextBox frmMain.RecTxt, "Spam detected. Wait.", 0, 255, 0, 0, 0
Exit Sub
End If

If UserDisguising = 0 Then
UserDisguising = 1
SendData "DGU"
Else
Image3.Picture = LoadPicture(IniPath & "Grh\diamond.bmp")
UserDisguising = 0
SendData "UGU"
End If

End Sub

Private Sub Label3_Click()
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me

End Sub

