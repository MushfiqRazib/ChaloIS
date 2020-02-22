<!-- #include file="../common.asp"     -->
<!-- #include file="../include/db.asp" -->
<%
Dim rs, fld, fldType, qbFrom, qbGroupBy, qbGBSelect, optionList, i

If RequestBool("Submitted") Then
  '*** On submit save 'GROUP BY' clause.
  gReport.Item("SQL_GroupBy") = RequestStr("GroupBy", "")
  gReport.Item("SQL_GroupBySelect") = RequestStr("GBSelectClause", "")
End If

If (RequestStr("SrcSubmit", "") = "btnSelect") Then
  Call Response.Redirect("qb_select.asp")
ElseIf (RequestStr("SrcSubmit", "") = "btnWhere") Then
  Call Response.Redirect("qb_where.asp")
ElseIf (RequestStr("SrcSubmit", "") = "btnSql") Then
  'Call Response.Redirect("qb_sql.asp")
  Response.Write "Nog niet beschikbaar: qb_sql.asp"
  Response.End
ElseIf (RequestStr("SrcSubmit", "") = "btnExecute") Then
  '*** Return to parent window.
  Call Response.Redirect("qb_finish.asp")
End If

'*** Get session parameters.
qbFrom     = gReport.Item("SQL_From")
qbGroupBy  = gReport.Item("SQL_GroupBy")
qbGBSelect = gReport.Item("SQL_GroupBySelect")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="../include/copyright.inc" -->
<html>

<head>
  <title>Query Builder: Groeperen</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="../style/qbuilder.css">
  
  <script type="text/javascript" src="../script/common.js"></script>
  <script type="text/javascript" src="../script/sarissa.js"></script>
  <script type="text/javascript" src="../script/qbuilder.js"></script>
  <script type="text/javascript" src="../script/obrowser.js"></script>
</head>

<body class="QBuilder" onload="selectGroupingField(FieldAction)">
<table width="100%" ID="Table1">
	<form name="QueryBuilder" action="qb_groupby.asp" method="POST" onsubmit="return checkGBSelectClause()">
	<tr><td width="100%"><input type="image" name="btnWhere" src="../image/filter_instellen.png" onClick='setElementAttrib("SrcSubmit", "value", "btnWhere");'><input type="image" name="btnSelect" src="../image/velden_selecteren.png" onClick='setElementAttrib("SrcSubmit", "value", "btnSelect");'><img src="../image/groeperen_active.png"><input type="image" name="btnSql" src="../image/sql_query.png" onClick='setElementAttrib("SrcSubmit", "value", "btnSql");' ID="Image3"></td></tr>
	    <!-- Local variables we want to submit -->
        <input type="hidden" name="Submitted"      value="1" ID="Hidden1">
        <input type="hidden" name="GroupBy"        value="<%= qbGroupBy  %>" ID="Hidden2">
        <input type="hidden" name="GroupingField"  value="" ID="Hidden3">
        <input type="hidden" name="GBSelectClause" value="<%= qbGBSelect %>" ID="Hidden4">
		<input type="hidden" name="SrcSubmit"   value="" ID="Hidden5">
	</form>
</table>

<fieldset>
  <legend>Groeperen</legend>
  
  <table style="margin: 8px 0px">
    <tr>
      <td width="110"><b>Groeperen op veld:</b></td>
      <td>
        <select onchange="setElementAttrib('GroupBy','value',this.value)">
          <option value=""></option>
<%
'*** Create fields array.
optionList = ColumnsAsArray(gDBConn, qbFrom)

For i = LBound(optionList) To UBound(optionList)
%>          <option value="<%= optionList(i) %>"<%= EchoSelected(optionList(i) = qbGroupBy) %>><%= optionList(i) %></option>
<%
Next
%>        </select>
      </td>
    </tr>
  </table>
</fieldset>
<br />
<fieldset>
  <legend>Groeptotalen</legend>
  
  <table style="margin: 8px 0px">
    <tr>
      <td align="left"><b>Totaliserings type</b></td>
      <td align="left"><b>Veldnaam</b></td>
      <td align="left"><b>Weergeven als</b></td>
      <td></td>
    </tr>
    <tr>
      <td align="left">
        <select id="GroupingType" style="width: 120px;"><option value="" selected></option></select>
      </td>
      <td align="left">
        <select name="FieldAction" id="FieldAction" onchange="selectGroupingField(FieldAction)" style="width: 120px;">
<%
If RSEmpty(rs, gDBConn, qbFrom) Then
  '*** Loop through fields and get their name and type.
  For Each fld In rs.Fields
    fldType = GetFieldType(fld.Type)
    
    '*** Only add field if supported data type.
    If (fldType <> adEmpty) Then
%>          <option value="<%= fldType & ";" & fld.Name %>"><%= fld.Name %></option>
<%
    End If
  Next
  
  Call RSClose(rs)
End If
%>        </select>
      </td>
      <td align="left"><input type="text" name="FieldAs" id="FieldAs" style="width: 147px;" onkeypress="return isValidField(event);" onpaste="return false;"></td>
      <td>
        <button onclick="addGrouping()">Toevoegen</button>
      </td>
      
    </tr>
    <tr>
      <td colspan="3" width="300px">
        <select name="GroupList" size="9" style="width: 395px">
<%
'*** Create fields array.
optionList = Split(qbGBSelect, ",")

For i = LBound(optionList) To UBound(optionList)
%>          <option value="<%= optionList(i) %>"><%= optionList(i) %></option>
<%
Next
%>
      </select>
      </td>
      <td valign="top">
        <button onclick="removeGrouping()">Verwijderen</button>
      </td>
    </tr>
  </table>
</fieldset><br><br>

<table width="100%">
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
