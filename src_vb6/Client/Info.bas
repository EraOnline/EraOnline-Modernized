Attribute VB_Name = "Info"

Function FileExist(File As String, FileType As VbFileAttribute) As Boolean

On Error Resume Next
'*****************************************************************
'Checks to see if a file exists
'*****************************************************************

If Dir(File, FileType) = "" Then
    FileExist = False
Else
    FileExist = True
End If

End Function
