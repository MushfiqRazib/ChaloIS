<!-- #include file="./functions.asp" -->
<%

Dim downloadpath,docType,printServerLocation
 
downloadpath   = Request("downloadpath")

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

  '*** Determine doctype.
  pathParts = Split(downloadpath,".")
  docType = pathParts(UBound(pathParts)) 

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
     Case "DOC"
        Response.ContentType = "application/msword"
     Case "ODT"
        Response.ContentType = "application/vnd.oasis.opendocument.text"      
     case "TXT"
        Response.ContentType = "text/xml"          	      
     Case Else
        '*** Default MIME type.
        Response.ContentType = "application/octet-stream"
  End Select     
  
  pathParts = Split(Replace(downloadpath, "\","/"),"/")
   
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
    <link href="styles/datagrid.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="./script/attachment.js"></script>

    <script type="text/javascript" src="./script/common.js"></script>

    <script type="text/javascript" src="./script/sarissa.js"></script>
    
     <script>   
         function Reload(){
            reloadTasksGrid();
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
 
 relativePath = "TASKS\"&ArtikelNr&"\"

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
  
topMsg = "Bijlagen voor Matcode:"
docPath    = DocBasePath & File_Subpath 

 If NOT FolderExists(docPath) Then
    CreatePath(docPath)    
 End If 
 
 
%>
<body class="BodyStyle">
    <form id="form1" name="form1">
    <div>
        <table>
            <tr>
                <td style="padding-left: 20px;" nowrap>
                    <%=topMsg %>
                </td>
                <td id="artikelNr" class="ArtikelStyle">
                    <%= ArtikelNr%>
                </td>
            </tr>
            <tr>
                <td style="padding-top: 10px; padding-left: 20px;" colspan="3">
                    <table>
                        <tr>
                            <td style="width: 11px; height: 100%">
                                <fieldset style="width: 600px; margin: 5px 10px 5px 10px;">
                                    <legend class="LegendStyle">Bijlagen</legend>
                                    <table>
                                        <tr>
                                            <td style="height: 100%; margin: 5px 10px 5px 10px;" colspan="5">
                                                <div id="GridTask" class="Datagrid" style="overflow: auto; height: 500px; width: 600px;">
                                                    <%= CreateBaseMaterialDataGrid(docPath,"GridTask",ArtikelNr)%>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="5" align="right" style="width: 630px; height: 26px;">
                                <input type="button" id="btnGeneralAdd" style="width: 78px; height: 24px;" onclick="addTaskAttachment('<%=RCorVA %>','tasks')"
                                    value="Toevoegen" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <input id="downloadpath" name="downloadpath" type="hidden" value='' />
        
         <input name="version" type="hidden" value='<%= version%>' />            
         <input name="RCorVA" type="hidden" value='<%= RCorVA%>' />           
	    <!-- <input name="downloadpath" type="hidden" value='' />           -->
	     <input name="File_Subpath" type="hidden" value='<%=File_Subpath %>' />          
        <input name="docPath" type="hidden" value='<%=docPath %>' />  
            
    </div>
    </form>
</body>
</html>
