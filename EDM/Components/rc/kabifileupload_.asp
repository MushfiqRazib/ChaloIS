<!-- #include file="./common.asp"                   -->
<!-- #include file="./include/db.asp"               -->
<!-- #include file="./include/classes/htmlform.asp" -->
<%
Dim rs, sql, oForm, oFile, sqlParams
Dim itemCode, itemRev, itemDescr, fileName, errMsg, SupTypes

'*** Use HTMLForm component because we need binary data for file upload.
Set oForm = New HTMLForm

If oForm.Submitted Then	
	
	Set pdfFile = oForm("FileNamePDF")
	Set sulFile = oForm("FileNameSUF")
	
	If (pdfFile.FileName <> "" AND sulFile.FileName <> "" ) Then
		
		'*** Need to save the file but be careful about the existing file
		'*** Use a temporary file
		Dim objFSO, tempFolder, tempName, tempFile
		Set objFSO = CreateObject("Scripting.FileSystemObject") 
		Set tempFolder = objFSO.GetSpecialFolder(2)
		tempSULFullPath = tempFolder & "\\" & objFSO.GetTempName()
		tempPDFFullPath = tempFolder & "\\" & objFSO.GetTempName()
			
		If sulFile.SaveAs(tempSULFullPath) And pdfFile.SaveAs(tempPDFFullPath)Then
			Dim retCode
			errMsg = ProcessSULFile(tempSULFullPath, itemCode, itemRev)
		Else
			errMsg = "Bestand kan niet worden opgeslagen."
		End If
		'*** if there is no error then redirect to next page
		If (errMsg = "") Then Call Response.Redirect("./itemkabi.asp?isSULPresent=true&itemCode=" & itemCode & "&itemRev=" & itemRev & "&tempPDFFullPath=" & tempPDFFullPath & "&tempSULFullPath=" & tempSULFullPath)
	ElseIf (pdfFile.FileName <> "") Then		
		
		' *** Get Item Code and revision
		Dim pdfFileName, tempPDFFullPath
		pdfFileName = pdfFile.FileName		
		itemCode = Mid(pdfFileName, 1, Len(pdfFileName) - Len(pdfFile.FileExt) - 3 - 1)
		itemRev = Mid(pdfFileName, Len(itemCode) + 2, 2)
		
		'*** Need to save the file but be careful about the existing file
		'*** Use a temporary file
		
		Set filesys = CreateObject("Scripting.FileSystemObject") 
		Set tempfolder = filesys.GetSpecialFolder(2)		
		tempPDFFullPath = tempfolder & "\\" & filesys.GetTempName()
		Call WriteToLogFile("C:\\Temp\\Log.txt", "pdf fi:" & tempPDFFullPath)		
		If Not pdfFile.SaveAs(tempPDFFullPath) Then
			errMsg = "Bestand kan niet worden opgeslagen."
		End If
		If (errMsg = "") Then Call Response.Redirect("./itemkabi.asp?isSULPresent=false&itemCode=" & itemCode & "&itemRev=" & itemRev & "&tempPDFFullPath=" & tempPDFFullPath)
	Else
		Call WriteToLogFile("C:\\Temp\\Log.txt", "No file found")		
		errMsg = "Please select a kabi file."
	End If
		
END IF

function ProcessSULFile(SULFilePath, ByRef itemCode, ByRef itemRev)
	'*** read the suf file	
	'*** get the item code and revision number
	
	Dim objFSO
	Dim unit, numberOfRecords, menge
	Set objFSO = CreateObject("Scripting.FileSystemObject") 
	Set objFile = objFSO.OpenTextFile(SULFilePath)
	Dim lineString, i
	
	ProcessSULFile = ""
	i = 1
	Do Until objFile.AtEndOfStream
		lineString = objFile.ReadLine				
		if i = 6 then
			itemCode = Mid(lineString, Instr(lineString,":") + 2,20)
		End If
		if i = 7 then
			itemRev = trim(Mid(lineString, Instr(lineString,"Zust.") + 5,10))					
		End If
		if i > 13 then

			partCode = trim(Mid(lineString, 23, 13))			
			unit = trim(Mid(lineString, 80, 2))
			menge = trim(Mid(lineString,84, 5))
			
			'*** Check 1. partCode and menge can not be empty. Unit must be ST or MM
			if(partCode = "" or menge = "" or (UCase(unit) <> "ST" and UCase(unit) <> "MM")) Then
				Call WriteToLogFile("C:\\Temp\\Log.txt", "check 1 failed. line : " & i)
				ProcessSULFile = "The part number or menge is empty or the Unit is not ST /MM. Line number " & i
				Exit Do
			End If
			
			
			'*** Check 2. Each Item should be in ARTBST table
			'*** Where artcode = itemCode and type_ = menge
			'*** For menge MM it will be MT in Type_ (why ??)
			Dim countParam
			Set countParam = Server.CreateObject("Scripting.Dictionary")
			
			Call countParam.Add("SQL_From",        "ARTBST")
			If (UCase(trim(unit)) = "MM") Then
				Call WriteToLogFile("C:\\Temp\\Log.txt", "MM item: " & partCode&menge)
				Call countParam.Add("SQL_Where",       "artcode = '" & trim(partCode) & "' and type_='MT'")
			Else
				Call WriteToLogFile("C:\\Temp\\Log.txt", "ST item: " & partCode&menge)
				Call countParam.Add("SQL_Where",       "artcode = '" & trim(partCode) & "' and type_='ST'")
			End If
			Call countParam.Add("SQL_GroupBy",       "NONE")
  
			numberOfRecords = GetSelectCount(gDBConn, countParam, False)
			IF numberOfRecords < 1 Then
				Call WriteToLogFile("C:\\Temp\\Log.txt", "check 2 failed. line : " & partCode)
				ProcessSULFile = "The part " & partCode & " are not in library. Line number " & i
				Exit Do
			End If
			Call WriteToLogFile("C:\\Temp\\Log.txt", "number of rows returned: " & numberOfRecords)
		End If
		i = i + 1
	Loop
	objFile.Close
end function

Sub WriteToLogFile(strFilePath, logMsg)
	Dim objFSO, objFile
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
	If objFSO.FileExists(strFilePath) Then		
		Set objFile=objFSO.OpenTextFile(strFilePath,8,true)
		objFile.WriteLine(logMsg)
		objFile.Close
	Else
		Set objFile=objFSO.CreateTextFile(strFilePath)
		objFile.WriteLine(logMsg)
		objFile.Close
	End If
	
	Set objFSO=Nothing
End Sub

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="./include/copyright.inc" -->
<html>

<head>
  <title>VDL Berkhof: Artikel Toevoegen</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="./style/qbuilder.css">
  
  <script type="text/javascript" src="./script/common.js"></script>
  <script type="text/javascript" src="./script/sarissa.js"></script>
  <script type="text/javascript" src="./script/window.js"></script>
  <script type="text/javascript" src="./script/custom.js"></script>  
</head>

<body <% If (errMsg <> "") Then %> onload="alert('<%= errMsg %>')"<% End If %>>

<fieldset>
  <legend>Artikel gegevens</legend>
  
  <table align="center" cellspacing="4" style="margin: 8px 0px">
    <form name="kabiItemForm" action="./kabifileupload.asp" enctype="multipart/form-data" method="POST">
    <tr>
      <td nowrap>PDF Bestand</td>
      <td>
        <div class="FileBrowse"><input type="file" class="FileBrowse" name="FileNamePDF" value="" onchange="setElementAttrib('FileDisplayPDF', 'value', this.value)"></div>
        <input type="text" class="FileDisplay" id="FileDisplayPDF" value="" readonly><input type="button" class="FileButton" value="..." onfocus="this.blur()">
      </td>
      <td>
      <input type="hidden" id="supportedDocs" value='<%=SUPPORTED_DOC_TYPE %>' />
      </td>
    </tr>
    <tr>
      <td nowrap>SUL Bestand</td>
      <td>
        <div class="FileBrowse"><input type="file" class="FileBrowse" name="FileNameSUF" value="" onchange="setElementAttrib('FileDisplaySUL', 'value', this.value)"></div>
        <input type="text" class="FileDisplay" id="FileDisplaySUL" value="" readonly><input type="button" class="FileButton" value="..." onfocus="this.blur()">
      </td>
      <td>
      <input type="hidden" id="supportedDocs" value='<%=SUPPORTED_DOC_TYPE %>' />
      </td>
    </tr>
	
    </form>
  </table>
</fieldset>

<table width="100%">
  <tr>
    <td style="padding-top: 6px">
      <button onclick="document.kabiItemForm.reset()">Wissen</button>
    </td>
    <td align="right" style="padding-top: 6px">
      <button onclick="window.close()">Annuleren</button>&nbsp;&nbsp;
      <button onclick="kabiItemSubmit()">OK</button>
    </td>
  </tr>
</table>

</body>
<%
'*** Cleanup.
Call DBDisconnect(gDBConn)
%>
</html>