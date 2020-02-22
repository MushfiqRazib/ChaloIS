<%
'*******************************************************************************
'***                                                                         ***
'*** File       : system.asp                                                 ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 15-08-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: System Functions                                           ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** Date/Time functions
'*******************************************************************************
Function Today()
  Dim day_value, month_value, year_value
  
  day_value   = IIf(Day(Now) < 10, "0", "") & Day(Now)
  month_value = IIf(Month(Now) < 10, "0", "") & Month(Now)
  year_value  = Year(Now)
  
  Today = day_value & "-" & month_value & "-" & year_value
End Function


'*******************************************************************************
'*** IO functions
'*******************************************************************************
Function SPrintf(format, args)
  Dim outStr, i
  
  outStr = format
  
  For i = 0 To UBound(args)
    '*** Replace '{i}' by argument i.
    outStr = Replace(outStr, "{" & i & "}", args(i))
  Next
  
  '*** Return formatted string.
  SPrintf = outStr
End Function


'*******************************************************************************
'*** File IO functions
'*******************************************************************************
Sub FileCopy(source, destination)
  Dim fso
  
  On Error Resume Next
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  
  '*** Copy file and force overwrite.
  Call fso.CopyFile(source, destination, True)
  
  '*** Delete object.
  Set fso = Nothing
End Sub


Sub FileDelete(FileSpec)
  Dim fso
  
  On Error Resume Next
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  
  Call fso.DeleteFile(FileSpec, true)
  
  '*** Delete object.
  Set fso = Nothing
End Sub


Function FileExists(filename)
  Dim fso
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  
  '*** Check if files exist.
  FileExists = fso.FileExists(filename)
  
  '*** Delete object.
  Set fso = Nothing
End Function


Sub FileExtract(fileFullName, fileDrive, filePath, fileBase, fileExt)
  Dim firstSlash, lastSlash, extDot
  
  '*** Get positions.
  firstSlash = InStr(fileFullName, "\")
  lastSlash  = InStrRev(fileFullName, "\")
  extDot     = InStrRev(fileFullName, ".")
  
  '*** Extract drive.
  If (firstSlash > 1) Then fileDrive = Left(fileFullName, firstSlash - 1)
  
  '*** Extract full path.
  If (lastSlash > 0) Then filePath = Left(fileFullName, lastSlash - 1)
  
  If (extDot > 0) Then
    '*** Extract base name and extension.
    fileBase = Right(fileFullName, Len(fileFullName) - extDot)
    fileExt  = Right(fileFullName, Len(fileFullName) - extDot)
  ElseIf (lastSlash > 0) Then
    '*** Extract base name.
    fileBase = Right(fileFullName, Len(fileFullName) - lastSlash)
  Else
    fileBase = fileFullName
  End If
End Sub


Function FileMatch(filename, filter)
 Dim wildcard, lpart, rpart, lmatch, rmatch
 
 wildcard = InStr(1, filter, "*", 1)
 
 If (wildcard > 0) Then
   '*** Compare left and right part.
   lpart = Left(filter, wildcard - 1)
   rpart = Right(filter, Len(filter) - wildcard)
   
   lmatch = (Left(filename, Len(lpart)) = lpart)
   rmatch = (Right(filename, Len(rpart)) = rpart)
   
   FileMatch = (lmatch And rmatch)
 Else
   '*** No wildcards, so perform 1-on-1 match.
   FileMatch = (filename = filter)
 End If
End Function


Sub FileRename(source, destination)
  Dim fso
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  
  '*** if source file is missing skip the whole copy thing,....
  If Not fso.FileExists(source) Then Exit Sub
  
  '*** Delete destination file if exists.
  If fso.FileExists(destination) Then Call fso.DeleteFile(destination, True)
  
  '*** Copy source to dest, force overwrite.
  Call fso.CopyFile(source, destination, True)
  
  '*** Delete source file if destination exist.
  If fso.FileExists(destination) Then Call fso.DeleteFile(source, True)
  
  '*** Delete object.
  Set fso = Nothing
End Sub


Function FolderExists(path)
  Dim fso
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  
  '*** Check if files exist.
  FolderExists = fso.FolderExists(path)
  
  '*** Delete object.
  Set fso = Nothing
End Function


Function CreateFolder(folder)
  Dim fso, f
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  
  If Not fso.FolderExists(folder) Then 
    '*** Folder does not exist, so try to create it.
    On Error Resume Next
    
    Set f = fso.CreateFolder(folder)
    
    '*** Return succes/failure.
    CreateFolder = IsObject(f)
  Else
    '*** Folder already exist.
    CreateFolder = True
  End If
  
  '*** Cleanup.
  Set f   = Nothing
  Set fso = Nothing
End Function

'*** Create the hierarchical directory structure
Function CreatePath(path)
  Dim tempDir,dirs,i
  dirs = Split(path,"\")
  tempDir = dirs(0)
  For i=1 To UBound(dirs)
    tempDir = tempDir + "\" + dirs(i)
    CreateFolder(tempDir)
  Next

End Function


Sub DeleteFolder(FileSpec)
  Dim oFSO
  
  '*** Create FileSystem object.
  Set oFSO = Server.CreateObject("Scripting.FileSystemObject")
  
  If oFSO.FolderExists(FileSpec) Then
    '*** Only delete folder if exists.
    Call oFSO.DeleteFolder(FileSpec, true)
  End If
  
  '*** Delete object.
  Set oFSO = Nothing
End Sub


Sub MoveFiles(src_path, src_files, dest_path)
  On Error Resume Next
  
  Dim fso
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  
  '*** Copy file.
  Call fso.CopyFile(src_path & src_files, dest_path, True)
  
  '*** Delete source files.
  Call fso.DeleteFile(src_path & src_files, True)
  
  '*** Delete object.
  Set fso = Nothing
End Sub
%>