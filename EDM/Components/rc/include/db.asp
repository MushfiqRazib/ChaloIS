<!-- #include file="./db/adodb.inc"  -->
<!-- #include file="./db/oracle.asp" -->
<%
'*******************************************************************************
'***                                                                         ***
'*** File       : db.asp                                                     ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 21-02-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Common Database Functions                                  ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** Database Connection Object
'*******************************************************************************
Dim gDBConn


'*******************************************************************************
'*** Create Database Connection
'*******************************************************************************
If Not DBConnect(gDBConn, DB_CONNSTRING, adModeRead) Then Call ErrorMessage(ERR_NODBCONNECT)


'*******************************************************************************
'*** Common database functions.
'*******************************************************************************
Function FieldExist(rs, fieldName)
  Dim i
  
  '*** Default return value.
  FieldExist = False
  
  For i = 0 To (rs.Fields.Count - 1)
    If (StrComp(rs.Fields(i).Name, fieldName, 1) = 0) Then
      '*** Field found!
      FieldExist = True
      
      '*** No need to continue.
      Exit For
    End If
  Next
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


Function ColumnsAsArray(conn, table_name)
  Dim list_csv
  
  '*** Get field names as CSV list.
  list_csv = TableColumns(conn, table_name, ",")
  
  '*** Return CSV list as an array.
  ColumnsAsArray = Split(list_csv, ",")
End Function


Function RecordCount(conn, source)
  Dim rs
  
  If RSOpen(rs, conn, source, False) Then
    '*** Return number of rows.
    RecordCount = rs(0)
    
    Call RSClose(rs)
  Else
    '*** Something went wrong?!?
    RecordCount = 0
  End If
End Function


Function HasRecords(rs)
  '*** Recordset open and record found?
  If (rs.State = adStateOpen) Then
    HasRecords = ((Not rs.BOF) And (Not rs.EOF))
  Else
    HasRecords = False
  End If
End Function
%>