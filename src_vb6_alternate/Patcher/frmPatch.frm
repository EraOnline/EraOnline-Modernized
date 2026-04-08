VERSION 5.00
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmPatch 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "EraOnline Patcher"
   ClientHeight    =   5985
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   5655
   Icon            =   "frmPatch.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5985
   ScaleWidth      =   5655
   StartUpPosition =   3  'Windows Default
   Begin MSComctlLib.ProgressBar progressbar 
      Height          =   195
      Left            =   3600
      TabIndex        =   1
      Top             =   5760
      Width           =   2030
      _ExtentX        =   3572
      _ExtentY        =   344
      _Version        =   393216
      Appearance      =   0
      Min             =   1e-4
      Scrolling       =   1
   End
   Begin VB.Timer tmrMOTD 
      Enabled         =   0   'False
      Interval        =   650
      Left            =   4200
      Top             =   3060
   End
   Begin MSComctlLib.StatusBar Statusbar 
      Align           =   2  'Align Bottom
      Height          =   285
      Left            =   0
      TabIndex        =   2
      Top             =   5700
      Width           =   5655
      _ExtentX        =   9975
      _ExtentY        =   503
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   3
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Object.Width           =   5116
            MinWidth        =   5116
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Object.Width           =   1058
            MinWidth        =   1058
         EndProperty
         BeginProperty Panel3 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Object.Width           =   5644
            MinWidth        =   5644
         EndProperty
      EndProperty
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin VB.TextBox txtMOTD 
      BackColor       =   &H8000000F&
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4065
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   960
      Width           =   5415
   End
   Begin InetCtlsObjects.Inet Inet 
      Left            =   0
      Top             =   0
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      Protocol        =   4
      RequestTimeout  =   99999999
   End
   Begin VB.Label patched 
      BackStyle       =   0  'Transparent
      Caption         =   "0"
      Height          =   375
      Left            =   0
      TabIndex        =   9
      Top             =   0
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Components are under txtMOTD ^_^"
      Enabled         =   0   'False
      Height          =   225
      Left            =   2850
      TabIndex        =   8
      Top             =   0
      Visible         =   0   'False
      Width           =   2805
   End
   Begin VB.Label lblVersion 
      AutoSize        =   -1  'True
      Caption         =   "EraOnline Patcher"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   195
      Left            =   30
      TabIndex        =   7
      Top             =   0
      Width           =   1755
   End
   Begin VB.Label Label2 
      AutoSize        =   -1  'True
      Caption         =   "© 2001 FuitadNET"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   195
      Left            =   30
      TabIndex        =   6
      Top             =   210
      Width           =   1755
   End
   Begin VB.Label lblMOTD 
      Alignment       =   2  'Center
      Caption         =   "Message of the day (aka MOTD)"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   120
      TabIndex        =   5
      Top             =   480
      Width           =   5415
   End
   Begin VB.Label lblFileStatus 
      Alignment       =   2  'Center
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   5160
      Width           =   5415
   End
   Begin VB.Label lblFileStatus2 
      Alignment       =   2  'Center
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   5400
      Width           =   5415
   End
End
Attribute VB_Name = "frmPatch"
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

Dim KBytesTotal As Integer
Dim Percent As Integer
Dim Playnow As Integer

Private Sub Form_Load()
Percent = 0
Playnow = 0
    Dim MyVersion As String
    MyVersion = App.Major & "." & App.Minor & " BETA (Build #" & App.Revision & ")"
    lblVersion.Caption = "EraOnline Patcher - Version " & MyVersion
    Statusbar.Panels(1).Text = "Connecting to patch server..."
    Statusbar.Panels(2).Text = Percent & "%"
Me.Show
DoEvents
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
    



If FileExist(App.Path & "\version.ver", vbNormal) = False Then
    Open App.Path & "\version.ver" For Output As #100
    Print #100, Chr(34) & "DontRun.exe, 0.0.0, 0" & Chr(34)
    Close #100
End If
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
    
    
    '/////DOWNLOAD NEWS//////
    
    If FileExist(Inipath & "\News.txt", vbNormal) = True Then
    Kill (Inipath & "News.txt")
    End If
    
    Inet.URL = "http://www.eraonline.net/patch/News.txt"
    
    Statusbar.Panels(1).Text = "Getting MOTD..."
    x = Inet.OpenURL(Inet.URL, icByteArray)
    
    
    
    nFile = FreeFile
    Open App.Path & "\News.txt" For Binary Access Write As nFile
        Put #nFile, , x()
    Close nFile
    
    Open App.Path & "\News.txt" For Input As #1
    txtMOTD.Text = StrConv(InputB(LOF(1), 1), vbUnicode)
    Close #1

    
    '////END DOWNLOAD NEWS////
    
    '/////Downalod imporant info/////

    'Inet.URL = "http://www.eraonline.net/patch/important.txt"
    'patch.important.Caption = Inet.OpenURL(Inet.URL, icString)

    '////End download imporant info////
    
    '////Download Updated files and new files////
    
    Statusbar.Panels(1).Text = "Getting Versions..."
    
    Inet.URL = "http://www.eraonline.net/patch/vagabond.ver"
    Data = Inet.OpenURL(Inet.URL, icString)
    
    Statusbar.Panels(1).Text = "Comparing versions..."
    
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
'playnow.Enabled = True
Resume Next
    
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
Dim retval

   Inipath = App.Path & "\"
   
patched = 1
retval = Shell(Inipath & "DontRun.Exe", vbMaximizedFocus)
End

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
            Statusbar.Panels(1).Text = "One file to update ..."
        Else
            Statusbar.Panels(1).Text = NumUpdates & " files to update ..."
        End If
        'AddText (Msg)
        UpdateInfo
        SaveVersion
        
        Statusbar.Panels(1).Text = "Done updating!"
        'playnow.Enabled = True
        progressbar.Value = 100
        Statusbar.Panels(2).Text = "100%"
        Statusbar.Panels(1).Text = "Click here to start EraOnline"
        Playnow = 1
     Else
        Statusbar.Panels(1).Text = "No files to update!"
        progressbar.Value = 100
        Statusbar.Panels(2).Text = "100%"
        Statusbar.Panels(1).Text = "Click here to start EraOnline"
        Playnow = 1
        'playnow.Enabled = True
    End If
    

    
Exit Sub


errorhandler:
        progressbar.Value = 100
        Statusbar.Panels(2).Text = "100%"
        Statusbar.Panels(1).Text = "Click here to start EraOnline"
        Playnow = 1
    
    
End Sub

Private Sub UpdateInfo()
'    Dim FileNum As Integer
    Dim x As Integer
    x = 1
   Inipath = App.Path & "\"

    For FileNum = 0 To UBound(RemoteFiles)
        If RemoteFiles(FileNum).Update Then
            KBytesTotal = KBytesTotal + (RemoteFiles(FileNum).Size / 1024)
        End If
    Next FileNum
Statusbar.Panels(2).Text = Percent & "%"
    For FileNum = 0 To UBound(RemoteFiles)
        If RemoteFiles(FileNum).Update Then
            Statusbar.Panels(1).Text = "Downloading file " & x & " of " & NumUpdates & "..."
            Call GetFile(FileNum)
            x = x + 1
        End If
    Next FileNum
End Sub

Private Sub GetFile(FileNum As Integer)

'On Error GoTo errorhandler

   Inipath = App.Path & "\"
   
'    Dim X() As Byte
    Dim nFile As Integer
    
    lblFileStatus.Caption = "Downloading " & RemoteFiles(FileNum).Name & " (" & RemoteFiles(FileNum).Size & " bytes)..."
    
    If FileExist(App.Path & "\" & RemoteFiles(FileNum).Name, vbNormal) = False Then
    Open App.Path & "\" & RemoteFiles(FileNum).Name For Random As #100
    Close #100
    End If
    Inet.URL = RemoteFiles(FileNum).URL
    x = Inet.OpenURL(Inet.URL, icByteArray)
    nFile = FreeFile
    Open App.Path & "\" & RemoteFiles(FileNum).Name For Binary Access Write As nFile
        Put #nFile, , x()
    Close nFile
    lblFileStatus.Caption = ""
    lblFileStatus2.Caption = RemoteFiles(FileNum).Name & " updated."
    Percent = Percent + ((RemoteFiles(FileNum).Size / 1024) / KBytesTotal) * 100
    progressbar.Value = Percent
    Statusbar.Panels(2).Text = Percent & "%"
Exit Sub

errorhandler:
    lblFileStatus.Caption = ""
    lblFileStatus2.Caption = "Error downloading " & RemoteFiles(FileNum).Name & "!"
    
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
        progressbar.Value = 100
        Statusbar.Panels(2).Text = "100%"
        Statusbar.Panels(1).Text = "Click here to start the EraOnline"
        Playnow = 1

End Sub

Private Sub Command1_Click()


End Sub

Private Sub Command2_Click()
End
End Sub

Private Sub Form_Unload(Cancel As Integer)
On Error Resume Next
Inet.Cancel
End
End Sub

Private Sub Statusbar_PanelClick(ByVal Panel As MSComctlLib.Panel)
If Panel.Index = 1 And Playnow = 1 Then
SaveVersion
Dim retval
patched = 1
retval = Shell(App.Path & "\DontRun.Exe --startedbypatcher", vbMaximizedFocus)
End
End If
End Sub
