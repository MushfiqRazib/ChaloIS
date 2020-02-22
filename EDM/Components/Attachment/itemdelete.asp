<!-- #include file="./../config.asp"                   -->
<!-- #include file="./../rc/include/functions/system.asp"  -->

<%
'*******************************************************************************
'***                                                                         ***
'*** File       : itemdelete.asp                                             ***
'*** Author     : Rashidul Islam                                             ***
'*** Date       : 23-06-2007                                                 ***
'*** Email      : rislam@erp-bd.com                                          ***
'*** Description: Delete an artikel                                          ***
'***                                                                         ***
'*******************************************************************************

Dim artikelNr, filename,file

'*** Get parameters.
filePath     = Request("filePath")
filePath     = Replace(filePath,"@","\")
If (Not FileExists(filePath)) Then 
    Call Quit("File '" & filePath & "' Not found")
End If

'*******************************************************************************
'*** Delete the item
'*******************************************************************************
Call FileDelete(filePath)

   
'*******************************************************************************
'*** OK! Now exit/quit
'*******************************************************************************
Call Quit("")


'*******************************************************************************
'*** Private Functions
'*******************************************************************************
Sub Quit(errMsg)
  
  If (errMsg <> "") Then
    '*** Write error to document.
    Call Response.Write(errMsg)
    Call Response.End()
  End If
End Sub
%>