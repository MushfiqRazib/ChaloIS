<!-- #include file="./../common.asp"                   -->
<!-- #include file="./../include/db.asp"               -->
<!-- #include file="./../include/functions/system.asp" -->
<%
'*******************************************************************************
'***                                                                         ***
'*** File       : release.asp                                                ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 29-08-2006                                                 ***
'*** Copyright  : (C) 2006 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Release Candidate                                          ***
'***                                                                         ***
'*******************************************************************************

Dim itemCode, itemRev,delDocs,File_Path

'*** Get parameters.
itemCode = RequestStr("Id", "")
itemRev  = RequestStr("Rev", "")

'*******************************************************************************
'*** Check presence of required parameters
'*******************************************************************************
If (itemCode = "" Or itemRev = "") Then Call Quit("Ontbrekende parameters!")

'*******************************************************************************
'*** Delete related documents
'*******************************************************************************
'*** Make path of the docs which should be deleted
File_Path = GetFilepath(itemCode)
'***Deletes main doc,all attachments and src doc <obsolete by Andre>
'delDocs = PATH_RC & File_SubPath & itemCode & "_*.*"  
'*** Delete only main doc
delDocs = PATH_RC & File_Path  

'*** Execute delete operations
Call FileDelete(delDocs)

'*******************************************************************************
'*** Delete record from 'Release Candidates'
'*******************************************************************************
Call DBExecute(gDBConn, "DELETE FROM rc_item_hit WHERE item = " & SQLEnc(itemCode) & " AND revision = " & SQLEnc(itemRev), True)

'*******************************************************************************
'*** OK! Now exit/quit
'*******************************************************************************
Call Quit("")

'*** Return FileSubPath plus File Name for the artikel
Function GetFilepath (ArtikelNr)
    Dim rs, sql,File_Path
    '*** create sql for the query
    sql = "SELECT File_SubPath, File_Name FROM RC_ITEM_HIT WHERE item = '" & ArtikelNr & "'"
    
    If RSOpen(rs, gDBConn, sql , True) Then      
         File_Path = rs("File_SubPath") & rs("File_Name")      
    End If      
        
    '*** Return FileSubpath + FileName
    GetFilepath = File_Path  
    
End Function


'*******************************************************************************
'*** Private Functions
'*******************************************************************************
Sub Quit(errMsg)
  '*** Cleanup.
  Call DBDisconnect(gDBConn)
  
  If (errMsg <> "") Then
    '*** Write error to document.
    Call Response.Write(errMsg)
    Call Response.End()
  End If
End Sub
%>