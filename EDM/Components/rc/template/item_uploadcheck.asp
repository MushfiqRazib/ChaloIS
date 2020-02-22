<!-- #include file="./../common.asp"     -->
<!-- #include file="./../include/db.asp" -->
<%
'*******************************************************************************
'***                                                                         ***
'*** File       : item_uploadcheck.asp                                       ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 29-08-2006                                                 ***
'*** Copyright  : (C) 2006 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Modified by : Kaisar                                                                        ***
'*** Description: Check if Item can be added to RC                           ***
'***                                                                         ***
'*******************************************************************************

Dim rs, itemCode, itemRev

'*** Get parameters.
itemCode = RequestStr("id",  "")
itemRev  = RequestStr("rev", "")


'*******************************************************************************
'*** Check presence of required parameters
'*******************************************************************************
If (itemCode = "" Or itemRev = "") Then Call Quit("Ontbrekende parameters!")


'*******************************************************************************
'*** Check presence of item within 'Glovia'
'*** For roeselare we dont need to check the item in glovia
'*******************************************************************************
If Not RSOpen(rs, gDBConn, "SELECT artcode FROM artbst WHERE artcode = " & SQLEnc(itemCode), True) Then
  '*** Item does not exist in Glovia!
  Call Quit("2;" & "Artikelnummer " & itemCode & " niet gevonden in Glovia1.")
 End If


'*******************************************************************************
'*** Check for item within 'Release Candidates'
'*******************************************************************************
If RSOpen(rs, gDBConn, "SELECT item, revision, file_type FROM rc_item_hit WHERE item = " & SQLEnc(itemCode) & " and revision=" & SQLEnc(itemRev), True) Then
  If (UCase(rs("file_type")) = "DIVERSEN") Then
    '*** Correct article type, return revision for overwrite confirmation.
    Call Quit("1;" & rs("revision"))
  Else
    '*** Not allowed to overwrite existing article.
    Call Quit("Artikelen van het type '" & rs("file_type") & "' mogen niet worden overschreven.")
  End If
End If


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