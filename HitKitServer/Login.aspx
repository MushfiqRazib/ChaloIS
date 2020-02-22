<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="HITKITServer.Login" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Kit Server</title>
    <link href="ext/resources/css/ext-all.css" rel="stylesheet" type="text/css" />
    <link href="css/Stylesheet.css" rel="stylesheet" type="text/css" />
    <link href="css/extcss.css" rel="stylesheet" type="text/css" />

    <script src="ext/adapter/ext/ext-base.js" type="text/javascript"></script>

    <script src="ext/ext-all.js" type="text/javascript"></script>

    <script src="Script/DataStore/ApplicationComboStore.js" type="text/javascript"></script>

    <script src="Script/Controls/ApplicationCombo.js" type="text/javascript"></script>

    <script src="Script/Controls/LoginPanel.js" type="text/javascript"></script>

    <script type="text/javascript">

    
  
        Ext.onReady(function() {
            Ext.QuickTips.init();
          
            var LoginPanel = new hit.excel.Controls.LoginPanel({
                renderTo: 'contentDiv'
                });
        });

    </script>

</head>
<body style="background-color:#76a4cc">
    <center>
            <div style="padding-top: 10px; padding-left:70px;">
                <span style="font: bold 32px tahoma,arial,helvetica,sans-serif;">ChaloIS EDM</span>&nbsp;<span
                    style="font: 15px tahoma,arial,helvetica,sans-serif; font-weight: normal;"> an engineering
                    document management system of HawarIT</span>
            </div>
        </center>
    <div align="center">
        <div style="width: 588px" align="center">
            <div id="contentDiv" align="center" style="height: 200px; margin-top: 75px">
            </div>
        </div>
    </div>
</body>
</html>
