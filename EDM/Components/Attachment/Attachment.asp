<!-- #include file="./functions.asp" -->

<%

Dim downloadpath,docType,printServerLocation
 
downloadpath   = Request("downloadpath")
session("printserverlocation") = Request("printserverlocation")

If downloadpath<>"" Then
Dim oStream,  pathParts
pathParts = Split(downloadpath,"@")
downloadpath =  Replace(downloadpath,"@","\\")

  '*** Create a stream object.
  Set oStream = Server.CreateObject("ADODB.Stream")
  
  '*** Open specified file...
  oStream.Type = 1
  oStream.Open
  oStream.LoadFromFile downloadpath    

'Response.write pathParts(UBound(pathParts)) 

'*** Determine doctype.
      If UCase(Right(downloadpath,3))="DWF" Then 
        docType = "DWF"
      ElseIf UCase(Right(downloadpath,3))="DWG" Then   
        docType = "DWG"   
      ElseIf UCase(Right(downloadpath,3))="PDF" Then   
        docType = "PDF"  
      ElseIf UCase(Right(downloadpath,3))="TIF" Then   
        docType = "TIFF" 
      ElseIf UCase(Right(downloadpath,4))="TIFF" Then   
        docType = "TIFF"    
     ElseIf UCase(Right(downloadpath,4))="JPEG" Then   
        docType = "JPEG" 
     ElseIf UCase(Right(downloadpath,4))="JPG" Then   
        docType = "JPEG" 
     ElseIf UCase(Right(downloadpath,4))="ZIP" Then   
        docType = "ZIP"
      Else
        docType = "text/plain; charset=us-ascii"  
      End If
  
  '*** Determine MIME type.
      Select Case UCase(docType)
        Case "DWF"
          Response.ContentType = "drawing/x-dwf"    
        Case "DWG"
          Response.ContentType = "drawing/x-dwf"   
        Case "PDF"
          Response.ContentType = "application/pdf"    
        Case "TIFF"
          Response.ContentType = "image/tiff" 
	Case "JPEG"
          Response.ContentType = "image/jpeg"
	Case "ZIP"
          Response.ContentType = "application/zip"
        Case Else
          '*** Default MIME type.
          Response.ContentType = "application/octet-stream"
      End Select     
  
  '*** Output the contents of the stream object.
  Response.AddHeader "Content-Disposition", "attachment; filename="& pathParts(UBound(pathParts)) 
  
  Response.BinaryWrite oStream.Read    
    
  '*** Close stream.
  Call oStream.Close()
  
  downloadpath=""
  
  '*** Clean up...
  Set oStream = Nothing
  Response.End
  
  End If




%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <title>Bijlagen</title>    
    <!--<link href="./../rc/style/datagrid.css" type="text/css" rel="stylesheet" />-->
    <link href="styles/datagrid.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="./script/attachment.js"></script>
    <script type="text/javascript" src="./script/common.js"></script>
    <script type="text/javascript" src="./script/sarissa.js"></script>
    
    <script>     
     var OB_AUTH_OBJ = window.opener.OB_AUTH_OBJ; 
     var NO_PERMISSION_MSG = window.opener.NO_PERMISSION_MSG;
     
     function Reload(version){      
        if(version!="X")
            reloadVersieGrid();
        else
            reloadGeneralGrid();     
     }
     
    </script>
</head>
<%
 Dim ArtikelNr, docPath,version,sqlFrom, RCorVA, DOC_DIR,mcodeField, revField, topMsg, relativePath,relPathParts
 ArtikelNr = Request("artikelnr")
 version   = Request("version")
  
 RCorVA    = Request("rc")
 sqlFrom = Request("sqlFrom")
 mcodeField    = Request("matcodeField")
 revField = Request("revField")
 
 relativePath = GetFileRelativePath(mcodeField,revField, ArtikelNr, version, sqlFrom)


 relPathParts = Split(relativePath,"\")
 For i = 0 To UBound(relPathParts) - 1
     File_Subpath = File_Subpath & relPathParts(i) & "\"
 Next
 
 If ArtikelNr="" Then
    'Response.Write("<script> alert('Please provide an artikel as artikelNr=123')</script>")
    Response.Write("Please provide an artikel at the end of url as:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; URL?artikelNr=123")
   //Response.End()
 End If
  
DOC_DIR = DocBasePath
topMsg = "Bijlagen voor " & mcodeField & ":"
docPath    = DocBasePath & File_Subpath 


 If NOT FolderExists(docPath) Then
    CreatePath(docPath)    
 End If 
 
 
 %>
<body class="BodyStyle" >
    <form id="form1" name="form1">       
        <div>                
            <table>  
             <tr>
                <td style="padding-left:20px;" nowrap><%=topMsg %></td>
                <td id="artikelNr" class="ArtikelStyle"><%= ArtikelNr%></td>
                </tr>
                <tr>
                    <td style="padding-top:10px; padding-left:20px;" colspan="3">
                        <table >
                            <tr >
                                <td style="width: 11px">
                                    <fieldset style="width: 685px;padding-bottom:6px;" >
                                        <legend class="LegendStyle">Versie Specifieke Bijlagen</legend>
                                        <table>
                                            <tr valign="top" >                                                
                                                <td style="padding-top: 10px;padding-left: 15px;" nowrap>Revisie:</td>
                                                <td style="width: 85%;padding-top: 10px;" >                                                                                                
                                                     <%= LoadDropVersie(docPath,ArtikelNr,version)%>
                                                    </td>
                                            </tr>
                                            <tr>                                                
                                                <td style="padding-top: 5px;padding-left: 15px;">Bijlagen:</td>
                                            </tr>
                                            <tr>                                            
                                            <td colspan="5" style="padding-top: 5px;padding-left: 15px; width: 658px;">
                                            <div id="GridSpecific" class="Datagrid" style="overflow:auto;height:192px;width: 641px;">
                                                 <%= CreateDataGrid(docPath,"GridSpecific",ArtikelNr,version)%>
                                            </div>
                                            </td>
                                            </tr>
                                            <tr>
                                                <td colspan="5" align="right" style="width: 658px; height: 24px;">
                                                <input type="button" id="btnVersieAddSrc" style="width: 130px; height: 24px;" onClick="addSrcAttachment('')" value="Bron Toevoegen" />&nbsp;
                                                    <input type="button" id="btnVersieAdd" style="width: 130px; height: 24px;" onClick="addAttachment('<%=RCorVA %>','versie')" value="Toevoegen" />

                                                    </td>                                                    
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 11px; height:100%">
                                    <fieldset style="width: 685px;padding-bottom:6px;">
                                        <legend class="LegendStyle">Algemene Bijlagen</legend>
                                        <table >
                                            <tr>                                                
                                                <td style="width: 52px; padding-top: 5px;padding-left: 15px;">
                                                    <label>Bijlagen:</label></td>
                                            </tr>
                                            <tr>                                            
                                                <td style="height: 100%; padding-top: 5px;padding-left: 15px;" colspan="5">
                                                    <div id="GridGeneral" class="Datagrid" style="overflow:auto;height:192px; width: 641px;">
                                                        <%= CreateDataGrid(docPath,"GridGeneral",ArtikelNr,"")%>                                                        
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="5" align="right" style="width: 656px;height: 26px;">                                                    
                                                    <input type="button" id="btnGeneralAdd" style="width: 78px; height: 24px;" onClick="addAttachment('<%=RCorVA %>','general')" value="Toevoegen" />
                                                    </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
                        
            <input name="version" type="hidden" value='<%= version%>' />            
            <input name="RCorVA" type="hidden" value='<%= RCorVA%>' />           
	 <input id="downloadpath"  name="downloadpath" type="hidden" value='' />           
	<input name="File_Subpath" type="hidden" value='<%=File_Subpath %>' />          
            <input id="docPath" name="docPath" type="hidden" value='<%=docPath %>' />         
            <%Session("reload") = "" %>
        </div>
    </form>
</body>
</html>
