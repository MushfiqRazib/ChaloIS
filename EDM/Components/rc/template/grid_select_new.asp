<!-- #include file="./../common.asp"     -->
<!-- #include file="./../include/db.asp" -->
<%
Dim rs, sql, gridId, gridSummary, group, orderBy, orderDir
Dim rowActive, rowCount, rowFirst, rowLast, rowVisible
Dim headerClass, pageStart, pageEnd, i

'*** Get parameters.
gridId     = RequestStr("Id", "CGrid")
group      = RequestStr("Group", "")
orderBy    = RequestStr("OrderBy", gReport.Item("SQL_OrderBy"))
orderDir   = RequestStr("OrderDir", "ASC")
rowActive  = RequestInt("Row", 1)
rowCount   = GetSelectCount(gDBConn, gReport, group)
rowFirst   = 0
rowLast    = 0
rowVisible = CLng(gReport.Item("MaxRows"))

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

'*** Get query.
sql = GetSelectQuery(gReport, group, orderBy, orderDir, rowFirst, rowLast)

'*** Try to open recordset.
If RSOpen(rs, gDBConn, sql, False) Then
  Dim rowNum
  
  '*** Determine grid header class.
  If (gridId = "PGrid") Then headerClass = " class=""Scroll"""
  
  '*** Create grid summary string: First Row;Last Row;Active Row;Total Rows;Allow Expand;Order By;Order Direction (ASC | DESC);URL;Child URL.
  gridSummary = rowFirst & ";" & rowLast & ";" & rowActive & ";" & rowCount & ";false;" & group & ";" & orderBy & ";" & orderDir & ";./template/grid_select.asp;"
%>
<table id="<%= gridId %>" cellspacing="0" cellpadding="0" class="ScrollTable" summary="<%= gridSummary %>" width="100%">
  <thead class="FixedHeader">
    <tr>
      <th style="text-align: center" nowrap>#</th>
      <th onclick="grid_orderBy('<%= gridId %>','ITEM_CODE')" nowrap><%= GetFieldCaption("ITEM_CODE") %></th>
      <th onclick="grid_orderBy('<%= gridId %>','ITEM_REV')" nowrap><%= GetFieldCaption("ITEM_REV") %></th>
    <!--
      <th<%= headerClass %> style="text-align: center" nowrap>#</th>
      <th<%= headerClass %> style="display: none" nowrap></th>
      <th<%= headerClass %> style="display: none" nowrap></th>
      <th<%= headerClass %> width="10%"  onclick="grid_orderBy('<%= gridId %>','ITEM_CODE')" nowrap><%= GetFieldCaption("ITEM_CODE") %></th>
      <th<%= headerClass %> width="10%"  onclick="grid_orderBy('<%= gridId %>','ITEM_REV')" nowrap><%= GetFieldCaption("ITEM_REV") %></th>
      <th<%= headerClass %> width="50%"  onclick="grid_orderBy('<%= gridId %>','ITEM_DESCR')" nowrap><%= GetFieldCaption("ITEM_DESCR") %></th>
      <th<%= headerClass %> width="10%" onclick="grid_orderBy('<%= gridId %>','FILE_PATH')" nowrap><%= GetFieldCaption("FILE_PATH") %></th>
      <th<%= headerClass %> width="10%" onclick="grid_orderBy('<%= gridId %>','FILE_NAME')" nowrap><%= GetFieldCaption("FILE_NAME") %></th>
      <th<%= headerClass %> width="10%" onclick="grid_orderBy('<%= gridId %>','FILE_TYPE')" nowrap><%= GetFieldCaption("FILE_TYPE") %></th>
    </tr>
    -->
  </thead>
  <tbody class="ScrollContent">
<%
  '*** Loop through rows and put in grid.
  While (Not rs.EOF)
    '*** Get row number.
    rowNum = rs(0)
%>
    <tr id="<%= gridId & "_Row" & rowNum %>" onclick="row_select('<%= gridId %>', <%= rowNum %>)">
      <td><%= EchoXHTML(rowNum, "&nbsp;") %></td>
      <td><%= EchoXHTML(rs("ITEM_CODE"), "&nbsp;") %></td>
      <td><%= EchoXHTML(rs("ITEM_REV"), "&nbsp;") %></td>
    <!--
      <td class="TDRight" nowrap><%= EchoXHTML(rowNum, "&nbsp;") %></td>
      <td class="Hidden" id="DOCUMENT" nowrap><%= PATH_RC & rs("FILE_PATH") & rs("FILE_NAME") %></td>
      <td class="Hidden" id="DETAIL" nowrap></td>
      <td class="TDLeft" nowrap><%= EchoXHTML(rs("ITEM_CODE"), "&nbsp;") %></td>
      <td class="TDLeft" nowrap><%= EchoXHTML(rs("ITEM_REV"), "&nbsp;") %></td>
      <td class="TDLeft" nowrap><%= EchoXHTML(rs("ITEM_DESCR"), "&nbsp;") %></td>
      <td class="TDLeft" nowrap><%= EchoXHTML(rs("FILE_PATH"), "&nbsp;") %></td>
      <td class="TDLeft" nowrap><%= EchoXHTML(rs("FILE_NAME"), "&nbsp;") %></td>
      <td class="TDLeft" nowrap><%= EchoXHTML(rs("FILE_TYPE"), "&nbsp;") %></td>
    -->
    </tr>
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