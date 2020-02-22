
<%

Dim gDBConn

Const adNumeric          = 131
Const adBoolean          = 11
Const adVarChar          = 200
Const adEmpty            = 0
Const adStateOpen        = &H00000001
Const adModeReadWrite    = 3
Const adUseServer        = 2
Const adLockReadOnly     = 1



'*******************************************************************************
'*** Create Database Connection
'*******************************************************************************
If Not DBConnect(gDBConn, DB_CONNSTRING, adModeReadWrite) Then Call ErrorMessage(ERR_NODBCONNECT)

Dim DATABASE_IMPLEMENTATION_TYPE
DATABASE_IMPLEMENTATION_TYPE = "POSTGIS"


'*******************************************************************************
'*** Connection functions
'*******************************************************************************
Function DBConnect(conn, connectionString, connectMode)
  '*** Delete Connection object in case already created.
  Call DBDisconnect(conn)
  
  '*** Create connection object.
  Set conn = Server.CreateObject("ADODB.Connection")
  
  With conn
    .ConnectionString = connectionString
    .Mode             = connectMode
	.ConnectionTimeout= 10
	On Error Resume Next
    .Open()
    If Err.number <> 0 Then
		'*** Some basic error handlign
		Dim message
		message = "<table><tr><th colspan='2'>Error creating connection:</th></tr>"
		'message = message & "<tr><td>Error source:</td><td>" & err.Source & "</td></tr>"
		'message = message & "<tr><td>Error number:</td><td>" & err.number & "</td></tr>"
		message = message & "<tr><td>Error description:</td><td>" & err.Description & "</td></tr>"
		'NO WAY JOSE! => message = message & "<tr><td>Connection:</td><td>" & conn.ConnectionString & "</td></tr>"
		message = message & "</table></body></html>"
		Call Response.Write(message)		
		Response.End  
    End If
    On Error Goto 0
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
	On Error Resume Next
  '*** Executes the specified query, SQL statement, stored procedure, or provider-specific text.
  conn.Execute(commandText)
    If Err.number <> 0 Then
		'*** Some basic error handlign
		Dim message
		message = "<table><tr><th colspan='2'>Error executing command:</th></tr>"
		'message = message & "<tr><td>Error source:</td><td>" & err.Source & "</td></tr>"
		'message = message & "<tr><td>Error number:</td><td>" & err.number & "</td></tr>"
		message = message & "<tr><td>Error description:</td><td>" & err.Description & "</td></tr>"
		'NO WAY JOSE! => message = message & "<tr><td>Connection:</td><td>" & conn.ConnectionString & "</td></tr>"
		message = message & "<tr><td>Sql:</td><td>" & commandText & "</td></tr>"
		message = message & "</table></body></html>"
		Call Response.Write(message)		
		Response.End  
    End If
    On Error Goto 0
  
  '*** Commit?
  If autoCommit Then conn.Execute("COMMIT")
End Sub


'*******************************************************************************
'*** Recordset functions.
'*******************************************************************************


'##### Fetches no result, but only emty recordset, containing columns F.E. to determine datatype
Function RSEmpty(rs, conn, table_name)
  '*** Delete Recordset object in case already created.
  Call RSClose(rs)
  
  '*** Create Recordset object.
  Set rs = Server.CreateObject("ADODB.Recordset")	

  If RSOpen(rs, gDBConn, "SELECT * FROM " & table_name & " WHERE 0 = 1", False) Then
	RSEmpty = True
  Else
	RSEmpty = False
  End If
End Function

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
  
  'Response.Write source
  
  '*** Create Recordset object.
  Set rs = Server.CreateObject("ADODB.Recordset")
  
  '*** Set Recordset properties.
  With rs
    .ActiveConnection = activeConnection
    .Source           = source
    .CursorType       = adOpenForwardOnly
    .CursorLocation   = adUseServer
    .LockType         = adLockReadOnly
	On Error Resume Next
    .Open()
    If Err.number <> 0 Then
		'*** Some basic error handlign
		Dim message
		message = "<table><tr><th colspan='2'>Error executing the query:</th></tr>"
		'message = message & "<tr><td>Error source:</td><td>" & err.Source & "</td></tr>"
		'message = message & "<tr><td>Error number:</td><td>" & err.number & "</td></tr>"
		message = message & "<tr><td>Error description:</td><td>" & err.Description & "</td></tr>"
		'NO WAY JOSE! => message = message & "<tr><td>Connection:</td><td>" & activeConnection.ConnectionString & "</td></tr>"
		message = message & "<tr><td>Sql:</td><td>" & source & "</td></tr></table></body></html>"
		Call Response.Write(message)		
		Response.End  
    End If
    On Error Goto 0
  End With
  
  If (rs.State = adStateOpen) Then
    '*** Recordset open, check for results (records) if specified.
    RSOpen = IIf(resultCheck, (Not rs.BOF And Not rs.EOF), True)
  Else
    '*** Recordset not open!
    RSOpen = False
  End If
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


Function TableFields(conn, table_name)
  Dim rs, flds(), max_index, i
  
  '*** Clear list.
  If RSOpen(rs, conn, "SELECT * FROM " & table_name & " WHERE 1 = 0", False) Then
    '*** Get upper index bound.
    max_index = (rs.Fields.Count - 1)
    
    '*** Initialize array.
    ReDim flds(max_index)
    
    '*** Loop through fields.
    For i = 0 To max_index
      '*** Add field name to list.
      flds(i) = rs.Fields(i).Name
    Next
  End If
  
  '*** Cleanup.
  Call RSClose(rs)
  
  '*** Return list.
  TableFields = flds
End Function


Function GetFieldType(fldType)
  '*** Narrow down field types.
  Select Case fldType
    Case 2, 3, 4, 5, 6, 14, 16, 17, 18, 19, 20, 21, 64, 131, 133, 134, 135, 137, 139
      '*** Numeric type.
      GetFieldType = adNumeric
    
    Case 11
      '*** Boolean type.
      GetFieldType = adBoolean
    
    Case 8, 72, 129, 130, 200, 201, 202, 203
      '*** String type.
      GetFieldType = adVarChar
    
    Case Else
      '*** Unknown/unsupported type.
      GetFieldType = adEmpty
  End Select
End Function


%>