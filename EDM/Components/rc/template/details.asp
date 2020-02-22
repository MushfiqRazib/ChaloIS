<!-- #include file="./../common.asp"     -->
<!-- #include file="./../include/db.asp" -->
<%
Dim rs, itemId, itemRev,File_Subpath, i

'*** Get id and revision.
itemId  = RequestStr("id",  "")
itemRev = RequestStr("rev", "")

'*** Try to open recordset.
If RSOpen(rs, gDBConn, "SELECT * FROM rc_item_hit WHERE item = " & SQLEnc(itemId) & " AND revision = " & SQLEnc(itemRev), True) Then
    File_Subpath = rs("File_Subpath")
    '*** replace file separator from filesub path if exists
    If File_Subpath <>"" Then File_Subpath = Replace(File_Subpath,"\","@")    
     
    Dim fs, folder, file, item, docPath, fileName, versionExists, attachmentString     
    docPath = PATH_RC & rs("File_Subpath")
    set fs = CreateObject("Scripting.FileSystemObject")
    set folder = fs.GetFolder(docPath)
    fileName = itemId & "_" & itemRev
    'get a list of files.  
    for each item in folder.Files                     
       If UBound(Split(item.Name, fileName))>0 Then
          versionExists = True
          Exit For
       End If
    next
                
    If versionExists Then
        attachmentString = "openChild('./../Attachment/Attachment.asp?rc=true&artikelnr=" & itemId & "&version=" & itemRev & "&File_Subpath=" & File_Subpath & "', '', true, 750, 677, 'no', 'no')"
    Else
        attachmentString = "alert('Geen document gevonden om bijlagen aan toe te voegen.')"
    End If
    

%>
<table align="center" cellspacing="20" style="width: 309px">
  <tr>
    <td style="width: 425px">
      <fieldset>
        <legend>Artikelgegevens</legend>
        
        <table align="center" cellspacing="4" style="margin: 8px 0px; width: 199px;">
<%
  '*** Loop through fields.
  For i = 0 To (rs.Fields.Count - 1)
%>
          <tr><td class="Detail" nowrap><%= GetFieldCaption(rs(i).Name) %></td><td nowrap style="width: 36px"><%= rs(i).Value %></td></tr>
<%
  Next 
  
%>
          <tr><td class="Detail" colspan="2" height="10"></td></tr>
          <tr>
          <td>
          <button title="Bijlage" onclick="<%=attachmentString %>;" onfocus="this.blur();">Bijlage</button>
          
          </td>
            <td align="right" class="Detail" nowrap>
              <button title="Stuklijst" onclick="openChild('./partlist.asp?id=<%= itemId %>&rev=<%= itemRev %>', '', true, 800, 600, 'yes', 'yes');" onfocus="this.blur();">Stuklijst</button>
            </td>
          </tr>
        </table>
      </fieldset>
    </td>
  </tr>
</table>
<%
Else
  '*** No object!
  Call Response.Write("Artikel niet gevonden!")
End If

'*** Cleanup.
Call RSClose(rs)
Call DBDisconnect(gDBConn)
%>