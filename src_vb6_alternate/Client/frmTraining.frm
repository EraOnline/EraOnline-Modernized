VERSION 5.00
Begin VB.Form frmTraining 
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
   ShowInTaskbar   =   0   'False
   Begin VB.Label Label6 
      BackStyle       =   0  'Transparent
      Caption         =   "Archery:"
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
      Left            =   1740
      TabIndex        =   59
      Top             =   1185
      Width           =   1605
   End
   Begin VB.Label archery 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   57
      Top             =   1185
      Width           =   585
   End
   Begin VB.Label lockpicking 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   56
      Top             =   4770
      Width           =   585
   End
   Begin VB.Label etiquette 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   55
      Top             =   3330
      Width           =   585
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "Close"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   7320
      TabIndex        =   54
      Top             =   7800
      Width           =   1695
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Training"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   435
      Left            =   3743
      TabIndex        =   53
      Top             =   0
      Width           =   1695
   End
   Begin VB.Label trainingpoints 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   4440
      TabIndex        =   52
      Top             =   5760
      Width           =   2475
   End
   Begin VB.Label Label2 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Training Points Left:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   270
      Left            =   4440
      TabIndex        =   51
      Top             =   5400
      Width           =   2475
   End
   Begin VB.Label cooking 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   50
      Top             =   2610
      Width           =   585
   End
   Begin VB.Label musicanship 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   49
      Top             =   840
      Width           =   585
   End
   Begin VB.Label tailoring 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   48
      Top             =   4410
      Width           =   585
   End
   Begin VB.Label carpenting 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   47
      Top             =   2250
      Width           =   585
   End
   Begin VB.Label lumberjacking 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   46
      Top             =   5115
      Width           =   585
   End
   Begin VB.Label tactics 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   45
      Top             =   4050
      Width           =   585
   End
   Begin VB.Label disguise 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   44
      Top             =   2970
      Width           =   585
   End
   Begin VB.Label merchant 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   43
      Top             =   5835
      Width           =   585
   End
   Begin VB.Label blacksmithing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   42
      Top             =   1905
      Width           =   585
   End
   Begin VB.Label hiding 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   41
      Top             =   4410
      Width           =   585
   End
   Begin VB.Label magery 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   40
      Top             =   5475
      Width           =   585
   End
   Begin VB.Label pickpocket 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   39
      Top             =   1545
      Width           =   585
   End
   Begin VB.Label stealth 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   38
      Top             =   2610
      Width           =   585
   End
   Begin VB.Label poisoning 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   37
      Top             =   1905
      Width           =   585
   End
   Begin VB.Label swordmanship 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   36
      Top             =   3690
      Width           =   585
   End
   Begin VB.Label parrying 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   35
      Top             =   1185
      Width           =   585
   End
   Begin VB.Label AnimalTaming 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   34
      Top             =   840
      Width           =   585
   End
   Begin VB.Label religionlore 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   33
      Top             =   2250
      Width           =   585
   End
   Begin VB.Label fishing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   32
      Top             =   3690
      Width           =   585
   End
   Begin VB.Label mining 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   31
      Top             =   6555
      Width           =   585
   End
   Begin VB.Label backstabbing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   30
      Top             =   1545
      Width           =   585
   End
   Begin VB.Label healing 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   29
      Top             =   4050
      Width           =   585
   End
   Begin VB.Label surviving 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   28
      Top             =   3330
      Width           =   585
   End
   Begin VB.Label streetwise 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   5910
      TabIndex        =   27
      Top             =   2970
      Width           =   585
   End
   Begin VB.Label meditating 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
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
      Left            =   3510
      TabIndex        =   26
      Top             =   6195
      Width           =   585
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Pickpocket:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   24
      Left            =   4200
      TabIndex        =   25
      Top             =   1545
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Backstabbing:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   22
      Left            =   1740
      TabIndex        =   24
      Top             =   1545
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Etiquette:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   21
      Left            =   1740
      TabIndex        =   23
      Top             =   3330
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Religion Lore:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   20
      Left            =   4200
      TabIndex        =   22
      Top             =   2250
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Magery:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   19
      Left            =   1740
      TabIndex        =   21
      Top             =   5475
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Healing:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   18
      Left            =   1740
      TabIndex        =   20
      Top             =   4050
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Parrying:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   17
      Left            =   4200
      TabIndex        =   19
      Top             =   1185
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Tactics:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   16
      Left            =   4200
      TabIndex        =   18
      Top             =   4050
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Swordmanship:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   15
      Left            =   4200
      TabIndex        =   17
      Top             =   3690
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Stealth:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   14
      Left            =   4200
      TabIndex        =   16
      Top             =   2610
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Hiding:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   13
      Left            =   1740
      TabIndex        =   15
      Top             =   4410
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Carpetning:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   12
      Left            =   1740
      TabIndex        =   14
      Top             =   2250
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Lumberjacking:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   11
      Left            =   1740
      TabIndex        =   13
      Top             =   5115
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Poisoning:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   10
      Left            =   4200
      TabIndex        =   12
      Top             =   1905
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "BlackSmithing:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   9
      Left            =   1740
      TabIndex        =   11
      Top             =   1905
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Tailoring:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   8
      Left            =   4200
      TabIndex        =   10
      Top             =   4410
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Fishing:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   7
      Left            =   1740
      TabIndex        =   9
      Top             =   3690
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Animal Taming:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   6
      Left            =   1740
      TabIndex        =   8
      Top             =   840
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Mechant:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   5
      Left            =   1740
      TabIndex        =   7
      Top             =   5835
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Musicanship:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   4
      Left            =   4200
      TabIndex        =   6
      Top             =   840
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Mining:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   3
      Left            =   1740
      TabIndex        =   5
      Top             =   6555
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Surviving:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   2
      Left            =   4200
      TabIndex        =   4
      Top             =   3330
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Disguise:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   1
      Left            =   1740
      TabIndex        =   3
      Top             =   2970
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Cooking:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   25
      Left            =   1740
      TabIndex        =   2
      Top             =   2610
      Width           =   1605
   End
   Begin VB.Label Label4 
      BackStyle       =   0  'Transparent
      Caption         =   "Streetwise:"
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
      Left            =   4200
      TabIndex        =   1
      Top             =   2970
      Width           =   1605
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Caption         =   "Meditating:"
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
      Left            =   1740
      TabIndex        =   0
      Top             =   6195
      Width           =   1605
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Lockpicking:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   255
      Index           =   23
      Left            =   1740
      TabIndex        =   58
      Top             =   4770
      Width           =   1605
   End
End
Attribute VB_Name = "frmTraining"
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



Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
frmTraining.Picture = LoadPicture(IniPath & "Grh\msgboard.jpg")

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



Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick
Unload Me

End Sub

Private Sub lockpicking_Click()
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick
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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
Call ButtonClick


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
