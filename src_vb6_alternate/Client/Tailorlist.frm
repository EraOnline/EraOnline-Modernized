VERSION 5.00
Begin VB.Form Tailorlist 
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   5880
   ClientLeft      =   15
   ClientTop       =   15
   ClientWidth     =   7260
   ControlBox      =   0   'False
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5880
   ScaleWidth      =   7260
   StartUpPosition =   3  'Windows Default
   Begin VB.ListBox TailorList 
      BackColor       =   &H80000006&
      Height          =   1035
      Left            =   480
      TabIndex        =   0
      Top             =   3480
      Width           =   6375
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Cancel"
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
      Left            =   5880
      TabIndex        =   3
      Top             =   5280
      Width           =   975
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Tailoring"
      BeginProperty Font 
         Name            =   "Bart"
         Size            =   36
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   975
      Left            =   840
      TabIndex        =   2
      Top             =   360
      Width           =   5775
   End
   Begin VB.Label Label1 
      BackColor       =   &H80000007&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      Height          =   1695
      Left            =   2640
      TabIndex        =   1
      Top             =   1560
      Width           =   2055
   End
   Begin VB.Image Image1 
      Height          =   5895
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   7305
   End
End
Attribute VB_Name = "Tailorlist"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
Image1 = trade.Image1.Picture
End Sub

Private Sub Label3_Click()
Unload Me

End Sub
