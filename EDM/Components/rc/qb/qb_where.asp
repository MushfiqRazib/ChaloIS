<!-- #include file="../common.asp"     -->
<!-- #include file="../include/db.asp" -->
<%
Dim rs, fld, fldType, qbFrom, qbWhere, optionList, optionValue, i

'*** On submit save 'WHERE' clause.
If RequestBool("Submitted") Then
	gReport.Item("SQL_Where") = RequestStr("WhereClause", "")
End If

If (RequestStr("SrcSubmit", "") = "btnSelect") Then
  Call Response.Redirect("qb_select.asp")
ElseIf (RequestStr("SrcSubmit", "") = "btnGroupBy") Then
  Call Response.Redirect("qb_groupby.asp")
ElseIf (RequestStr("SrcSubmit", "") = "btnSql") Then
  'Call Response.Redirect("qb_sql.asp")
  Response.Write "Nog niet beschikbaar: qb_sql.asp"
  Response.End
ElseIf (RequestStr("SrcSubmit", "") = "btnExecute") Then
  '*** Return to parent window.
  Call Response.Redirect("qb_finish.asp")
End If

'*** Get session parameters.
qbFrom  = gReport.Item("SQL_From")
qbWhere = gReport.Item("SQL_Where")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="../include/copyright.inc" -->
<html>

<head>
  <title>Query Builder: Filter</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="../style/qbuilder.css">
  
  <script type="text/javascript" src="../script/common.js"></script>
  <script type="text/javascript" src="../script/sarissa.js"></script>
  <script type="text/javascript" src="../script/obrowser.js"></script>
  <script type="text/javascript" src="../script/qbuilder.js"></script>
  <script type="text/javascript">
  function selectField(fldProperties)
  {
    var fldName = fldProperties[0];
    var fldType = fldProperties[1];
    
    //*** Set field name.
    setElementAttrib("FieldName", "value", fldName);
    
    //*** Set field type.
    setElementAttrib("FieldType", "value", fldType);
    
    //*** Get a list of distinct values for selected field.
    getDistinctValues("<%= qbFrom %>", fldName, 50, "ValueList");
  }
  </script>
</head>

<body class="QBuilder">
<table width="100%">
	<form name="QueryBuilder" action="qb_where.asp" method="POST" onsubmit="return checkWhereClause()" ID="Form1">
	<tr><td width="100%"><img src="../image/filter_instellen_active.png"><input type="image" name="btnSelect" src="../image/velden_selecteren.png" onClick='setElementAttrib("SrcSubmit", "value", "btnSelect");' ID="Image1"><input type="image" name="btnGroupBy" src="../image/groeperen.png" onClick='setElementAttrib("SrcSubmit", "value", "btnGroupBy");' ID="Image2"><input type="image" name="btnSql" src="../image/sql_query.png" onClick='setElementAttrib("SrcSubmit", "value", "btnSql");' ID="Image3"></td></tr>
	    <!-- Local variables we want to submit -->
		<input type="hidden" name="FieldName"   value="">
		<input type="hidden" name="FieldType"   value="">
		<input type="hidden" name="Submitted"   value="1">
		<input type="hidden" name="WhereClause" value="<%= qbWhere %>">
		<input type="hidden" name="SrcSubmit"   value="">
	</form>
</table>

<fieldset style="height: 305px">
  <legend>Instellen Filter</legend>
  
  <table align="center" style="margin: 8px 0px" border="0">
    <tr>
      <th width="160">Veldnaam</th>
      <th>Vergelijking</th>
      <th width="160">Waarde</th>
      <th></th>
    </tr>
    <tr>
      <td height="27" style="padding-top: 3px">
        <select name="FieldDef" onchange="selectField(this.value.split(';'))">
<%
If RSEmpty(rs, gDBConn, qbFrom) Then
  '*** Loop through fields and get their name and type.
  For Each fld In rs.Fields
    fldType = GetFieldType(fld.Type)
    
    '*** Only add field if supported data type.
    If (fldType <> adEmpty) Then
%>          <option value="<%= fld.Name & ";" & fldType %>"><%= fld.Name %></option>
<%
    End If
  Next
  
  Call RSClose(rs)
End If
%>        </select>
      </td>
      <td align="center" style="padding-top: 3px">
        <select name="FieldComp" style="width: 60px">
          <option value="=" selected>=</option>
          <option value="&lt;&gt;">&lt;&gt;</option>
          <option value="&lt;">&lt;</option>
          <option value="&gt;">&gt;</option>
          <option value="&lt;=">&lt;=</option>
          <option value="&gt;=">&gt;=</option>
          <!--<option value="IN">IN</option>-->
          <option value="LIKE">LIKE</option>
        </select>
      </td>
      <td valign="top" style="padding-top: 4px">
        <input type="text" class="Combobox" name="FieldValue">
        <select class="Combobox" id="ValueList" onchange="setElementAttrib('FieldValue', 'value', this.value)">
          <option value="" selected></option>
        </select>
      </td>
      <td>
        <button onclick="addWhereClause()">Toevoegen</button>
      </td>
    </tr>
    <tr>
      <td colspan="3">
        <select name="WhereList" size="14" style="width: 395px">
<%
'*** Create fields array.
optionList = Split(ToString(qbWhere), "AND")

For i = LBound(optionList) To UBound(optionList)
  '*** Chunk of unneccessary characters.
  optionValue = Trim(optionList(i))
  
  If (Left(optionValue, 1) = "(") And (Right(optionValue, 1) = ")") Then
    '*** Remove brackets.
    optionValue = Mid(optionValue, 2, Len(optionValue) - 2)
  End If
%>          <option value="<%= optionValue %>"><%= optionValue %></option>
<%
Next
%>        </select>
      </td>
      <td valign="top">
        <button onclick="removeWhereClause()">Verwijderen</button>
      </td>
    </tr>
  </table>
</fieldset><br><br>

<table width="100%" ID="Table2">
  <tr>
    <td align="right" style="padding-top: 8px">
        <input type="button" class="Button" name="Execute" value="Uitvoeren" onclick='setElementAttrib("SrcSubmit", "value", "btnExecute"); document.QueryBuilder.submit();'>
    </td>
  </tr>
</table>

</body>
<%
'*** Cleanup.
Call DBDisconnect(gDBConn)
%>
</html>