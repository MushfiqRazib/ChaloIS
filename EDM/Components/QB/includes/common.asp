<%

Function GetCultureValue(cultureDoc, XPath)

   Dim mydoc,NodeList,Node,cultureValue   
   Set mydoc=Server.CreateObject("Microsoft.XMLDOM")   
   mydoc.async=false 
   mydoc.load(Server.Mappath(cultureDoc))   
   IF mydoc.parseError.errorcode<>0 then
     Response.Write("Invalid XML in culture document")
   Else        
     'Set NodeList = mydoc.documentElement.selectNodes("defaultUnknownFormat/defaultformat")   
     Set NodeList = mydoc.documentElement.selectNodes(xPath)   
     
     For Each Node In NodeList             
        cultureValue = cultureValue & IIf(cultureValue<>"","*","") & Node.text       
     Next
   End IF  
   
   '*** Return culture value for the xpath
   GetCultureValue =  cultureValue
   
End Function


Function IIf(bExpression, vTrue, vFalse)
  If bExpression then
    '*** Return 'TRUE' part.
    IIf = vTrue
  Else
    '*** Return 'FALSE' part.
    IIf = vFalse
  End If
End Function


Function RequestStr(key, default)
  Dim value
  
  '*** Get parameter value.
  value = Request(key)
  
  '*** Return as string even if parameter doesn't exist.
  RequestStr = IIf(value = "", default, CStr(value))
End Function

Sub ErrorMessage(message)
  '*** Redirect to error page with specified parameters.
  Response.Redirect("error.asp?msg=" & Server.URLEncode(message))  
End Sub

Function RequestBool(key)
  Dim value
  
  '*** Get parameter value.
  value = UCase(Request(key))
  
  '*** Return boolean.
  RequestBool = CBool(value = "TRUE" Or value = "1")
End Function


Function RequestInt(key, default)
  Dim value
  
  value = Request(key)
  
  If (value <> "" And IsNumeric(value)) Then
    '*** Return integer value of string.
    RequestInt = CLng(value)
  Else
    '*** Return default value.
    RequestInt = default
  End If
End Function


Function RequestSng(key, default)
  Dim value
  
  value = Request(key)
  
  If (value <> "" And IsNumeric(value)) Then
    '*** Return value as single.
    RequestSng = CSng(value)
  Else
    '*** Return default value.
    RequestSng = default
  End If
End Function


Function ToString(expr)
  If IsNull(expr) then
    '*** Return empty string.
    ToString = ""
  Else
    '*** Return expression as string.
    ToString = CStr(expr)
  End If
End Function


Function InArray(arr, searchvalue)
  Dim i
  
  '*** Default return value.
  InArray = False
  
  '*** Loop through array elements.
  For i = 0 To UBound(arr)
    If (StrComp(arr(i), searchvalue, 1) = 0) Then
      '*** Report back that array contains specified value.
      InArray = True
      
      '*** Stop searching.
      Exit For
    End If
  Next
End Function

Function EchoSelected(bExpression)
  '*** Return SELECTED tag (or not!).
  EchoSelected = IIf(bExpression, " selected", "")
End Function

Function FileExists(filename)
  Dim fso
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  
  '*** Check if files exist.
  FileExists = fso.FileExists(filename)
  
  '*** Delete object.
  Set fso = Nothing
End Function

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

Sub FileDelete(FileSpec)
  Dim fso
  
  On Error Resume Next
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  
  Call fso.DeleteFile(FileSpec, true)
  
  '*** Delete object.
  Set fso = Nothing
End Sub

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

Function ABStr(string)
  '*** Converts a Unicode string to ANSI.
  Dim outStr, i
  
  For i = 1 to Len(string)
    '*** Convert Unicode char to ANSI char.
    outStr = outStr & ChrB(Asc(Mid(string, i, 1)))
  Next
  
  '*** Return ANSI string/array.
  ABStr = outStr
End Function

Function BStr(string)
  '*** Converts an ANSI string to Unicode.
  Dim outStr, i
  
  For i = 1 to LenB(string)
    '*** Convert ANSI char to Unicode char.
    outStr = outStr & Chr(AscB(MidB(string, i, 1)))
  Next
  
  '*** Return Unicode string/array.
  BStr = outStr
End Function


Function EchoXHTML(expression, default)
  '*** Return XHTML formatted value.
  If (expression <> "") Then
    EchoXHTML = Server.HTMLEncode(expression)
  Else
    EchoXHTML = default
  End If
End Function


%>