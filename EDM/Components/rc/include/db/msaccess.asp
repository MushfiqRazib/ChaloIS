<%
'*******************************************************************************
'***                                                                         ***
'*** File       : msaccess.asp                                               ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 21-02-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: MSAccess Database Functions                                ***
'***                                                                         ***
'*******************************************************************************


'*******************************************************************************
'*** Connection functions
'*******************************************************************************
Function DBConnect(conn, connect_str, connect_mode)
  '*** Delete Connection object in case already created.
  Call DBDisconnect(conn)
  
  '*** Create connection object.
  Set conn = Server.CreateObject("ADODB.Connection")
  
  With conn
    .ConnectionString = connect_str
    .Mode             = connect_mode
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


Sub DBExecute(conn, command_text, auto_commit)
  '*** Executes the specified query, SQL statement, stored procedure, or provider-specific text.
  conn.Execute(command_text)
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


Function RSOpen(rs, active_connection, source, check_results)
  '*** Delete Recordset object in case already created.
  Call RSClose(rs)
  
  '*** Create Recordset object.
  Set rs = Server.CreateObject("ADODB.Recordset")
  
  '*** Set Recordset properties.
  With rs
    .ActiveConnection = active_connection
    .Source           = source
    .CursorType       = adOpenForwardOnly
    .CursorLocation   = adUseServer
    .LockType         = adLockOptimistic
    .Open()
  End With
  
  If (rs.State = adStateOpen) Then
    '*** Recordset open, check for results (records) if specified.
    RSOpen = IIf(check_results, (Not rs.BOF And Not rs.EOF), True)
  Else
    '*** Recordset not open!
    RSOpen = False
  End If
End Function


'*******************************************************************************
'*** Table Related functions.
'*******************************************************************************
Function TableColumns(conn, table_name, delimiter)
  Dim rs, fld, cols
  
  '*** Clear list.
  cols = ""
  
  If RSOpen(rs, conn, "SELECT * FROM " & table_name & " WHERE FALSE", False) Then
    '*** Loop through fields and get their name.
    For Each fld In rs.Fields
      '*** Add field name to list
      cols = cols & delimiter & fld.Name
    Next
    
    '*** Cut of first delimiter.
    If (cols <> "") Then cols = Right(cols, Len(cols) - 1)
    
    Call RSClose(rs)
  End If
  
  '*** Return list.
  TableColumns = cols
End Function
%>