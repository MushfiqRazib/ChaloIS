<!-- #include file="../common.asp"                   -->
<!-- #include file="../include/db.asp"               -->
<!-- #include file="../include/functions/custom.asp" -->
<%
'*******************************************************************************
'***                                                                         ***
'*** File       : item_release.asp                                           ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 29-08-2006                                                 ***
'*** Copyright  : (C) 2006 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Release Candidate                                          ***
'***                                                                         ***
'*******************************************************************************

Dim rs, sqlParams(3)
Dim sql, itemCode, itemRev, itemRevStatus, allowOldRev
Dim rcPath, rcFileName, vaPath, vaSubpath

'*** Get parameters.
itemCode     = RequestStr("id",  "")
itemRev      = RequestStr("rev", "")


allowOldRev  = (RequestInt("old", 0) = 1)
sqlParams(0) = SQLEnc(itemCode)
sqlParams(1) = SQLEnc(itemRev)
sqlParams(2) = ""
sqlParams(3) = SQLEnc(gUserName)


'*******************************************************************************
'*** Check presence of required parameters
'*******************************************************************************
If (itemCode = "" Or itemRev = "") Then Call Quit("Ontbrekende parameters!")


'*******************************************************************************
'*** Check presence of item within 'Release Candidates'
'*******************************************************************************
sql = SPrintf("SELECT * FROM rc_item_hit WHERE item = {0} AND revision = {1}", sqlParams)

If RSOpen(rs, gDBConn, sql, True) Then
  '*** Get file info.
  rcPath     = PATH_RC & rs("file_subpath")
  rcFileName = rs("file_name")
Else
  '*** Item does not exist in RC.
  Call Quit("Artikel " & itemCode & " Rev. " & itemRev & " niet gevonden in Release Candidates.")
End If


'*******************************************************************************
'*** Check presence of item within 'Glovia'
'*******************************************************************************
If Not itemInGlovia(itemCode) Then Call Quit("Artikelnummer " & itemCode & " niet gevonden in Glovia.")


'*******************************************************************************
'*** Check item revision within 'Vrijgegeven Archief'
'*******************************************************************************
itemRevStatus = getRevisionStatus(itemCode, itemRev)

If (itemRevStatus = 1) Then
  '*** Revision already exist.
  Call Quit("Revisie " & itemRev & " bestaat al voor artikelnummer " & itemCode & ".")
ElseIf (itemRevStatus = -1 And Not allowOldRev) Then
  '*** This an old revision, with no permission to release it.
  Call Quit("OLD_REVISION")
End If


'*******************************************************************************
'*** Create required directories
'*******************************************************************************
vaSubpath = Left(itemCode, 1) & "0\"
vaPath    = PATH_VA & vaSubpath

If Not CreateFolder(vaPath) Then Call Quit("Directorie " & vaPath & " kan niet worden aangemaakt.")

'*** Create second subdir.
vaSubpath = vaSubpath & Left(itemCode, 2) & "\"
vaPath    = PATH_VA & vaSubpath

If Not CreateFolder(vaPath) Then Call Quit("Directorie " & vaPath & " kan niet worden aangemaakt.")


'*******************************************************************************
'*** Check file existence within 'Vrijgegeven Archief'
'*******************************************************************************
If FileExists(vaPath & rcFileName) Then Call Quit("Bestand " & vaPath & rcFileName & " bestaat al.")


'*******************************************************************************
'*** Move files from 'Release Candidates' to 'Vrijgegeven Archief'
'*******************************************************************************
Call MoveFiles(rcPath, itemCode & "_" & itemRev & ".*", vaPath)


'*******************************************************************************
'*** Move records from 'Release Candidates' to 'Vrijgegeven Archief'
'*******************************************************************************
If (itemRevStatus = 0) Then
  '*** Delete current revision from VA (if exist).
  Call DBExecute(gDBConn, "DELETE FROM va_item_hit WHERE item = " & sqlParams(0), False)
  
  '*** Copy record from RC to VA.
  sqlParams(2) = SQLEnc(vaSubpath)
  sql          = "INSERT INTO va_item_hit (item, revision, description, file_subpath, file_name, file_type, file_createdby, file_date, file_format, releasedby, validated) " & _
                 "SELECT item, revision, description, " & sqlParams(2) & ", file_name, file_type, file_createdby, file_date, file_format, " & sqlParams(3) & ", 1 "          & _
                 "FROM rc_item_hit WHERE item = " & sqlParams(0)
  
  Call DBExecute(gDBConn, sql, False)
  
  '*** Copy part list from RC to VA.
  Call DBExecute(gDBConn, "DELETE FROM va_c_bomeng WHERE item = " & sqlParams(0) & " AND draw_rev = " & sqlParams(1), False)
  Call DBExecute(gDBConn, "INSERT INTO va_c_bomeng SELECT * FROM rc_c_bomeng WHERE item = " & sqlParams(0), False)
  
  '*** Copy part list from RC to Glovia.
  Call DBExecute(gDBConn, "DELETE FROM c_bomeng WHERE item = " & sqlParams(0), False)
  Call DBExecute(gDBConn, "INSERT INTO c_bomeng SELECT * FROM rc_c_bomeng WHERE item = " & sqlParams(0), False)
End If

'*** Delete record(s) from RC.
Call DBExecute(gDBConn, "DELETE FROM rc_item_hit WHERE item = " & sqlParams(0), False)
Call DBExecute(gDBConn, "DELETE FROM rc_c_bomeng WHERE item = " & sqlParams(0), True)


'*******************************************************************************
'*** OK! Now exit/quit
'*******************************************************************************
Call Quit("")


'*******************************************************************************
'*** Private Functions
'*******************************************************************************
Sub Quit(errMsg)
  '*** Cleanup.
  Call RSClose(rs)
  Call DBDisconnect(gDBConn)
  
  If (errMsg <> "") Then
    '*** Write error to document.
    Call Response.Write(errMsg)
    Call Response.End()
  End If
End Sub
%>