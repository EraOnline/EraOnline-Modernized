Attribute VB_Name = "modRes"
Public OldWidth As Single
Public OldHeight As Single
Public OldBPP As Integer

Private Declare Function EnumDisplaySettings Lib "user32" Alias "EnumDisplaySettingsA" (ByVal lpszDeviceName As Long, ByVal iModeNum As Long, lpDevMode As Any) As Boolean
Private Declare Function ChangeDisplaySettings Lib "user32" Alias "ChangeDisplaySettingsA" (lpDevMode As Any, ByVal dwflags As Long) As Long
    
    Private Const CCDEVICENAME = 32
    Private Const CCFORMNAME = 32
    Private Const DM_BITSPERPEL = &H60000
    Private Const DM_PELSWIDTH = &H80000
    Private Const DM_PELSHEIGHT = &H100000

Private Type DEVMODE
    dmDeviceName As String * CCDEVICENAME
    dmSpecVersion As Integer
    dmDriverVersion As Integer
    dmSize As Integer
    dmDriverExtra As Integer
    dmFields As Long
    dmOrientation As Integer
    dmPaperSize As Integer
    dmPaperLength As Integer
    dmPaperWidth As Integer
    dmScale As Integer
    dmCopies As Integer
    dmDefaultSource As Integer
    dmPrintQuality As Integer
    dmColor As Integer
    dmDuplex As Integer
    dmYResolution As Integer
    dmTTOption As Integer
    dmCollate As Integer
    dmFormName As String * CCFORMNAME
    dmUnusedPadding As Integer
    dmBitsPerPel As Integer
    dmPelsWidth As Long
    dmPelsHeight As Long
    dmDisplayFlags As Long
    dmDisplayFrequency As Long
End Type

Function ChangeRes(Width As Single, Height As Single, bpp As Integer) As Integer

    On Error GoTo ERROR_HANDLER
    
    Dim DevM As DEVMODE
    Dim i As Integer
    Dim returnVal As Boolean
    Dim RetValue
    
    Call EnumDisplaySettings(0&, -1, DevM)

    If OldBPP = 0 Then
        OldWidth = DevM.dmPelsWidth
        OldHeight = DevM.dmPelsHeight
        OldBPP = DevM.dmBitsPerPel
    End If
    i = 0

    Do
        returnVal = EnumDisplaySettings(0&, i, DevM)
        i = i + 1
    Loop Until (returnVal = False)

    DevM.dmFields = DM_PELSWIDTH Or DM_PELSHEIGHT Or DM_BITSPERPEL
    DevM.dmPelsWidth = Width
    DevM.dmPelsHeight = Height
    DevM.dmBitsPerPel = bpp
    
    Call ChangeDisplaySettings(DevM, 1)
    
    ChangeRes = 1
    Exit Function
    
ERROR_HANDLER:
    MsgBox "There was an error while attempting to change your display settings."
    End
    
End Function

Public Sub SetRes()
OldBPP = 0
Call ChangeRes(800, 600, 16)
End Sub

Public Sub RestoreRes()
Call ChangeRes(OldWidth, OldHeight, OldBPP)
End Sub
