<!-- #include file="./common.asp"                   -->
<!-- #include file="./include/db.asp"               -->
<!-- #include file="./include/classes/htmlform.asp" -->
<%
Dim rs, sql, oForm, oFile, sqlParams
Dim itemCode, itemRev, itemDescr, fileName, errMsg, SupTypes,i
Dim isSULPresent, tempPDFFullPath, tempSULFullPath

'*** Use HTMLForm component because we need binary data for file upload.
Set oForm = New HTMLForm

If oForm.Submitted Then
  '*** Get file.
  'Set oFile = oForm("FileName")
  
  '*** Get submitted values.
  itemCode  = trim(oForm("ItemCode"))
  itemRev   = trim(oForm("ItemRev"))
  itemDescr = trim(oForm("ItemDescr"))
  
  tempPDFFullPath = oForm("tempPDFFullPath")
  tempSULFullPath = oForm("tempSULFullPath")
  
  Call WriteToLogFile("C:\\Temp\\Log.txt", "itemCode tme: " & oForm("ItemCode") & itemDescr & tempPDFFullPath)		
  fileName  = itemCode & "_" & itemRev & "." & "PDF"
  sqlParams = Array(SQLEnc(itemCode), SQLEnc(itemRev), SQLEnc(itemDescr), SQLEnc(fileName), "'Diversen'", SQLEnc(oForm("FileFormat")))
  
  '*** Only proceed if we have a file (and thereby all other information).
  'If (oFile.FileSize > 0) Then
    '*** Delete current revision (if exist).
	if (trim(itemCode) <> "") Then 
'***************************************************************************************************
		Call DBExecute(gDBConn, "DELETE FROM rc_item_hit WHERE item = " & sqlParams(0), False)
		Call DBExecute(gDBConn, "DELETE FROM rc_c_bomeng WHERE item = " & sqlParams(0), False)
	
		'*** Delete only main document if exist
		Call FileDelete(PATH_RC & itemCode & "_*.*")
'**************************************************************************************************  
	End if
	
	Dim objFSO
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
    '*** Try to save new file.
	'If oFile.SaveAs(PATH_RC & fileName) Then
	Call WriteToLogFile("C:\\Temp\\Log.txt", tempPDFFullPath & "  " & PATH_RC & fileName)		
	'If objFSO.MoveFile(tempPDFFullPath, PATH_RC & fileName) Then
		objFSO.MoveFile tempPDFFullPath, PATH_RC & fileName
    	
      '*** Insert new item.
      sql = SPrintf("INSERT INTO rc_item_hit (item, revision, description, file_name, file_type, file_format) VALUES ({0}, {1}, {2}, {3}, {4}, {5})", sqlParams)
      Call WriteToLogFile("C:\\Temp\\Log.txt", "going DBEXecutr")		
      '*** File uploaded and saved, so update database.
      Call DBExecute(gDBConn, sql, True)
	  Call WriteToLogFile("C:\\Temp\\Log.txt", "DBEXecutr is done")		
	  '*** if sul file is present then insert the part records in database
	  
	  If trim(tempSULFullPath) <> "" Then
		errMsg = ProcessSULFile(tempSULFullPath, itemCode, itemRev, gDBConn)
	  End If
    'Else
      '*** Something went wrong!
      'errMsg = "Bestand " & PATH_RC & fileName & " kan niet worden opgeslagen."
    'End If
    
    '*** Redirect if no errors.
    If (errMsg = "") Then 
		Call Response.Redirect("./qb/qb_finish.asp")
	Else
		Call WriteToLogFile("C:\\Temp\\Log.txt", "No file found")		
		errMsg = "Please select a kabi file."
	End If
Else
	itemCode = trim(Request.QueryString("itemCode"))
	itemRev = trim(Request.QueryString("itemRev"))
	isSULPresent = trim(Request.QueryString("isSULPresent"))
	tempPDFFullPath = trim(Request.QueryString("tempPDFFullPath"))
	tempSULFullPath = trim(Request.QueryString("tempSULFullPath"))
	
	'errMsg = "itemCode : " & itemCode & " itemRev :" & itemRev & " isSULPresent: " & isSULPresent & " tempSULFullPath: " & tempSULFullPath& " tempPDFFullPath: " & tempPDFFullPath
	Call WriteToLogFile("C:\\Temp\\Log.txt", "tempPDFFullPath k: " & tempPDFFullPath)	
	
End If


function ProcessSULFile(SULFilePath, itemCode, itemRev, gDBConn)
	'*** read the suf file	
	'*** get the item code and revision number
	
	Dim objFSO
	Dim unit, numberOfRecords, menge, description
	Set objFSO = CreateObject("Scripting.FileSystemObject") 
	Set objFile = objFSO.OpenTextFile(SULFilePath)
	Dim lineString, i, pos
	
	ProcessSULFile = ""
	i = 1
	pos = 1
	Do Until objFile.AtEndOfStream
		lineString = objFile.ReadLine
		if i > 13 and trim(lineString) <> "" then

			partCode = trim(Mid(lineString, 23, 13))
			description	= trim(Mid(lineString, 38, 39))		
			unit = trim(Mid(lineString, 80, 2))
			menge = trim(Mid(lineString,84, 5))
			Call WriteToLogFile("C:\\Temp\\Log.txt", "going to insert sul data: ")
			
			If UCase(trim(unit)) = "ST" Then
				sqlParams = Array(SQLEnc(itemCode), "'BHH'", pos, SQLEnc(menge), SQLEnc(partCode), menge,SQLEnc(description), "0" , SQLEnc(itemRev))
			Else
				dim anntal
				anntal = menge / 1000
				anntal = replace(anntal, ",",".")
				menge = replace(menge, ",",".")
				sqlParams = Array(SQLEnc(itemCode), "'BHH'", pos, "1", SQLEnc(partCode), anntal,SQLEnc(description), menge, SQLEnc(itemRev))
			End If
			Call WriteToLogFile("C:\\Temp\\Log.txt", "going to insert sul data: ")	
			sql = SPrintf("INSERT INTO rc_c_bomeng (item, CCN, C_BOMENG_BALLOON, ref_qty, comp_item, comp_qty,REF_DESCRIPTION, ref_user_num1, draw_rev) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6},{7} ,{8})", sqlParams)
			Call WriteToLogFile("C:\\Temp\\Log.txt", sql)
      
			'*** File uploaded and saved, so update database.
			Call DBExecute(gDBConn, sql, true)
			Call WriteToLogFile("C:\\Temp\\Log.txt", "inserted to insert sul data: ")	
			pos = pos + 1
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
    <form name="ItemForm" action="./itemkabi.asp" enctype="multipart/form-data" method="POST">
    <tr>
      <td nowrap>Artikelnummer</td>
      <td><input type="text" name="ItemCode" id="ItemCode" maxlength="15" <% If(isSULPresent) Then %> disabled="disabled" <% End IF %> value="<%= itemCode %>"></td>
    </tr>
    <tr>
      <td nowrap>Revisie</td>
      <td><input type="text" name="ItemRev" id="ItemRev" maxlength="5" <% If(isSULPresent) Then %> disabled="disabled" <% End IF %> style="width: 50px" onpaste="return false" onkeypress="return isNum(event)" value="<%= itemRev %>"></td>
    </tr>
    <tr>
      <td nowrap>Formaat</td>
      <td>
        <select name="FileFormat" id="FileFormat" style="width: 50px">
          <option value="A0" selected>A0</option>
          <option value="A1">A1</option>
          <option value="A2">A2</option>
          <option value="A3">A3</option>
          <option value="A4">A4</option>
        </select>
      </td>
    </tr>
    <tr>
      <td nowrap>Omschrijving</td>
      <td><input type="text" name="ItemDescr" maxlength="100" style="width: 290px" value="<%= itemDescr %>"></td>
    </tr>
    <tr>
      <td nowrap></td>
      <td>
      </td>
      <td>
      <input type="hidden" id="supportedDocs" value='<%=SUPPORTED_DOC_TYPE %>' />
	  <input type="hidden" name="tempPDFFullPath" id="tempPDFFullPath" value='<%=tempPDFFullPath %>' />
	  <input type="hidden" name="tempSULFullPath" id="tempSULFullPath" value='<%=tempSULFullPath %>' />
      </td>
    </tr>
    </form>
  </table>
</fieldset>

<table width="100%">
  <tr>
    <td style="padding-top: 6px">
      <button onclick="document.ItemForm.reset()">Wissen</button>
    </td>
    <td align="right" style="padding-top: 6px">
      <button onclick="window.close()">Annuleren</button>&nbsp;&nbsp;
      <button onclick="kabiitemSubmit2()">OK</button>
    </td>
  </tr>
</table>

</body>
<%
'*** Cleanup.
Call DBDisconnect(gDBConn)
%>
</html>