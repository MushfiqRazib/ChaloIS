<!-- #include file="../common.asp"     -->
<!-- #include file="../include/db.asp" -->
<%
'*** Form submitted (or is this the first entry)?
If RequestBool("Submitted") Then
  '*** Save 'WHERE' clause.
  gReport.Item("SQL_Where") = joinLikeParts()
  
  '*** Write Report to session.
  Call Report_ToSession()
  
  '*** Quit Query Builder.
  Call Response.Redirect("./qb_finish.asp")
End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="../include/copyright.inc" -->
<html>

<head>
  <title>Snel Zoeken</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="../style/qbuilder.css">
  
  <script type="text/javascript" src="../script/common.js"></script>
</head>

<body>

<fieldset>
  <legend>Zoeken op</legend>
  
  <table align="center" cellspacing="4" style="margin: 8px 0px">
    <form name="QuickSearch" action="./qb_quick.asp" method="POST">
      <input type="hidden" name="Submitted" value="1">
    
    <tr>
        <td nowrap>Artikelnummer</td>
        <td><input type="text" name="ITEM" maxlength="30" value=""></td>
    </tr>
    <tr>
        <td nowrap>Omschrijving</td>
        <td><input type="text" name="DESCRIPTION" maxlength="50" style="width: 250px" value=""></td>
    </tr>
    
    </form>
  </table>
</fieldset>

<table width="100%">
  <tr>
    <td style="padding-top: 6px">
      <button onclick="document.QuickSearch.reset()">Wissen</button>
    </td>
    <td align="right" style="padding-top: 6px">
      <button onclick="window.close()">Annuleren</button>&nbsp;&nbsp;
      <button onclick="document.QuickSearch.submit()">OK</button>
    </td>
  </tr>
</table>

</body>
<%
'*******************************************************************************
'*** Filter Functions
'*******************************************************************************
Function joinLikeParts()
  Dim searchFields, whereClause, i, fieldName, fieldValue
  
  '*** Set fields to search on.
  searchFields = Array("ITEM", "DESCRIPTION")
  
  '*** Clear 'WHERE' clause.
  whereClause = ""
  
  For i = 0 To UBound(searchFields)
    '*** Get name and submitted value.
    fieldName  = searchFields(i)
    fieldValue = RequestStr(fieldName, "")
    
    If (fieldValue <> "") Then
      '*** Format value.
      fieldValue = SQLEnc(DB_WILDCARD & fieldValue & DB_WILDCARD)
      
      '*** Add 'WHERE' part to clause.
      If (whereClause <> "") Then whereClause = whereClause & " AND "
      
      whereClause = whereClause & "(" & fieldName & " LIKE " & fieldValue & ")"
    End If
  Next
  
  '*** Return clause.
  joinLikeParts = whereClause
End Function
%>
</html>