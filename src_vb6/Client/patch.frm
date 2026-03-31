VERSION 5.00
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Begin VB.Form patch 
   BackColor       =   &H8000000A&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Era Online Patch"
   ClientHeight    =   6450
   ClientLeft      =   2265
   ClientTop       =   1950
   ClientWidth     =   7500
   ControlBox      =   0   'False
   Icon            =   "patch.frx":0000
   LinkTopic       =   "Form9"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6450
   ScaleWidth      =   7500
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox news 
      BackColor       =   &H80000004&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000007&
      Height          =   2895
      Left            =   240
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   8
      Top             =   960
      Width           =   6975
   End
   Begin VB.Frame Frame5 
      Height          =   375
      Left            =   1920
      TabIndex        =   13
      Top             =   4080
      Width           =   5415
      Begin VB.Label important 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   120
         Width           =   5175
      End
   End
   Begin VB.Frame Frame4 
      Height          =   375
      Left            =   120
      TabIndex        =   12
      Top             =   4080
      Width           =   1695
      Begin VB.Label Label3 
         BackStyle       =   0  'Transparent
         Caption         =   "Imporant Information:"
         Height          =   255
         Left            =   120
         TabIndex        =   14
         Top             =   120
         Width           =   1575
      End
   End
   Begin VB.TextBox txtStatus 
      BackColor       =   &H80000004&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000006&
      Height          =   1455
      Left            =   2040
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      TabIndex        =   9
      Top             =   4800
      Width           =   5175
   End
   Begin InetCtlsObjects.Inet Inet 
      Left            =   6840
      Top             =   120
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      Protocol        =   4
      RequestTimeout  =   99999999
   End
   Begin VB.Frame Frame3 
      Height          =   1815
      Left            =   1920
      TabIndex        =   7
      Top             =   4560
      Width           =   5415
   End
   Begin VB.Frame Frame2 
      Height          =   375
      Left            =   120
      TabIndex        =   5
      Top             =   4560
      Width           =   1695
      Begin VB.Label Label4 
         BackStyle       =   0  'Transparent
         Caption         =   "Status:"
         Height          =   255
         Left            =   120
         TabIndex        =   6
         Top             =   120
         Width           =   1335
      End
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Quit"
      Height          =   495
      Left            =   120
      TabIndex        =   4
      Top             =   5640
      Width           =   1695
   End
   Begin VB.CommandButton playnow 
      Caption         =   "Continue"
      Enabled         =   0   'False
      Height          =   495
      Left            =   120
      TabIndex        =   3
      Top             =   5040
      Width           =   1695
   End
   Begin VB.Frame Frame1 
      Height          =   3255
      Left            =   120
      TabIndex        =   0
      Top             =   720
      Width           =   7215
   End
   Begin VB.Label patched 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   375
      Left            =   9999
      TabIndex        =   11
      Top             =   9999
      Width           =   975
   End
   Begin VB.Label test 
      BackStyle       =   0  'Transparent
      Caption         =   "1"
      Height          =   255
      Left            =   9999
      TabIndex        =   10
      Top             =   120
      Width           =   975
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "Copyright (c) 1999-2000 Fantasia Studios"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   360
      Width           =   5655
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Era Online Auto-Patch And Updater"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   6495
   End
End
Attribute VB_Name = "patch"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Dim StartX As Long, StartY As Long

Private Type FileType
    Name As String
    version As String
    Size As Long
    URL As String
    Update As Boolean
End Type
Dim RemoteFiles() As FileType
Dim LocalFiles() As FileType

Dim Inipath As String

Dim TotalFiles As Integer

Dim Updates() As Integer
Dim NumUpdates As Integer

Dim x() As Byte
Dim newsnow() As Byte
Dim FileNum As Integer
Private Sub Command3_Click()

End Sub

Private Sub Form_Load()
   
   Inipath = App.Path & "\"
   
    Dim filename
    Dim TempData As String, TempBreakDown() As String
    Dim LineCount As Integer
    Dim Data As String
    Dim BreakDown() As String, BreakDown2() As String
    Dim a As Integer, nFile As Integer

On Error GoTo errorhandler

If patched = 0 Then
  
    NumUpdates = 0
    FileNum = -1
    
    Me.Show
    DoEvents
    



 
    LineCount = -1
    
  nFile = FreeFile
    Open App.Path & "\version.ver" For Input As nFile
        While Not EOF(nFile)
            LineCount = LineCount + 1
            Line Input #nFile, TempData
            
            TempData = Mid(TempData, 2, Len(TempData) - 2)
            TempBreakDown = Split(TempData, ",")
            
            ReDim Preserve LocalFiles(LineCount)
            LocalFiles(LineCount).Name = Trim(TempBreakDown(0))
            LocalFiles(LineCount).version = Trim(TempBreakDown(1))
            LocalFiles(LineCount).Size = Val(Trim(TempBreakDown(2)))
        Wend
    Close nFile
    
    AddText ("Connecting to patch server...")
    
    '/////DOWNLOAD NEWS//////
    
    If FileExist(Inipath & "News.txt", vbNormal) = True Then
    Kill (Inipath & "News.txt")
    End If
    
    Inet.URL = "http://www.erlingellingsen.com/era/news.txt"
    x = Inet.OpenURL(Inet.URL, icByteArray)
    
    nFile = FreeFile
    Open App.Path & "\news.txt" For Binary Access Write As nFile
        Put #nFile, , x()
    Close nFile
    
    Open App.Path & "\News.txt" For Input As #1
    patch.news.Text = StrConv(InputB(LOF(1), 1), vbUnicode)
    Close #1

    
    '////END DOWNLOAD NEWS////
    
    '/////Downalod imporant info/////

    Inet.URL = "http://www.erlingellingsen.com/era/important.txt"
    patch.important.Caption = Inet.OpenURL(Inet.URL, icString)

    '////End download imporant info////
    
    '////Download Updated files and new files////
    Inet.URL = "http://www.erlingellingsen.com/era/vagabond.ver"
    Data = Inet.OpenURL(Inet.URL, icString)
    
    AddText ("Data arrived, comparing versions...")
    
    BreakDown = Split(Data, vbCrLf)
    
    TotalFiles = Val(Trim(BreakDown(0)))
    ReDim RemoteFiles(TotalFiles - 1)
    
    For a = 1 To TotalFiles
        BreakDown2 = Split(BreakDown(a), ",")
        
        RemoteFiles(a - 1).Name = Trim(BreakDown2(0))
        RemoteFiles(a - 1).version = Trim(BreakDown2(1))
        RemoteFiles(a - 1).Size = Val(Trim(BreakDown2(2)))
        RemoteFiles(a - 1).URL = Trim(BreakDown2(3))
    Next a
    AnalyzeData
    
    End If
    
Exit Sub

errorhandler:
playnow.Enabled = True
    
End Sub

Private Sub Form_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    StartX = x
    StartY = y
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = 1 Then
        Me.Left = Me.Left - (StartX - x)
        Me.Top = Me.Top - (StartY - y)
    End If
End Sub

Private Sub playnow_Click()
Dim Retval

   Inipath = App.Path & "\"
   
patch.patched = 1
Retval = Shell(Inipath & "DontRun.Exe", vbMaximizedFocus)
End

End Sub

Private Sub txtStatus_Change()
    txtStatus.SelStart = Len(txtStatus)
End Sub

Private Sub AddText(Text As String)
    txtStatus.Text = txtStatus.Text & Text & vbCrLf
End Sub

Private Sub AnalyzeData()

   Inipath = App.Path & "\"
   
On Error GoTo errorhandler

    Dim a As Integer, b As Integer
    Dim Found As Boolean
    Dim Msg As String
    
    For a = 0 To UBound(RemoteFiles)
        Found = False
        For b = 0 To UBound(LocalFiles)
            If RemoteFiles(a).Name = LocalFiles(b).Name Then
                Found = True
                If RemoteFiles(a).Size <> LocalFiles(b).Size Or RemoteFiles(a).version <> LocalFiles(b).version Then
                    Found = False
                End If
            End If
        Next b
        If Found = False Then
            RemoteFiles(a).Update = True
            NumUpdates = NumUpdates + 1
        End If
    Next a
    If NumUpdates > 0 Then
        If NumUpdates = 1 Then
            Msg = "One file to update ..."
        Else
            Msg = NumUpdates & " files to update ..."
        End If
        AddText (Msg)
        UpdateInfo
        SaveVersion
        
        AddText ("Done updating, press ""Continue""!")
        playnow.Enabled = True
     Else
        AddText ("No files to update, press ""Continue""!")
        playnow.Enabled = True
    End If
    
Exit Sub


errorhandler:
playnow.Enabled = True
    
    
End Sub

Private Sub UpdateInfo()
'    Dim FileNum As Integer
    
   Inipath = App.Path & "\"
   
    For FileNum = 0 To UBound(RemoteFiles)
        If RemoteFiles(FileNum).Update Then
            Call GetFile(FileNum)
        End If
    Next FileNum
End Sub

Private Sub GetFile(FileNum As Integer)

On Error GoTo errorhandler

   Inipath = App.Path & "\"
   
'    Dim X() As Byte
    Dim nFile As Integer
    
    AddText ("Downloading " & RemoteFiles(FileNum).Name & " (" & RemoteFiles(FileNum).Size & " bytes)...")
    
    Inet.URL = RemoteFiles(FileNum).URL
    x = Inet.OpenURL(Inet.URL, icByteArray)
    
    nFile = FreeFile
    Open App.Path & "\" & RemoteFiles(FileNum).Name For Binary Access Write As nFile
        Put #nFile, , x()
    Close nFile
    
    AddText (RemoteFiles(FileNum).Name & " updated.")

Exit Sub

errorhandler:
playnow.Enabled = True
    
End Sub

Private Sub SaveVersion()

On Error GoTo errorhandler

    Dim a As Integer, nFile As Integer
    
    nFile = FreeFile
    Open App.Path & "\version.ver" For Output As nFile
        For a = 0 To UBound(RemoteFiles)
            Write #nFile, RemoteFiles(a).Name & ", " & RemoteFiles(a).version & ", " & RemoteFiles(a).Size
        Next a
    Close nFile

Exit Sub

errorhandler:
playnow.Enabled = True

End Sub

Private Sub Command1_Click()


End Sub

Private Sub Command2_Click()
End
End Sub


