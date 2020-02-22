<!-- #include file="./../common.asp"     -->
<!-- #include file="./../include/db.asp" -->
<%
Dim rs, sql, gridId, gridSummary, orderBy, orderDir, groupByField
Dim rowActive, rowCount, rowFirst, rowLast, rowVisible
Dim pageStart, pageEnd, i

'*** Get parameters.
gridId       = RequestStr("Id", "PGrid")
'expand       = RequestStr("Expand", "<NONE>")
groupByField = gReport.Item("SQL_GroupBy")
orderBy      = RequestStr("OrderBy", groupByField)
orderDir     = RequestStr("OrderDir", "ASC")
rowActive    = RequestInt("Row", 1)
rowCount     = GetGroupByCount(gDBConn, gReport)
rowVisible   = CLng(gReport.Item("MaxRows"))

If (rowActive < 1) Then
  '*** First row active.
  rowActive = 1
ElseIf (rowActive > rowCount) Then
  '*** Last row active.
  rowActive = rowCount
End If

'*** Now search page which contain active row.
For pageStart = 1 To rowCount Step rowVisible
  '*** Calculate end of page.
  pageEnd = (pageStart + rowVisible - 1)
  
  If (rowActive >= pageStart And rowActive <= pageEnd) Then
    '*** Active row within page range.
    rowFirst = pageStart
    rowLast  = IIf(pageEnd <= rowCount, pageEnd, rowCount)
        
    Exit For
  End If
Next

'*** Check null
rowFirst=IIf(rowFirst<>"",rowFirst,0)
rowLast=IIf(rowLast<>"",rowLast,0)

'*** Get query.
sql = GetGroupByQuery(gReport, orderBy, orderDir, rowFirst, rowLast)

'*** Try to open recordset.
If RSOpen(rs, gDBConn, sql, False) Then
  Dim cellType, cellWidth, rowNum, groupValue
  
  '*** Create grid summary string: First Row;Last Row;Active Row;Total Rows;Allow Expand;Order By;Order Direction (ASC | DESC);URL;Child URL.
  gridSummary = rowFirst & ";" & rowLast & ";" & rowActive & ";" & rowCount & ";true;;" & orderBy & ";" & orderDir & ";./template/grid_grouped.asp;./template/grid_select.asp"
  
  '*** Calculate cell width (in %).
  cellWidth = CInt(100 / (rs.Fields.Count - 1)) & "%"
%>
<table id="<%= gridId %>" cellspacing="0" cellpadding="0" class="Datagrid" summary="<%= gridSummary %>">
  <thead>
    <tr>
      <th class="Scroll" style="text-align: center" nowrap>#</th>
      <th class="Scroll" style="display: none" nowrap></th>
      <th class="Scroll" nowrap width="1"></th>
<%
  '*** Loop through fieldnames and put in grid.
  For i = 1 To (rs.Fields.Count - 1)
    '*** Set cell type.
    cellType = IIf(GetFieldType(rs(i).Type) = adVarChar, "left", "right")
%>
      <th class="Scroll" style="text-align: <%= cellType %>; width: <%= cellWidth %>" onclick="grid_orderBy('<%= gridId %>','<%= rs(i).Name %>')" nowrap><%= GetFieldCaption(rs(i).Name) %></th>
<%
  Next
%>
    </tr>
  </thead>
  <tbody>
<%
  '*** Loop through rows and put in grid.
  While (Not rs.EOF)
    '*** Get 'Group By' value.
    If IsNull(rs(groupByField)) Then
      groupValue = NULLSTRING
    Else
      groupValue = CStr(rs(groupByField))
    End If
    
    '*** Get row number.
    rowNum = rs(0)
%>
    <tr id="<%= gridId & "_Row" & rowNum %>" onclick="row_select('<%= gridId %>', <%= rowNum %>)">
      <td class="TDRight" nowrap><%= EchoXHTML(rowNum, "&nbsp;") %></td>
      <td class="Hidden" id="GROUP" nowrap><%= groupValue %></td>
      <td class="TDCenter"><img id="<%= gridId & "_Img" & rowNum %>" class="Link" src="./image/expand.gif" onclick="grid_childToggle('<%= gridId %>', <%= rowNum %>)"></td>
<%
    For i = 1 To (rs.Fields.Count - 1)
      '*** Set cell type.
      cellType = IIf(GetFieldType(rs(i).Type) = adVarChar, "TDLeft", "TDRight")
%>
      <td class="<%= cellType %>"><%= EchoXHTML(rs(i), "&nbsp;") %></td>
<%
    Next
%>
    </tr>
    <tr id="<%= gridId & "_Expansion" & rowNum %>"><td colspan="2"></td><td id="<%= "Container_CGrid" & rowNum %>" colspan="<%= rs.Fields.Count - 1 %>"></td></tr>
<%
    rs.MoveNext()
  Wend
%>
  </tbody>
</table>
<%
End If

'*** Cleanup.
Call RSClose(rs)
Call DBDisconnect(gDBConn)
%>