<%@ Page Language="C#" AutoEventWireup="true" Debug="true"  CodeFile="StuklijstWriter.aspx.cs" Inherits="StuklijstWriter" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
<title>Reporten</title>
<script>
function CallKitServerToGetFullXml(kitServerPath,filePath)
{    
   
    var url = kitServerPath+"/DownloadFullXML.aspx?filePath="+filePath ;
    window.location = url;
    return;
}

</script>    
</head>
<%
  
 %>
<body class='BodyStyle' >
    <form id="form1" runat="server">
    <div >
    <div id="progressGrid" runat="server"></div>
    
    </div>
    </form>
</body>
</html>
