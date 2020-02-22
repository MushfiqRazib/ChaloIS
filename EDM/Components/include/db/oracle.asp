<!-- #include file="./adodb.inc" -->
<%
'*******************************************************************************
'***                                                                         ***
'*** File       : oracle.asp                                                 ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 21-02-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Oracle Database Functions                                  ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** Database engine specific definitions.
'*******************************************************************************
Const DB_WILDCARD = "%"


'*******************************************************************************
'*** Connection functions
'*******************************************************************************
Function DBConnect(conn, connectString, connectMode)
  '*** Delete Connection object in case already created.
  Call DBDisconnect(conn)
  
  '*** Create connection object.
  Set conn = Server.CreateObject("ADODB.Connection")
  
  With conn
    .ConnectionString = connectString
    .Mode             = connectMode
    .Open()
  End With
  
  '*** Return connection object.
  DBConnect = (conn.State = adStateOpen)
End Function


Sub DBDisconnect(conn)
  '*** Only close connection if it was previously opened.
  If IsObject(conn) Then
    If (conn.State = adStateOpen) Then conn.Close()
    
    Set conn = Nothing
  End If
End Sub


Sub DBExecute(conn, commandText, autoCommit)
  '*** Executes the specified query, SQL statement, stored procedure, or provider-specific text.
  conn.Execute(commandText)
  
  '*** Commit?
  If autoCommit Then conn.Execute("COMMIT")
End Sub


'*******************************************************************************
'*** Recordset functions.
'*******************************************************************************
Sub RSClose(rs)
  '*** Only clean up object if it was previously created.
  If IsObject(rs) Then
    '*** Only close recordset if it was previously opened.
    If (rs.State = adStateOpen) Then rs.Close()
    
    Set rs = Nothing
  End If
End Sub


Function RSOpen(rs, activeConnection, source, resultCheck)
  '*** Delete Recordset object in case already created.
  Call RSClose(rs)
  
  '*** Create Recordset object.
  Set rs = Server.CreateObject("ADODB.Recordset")
  
  On Error Resume Next
  
  '*** Set Recordset properties.
  With rs
    .ActiveConnection = activeConnection
    .Source           = source
    .CursorType       = adOpenStatic
    .CursorLocation   = adUseServer
    .LockType         = adLockReadOnly
    .Open()
  End With
  
  If (Err.Number <> 0) Then
    '*** Write error to screen.
    Call Response.Write(Err.Description & "<br /><br /><u><b>Query</b></u><br />" & source)
    Call Response.End()
  End If
  
  If (rs.State = adStateOpen) Then
    '*** Recordset open, check for results (records) if specified.
    RSOpen = IIf(resultCheck, (Not rs.BOF And Not rs.EOF), True)
  Else
    '*** Recordset not open!
    RSOpen = False
  End If
End Function

'##### Fetches no result, but only emty recordset, containing columns F.E. to determine datatype
Function RSEmpty(rs, conn, table_name)
  '*** Delete Recordset object in case already created.
  Call RSClose(rs)
  
  '*** Create Recordset object.
  Set rs = Server.CreateObject("ADODB.Recordset")	

  If RSOpen(rs, gDBConn, "SELECT * FROM " & table_name & " WHERE rownum < 0", False) Then
	RSEmpty = True
  Else
	RSEmpty = False
  End If
End Function


Function SQLDec(str)
  Dim decodedStr
  
  '*** Convert NULL value.]
  decodedStr = IIf(IsNull(str), "", str)
  
  If (decodedStr <> "") Then
    If (Left(decodedStr, 1) = "'" And Right(decodedStr, 1) = "'") Then
      '*** Remove single quotes.
      decodedStr = Mid(decodedStr, 2, Len(decodedStr) - 2)
    End If
    
    '*** Remove SQL encoding.
    decodedStr = Replace(decodedStr, "''", "'")
  End If
  
  SQLDec = decodedStr
End Function


Function SQLEnc(str)
  If IsNull(str) Then
    '*** Return empty string.
    SQLEnc = "''"
  Else
    '*** Replace quotes.
    SQLEnc = "'" & Replace(str, "'", "''") & "'"
  End If
End Function


'*******************************************************************************
'*** Table Related functions.
'*******************************************************************************
Function TableColumns(conn, table_name, delimiter)
  Dim rs, cols
  
  '*** Clear list.
  cols = ""
  
  If RSOpen(rs, conn, "SELECT column_name FROM all_tab_columns WHERE table_name = " & SQLEnc(UCase(table_name)), False) Then
    '*** Loop through records.
    While (Not rs.EOF)
      '*** Add column name to list
      cols = cols & delimiter & rs("column_name")
      
      rs.MoveNext()
    Wend
    
    '*** Cut of first delimiter.
    If (cols <> "") Then cols = Right(cols, Len(cols) - 1)
  End If
  
  '*** Cleanup.
  Call RSClose(rs)
  
  '*** Return list.
  TableColumns = cols
End Function



'*******************************************************************************
'*** Query/SQL functions.
'*******************************************************************************
Function GetGroupByCount(conn, params)
  Dim rs, sql
  
  '*** Standard 'SELECT' part.
  sql = "SELECT " & params.Item("SQL_GroupBy") & " FROM " & params.Item("SQL_From")
  
  '*** 'WHERE' part (if specified).
  If (params.Item("SQL_Where") <> "") Then sql = sql & " WHERE " & params.Item("SQL_Where")
  
  '*** 'GROUP BY' part.
  sql = sql & " GROUP BY " & params.Item("SQL_GroupBy")
  
  '*** 'COUNT' part.
  sql = "SELECT COUNT(*) FROM (" & sql & ")"
  
  '*** Execute query.
  If RSOpen(rs, conn, sql, False) Then
    '*** Return number of rows.
    GetGroupByCount = CLng(rs(0))
  Else
    '*** Something went wrong?!?
    GetGroupByCount = 0
  End If
  
  '*** Cleanup.
  Call RSClose(rs)
End Function


Function GetGroupByQuery(params, order_by, order_dir, row_first, row_last)
  Dim sql
  
  '*** Standard 'SELECT' part.
  sql = "SELECT row_number() OVER (ORDER BY " & order_by & " " & order_dir & ") R, " & params.Item("SQL_GroupBy")
  
  '*** Custom 'SELECT' part.
  If (params.Item("SQL_GroupBySelect") <> "") Then sql = sql & ", " & params.Item("SQL_GroupBySelect")
  
  '*** 'FROM' part.
  sql = sql & " FROM " & params.Item("SQL_From")
  
  '*** 'WHERE' part (if specified).
  If (params.Item("SQL_Where") <> "") Then sql = sql & " WHERE " & params.Item("SQL_Where")
  
  '*** 'GROUP BY' part.
  sql = sql & " GROUP BY " & params.Item("SQL_GroupBy")
  
  '*** Now limit results.
  sql = "SELECT * FROM (" & sql & ") WHERE R BETWEEN " & row_first & " AND " & row_last
  
  '*** Return query.
  GetGroupByQuery = sql
End Function


Function GetSelectCount(conn, params, group)
  Dim rs, sql, sqlWhere
  
  sqlWhere = params.Item("SQL_Where")
  
  '*** Is this a group?
  If (params.Item("SQL_GroupBy") <> "NONE") Then
    '*** Add group condition to WHERE clause.
    sqlWhere = sqlWhere & IIf(sqlWhere <> "", " AND ", "") & "(" & params.Item("SQL_GroupBy") & " = " & SQLEnc(group) & ")"
  End If
  
  '*** Standard count part.
  sql = "SELECT COUNT(*) FROM " & params.Item("SQL_From")
  
  '*** Add 'WHERE' part (if specified).
  If (sqlWhere <> "") Then sql = sql & " WHERE " & sqlWhere
  
  '*** Execute query.
  If RSOpen(rs, conn, sql, False) Then
    '*** Return number of rows.
    GetSelectCount = CLng(rs(0))
  Else
    '*** Something went wrong?!?
    GetSelectCount = 0
  End If
  
  '*** Cleanup.
  Call RSClose(rs)
End Function


Function GetSelectQuery(params, group, order_by, order_dir, row_first, row_last)
  Dim innerSQL, rownumSQL, limitSQL, sqlWhere
  
  sqlWhere = params.Item("SQL_Where")
  
  '*** Is this a group?
  If (params.Item("SQL_GroupBy") <> "NONE") Then
    '*** Add group condition to WHERE clause.
    sqlWhere = sqlWhere & IIf(sqlWhere <> "", " AND ", "") & "(" & params.Item("SQL_GroupBy") & " = " & SQLEnc(group) & ")"
  End If
  
  '*** 'SELECT' part.
  innerSQL = "SELECT " & IIf(params.Item("SQL_Select") <> "", params.Item("SQL_Select"), "*")
  
  '*** GIS fields specified?
  If (params.Item("SQL_GISSelect") <> "") Then innerSQL = innerSQL & ", " & params.Item("SQL_GISSelect")
  
  '*** 'FROM' part.
  innerSQL = innerSQL & " FROM " & params.Item("SQL_From")
  
  '*** Add 'WHERE' part (if specified).
  If (sqlWhere <> "") Then innerSQL = innerSQL & " WHERE " & sqlWhere
  
  '*** Add row numbering and ordering.
  rownumSQL = "SELECT row_number() OVER (ORDER BY " & order_by & " " & order_dir & ") R, A.* FROM (" & innerSQL & ") A"
  
  '*** Limit SQL.
  limitSQL = "SELECT * FROM (" & rownumSQL & ") WHERE R BETWEEN " & row_first & " AND " & row_last
  
  '*** Return query.
  GetSelectQuery = limitSQL
End Function
%>