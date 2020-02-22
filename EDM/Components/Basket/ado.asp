
<%
Dim relatedArtikels,artikelNr, c_Bomengs,relatedArtikelInfo


set conn=Server.CreateObject("ADODB.Connection")
conString = "dsn=OracleDSIqbal;uid=vdl;pwd=vdl;"

With conn
    .ConnectionString = conString
    .Mode             = 1
    .Open()
  End With

artikelNr = "'13450084'"

Response.Write getRelatedArtikelInfo(conn,artikelNr)
conn.close

Function getRelatedArtikelInfo(conn,artikelNr )
    Dim c_Bomengs, artikelInfo, relatedArtikels, fileSubPath,fileName
    c_Bomengs = artikelNr
    relatedArtikels = ""    
    
    while c_Bomengs<>"" 
        If c_Bomengs<>"" Then
            relatedArtikels = relatedArtikels & IIf(relatedArtikels<>"",",","") & c_Bomengs
        End If 
        c_Bomengs = getRelatedArtikels(c_Bomengs,conn)              
    Wend   
   
    artikelInfo = ""
    set rs=Server.CreateObject("ADODB.recordset")
    sql = "SELECT matcode, rev, file_format FROM heyedm where matcode in (" & relatedArtikels & ")"
    
    'Response.Write sql
    
    rs.Open sql, conn    
    while Not rs.EOF    
        fileSubPath = GetFileSubPathFromMatCode(rs("matcode"))
        fileName = rs("matcode") &"_"& rs("rev")&".dwf"
        
        artikelInfo = artikelInfo & IIf(artikelInfo<>"","****","") & rs("matcode") & "@@@@" & rs("rev")& "@@@@" & rs("file_format") & "@@@@" & fileSubPath & fileName
        rs.MoveNext    
    Wend
    rs.close
  '*** return related artikel info
  getRelatedArtikelInfo = artikelInfo
    
End Function

Function getRelatedArtikels(c_Bomengs,conn)
    Dim artikels
    artikels = ""
    set rs=Server.CreateObject("ADODB.recordset")
    sql = "SELECT comp_item FROM va_c_bomeng where item in (" & c_Bomengs & ")"
    'Response.Write sql
    rs.Open sql, conn    
    while Not rs.EOF    
        artikels = artikels & IIf(artikels<>"",",","") & "'" & rs("comp_item") & "'"    
        rs.MoveNext    
    Wend
    rs.close
  '*** return related artikels
  getRelatedArtikels = artikels
    
End Function
  
Function IIf(bExpression, vTrue, vFalse)
  If bExpression then
    '*** Return 'TRUE' part.
    IIf = vTrue
  Else
    '*** Return 'FALSE' part.
    IIf = vFalse
  End If
End Function
  
Function GetFileSubPathFromMatCode(matCode)
    Dim path
    IF Len(matCode) >= 4 then
        path = Left(matCode,2) &  "\" & Mid(matCode,3,4) & "\"        
    End IF
    GetFileSubPathFromMatCode = path
End Function

  
%>

