VERSION 5.00
Begin VB.Form Form7 
   BackColor       =   &H00004080&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   3195
   ClientLeft      =   3645
   ClientTop       =   1815
   ClientWidth     =   4680
   ControlBox      =   0   'False
   LinkTopic       =   "Form7"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   Begin VB.Image Slot30 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   2760
      Top             =   2040
      Width           =   495
   End
   Begin VB.Image Slot29 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   2280
      Top             =   2040
      Width           =   495
   End
   Begin VB.Image Slot28 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   1800
      Top             =   2040
      Width           =   495
   End
   Begin VB.Image Slot27 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   1320
      Top             =   2040
      Width           =   495
   End
   Begin VB.Image Slot26 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   840
      Top             =   2040
      Width           =   495
   End
   Begin VB.Image Slot25 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   360
      Top             =   2040
      Width           =   495
   End
   Begin VB.Image Slot24 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   3720
      Top             =   1560
      Width           =   495
   End
   Begin VB.Image Slot23 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   3240
      Top             =   1560
      Width           =   495
   End
   Begin VB.Image Slot22 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   2760
      Top             =   1560
      Width           =   495
   End
   Begin VB.Image Slot21 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   2280
      Top             =   1560
      Width           =   495
   End
   Begin VB.Image Slot20 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   1800
      Top             =   1560
      Width           =   495
   End
   Begin VB.Image Slot19 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   1320
      Top             =   1560
      Width           =   495
   End
   Begin VB.Image Slot18 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   840
      Top             =   1560
      Width           =   495
   End
   Begin VB.Image Slot17 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   360
      Top             =   1560
      Width           =   495
   End
   Begin VB.Image Slot16 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   3720
      Top             =   1080
      Width           =   495
   End
   Begin VB.Image Slot15 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   3240
      Top             =   1080
      Width           =   495
   End
   Begin VB.Image Slot14 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   2760
      Top             =   1080
      Width           =   495
   End
   Begin VB.Image Slot13 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   2280
      Top             =   1080
      Width           =   495
   End
   Begin VB.Image Slot12 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   1800
      Top             =   1080
      Width           =   495
   End
   Begin VB.Image Slot11 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   1320
      Top             =   1080
      Width           =   495
   End
   Begin VB.Image Slot10 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   840
      Top             =   1080
      Width           =   495
   End
   Begin VB.Image Slot9 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   360
      Top             =   1080
      Width           =   495
   End
   Begin VB.Image Slot8 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   3720
      Top             =   600
      Width           =   495
   End
   Begin VB.Image Slot7 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   3240
      Top             =   600
      Width           =   495
   End
   Begin VB.Image Slot6 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   2760
      Top             =   600
      Width           =   495
   End
   Begin VB.Image Slot5 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   2280
      Top             =   600
      Width           =   495
   End
   Begin VB.Image Slot4 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   1800
      Top             =   600
      Width           =   495
   End
   Begin VB.Image Slot3 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   1320
      Top             =   600
      Width           =   495
   End
   Begin VB.Image Slot2 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   840
      Top             =   600
      Width           =   495
   End
   Begin VB.Image Slot1 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   360
      Top             =   600
      Width           =   495
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "Close"
      ForeColor       =   &H80000007&
      Height          =   255
      Left            =   4080
      TabIndex        =   1
      Top             =   2880
      Width           =   495
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Inventory"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   -1  'True
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   2655
   End
   Begin VB.Image Image1 
      Height          =   3255
      Left            =   -480
      Picture         =   "Form8.frx":0000
      Stretch         =   -1  'True
      Top             =   0
      Width           =   5175
   End
End
Attribute VB_Name = "Form7"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
    Form7.Slot1.Tag = UserSlot1
    Form7.Slot2.Tag = UserSlot2
    Form7.Slot3.Tag = UserSlot3
    Form7.Slot4.Tag = UserSlot4
    Form7.Slot5.Tag = Userslot5
    Form7.Slot6.Tag = UserSlot6
    Form7.Slot7.Tag = UserSlot7
    Form7.Slot8.Tag = UserSlot8
    Form7.Slot9.Tag = UserSlot9
    Form7.Slot10.Tag = UserSlot10
    Form7.Slot11.Tag = UserSlot11
    Form7.Slot12.Tag = UserSlot12
    Form7.Slot13.Tag = UserSlot13
    Form7.Slot14.Tag = UserSlot14
    Form7.Slot15.Tag = UserSlot15
    Form7.Slot16.Tag = UserSlot16
    Form7.Slot17.Tag = UserSlot17
    Form7.Slot18.Tag = UserSlot18
    Form7.Slot19.Tag = UserSlot18
    Form7.Slot20.Tag = UserSlot20
    Form7.Slot21.Tag = UserSlot22
    Form7.Slot22.Tag = UserSlot21
    Form7.Slot23.Tag = UserSlot23
    Form7.Slot24.Tag = UserSlot24
    Form7.Slot25.Tag = UserSlot25
    Form7.Slot26.Tag = UserSlot26
    Form7.Slot27.Tag = UserSlot27
    Form7.Slot28.Tag = UserSlot28
    Form7.Slot29.Tag = UserSlot29
    Form7.Slot30.Tag = UserSlot30
    
    
    
End Sub

Private Sub Label2_Click()
Unload Form7
End Sub
