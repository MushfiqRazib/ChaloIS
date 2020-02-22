<!-- #include file="./functions.asp" -->
<!-- #include file="htmlform.asp" -->
<%
Dim rs, sql, oForm, oFile, version,Dir
Dim ArtikelNr, fileName, errMsg
'*** Get page values
 ArtikelNr = Request("artikelnr")
 version   = Request("version")
 docPath   = Request("docPath")
 
   
'*** Use HTMLForm component because we need binary data for file upload.
Set oForm = New HTMLForm

If oForm.Submitted Then
  '*** Get file.
  Set oFile = oForm("FileName")      
  ArtikelNr = oForm("artikelnr")
  version   = oForm("version")   
  docPath   = oForm("docPath")
       
  '*** Only proceed if we have a file (and thereby all other information).
  If (oFile.FileSize > 0) Then    
    fileName = ArtikelNr & "_" & version & "." & oFile.FileExt
    docPath  = docPath & "\" & fileName
    
    If(NOT FileExists(docPath)) Then    
       oFile.SaveAs(docPath)     
       Response.Write("<script>self.close();window.opener.Reload('"+version+"');window.opener.focus();</script>")
       Response.End()         
    End If     
  End If
End If

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head id="Head1" runat="server">
     <title>ADD Bijlage</title>
    
    <link href="styles/datagrid.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="./script/AddAttachment.js"></script>
    <script type="text/javascript" src="./script/common.js"></script>
    <script type="text/javascript" src="./script/sarissa.js"></script>
    <script type="text/javascript" src="./script/window.js"></script> 
    
</head>
<body class="BodyStyle" >
    <form name="ItemForm" action="./AddSrcAttachment.asp" enctype="multipart/form-data" method="POST">
     <div style="position:absolute; left:30px; top: 30px; width:s 416px; height: 211px;">
       <table >
          <tr>
            <td style="width: 403px">
            <table border="0" style="width: 390px">                                                        
              <tr>
                  <td colspan="2" style="padding-bottom:30px;text-align:left;">                 
                    Bron Bijlage voor Artikel: <b><%=ArtikelNr %></b>   Revisie: <b><%=version %></b>                    
                  </td>
              </tr>              
              
              <div id="myDiv" style="position:absolute;border-style:solid; border-width:thin; border-color:Black;position:absolute; left: 117px; top: 526px; width: 356px; visibility:hidden; height: 22px;background-color: #ffffcc;">
                <span id="myspan" style="background-color: #ffffcc; width:100%; height: 21px;">&nbsp; \ / : * ? " < > | &nbsp;
                    these characters are not allowed...</span>
              </div>
              <tr><td style="width: 102px;padding-bottom:10px;">Bestand &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; :</td>
               <td style="width: 272px">

                <div class="FileBrowse">
                    <input type="file" class="FileBrowse" name="FileName" value="" onchange="setElementAttrib('FileDisplay', 'value', this.value)">
                </div>
                <input type="text" class="FileDisplay" id="FileDisplay" value="" style="width: 145px">
                <input type="button" class="FileButton" value="Browse..." onfocus="this.blur()" style="left: -6px; width: 61px">
                </td>
                 </tr>
              <tr><td colspan="2" style="width: 300px;padding-top:80px;">
                  <button id="add" style="width: 90px; height: 24px;" onclick="srcItemSubmit()">Toevoegen</button>
                  &nbsp; 
                  <button id="btnCancel" style="width: 90px; height: 24px;" onclick="window.close()">Cancel</button>
                  </td></tr>                                   
            </table>
          </td>
            </tr>            
         </table>                          
     </div>     
         <input type="hidden" name="artikelnr" value='<%= ArtikelNr%>' />                     
         <input type="hidden" name="version" value='<%= version%>' />                     
         <input type="hidden" name="docPath"  value='<%=docPath %>' />
         
    </form>
</body>
</html>