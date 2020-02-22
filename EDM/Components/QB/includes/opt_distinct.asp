<!-- #include file="../../config.asp"     -->
<!-- #include file="./common.asp"  -->
<!-- #include file="./postgres.asp"  -->
<%
Dim rs, tablename, fieldname, maxResults, rowCount

'*** Get submitted parameters.
tablename  = RequestStr("table", "")
fieldname  = RequestStr("field", "")
maxResults = RequestInt("max",   25)

'*** Try to create database connection.
If RSOpen(rs, gDBConn, "SELECT DISTINCT(" & fieldname & ") FROM " & tablename, False) Then
  '*** Reset row counter.
  rowCount = 0
  
  '*** Loop through records.
  While ((Not rs.EOF) And (rowCount < maxResults))
    '*** ?
    Call Response.Write(rs(0) & vbCrLf)
    
    rowCount = rowCount + 1
    
    rs.MoveNext()
  Wend
   
  '*** Cleanup.
  Call RSClose(rs)
  Call DBDisconnect(gDBConn)
End If
%>