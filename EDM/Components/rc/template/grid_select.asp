<!-- #include file="./../common.asp"                   -->
<!-- #include file="./../include/db.asp"               -->
<!-- #include file="./../include/functions/system.asp" -->
<%
Dim rs, sql, gridId, gridSummary, group, orderBy, orderDir, visibleFields, fld
Dim rowActive, rowCount, rowFirst, rowLast, rowVisible
Dim headerClass, pageStart, pageEnd, i, hasPermission, hasDetails

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

'*** Check null
rowFirst=IIf(rowFirst<>"",rowFirst,0)
rowLast=IIf(rowLast<>"",rowLast,0)


'*** User allowed to release candidate?
hasPermission = (gLoggedIn And gUserRights = "1")

'*** Get query.
sql = GetSelectQuery(gReport, group, orderBy, orderDir, rowFirst, rowLast)


'*** Try to open recordset.
If RSOpen(rs, gDBConn, sql, False) Then
  Dim rowNum, cellType, cellWidth, filePath
  
  '*** Use generated query fields.
  visibleFields = Split(gReport.Item("SQL_Select"), ",")
  
  '*** Determine grid header class.
  If (gridId = "PGrid") Then headerClass = " class=""Scroll"""
  
  '*** Create grid summary string: First Row;Last Row;Active Row;Total Rows;Allow Expand;Order By;Order Direction (ASC | DESC);URL;Child URL.
  gridSummary = rowFirst & ";" & rowLast & ";" & rowActive & ";" & rowCount & ";false;" & group & ";" & orderBy & ";" & orderDir & ";./template/grid_select.asp;"
  
  '*** Detail info?
  hasDetails = (FieldExist(rs, "item") And FieldExist(rs, "revision"))
  
  '*** Calculate cell width (in %).
  cellWidth = CInt(100 / (UBound(visibleFields) + 1)) & "%"
  
  
%>
<table id="<%= gridId %>" cellspacing="0" cellpadding="0" class="Datagrid" summary="<%= gridSummary %>">
  <thead>
    <tr>
      <th <%= headerClass %> style="text-align: center" nowrap>#</th>
      <th <%= headerClass %> style="display: none" nowrap></th>      
      <% If Session("loggedIn")="TRUE" Then%>
      <th <%= headerClass %> style="text-align: center" nowrap></th>
      <% End If %>
      <th <%= headerClass %> style="text-align: center" nowrap></th>      
<%
	For i = 0 To UBound(visibleFields)
    '*** Get field.
    Set fld = rs.Fields(Trim(visibleFields(i)))
    
	  '*** Determine cell alignment by field type.
		cellType = IIf(GetFieldType(fld.Type) = adVarChar, "left", "right")
%>
      <th <%= headerClass %> style="text-align: <%= cellType %>; width: <%= cellWidth %>" onclick="grid_orderBy('<%= gridId %>','<%= fld.Name %>')" nowrap><%= GetFieldCaption(fld.Name) %></th>
<%
	Next
%>
    </tr>
  </thead>
  <tbody>
<%
  '*** Loop through rows and put in grid.
  While (Not rs.EOF)
    '*** Get row number.
    rowNum   = rs(0)
    filePath = PATH_RC & rs("file_subpath") & rs("file_name")
    
%>
    <tr id="<%= gridId & "_Row" & rowNum %>" onclick="row_select('<%= gridId %>', <%= rowNum %>)">
      <td class="TDRight" nowrap style="height: 30px"><%= EchoXHTML(rowNum, "&nbsp;") %></td>
      <td class="Hidden" id="DOCUMENT" nowrap style="height: 30px"><%= IIf(FileExists(filePath), filePath, "") %></td>           
      <td class="Hidden" id="DETAIL" nowrap style="height: 30px"><%= IIf(hasDetails, "template\details.asp?id=" & rs("item") & "&rev=" & rs("revision"), "") %></td>
      <% If Session("loggedIn")="TRUE" Then%>
      <td class="TDCenter" nowrap style="height: 30px"><img class="Link" src="./image/delete.gif" alt="Verwijderen" onclick="itemDelete('<%= rs("item") %>','<%= rs("revision") %>')"></td>
      <% End If %>
      <td class="TDCenter" nowrap style="height: 30px"><img class="Link" src="./image/add.gif" alt="Send Item" onclick="sendItem('<%= rs("item") %>','<%= rs("revision") %>','<%=rs("file_format") %>','<%= Replace(filePath,"\","@") %>')"></td>           
<%
   
    For i = 0 To UBound(visibleFields)
      '*** Get field.
      Set fld = rs.Fields(Trim(visibleFields(i)))
      
      '*** Set cell type.
      cellType = IIf(GetFieldType(fld.Type) = adVarChar, "TDLeft", "TDRight")
%>
      <td class="<%= cellType %>" nowrap style="height: 30px"><%= EchoXHTML(fld.Value, "&nbsp;") %></td>
<%
    Next
%>
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