VERSION 5.00
Begin VB.Form frmCreation_Part2 
   BackColor       =   &H80000008&
   BorderStyle     =   0  'None
   ClientHeight    =   9000
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12000
   ControlBox      =   0   'False
   LinkTopic       =   "Form5"
   ScaleHeight     =   9000
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.CommandButton cmd_Continue 
      Caption         =   "Continue ->"
      Default         =   -1  'True
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   9150
      TabIndex        =   5
      Top             =   5970
      Width           =   1395
   End
   Begin VB.CommandButton cmd_Back 
      Caption         =   "<- Back"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   7710
      TabIndex        =   4
      Top             =   5970
      Width           =   1395
   End
   Begin VB.ComboBox cmbClass 
      BackColor       =   &H00808080&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "frmCreation_Part2.frx":0000
      Left            =   4560
      List            =   "frmCreation_Part2.frx":0002
      Sorted          =   -1  'True
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   3780
      Width           =   4215
   End
   Begin VB.ComboBox cmbSkill3 
      BackColor       =   &H00808080&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "frmCreation_Part2.frx":0004
      Left            =   4560
      List            =   "frmCreation_Part2.frx":005C
      Style           =   2  'Dropdown List
      TabIndex        =   3
      Top             =   4920
      Width           =   4215
   End
   Begin VB.ComboBox cmbSkill2 
      BackColor       =   &H00808080&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "frmCreation_Part2.frx":019A
      Left            =   4560
      List            =   "frmCreation_Part2.frx":01F2
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   4560
      Width           =   4215
   End
   Begin VB.ComboBox cmbSkill1 
      BackColor       =   &H00808080&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "frmCreation_Part2.frx":0330
      Left            =   4560
      List            =   "frmCreation_Part2.frx":0388
      Style           =   2  'Dropdown List
      TabIndex        =   1
      Top             =   4200
      Width           =   4215
   End
   Begin VB.Label Label8 
      BackStyle       =   0  'Transparent
      Caption         =   "Specialized Skill 3:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2580
      TabIndex        =   11
      Top             =   4950
      Width           =   1995
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "Specialized Skill 2:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2580
      TabIndex        =   10
      Top             =   4590
      Width           =   1995
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Specialized Skill 1:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2580
      TabIndex        =   9
      Top             =   4230
      Width           =   1995
   End
   Begin VB.Label lblDescription 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   645
      Left            =   1680
      TabIndex        =   8
      Top             =   5370
      Width           =   8655
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Character Creation"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   14.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   1680
      TabIndex        =   7
      Top             =   2460
      Width           =   4095
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"frmCreation_Part2.frx":04C6
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   1095
      Left            =   1710
      TabIndex        =   6
      Top             =   2790
      Width           =   8685
   End
   Begin VB.Image Image1 
      Height          =   9120
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   12120
   End
End
Attribute VB_Name = "frmCreation_Part2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmbClass_click()
'On Error Resume Next

Select Case Me.cmbClass.Text
    Case "Warrior"
        Me.lblDescription.Caption = "Warriors specialize in the art of battle. They are fighters by profession and always carry their sword ready to fight for gold and glory."
    Case "Druid"
        Me.lblDescription.Caption = "Druids dedicate their life to the study of the magic of nature. They are generally good at heart and only use destructive magic when absolutely necessary."
    Case "Healer"
        Me.lblDescription.Caption = "Healers are mainly against fighting and know how to make a nice pile of gold by healing less fortunate adventurers. Healers can also be very valuable in fights, where they can stand back and heal their companions."
    Case "Cleric"
        Me.lblDescription.Caption = "Clerics are also against fighting and are very much alike the healers in any ways. But clerics also have very high religion lore and some say they can easily communicate with the gods."
    Case "Thief"
        Me.lblDescription.Caption = "Thieves dedicate their life to roaming the alleys and lifting items and gold from unsuspecting people. Some say a good thief could steal the bed from under a sleeping man. A quick thief is always a welcome addition to an adventuresome party."
    Case "Paladin"
        Me.lblDescription.Caption = "Knights are the noble warriors. Their chivalry and deadly fighting skills are a good mix. Nobles often hire Knights for important quests and missions."
    Case "Bandit"
        Me.lblDescription.Caption = "Bandits are the pirates on land. They often attack travelers, take everything, and quickly disappear. Bandits are feared throughout Menath."
    Case "Woodworker"
        Me.lblDescription.Caption = "This is the classic lumberjack and carpenter profession in one. They cut wood and fashion furniture and such from it."
    Case "Blacksmith"
        Me.lblDescription.Caption = "Blacksmiths process ore and make nice weapons out of it. Quite simple. Quite profitable."
    Case "Tailor"
        Me.lblDescription.Caption = "Tailors take hides, cloth or fur and make clothing out of it for all of Menath. It's a very popular profession and quite profitable."
    Case "Fisher"
        Me.lblDescription.Caption = "Fishermen do exactly as the name implies. They catch and sell fish. This can be quite valuable for adventurers who need food fast."
    Case "Animal Tamer"
        Me.lblDescription.Caption = "Animal Tamers dedicate their life to the wildlife. As an animal tamer you are specialized in taming animals of all sorts."
    Case "Merchant"
        Me.lblDescription.Caption = "Merchants can be very charming and dangerous in the way that they can fool you to buy anything from them. They often travel all over the land to sell and buy their goods."
    Case "Bard"
        Me.lblDescription.Caption = "The Bards of Menath can play any instrument and make any dark place bright and happy. They often earn quite a nice sum of gold during their travels around the world."
    Case "Miner"
        Me.lblDescription.Caption = "Miners spend most of their lives in the mountains mining ore to sell to the blacksmiths."
    Case "Pirate"
        Me.lblDescription.Caption = "Pirates are sailors but they use their sailing skills for themselves. They sail the seas as bandits-- stealing, killing, and drinking!"
    Case "Cook"
        Me.lblDescription.Caption = "It's hard to live without cooks. With a few resources, they can create a meal fit for a king!"
    Case "Assasin"
        Me.lblDescription.Caption = "Assassins are dealers in death. For the right price you can destroy an enemy, or be destroyed yourself."
    Case "Enchanter"
        Me.lblDescription.Caption = "Enchanters use magic to summon creatures and create items. They focus on material magic rather than spiritual magic."
    Case "Wizard"
        Me.lblDescription.Caption = "Wizards focus primarily on offensive magic. They can be a tough foe on the battlefield."
    Case Else
        Me.lblDescription.Caption = "There is no description for this class."
End Select
End Sub

Private Sub cmd_Continue_Click()
Call ButtonClick

If Me.cmbClass.Text = "" Then
    MsgBox "You must pick a class!"
ElseIf Me.cmbSkill1.Text = "" Then
    MsgBox "You must pick 3 skills!"
    Me.cmbSkill1.SetFocus
ElseIf Me.cmbSkill2.Text = "" Then
    MsgBox "You must pick 3 skills!"
    Me.cmbSkill2.SetFocus
ElseIf Me.cmbSkill3.Text = "" Then
    MsgBox "You must pick 3 skills!"
    Me.cmbSkill3.SetFocus
ElseIf Me.cmbSkill2.Text = Me.cmbSkill1.Text Then
    MsgBox "You can't pick the same skill twice!"
    Me.cmbSkill2.SetFocus
ElseIf Me.cmbSkill3 = Me.cmbSkill1.Text Or Me.cmbSkill3.Text = Me.cmbSkill2.Text Then
    MsgBox "You can't pick the same skill twice!"
    Me.cmbSkill3.SetFocus
Else
    CreateClass = Me.cmbClass.Text
    CreateSpecSkill1 = Me.cmbSkill1.Text
    CreateSpecSkill2 = Me.cmbSkill2.Text
    CreateSpecSkill3 = Me.cmbSkill3.Text

    frmCreation_Part3.Show
    Unload Me
End If
End Sub

Private Sub cmd_Back_Click()
On Error Resume Next

Call ButtonClick
frmCreation_Part1.Show
Unload Me
End Sub

Private Sub Form_Load()
On Error Resume Next

'4 combos is too much and is way too much confusing
'let's use 1 combo named 'cmbClass' and just fill it on load =)
'PL 11/20/2000
Select Case CreateRace
    Case "Human"
        With Me.cmbClass
            .AddItem "Warrior"
            .AddItem "Healer"
            .AddItem "Thief"
            .AddItem "Paladin"
            .AddItem "Bandit"
            .AddItem "Woodworker"
            .AddItem "Blacksmith"
            .AddItem "Tailor"
            .AddItem "Fisher"
            .AddItem "Animal Tamer"
            .AddItem "Merchant"
            .AddItem "Bard"
            .AddItem "Pirate"
            .AddItem "Cook"
            .AddItem "Cleric"
            .AddItem "Wizard"
            .AddItem "Druid"
            .AddItem "Enchanter"
            .AddItem "Miner"
        End With
    Case "Haaki"
        With Me.cmbClass
            .AddItem "Warrior"
            .AddItem "Thief"
            .AddItem "Bandit"
            .AddItem "Blacksmith"
            .AddItem "Tailor"
            .AddItem "Animal Tamer"
            .AddItem "Merchant"
            .AddItem "Bard"
            .AddItem "Cook"
            .AddItem "Cleric"
            .AddItem "Wizard"
            .AddItem "Druid"
            .AddItem "Miner"
        End With
    Case "Wood Elf"
        With Me.cmbClass
            .AddItem "Warrior"
            .AddItem "Healer"
            .AddItem "Thief"
            .AddItem "Paladin"
            .AddItem "Bandit"
            .AddItem "Woodworker"
            .AddItem "Blacksmith"
            .AddItem "Tailor"
            .AddItem "Fisher"
            .AddItem "Animal Tamer"
            .AddItem "Merchant"
            .AddItem "Bard"
            .AddItem "Cook"
            .AddItem "Cleric"
            .AddItem "Druid"
            .AddItem "Enchanter"
            .AddItem "Miner"
        End With
    Case "Dark Elf"
        With Me.cmbClass
            .AddItem "Warrior"
            .AddItem "Thief"
            .AddItem "Paladin"
            .AddItem "Bandit"
            .AddItem "Woodworker"
            .AddItem "Blacksmith"
            .AddItem "Tailer"
            .AddItem "Merchant"
            .AddItem "Cook"
            .AddItem "Wizard"
            .AddItem "Enchanter"
            .AddItem "Miner"
            .AddItem "Assasin"
        End With
End Select

If CreateClass <> "" Then Me.cmbClass.Text = CreateClass
If CreateSpecSkill1 <> "" Then Me.cmbSkill1.Text = CreateSpecSkill1
If CreateSpecSkill2 <> "" Then Me.cmbSkill2.Text = CreateSpecSkill2
If CreateSpecSkill3 <> "" Then Me.cmbSkill3.Text = CreateSpecSkill3
Me.Image1.Picture = LoadPicture(IniPath & "Grh\menu2.jpg")
End Sub
