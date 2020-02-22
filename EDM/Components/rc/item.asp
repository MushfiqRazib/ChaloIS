<!-- #include file="./common.asp"                   -->
<!-- #include file="./include/db.asp"               -->
<!-- #include file="./include/classes/htmlform.asp" -->


<%
Dim rs, sql, oForm, oFile, sqlParams
Dim itemCode, itemRev, itemDescr, fileName, errMsg, SupTypes,i

'*** Use HTMLForm component because we need binary data for file upload.
Set oForm = New HTMLForm

If oForm.Submitted Then
  '*** Get file.
  Set oFile = oForm("FileName")
  
  '*** Get submitted values.
  itemCode  = oForm("ItemCode")
  itemRev   = oForm("ItemRev")
  itemDescr = oForm("ItemDescr")
  fileName  = itemCode & "_" & itemRev & "." & oFile.FileExt
  sqlParams = Array(SQLEnc(itemCode), SQLEnc(itemRev), SQLEnc(itemDescr), SQLEnc(fileName), "'Diversen'", SQLEnc(oForm("FileFormat")), SQLEnc(Today()) )
  
  '*** Only proceed if we have a file (and thereby all other information).
  If (oFile.FileSize > 0) Then
    '*** Delete current revision (if exist).
    Call DBExecute(gDBConn, "DELETE FROM rc_item_hit WHERE item = " & sqlParams(0), False)
    
    '*** Delete current file (if exist).
    '***Deletes main doc,all attachments and src doc <obsolete by Andre>
    'Call FileDelete(PATH_RC & itemCode & "_*.*")
    '*** Delete only main document if exist
    SupTypes = Split(SUPPORTED_DOC_TYPE,";")
   
    For i=0 To UBound(SupTypes) 
        Call FileDelete(PATH_RC & itemCode & "_" & itemRev & "." & SupTypes(i))    
    Next
    
    '*** Try to save new file.
    If oFile.SaveAs(PATH_RC & fileName) Then
      '*** Insert new item.
      
      sql = SPrintf("INSERT INTO rc_item_hit (item, revision, description, file_name, file_type, file_format,file_date) VALUES ({0}, {1}, {2}, {3}, {4}, {5},{6})", sqlParams)
      
      '*** File uploaded and saved, so update database.
      Call DBExecute(gDBConn, sql, True)
    Else
      '*** Something went wrong!
      errMsg = "Bestand " & PATH_RC & fileName & " kan niet worden opgeslagen."
    End If
    
    '*** Redirect if no errors.
    If (errMsg = "") Then Call Response.Redirect("./qb/qb_finish.asp")
  End If
End If


Function SQLEnc(str)
  If IsNull(str) Then
    '*** Return empty string.
    SQLEnc = "''"
  Else
    '*** Replace quotes.
    SQLEnc = "'" & Replace(str, "'", "''") & "'"
  End If
End Function
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="./include/copyright.inc" -->
<html>

<head>
  <title>ChaloIS EDM : Artikel toevoegen</title>
  
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
    <form name="ItemForm" action="./item.asp" enctype="multipart/form-data" method="POST">
    <tr>
      <td nowrap>Artikelnummer</td>
      <td><input type="text" name="ItemCode" maxlength="15" value="<%= itemCode %>"></td>
    </tr>
    <tr>
      <td nowrap>Revisie</td>
      <td><input type="text" name="ItemRev" maxlength="5" style="width: 50px" onpaste="return false" onkeypress="return isNum(event)" value="<%= itemRev %>"></td>
    </tr>
    <tr>
      <td nowrap>Formaat</td>
      <td>
        <select name="FileFormat" style="width: 50px">
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
      <td nowrap>Bestand</td>
      <td>
        <div class="FileBrowse"><input type="file" class="FileBrowse" name="FileName" value="" onchange="setElementAttrib('FileDisplay', 'value', this.value)"></div>
        <input type="text" class="FileDisplay" id="FileDisplay" value="" readonly><input type="button" class="FileButton" value="..." onfocus="this.blur()">
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
      <button onclick="document.ItemForm.reset()">Wissen</button>
    </td>
    <td align="right" style="padding-top: 6px">
      <button onclick="window.close()">Annuleren</button>&nbsp;&nbsp;
      <button onclick="itemSubmit()">OK</button>
    </td>
  </tr>
</table>

</body>
<%
'*** Cleanup.
Call DBDisconnect(gDBConn)
%>
</html>