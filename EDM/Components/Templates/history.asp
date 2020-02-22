<!-- #include file="../Basket/functions.asp"  -->

<%
Dim sql,rs, fso, folderSpec, fileSpec, fldr, f, itemCode, itemLen, baseLen, baseName, fileExt,filenameLen,fileSubPath,fileName

'*** Get parameters.
tableName = RequestStr("tableName", "")
keyValue = RequestStr("keyvalue", "")

keyValueArr = Split(keyValue,"|")
itemCode = keyValueArr(1)
keyValue = Replace(keyValue,"|","'")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="../qb/includes/copyright.inc" -->
<html>

<head>
  <title>EDM</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="./styles/obrowser.css">
  <script type="text/javascript" src="./scripts/common.js"></script>
  <script type="text/javascript" src="./scripts/history.js"></script>
  
</head>

<body>

<table cellspacing="0" cellpadding="0" height="100%" width="100%">
<%
'*** Try to open recordset.
Dim enc_itemCode,sql_repDetail
enc_itemCode =  SQLEnc(itemCode)


'sql = Replace(Replace(sql,"[tablename]",tableName),"[keyvalue]",keyValue) 
sql = "Select relfilename from " & tableName & " where " & keyValue


If RSOpen(rs, gDBConn, sql , True) Then

%>
  <tr>
    <td style="border-right: 1px solid #BBBBBB; padding: 10px; vertical-align: top" nowrap>
<%
  '*** Get item code length.
  baseLen = Len(itemCode) + 3
  itemLen = Len(itemCode)
  
  fileSubPath = GetFileSubPathFromRelfilename(rs("relfilename"))  
 

  'fileName = rs("matcode") & "_" & rs("rev")&".dwf"
  '*** Get folder and file name.
  folderSpec = DocBasePath & fileSubPath
  
  'fileSpec   = folderSpec & fileName
  
  '*** Create FileSystem object.
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  If (fso.FolderExists(folderSpec)) Then
    '*** Get folder object.
    Set fldr = fso.GetFolder(folderSpec)
   
    '*** Loop through files.
    For Each f In fldr.Files
	
	 '*** Get base name.
	  filenameLen = InStrRev(f.Name, ".")
	  IF filenameLen > 0 Then
		filenameLen = filenameLen
	  Else
		filenameLen = 1
	  End If
      
	  baseName = Left(f.Name, filenameLen - 1)
      fileExt  = Right(f.Name, Len(f.Name) - InStrRev(f.Name, "."))
      
        
      '*** Correct file?
      
      If (InStr(1, baseName, itemCode, 1) = 1 And Len(baseName) = baseLen And fileExt <> "dwg") Then
      
%>      
      <a href="#" onclick="LoadDocument('<%= Replace(folderSpec & f.Name, "\", "\\") %>');"><%= f.Name %></a><br />
<%
      End If
    Next
  End If
%>
    </td>
    <td id="Document" width="100%">
      
    </td>
  </tr>
<%
Else
%>
  <tr><td>Geen historie gevonden.</td></tr>
<%
End If
%>
</table>

</body>

</html>