<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WhereUsed.aspx.cs" Inherits="WhereUsed" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Where Used</title>
    <link href="ext/resources/css/ext-all.css" rel="stylesheet" type="text/css" />
    <link href="styles/obrowser.css" rel="stylesheet" type="text/css" />
     
    <script src="ext/adapter/ext/ext-base.js" type="text/javascript"></script>
    <script src="ext/ext-all-debug.js" type="text/javascript"></script>
    <script src="Scripts/Wrapper/WrapperServiceProxy.js" type="text/javascript"></script>
    <script src="Scripts/Wrapper/whereUsed.js" type="text/javascript"></script>
    <script type="text/javascript">
        
        function GetWrapperServiceUrl() 
        {
            return '<%= Page.ResolveUrl("~/WrapperServices.asmx") %>';
        }
            
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true">
        <Services>            
            <asp:ServiceReference InlineScript="true" Path="~/WrapperServices.asmx" />
        </Services>
    </asp:ScriptManager>
    <div style="margin:10px;">
        <div id="WhereUsedDiv" style="background-color: #eeffdd; position: relative;overflow:auto" > </div>
    </div>
    </form>
</body>
</html>
