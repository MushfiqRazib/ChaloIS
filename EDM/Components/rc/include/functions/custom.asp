<%
'*******************************************************************************
'***                                                                         ***
'*** File       : custom.asp                                                 ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 27-09-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Custom Functions                                           ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** Item Functions
'*******************************************************************************
Function itemInGlovia(item)
  Dim rs, sql
  
  '*** Build query...
  sql = "SELECT artcode FROM artbst WHERE artcode = " & SQLEnc(item)
  
  '*** Return result.
  itemInGlovia = RSOpen(rs, gDBConn, sql, True)
  
  '*** Cleanup.
  Call RSClose(rs)
End Function


Function itemInRC(item, revision)
  Dim rs, sql
  
  '*** Build query...
  sql = "SELECT item FROM rc_item_hit WHERE item = " & SQLEnc(item) & " AND revision = " & SQLEnc(revision)
  
  '*** Return result.
  itemInRC = RSOpen(rs, gDBConn, sql, True)
  
  '*** Cleanup.
  Call RSClose(rs)
End Function


'*******************************************************************************
'*** Misc Functions
'*******************************************************************************
Function getRevisionStatus(item, revision)
  Dim rs
  
  If RSOpen(rs, gDBConn, "SELECT item FROM va_item_hit WHERE item = " & SQLEnc(item) & " AND revision = " & SQLEnc(revision), True) Then
    '*** Revision exist.
    getRevisionStatus = 1
  ElseIf RSOpen(rs, gDBConn, "SELECT item FROM va_item_hit WHERE item = " & SQLEnc(item) & " AND revision > " & SQLEnc(revision), True) Then
    '*** Revision is old.
    getRevisionStatus = -1
  Else
    '*** Revision does not exist and is newer than existing ones.
    getRevisionStatus = 0
  End If
  
  '*** Cleanup.
  Call RSClose(rs)
End Function
%>