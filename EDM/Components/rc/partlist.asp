<!-- #include file="./common.asp"     -->
<!-- #include file="./include/db.asp" -->
<%
Dim rs, sql, itemId, itemRev, itemDescr

'*** Get parameters.
itemId  = RequestStr("id", "")
itemRev = RequestStr("rev", " ")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<!-- #include file="./include/copyright.inc" -->
<html>

<head>
  <title>VDL Jonckheere: Stuklijst</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="./style/obrowser.css">
  <link rel="Stylesheet" type="text/css" href="./style/datagrid.css">
  
  <style>
  TABLE.Datagrid { background-color: #FFFFFF }
  TABLE.Datagrid THEAD TH { border-right: 1px solid #FFFFFF; cursor: default }
  TD.TDLeft, TD.TDCenter, TD.TDRight { border-style: none; padding: 2px 5px }
  </style>
</head>

<body style="background-color: #FFFFFF; margin: 5px">

<table cellspacing="10" cellpadding="0" width="100%">
  <tr>
    <td nowrap><%= COMPANY_NAME %></td><td align="right" nowrap><%= FormatDateTime(Now(), 2) & " " & FormatDateTime(Now(), 4) %></td>
  </tr>
</table>
<%
'*** Try to open recordset.
If RSOpen(rs, gDBConn, "SELECT * FROM rc_item_hit WHERE item = " & SQLEnc(itemId) & " AND revision = " & SQLEnc(itemRev), True) Then
  '*** Get item info.
  itemDescr = rs("description")
End If
%>
<table cellspacing="10" cellpadding="0">
  <tr>
    <td nowrap>Artikel:</td><td nowrap><b><%= itemId %></b></td><td nowrap>Rev:</td><td nowrap><b><%= itemRev %></b></td><td nowrap>Type:</td><td nowrap><b>ENG</b></td>
  </tr>
  <tr>
    <td nowrap>&nbsp;</td><td nowrap><b><%= itemDescr %></b>&nbsp;</td><td colspan="4">&nbsp;</td>
  </tr>
</table>

<table cellspacing="0" cellpadding="0" class="Datagrid">
  <thead>
    <tr>
      <th style="text-align: right"  nowrap><b>Pos</b></th>
      <th style="text-align: left"   nowrap><b>Component</b></th>
      <th style="text-align: left; width: 70%" nowrap><b>Omschrijving</b></th>
      <th style="text-align: right"  nowrap><b>Verbruik</b></th>
      <th style="text-align: center" nowrap><b>M</b></th>
      <th style="text-align: center" nowrap><b>Ph</b></th>
      <th style="text-align: right"  nowrap><b>Aantal</b></th>
      <th style="text-align: right"  nowrap><b>Lengte</b></th>
      <th style="text-align: right"  nowrap><b>Breedte</b></th>
      <th style="text-align: left; width: 30%" nowrap><b>Zaaghoeken</b></th>
    </tr>
  </thead>
  <tbody>
<%
sql = "SELECT * FROM rc_bom WHERE item = " & SQLEnc(itemId) & " AND revision = " & SQLEnc(itemRev)

'*** Try to open recordset.
If RSOpen(rs, gDBConn, sql, True) Then
  '*** Loop through rows.
  While (Not rs.EOF)
%>
    <tr>
      <td class="TDRight" nowrap><%= EchoXHTML(rs("pos_nr"), "&nbsp;") %></td>
      <td class="TDLeft" nowrap><%= EchoXHTML(rs("comp_item"), "&nbsp;") %></td>
      <td class="TDLeft" nowrap><%= EchoXHTML(rs("description"), "&nbsp;") %></td>
      <td class="TDRight" nowrap><%= EchoNumber(rs("comp_qty"), 4, ",") %></td>
      <td class="TDCenter" nowrap>&nbsp;</td>
      <td class="TDCenter" nowrap>&nbsp;</td>
      <td class="TDRight" nowrap><%= EchoXHTML(rs("ref_qty"), "&nbsp;") %></td>
      <td class="TDRight" nowrap><%= EchoXHTML(rs("length"), "&nbsp;") %></td>
      <td class="TDRight" nowrap><%= EchoXHTML(rs("width"), "&nbsp;") %></td>
      <td class="TDLeft" nowrap><%= EchoXHTML(rs("ref_description"), "&nbsp;") %></td>
    </tr>
<%
    rs.MoveNext()
  Wend
End If

'*** Cleanup.
Call RSClose(rs)
Call DBDisconnect(gDBConn)
%>
  </tbody>
</table>

</body>

</html>