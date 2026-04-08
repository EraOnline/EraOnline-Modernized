VERSION 5.00
Begin VB.Form loading 
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   1560
   ClientLeft      =   2460
   ClientTop       =   3015
   ClientWidth     =   5955
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1560
   ScaleWidth      =   5955
   Begin VB.Label lblVersion 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   210
      Left            =   60
      TabIndex        =   2
      Top             =   1320
      Width           =   60
   End
   Begin VB.Label percent 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   0
      TabIndex        =   1
      Top             =   720
      Width           =   5895
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Loading up Era Online Server Program. Please wait this may take a while..."
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   0
      TabIndex        =   0
      Top             =   360
      Width           =   5895
   End
End
Attribute VB_Name = "loading"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
    Me.lblVersion = App.Major & "." & App.Minor & "." & App.Revision
End Sub
