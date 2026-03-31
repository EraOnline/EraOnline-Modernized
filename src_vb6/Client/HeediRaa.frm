VERSION 5.00
Begin VB.Form HeediRaa 
   BorderStyle     =   0  'None
   ClientHeight    =   9000
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12000
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   ScaleHeight     =   9000
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "PROCEED"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   14.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   10200
      TabIndex        =   3
      Top             =   8400
      Width           =   1575
   End
   Begin VB.Label StartupTown 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   9360
      TabIndex        =   2
      Top             =   480
      Width           =   2535
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Current Startup Location:"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   9360
      TabIndex        =   1
      Top             =   120
      Width           =   2655
   End
   Begin VB.Label Bern 
      BackStyle       =   0  'Transparent
      Height          =   855
      Left            =   840
      TabIndex        =   0
      Top             =   3960
      Width           =   975
   End
End
Attribute VB_Name = "HeediRaa"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Angelmoor_Click()
StartupTown.Caption = "Angelmoor"

End Sub

Private Sub Bern_Click()
StartupTown.Caption = "Bernvillage"

End Sub

Private Sub castleFall_Click()
StartupTown.Caption = "CastleFall"

End Sub

Private Sub Denc_Click()
StartupTown.Caption = "Denc"

End Sub

Private Sub Form_Load()

HeediRaa.Picture = LoadPicture("grh\HeediRaa.jpg")

End Sub

Private Sub Gorth_Click()
StartupTown.Caption = "Gorth"

End Sub

Private Sub Hilloc_Click()
StartupTown.Caption = "Hilloc"

End Sub

Private Sub Jemhoo_Click()
StartupTown.Caption = "Jemhoo"

End Sub

Private Sub Label2_Click()
If HeediRaa.StartupTown = "" Then
MsgBox "You must select a starting town."
Else
Form7.Show
End If
End Sub

Private Sub Watergone_Click()

StartupTown.Caption = "Anon-Raa"

End Sub
