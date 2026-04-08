VERSION 5.00
Begin VB.Form attributes 
   BorderStyle     =   0  'None
   ClientHeight    =   4800
   ClientLeft      =   3390
   ClientTop       =   1350
   ClientWidth     =   4890
   LinkTopic       =   "Form8"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4800
   ScaleWidth      =   4890
   ShowInTaskbar   =   0   'False
   Begin VB.Image Image4 
      Height          =   375
      Left            =   3480
      Picture         =   "attributes.frx":0000
      Stretch         =   -1  'True
      Top             =   1920
      Width           =   1095
   End
   Begin VB.Image Image3 
      Height          =   375
      Left            =   3480
      Picture         =   "attributes.frx":0441
      Stretch         =   -1  'True
      Top             =   1320
      Width           =   1095
   End
   Begin VB.Label gold 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   2760
      TabIndex        =   8
      Top             =   3720
      Width           =   1935
   End
   Begin VB.Image Image2 
      Height          =   615
      Left            =   0
      Picture         =   "attributes.frx":0854
      Stretch         =   -1  'True
      Top             =   3600
      Width           =   4935
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Close"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   120
      TabIndex        =   7
      Top             =   4320
      Width           =   4455
   End
   Begin VB.Image Image1 
      Height          =   615
      Index           =   6
      Left            =   0
      Picture         =   "attributes.frx":11D4
      Stretch         =   -1  'True
      Top             =   4200
      Width           =   4890
   End
   Begin VB.Label desc 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4815
      Left            =   5280
      TabIndex        =   6
      Top             =   1320
      Width           =   3495
   End
   Begin VB.Label practice 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   2760
      TabIndex        =   5
      Top             =   3120
      Width           =   1815
   End
   Begin VB.Label food 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   2760
      TabIndex        =   4
      Top             =   1320
      Width           =   2055
   End
   Begin VB.Label drink 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   2760
      TabIndex        =   3
      Top             =   1920
      Width           =   2055
   End
   Begin VB.Label fatigue 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   2760
      TabIndex        =   2
      Top             =   2520
      Width           =   2055
   End
   Begin VB.Label mana 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   375
      Left            =   2760
      TabIndex        =   1
      Top             =   720
      Width           =   1935
   End
   Begin VB.Label strenght 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   2760
      TabIndex        =   0
      Top             =   120
      Width           =   1935
   End
   Begin VB.Image Image1 
      Height          =   615
      Index           =   0
      Left            =   0
      Picture         =   "attributes.frx":19DC
      Stretch         =   -1  'True
      Top             =   0
      Width           =   4890
   End
   Begin VB.Image Image1 
      Height          =   615
      Index           =   1
      Left            =   0
      Picture         =   "attributes.frx":7266
      Stretch         =   -1  'True
      Top             =   600
      Width           =   4890
   End
   Begin VB.Image Image1 
      Height          =   615
      Index           =   2
      Left            =   0
      Picture         =   "attributes.frx":7AE4
      Stretch         =   -1  'True
      Top             =   1200
      Width           =   4890
   End
   Begin VB.Image Image1 
      Height          =   615
      Index           =   3
      Left            =   0
      Picture         =   "attributes.frx":83D9
      Stretch         =   -1  'True
      Top             =   2400
      Width           =   4890
   End
   Begin VB.Image Image1 
      Height          =   615
      Index           =   4
      Left            =   0
      Picture         =   "attributes.frx":8C5F
      Stretch         =   -1  'True
      Top             =   1800
      Width           =   4890
   End
   Begin VB.Image Image1 
      Height          =   615
      Index           =   5
      Left            =   0
      Picture         =   "attributes.frx":94D7
      Stretch         =   -1  'True
      Top             =   3000
      Width           =   4890
   End
End
Attribute VB_Name = "attributes"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub drink_Click()
desc = "Drink is how much water or any other energy drink you have on your character. When ever you are damaged and need to heal automaticly, you do need to have drink. Drink can be bought and found most places in Menath. "

End Sub

Private Sub fatigue_Click()
desc = "Fatigue is your characters stamina. Fighting uses fatigue and when you have no more fatigue you will have to rest to get more fatigue. Fatigue points is gained by leveling."

End Sub

Private Sub food_Click()
desc = "Food is how much edible things you have on your character. If you are damaged and needs to be healed automaticly, you will need to have food. Food can be found by killing animals or eating plants found in the wilderness or buying it in many of Menath`s shops."

End Sub

Private Sub Form_Load()

gold = UserGLD
food = UserFood
drink = UserDrink
strenght = UserMaxHP
mana = UserMaxMAN
fatigue = UserMaxSTA
practice = UserPracticePoints


End Sub

Private Sub Image3_Click()
If food > 0 Then
food = food - 1
SendData "EAT"
End If

End Sub

Private Sub Image3_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Press here to eat food and heal"
End Sub

Private Sub Image4_Click()
If drink > 0 Then
drink = drink - 1
SendData "DRK"
End If
End Sub

Private Sub Image4_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Press here to drink it and heal fatigue"
End Sub

Private Sub Label2_Click()
desc = "Strenght is your characters health. The high strenght you have, the more hits you may take and more tolerant your character becomes to things. Also, certain items and weapons may only be wore by people over a certain strenght. Strenght is gained by fighting."
End Sub

Private Sub Label3_Click()
desc = "Mana or as many call it Magicka, is the power your character can put in spells. Spells requier a certain number of mana, and the big spells usually requier more mana that you can imagine. Mana is gained by leveling."
End Sub

Private Sub Label4_Click()
desc = "Fatigue is your characters stamina. Fighting uses fatigue and when you have no more fatigue you will have to rest to get more fatigue. Fatigue points is gained by leveling."

End Sub

Private Sub Label5_Click()
desc = "Drink is how much water or any other energy drink you have on your character. When ever you are damaged and need to heal automaticly, you do need to have drink. Drink can be bought and found most places in Menath. "
End Sub

Private Sub Label6_Click()
desc = "Food is how much edible things you have on your character. If you are damaged and needs to be healed automaticly, you will need to have food. Food can be found by killing animals or eating plants found in the wilderness or buying it in many of Menath`s shops."

End Sub

Private Sub Label7_Click()
desc = "Practice points is how many times you can train at a NPC trainer. When you train, and click on a skill, the practice points goes down. This makes it just as easy for players without much gold to get better at skills as the ones that has much gold. Cause you cannot buy training points. Training points are gained by leveling."
End Sub

Private Sub Label8_Click()
Unload Me
End Sub

Private Sub Label1_Click()
Unload Me
End Sub

Private Sub Label1_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Close"
End Sub

Private Sub Label2_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Strenght/Hp"

End Sub

Private Sub Label3_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Mana/Magicka"
End Sub

Private Sub Label4_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Food"
End Sub

Private Sub Label5_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Drink"
End Sub

Private Sub Label6_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Fatigue"
End Sub

Private Sub Label7_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Training Points"
End Sub

Private Sub Label8_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Label1 = "Gold"
End Sub

Private Sub mana_Click()
desc = "Mana or as many call it Magicka, is the power your character can put in spells. Spells requier a certain number of mana, and the big spells usually requier more mana that you can imagine. Mana is gained by leveling."

End Sub

Private Sub practice_Click()
desc = "Practice points is how many times you can train at a NPC trainer. When you train, and click on a skill, the practice points goes down. This makes it just as easy for players without much gold to get better at skills as the ones that has much gold. Cause you cannot buy training points. Training points are gained by leveling."

End Sub

Private Sub strenght_Click()
desc = "Strenght is your characters health. The high strenght you have, the more hits you may take and more tolerant your character becomes to things. Also, certain items and weapons may only be wore by people over a certain strenght. Strenght is gained by fighting."
End Sub
