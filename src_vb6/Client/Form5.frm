VERSION 5.00
Begin VB.Form Form5 
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
   Begin VB.CommandButton Command2 
      Caption         =   "Back"
      Height          =   255
      Left            =   7920
      TabIndex        =   15
      Top             =   5640
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Continue"
      Height          =   255
      Left            =   9120
      TabIndex        =   14
      Top             =   5640
      Width           =   1095
   End
   Begin VB.ComboBox darkelfclass 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "Form5.frx":0000
      Left            =   3600
      List            =   "Form5.frx":0028
      Style           =   2  'Dropdown List
      TabIndex        =   13
      Top             =   3720
      Visible         =   0   'False
      Width           =   4215
   End
   Begin VB.ComboBox haakiclass 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "Form5.frx":0097
      Left            =   3600
      List            =   "Form5.frx":00C2
      Style           =   2  'Dropdown List
      TabIndex        =   12
      Top             =   3720
      Visible         =   0   'False
      Width           =   4215
   End
   Begin VB.ComboBox woodelfclass 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "Form5.frx":0134
      Left            =   3600
      List            =   "Form5.frx":016B
      Style           =   2  'Dropdown List
      TabIndex        =   11
      Top             =   3720
      Visible         =   0   'False
      Width           =   4215
   End
   Begin VB.ComboBox skill3 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "Form5.frx":0205
      Left            =   3600
      List            =   "Form5.frx":025D
      Style           =   2  'Dropdown List
      TabIndex        =   6
      Top             =   4920
      Width           =   4215
   End
   Begin VB.ComboBox skill2 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "Form5.frx":039B
      Left            =   3600
      List            =   "Form5.frx":03F3
      Style           =   2  'Dropdown List
      TabIndex        =   5
      Top             =   4560
      Width           =   4215
   End
   Begin VB.ComboBox skill1 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "Form5.frx":0531
      Left            =   3600
      List            =   "Form5.frx":0589
      Style           =   2  'Dropdown List
      TabIndex        =   4
      Top             =   4200
      Width           =   4215
   End
   Begin VB.ComboBox humanclass 
      BackColor       =   &H00808080&
      ForeColor       =   &H80000009&
      Height          =   315
      ItemData        =   "Form5.frx":06C7
      Left            =   3600
      List            =   "Form5.frx":0704
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   3720
      Visible         =   0   'False
      Width           =   4215
   End
   Begin VB.Label Label9 
      BackStyle       =   0  'Transparent
      ForeColor       =   &H8000000E&
      Height          =   735
      Left            =   1680
      TabIndex        =   10
      Top             =   5400
      Width           =   6135
   End
   Begin VB.Label Label8 
      BackStyle       =   0  'Transparent
      Caption         =   "Specialized Skill 3:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2160
      TabIndex        =   9
      Top             =   4920
      Width           =   1455
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "Specialized Skill 2:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2160
      TabIndex        =   8
      Top             =   4560
      Width           =   1455
   End
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Specialized Skill 1:"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2160
      TabIndex        =   7
      Top             =   4200
      Width           =   1455
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      ForeColor       =   &H8000000E&
      Height          =   735
      Left            =   1680
      TabIndex        =   3
      Top             =   4800
      Width           =   8655
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "-Character Creation"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   15.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   1680
      TabIndex        =   1
      Top             =   2520
      Width           =   4095
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   $"Form5.frx":07AE
      ForeColor       =   &H8000000E&
      Height          =   1095
      Left            =   1680
      TabIndex        =   0
      Top             =   3000
      Width           =   8295
   End
   Begin VB.Image Image1 
      Height          =   9120
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   12120
   End
End
Attribute VB_Name = "Form5"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Combo1_Change()


On Error Resume Next


If Combo1.Text = "Warrior" Then Label3 = "Warriors specialize in the art of battle. They are fighters by proffession and always carry their sword and lance ready to fight for gold and for glory."

If Combo1.Text = "Druid" Then
Label3 = "Druids dedicate their life to the study of magic of the nature. These are general do gooders and only uses destructive magic when provoked."
Label9 = "Druids are a member of the nature school of magic."
End If

If Combo1.Text = "Healer" Then
Label3 = "Healers are mainly against fighting and know how to make a nice pile of gold by healing less successful adventurers coming from home from advenures. Healers can also be very valuable in fights, where they can heal their friends while they fight."
Label9 = "Healers are a member of the nature school of magic."
End If

If Combo1.Text = "Cleric" Then
Label3 = "Clerics are also against fighting and are very much alike the healers in any ways. But clerics also has a very high religion lore and can easily communicate with the gods."
Label9 = "Clerics are a member of the nature school of magic."
End If

If Combo1.Text = "Thief" Then Label3 = "Thieves dedicate their life to the roaming the streets and pickpocket any person they think may carry a nice gold pile. Thieves also are fully capable of breaking into houses and rip it from its foundations while not weaking up a soul."
If Combo1.Text = "Paladin" Then
Label3 = "Knights are the noble fighters. Their good manners and figthing skills are a good mix. They are often hired by royals for important quests, like saving the princess from a dragon !"
Label9 = "Paladins are a member of the enchanting school of magic."
End If

If Combo1.Text = "Bandit" Then Label3 = "Bandits are the pirates on land. They often attacks people on the roads and take everything they got and dissapear. Bandits are very hatred troughout Menath."
If Combo1.Text = "Woodworker" Then Label3 = "This is the classic lumberjacker and carpenter professions in one. They cut woods and make nice wooden items of it like furniture and so on. "
If Combo1.Text = "BlackSmith" Then Label3 = "Blacksmiths process ore and make nice weapons out of it. Quite simple. Quite profitable."
If Combo1.Text = "Tailor" Then Label3 = "Tailors take hides, clothes or fur and make nice clothing out of it to nobles or peasants or whoever. Very amusing profession and quite profitable."
If Combo1.Text = "Fisher" Then Label3 = "Fishers do exactly what your thinking. They fish and sell their fish. This can be very valueable for adventurers wich need food fast."
If Combo1.Text = "Animal Taming" Then Label3 = "Animal Tamers dedicate their life to the wildlife. As an animal tamer you are specialized in taming animals of all kinds !"
If Combo1.Text = "Merchant" Then Label3 = "Merchants can be very charming and dangerous in the way that they can fool you to buy anything from them. They often travel all over the land to sell and buy their goods."
If Combo1.Text = "Bard" Then Label3 = "The musicians and entertainers of Menath. These people can play any instrument and make any dark place bright happy. They often earn quite a nice sum of gold on their plays. They travel all over the world !"
If Combo1.Text = "Miner" Then Label3 = "Miners spend most of their lives in the mountains mining out ore to sell to the blacksmiths."
If Combo1.Text = "Pirate" Then Label3 = "Pirates are also sailors but they use their sailing skills for the evil. They sail the seas and plunder and lives a drunk mans life. They bury down treasures on islands and often plunders harbors."
If Combo1.Text = "Cook" Then Label3 = "Hard to live without cooks. With a little food resources they can cook any kind of food ready to be served for themselves or maybe to the royal family ?"
If Combo1.Text = "Assasin" Then Label3 = "Assasin is very much alike the merchants only that their commodity is death. A assasin can have quite a long and lucrative career."

If Combo1.Text = "Enchanter" Then
Label3 = "Enchanters uses magic like summonings and creating items. They focus on materialized magic instead of spiritual magic."
Label9 = "Enchanters are a member of the enchanting school of magic."
End If

If Combo1.Text = "Wizard" Then
Label3 = "Wizards focus sorely on hate and destruction magic. They can be a horrible foe when all comes to all."
Label9 = "Wizards are a member of the destruction school of magic."
End If


End Sub

Private Sub Command1_Click()


Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")

If CreateRace = "Human" Then CreateClass = humanclass.Text
If CreateRace = "Haaki" Then CreateClass = haakiclass.Text
If CreateRace = "Wood Elf" Then CreateClass = woodelfclass.Text
If CreateRace = "Dark Elf" Then CreateClass = darkelfclass.Text

CreateSpecSkill1 = skill1
CreateSpecSkill2 = skill2
CreateSpecSkill3 = skill3



Form4.Show
Unload Me

End Sub

Private Sub Command2_Click()
On Error Resume Next

Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Form3.Show
Unload Me
End Sub

Private Sub Form_Load()

On Error Resume Next

If CreateRace = "Human" Then humanclass.Visible = True
If CreateRace = "Dark Elf" Then darkelfclass.Visible = True
If CreateRace = "Haaki" Then haakiclass.Visible = True
If CreateRace = "Wood Elf" Then woodelfclass.Visible = True

Image1.Picture = LoadPicture(IniPath & "Grh\menu2.jpg")
End Sub

Private Sub Label4_Click()


End Sub

Private Sub Label5_Click()


End Sub

