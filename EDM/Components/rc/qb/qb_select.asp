<!-- #include file="../common.asp"     -->
<!-- #include file="../include/db.asp" -->
<%
Dim qbSelect, qbFrom, fldAvailable, fldSelected, i

'*** On submit save selected fields into session.
If RequestBool("Submitted") Then
	gReport.Item("SQL_Select") = RequestStr("SelectClause", "")
End If

If (RequestStr("SrcSubmit", "") = "btnGroupBy") Then
  Call Response.Redirect("qb_groupby.asp")
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
qbSelect = gReport.Item("SQL_Select")
qbFrom   = gReport.Item("SQL_From")


'*** Create 'Available Fields' array.
fldAvailable = ColumnsAsArray(gDBConn, qbFrom)

'*** Create 'Selected Fields' array.
fldSelected = Split(ToString(qbSelect), ",")

'*** Cleanup.
Call DBDisconnect(gDBConn)
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="../include/copyright.inc" -->
<html>

<head>
  <title>Query Builder: Veldselectie</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="../style/qbuilder.css">
  
  <script type="text/javascript" src="../script/common.js"></script>
  <script type="text/javascript" src="../script/obrowser.js"></script>
</head>

<body class="QBuilder">
<table width="100%" ID="Table1">
	<form name="QueryBuilder" action="qb_select.asp" method="POST" onsubmit="return checkSelectClause()">
	<tr><td width="100%"><input type="image" src="../image/filter_instellen.png" onClick='setElementAttrib("SrcSubmit", "value", "btnWhere");'><img src="../image/velden_selecteren_active.png"><input type="image" name="btnGroupBy" src="../image/groeperen.png" onClick='setElementAttrib("SrcSubmit", "value", "btnGroupBy");' ID="Image2"><input type="image" name="btnSql" src="../image/sql_query.png" onClick='setElementAttrib("SrcSubmit", "value", "btnSql");' ID="Image3"></td></tr>
	    <!-- Local variables we want to submit -->
		<input type="hidden" name="Submitted"   value="1" ID="Hidden3">
		<input type="hidden" name="SelectClause" value="<%= qbSelect %>" ID="Hidden4">
		<input type="hidden" name="SrcSubmit"   value="" ID="Hidden5">
	</form>
</table>
<fieldset style="height: 305px">
  <legend>Selecteer zichtbare velden</legend>
  
  <table align="center" style="margin: 8px 0px">
    <tr>
      <th>Beschikbare velden</th>
      <th></th>
      <th>Geselecteerde velden</th>
      <th></th>
    </tr>
    <tr>
      <td>
        <select name="Fields_A" size="15">
<%
For i = LBound(fldAvailable) To UBound(fldAvailable)
  '*** Only add field to Available Fields' if it's not selected.
  If Not InArray(fldSelected, fldAvailable(i)) Then
%>          <option value="<%= fldAvailable(i) %>"><%= fldAvailable(i) %></option>
<%
  End If
Next
%>        </select>
      </td>
      <td style="padding: 0px 20px" valign="middle">
        <button style="width: 30px" onclick="optionMove('Fields_A','Fields_V')">&gt;</button><br />
        <button style="width: 30px" onclick="optionMoveAll('Fields_A','Fields_V')">&gt;&gt;</button><br />
        <button style="width: 30px" onclick="optionMoveAll('Fields_V','Fields_A')">&lt;&lt;</button><br />
        <button style="width: 30px" onclick="optionMove('Fields_V','Fields_A')">&lt;</button>
      </td>
      <td>
        <select name="Fields_V" size="15">
<%
For i = LBound(fldSelected) To UBound(fldSelected)
%>          <option value="<%= fldSelected(i) %>"><%= fldSelected(i) %></option>
<%
Next
%>        </select>
      </td>
      <td valign="middle" width="100" align="center">
        <button onclick="optionSwap('Fields_V',-1)">Omhoog</button><br />
        <button onclick="optionSwap('Fields_V',1)">Omlaag</button>
      </td>
    </tr>
  </table>
</fieldset>

<table width="100%">
  <tr>
    <td align="right" style="padding-top: 8px">
      <br><input type="button" class="Button" name="Execute" value="Uitvoeren" onclick='setElementAttrib("SrcSubmit", "value", "btnExecute"); document.QueryBuilder.submit();' ID="Button1">
    </td>
  </tr>
</table>

</body>

</html>