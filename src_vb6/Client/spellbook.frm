VERSION 5.00
Begin VB.Form spellbook 
   BackColor       =   &H80000008&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   7320
   ClientLeft      =   1140
   ClientTop       =   690
   ClientWidth     =   9525
   ControlBox      =   0   'False
   LinkTopic       =   "Form9"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7320
   ScaleWidth      =   9525
   ShowInTaskbar   =   0   'False
   Begin VB.ListBox SpellLst 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   5160
      ItemData        =   "spellbook.frx":0000
      Left            =   840
      List            =   "spellbook.frx":0002
      TabIndex        =   3
      Top             =   840
      Width           =   3495
   End
   Begin VB.Label spelldesc 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   15.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4335
      Left            =   5280
      TabIndex        =   2
      Top             =   1800
      Width           =   4095
   End
   Begin VB.Label spellname 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   20.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   5280
      TabIndex        =   1
      Top             =   960
      Width           =   4095
   End
   Begin VB.Label Label1 
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
      Height          =   375
      Left            =   8280
      TabIndex        =   0
      Top             =   6600
      Width           =   735
   End
   Begin VB.Menu mnufile 
      Caption         =   "mnufile"
      Visible         =   0   'False
      Begin VB.Menu mnufile2 
         Caption         =   "Cast Spell"
      End
   End
End
Attribute VB_Name = "spellbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
On Error Resume Next
spellbook.Picture = LoadPicture(IniPath & "Grh\book.jpg")
End Sub

Private Sub Label1_Click()
On Error Resume Next
Call PlayWaveDS(IniPath & "Sound\" & "Snd" & 58 & ".wav")
Unload Me

End Sub

Private Sub Spell4_Click()
End Sub

Private Sub mnufile2_Click()
On Error Resume Next
'Send command
If SpellLst.ListIndex > -1 Then
    SendData "CST" & SpellLst.ListIndex + 1
Unload Me
End If
End Sub

Private Sub SpellLst_Click()
On Error Resume Next

If UserSpellBook(SpellLst.ListIndex + 1).SpellIndex > 0 Then
spelldesc.Caption = UserSpellBook(SpellLst.ListIndex + 1).desc
spellname.Caption = UserSpellBook(SpellLst.ListIndex + 1).Name
End If

If UserSpellBook(SpellLst.ListIndex + 1).SpellIndex = 0 Then
spellname = ""
spelldesc = ""
End If

End Sub

Private Sub SpellLst_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
On Error Resume Next
If Button = 2 Then
        PopupMenu mnufile
End If
End Sub
