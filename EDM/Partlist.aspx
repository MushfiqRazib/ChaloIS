<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Partlist.aspx.cs" Inherits="Partlist" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Partlist</title>
    <link href="ext/resources/css/ext-all.css" rel="stylesheet" type="text/css" />
    <link href="styles/obrowser.css" rel="stylesheet" type="text/css" />
     
    <script src="ext/adapter/ext/ext-base.js" type="text/javascript"></script>
    <script src="ext/ext-all-debug.js" type="text/javascript"></script>
    <script src="Scripts/Wrapper/WrapperServiceProxy.js" type="text/javascript"></script>
    <script src="Scripts/Wrapper/partlist.js" type="text/javascript"></script>
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
    &nbsp;</label>
     &nbsp;<label id="lblMatCode" runat=server></label> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <label id="lblRevision" runat=server></label>
    <div id="partlistgrid" style="margin:5px;">
    </div>
    </div>
    <input type=button value="Close" style="margin-left:725px;width:60px" onclick="self.close()" />
    <asp:HiddenField runat="server" ID="sqlFrom" />
    <asp:HiddenField runat="server" ID="whereClause" />
    <asp:HiddenField runat="server" ID="reportCode" />
    </form>
</body>
</html>
