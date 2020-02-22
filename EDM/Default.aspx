<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>ChaloIS</title>
    <!-- ***************  CSS Links ***************** -->
    <link href="ext/resources/css/ext-all.css" rel="stylesheet" type="text/css" />
    <link href="styles/ext-override.css" rel="stylesheet" type="text/css" />
    <link href="styles/obrowser.css" rel="stylesheet" type="text/css" />
    <!--[if IE 6]>
        <link href="styles/ie6.css" rel="stylesheet" type="text/css" />
    <![endif]-->

    <script src="Scripts/Wrapper/PartListDetail.js" type="text/javascript"></script>

    <script src="ext/adapter/ext/ext-base.js" type="text/javascript"></script>

    <script src="ext/ext-all.js" type="text/javascript"></script>

    <script src="Scripts/Wrapper/CustomTools.js" type="text/javascript"></script>

    <script src="Components/rc/script/custom.js" type="text/javascript"></script>

    <script src="Components/rc/script/window.js" type="text/javascript"></script>
    <script type="text/javascript">
    
    var kitServerPath = "<%= kitServerPath %>";
    kitServerPath = unescape(kitServerPath);   
    var LOGIN_URL = kitServerPath + "/Login.aspx";
    var defaultconnectionkit = "<%= defaultconnectionkit %>";
    defaultconnectionkit = unescape(defaultconnectionkit);
    var printSeverLocation = "<%= printSeverLocation %>";
    printSeverLocation = unescape(printSeverLocation);
    var docSharedPath = "<%= sharedPath %>";
    docSharedPath = unescape(docSharedPath);

    var SIDValid = eval("<%= SIDValid %>");
    var REPEATER = eval("<%= repeater %>");
    var SECURITY_KEY = "<%= SECURITY_KEY %>";
    var BYPASSED_USER = eval("<%= BYPASSED_USER %>");
    var authInformation = "<%= authInformation %>";   
    authInformation = unescape(authInformation);
    if (authInformation) {
        authInformation = eval('(' + authInformation + ')');
    }

    //*** Deep link section
    var deepLinkReport = "<%= deepLinkReport %>";
    var deepLinkTab = "<%= tab %>";
        
    var deepLinkWhere = unescape("<%= whereClause %>");
    var deepLinkStatus = "<%= deepLinkStatus %>";
        
    window.onunload = CookieUpdate;           
    function CookieUpdate()
    {                
        SaveUserSettingsInCookie();        
    }   

    function GetOBServiceUrl() {
        return '<%= Page.ResolveUrl("~/OBServices.asmx") %>';
    }

    function GetWrapperServiceUrl() 
    {
        return '<%= Page.ResolveUrl("~/WrapperServices.asmx") %>';
    }

    function GetBasketServiceUrl() {
        return '<%= Page.ResolveUrl("~/BasketServices.asmx") %>';
    }

    window.onerror = function() {
        //code to run when error has occured on page
        try 
        {
            if(arguments[0].indexOf("REPORT")>-1)
            {
                ShowMessage("REPORT", "There is no report configured for this user", 'w', null);
            }
        } catch (e) 
        {
        
        }
    }
    
    </script>

    <!-- ***************  Javascript Links ***************** -->

    <script src="Scripts/Common.js" type="text/javascript"></script>

    <script src="Scripts/Core/OBrowser.js" type="text/javascript"></script>

    <script src="Scripts/Core/Navigations.js" type="text/javascript"></script>

    <script src="Components/Basket/script/sarissa.js" type="text/javascript"></script>

    <script src="Scripts/SecurityManager.js" type="text/javascript"></script>

    <script src="Scripts/OBController.js" type="text/javascript"></script>

    <script src="Scripts/Core/ext-override.js" type="text/javascript"></script>

    <script src="Scripts/Wrapper/SettingsProcessor.js" type="text/javascript"></script>

    <script src="Scripts/Wrapper/Wrapper.js" type="text/javascript"></script>

    <script src="Scripts/Wrapper/Toolbar.js" type="text/javascript"></script>

    <script src="Scripts/Wrapper/WrapperServiceProxy.js" type="text/javascript"></script>

    <script src="Scripts/Wrapper/details.js" type="text/javascript"></script>

    <script src="Scripts/Wrapper/Redline.js" type="text/javascript"></script>

    <script src="Components/Basket/script/basket.js" type="text/javascript"></script>

    <script src="Scripts/MainFilterContainer.js" type="text/javascript"></script>

    <script src="Scripts/MainReport.js" type="text/javascript"></script>

    <script src="Scripts/Basketfunctions.js" type="text/javascript"></script>

    <script src="Scripts/BasketPanel.js" type="text/javascript"></script>

    <script src="Scripts/MainSettings.js" type="text/javascript"></script>

    <script src="Scripts/MainsettingsViewControl.js" type="text/javascript"></script>

    <script src="Scripts/AddNormalColumn.js" type="text/javascript"></script>

    <script src="Scripts/AddGroupColumn.js" type="text/javascript"></script>

    <script src="Scripts/SaveAsWindow.js" type="text/javascript"></script>

    <script src="Scripts/Wrapper/Reports.js" type="text/javascript"></script>

    <%--    <script src="Query Builder/Scripts/QueryBuilder.js" type="text/javascript"></script>--%>

    <script type="text/javascript" for="ADViewer" event="OnEndLoadItem(bstrItemType,vData,vResult)">     
      if (bstrItemType == 'DOCUMENT')
      {         
      
        // var ADViewer = document.getElementById("ADViewer");
        // var ECompViewer = ADViewer.ECompositeViewer;
        //ECompViewer.ToolbarVisible = false;     	       
        //ECompViewer.MarkupsVisible = false;
                  
      }      


    </script>

</head>
<body id="docbody">
    <form id="form1" runat="server" action="./Default.aspx" method="POST">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true">
        <Services>
            <asp:ServiceReference InlineScript="true" Path="~/OBServices.asmx" />
            <asp:ServiceReference InlineScript="true" Path="~/WrapperServices.asmx" />
        </Services>
    </asp:ScriptManager>
    <div id="header-top">
        <div style="width: 70px; float: right; padding-top: 5px; font: 14px tahoma,arial,helvetica,sans-serif;">
            <a href="#" style="float: left; margin-top: 4px; margin-right: 4px;" onclick="LogOut()">
                <img src="Images/logout.png" />
            </a><a href="#" style="float: left;" onclick="LogOut()">Logout </a>
        </div>
        <center>
            <div style="padding-top: 10px; padding-left:70px;">
                <span style="font: bold 32px tahoma,arial,helvetica,sans-serif;">ChaloIS EDM</span>&nbsp;<span
                    style="font: 15px tahoma,arial,helvetica,sans-serif; font-weight: normal;"> an engineering
                    document management system of HawarIT</span>
            </div>
        </center>
    </div>
    <div id="tabContainer">
    </div>
    <div id="nonReportTabPanel1" class="hideDiv" style="overflow: auto">
    </div>
    <div id="nonReportTabPanel2" class="hideDiv" style="overflow: auto">
    </div>
    <div id="nonReportTabPanel3" class="hideDiv" style="overflow: auto">
    </div>
    <div id="nonReportTabPanel4" class="hideDiv" style="overflow: auto">
    </div>
    <div id="nonReportTabPanel5" class="hideDiv" style="overflow: auto">
    </div>
    <div id="nonReportTabPanel6" class="hideDiv" style="overflow: auto">
    </div>
    <div id="reportContainer" style="width: 100%;">
        <div id="header-wrap">
            <div id="header-container" style="margin-left: 3px; margin-top: 4px;">
                <div id="header">
                    <table style="width: 100%; margin-top: 4px;">
                        <tr>
                            <td>
                                <div style="float: left; margin-top: 2px">
                                    <div id="drpReportListConainerDiv" style="float: left; margin-left: 2px; width: 130px;">
                                    </div>
                                    <div style="float: left;">
                                        <div style="float: left; margin-left: 8px; width: 200px;">
                                            <div id="searchDiv" style="width: 150px; position: relative">
                                            </div>
                                            <div style="float: right; position: relative; margin-top: -19px">
                                                <a onclick="OBSettings.QuickSearchOnUserData()">
                                                    <img src="./images/search.png" style="height: 18px; cursor: pointer" alt="Add to filter" /></a>
                                                <a onclick="OBSettings.ClearFilterString()">
                                                    <img src="./images/clearsearch.png" style="padding-left: -8px; padding-right: 0px;
                                                        cursor: pointer" id="btnClearFilter" alt="Clear filter" /></a>
                                            </div>
                                        </div>
                                        <div id="drpGroupByWrapper" style="float: left; margin-left: 8px; width: 300px;">
                                            <label style="float: left; margin-top: 3px; font-family: Helvetica,sans-serif; font-size: 13px;">
                                                Group on field
                                            </label>
                                            <div id="drpGroupByContainerDiv" style="margin-left: 5px; float: left;">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div style="float: right; padding-right: 15px">
                                    <div id="divImportExcel"style ="  float: left">
                                        <a onclick="return importExcel();">
                                            <img src="Images/ExcelImport.png" style="padding-top: 7px; cursor: pointer;" title="Excel Import" /></a>
                                    </div>
                                    <div id="btnAdd" style="  float: left">
                                        <a onclick="return itemAdd();">
                                            <img src="Images/page_add.png" style="padding-top: 7px; padding-right:2px; cursor: pointer;" title="Add new item" /></a>
                                    </div>
                                    <div id="btnImport"style ="  float: left">
                                        <a onclick="return kabiFileUpload();">
                                            <img src="Images/image_add.png" style="padding-top: 7px; cursor: pointer;" title="KABI import starten" /></a>
                                    </div>
                                    <div style="float: left">
                                        <a onclick="ShowHideMainFilter('queryBuilderPanel')">
                                            <img src="Images/MainFilter.png" style="padding-top: 5px; cursor: pointer;" title="Filter" /></a>
                                    </div>
                                    <%-- <div style="float: left;">
                                        <input id="btnBasket" type="button" value="Basket Unnamed(0)" onclick="OpenBasket()" />&nbsp;
                                    </div>--%>
                                    <div id="divAddNewTask" style="float: left; margin-right: 2px; display: none;">
                                        <a onclick="OpenPostUpdate()">
                                            <img src="Images/addtask.png" style="padding-top: 5px;cursor: pointer;"  title="Add New Task" /></a>
                                    </div>
                                    <div id="divSaveColor" style="float: left; margin-right: 2px; display: none;">
                                        <a onclick="SaveSelectedThemeColors()">
                                            <img src="./images/save-colors.png" style="padding-top: 5px;cursor: pointer;" title="Save Color" /></a>
                                    </div>
                                    <div id="divSaveReportSettings" style="float: left; margin-right: 2px">
                                        <a onclick="SaveUsersCurrentSettings()">
                                            <img src="./images/save-settings.png" style="padding-top: 5px;cursor: pointer;" title="Save Settings" /></a>
                                    </div>
                                    <div id="divReport" style="float: left; margin-right: 5px; width: 17px;">
                                        <a onclick="ShowHideMainFilter('mainReportPanel')">
                                            <img src="./images/report.png" style="padding-top: 5px;cursor: pointer;" title="Create Report" /></a>
                                    </div>
                                    <div id="divBasket" style="float: left; margin-right: 5px;">
                                        <a onclick="ShowHideMainFilter('basketPanel')">
                                            <img src="Images/basketIcon.png" style="padding-top: 5px;cursor: pointer;" title="Show Basket Content" /></a>
                                    </div>
                                    <div id="divMainSettings" style="float: left; margin-right: 2px; width: 17px;">
                                        <a onclick="ShowHideMainFilter('mainSettingsPanel')">
                                            <img src="Images/mainsettnigs.png" alt="" style="padding-top: 5px;cursor: pointer;" title="Main Settings" /></a>
                                    </div>
                                    <div id="divThemeColor" style="float: left; margin-right: 2px">
                                        <a name="cmdTheme" onclick="ShowThemeColor()">
                                            <img id="Img2" src="./images/themecolor.png" style="padding-top: 5px;cursor: pointer;" title="Theme Color" /></a>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
        <div id="Container" style="background-color: #F4F3EE;">
            <div id="containerDiv" style="position: relative; height: auto;">
            </div>
        </div>
        <div id="Obrowser">
            <div id="gridContainer" style="background-color: #F4F3EE; position: relative; overflow: hidden;
                height: 300px;">
            </div>
        </div>
    </div>
    <div id="footer-wrap">
        <div id="footer-container">
            <div id="footer">
                <div style="float: left; font:14px tahoma,arial,helvetica,sans-serif">
                    <a onclick="OBSettings.GotoFirstPage()">
                        <img src="./images/nav_firstpage.gif" style="padding-top: 5px;" title="First page" /></a>
                    <a onclick="OBSettings.GotoPreviousPage()">
                        <img src="./images/nav_prevpage.gif" title="Previous page" /></a> <a onclick="OBSettings.GotoPrevRow()">
                            <img src="./images/nav_prevrow.gif" title="Previous Item" /></a>
                    <input type="text" id="txtSelectedRow" style="width: 25px; height: 15px;" value="1" />
                    <a onclick="OBSettings.GotoNextRow()">
                        <img src="./images/nav_nextrow.gif" title="Next Item" /></a> <a onclick="OBSettings.GotoNextPage()">
                            <img src="./images/nav_nextpage.gif" title="Next page" /></a> <a onclick="OBSettings.GotoLastPage()">
                                <img src="./images/nav_lastpage.gif" title="Last page" /></a> of &nbsp;
                    <label id="lblTotalRow">
                    </label>
                    &nbsp;&nbsp;
                    <input type="text" value="" style="width: 25px; height: 15px;" id="txtGotoPage" />
                    <a onclick="OBSettings.GotoPage()">
                        <img id="Img1" src="./images/gotopage.png" style="margin-left: -5px;" title="Goto Page" /></a>
                    <a href="#">
                        <img id="Img3" src="./images/separator.png" style="margin-left: 3px;" /></a>
                </div>
                <div id="divSearch" style="float: left; margin-left: 5px;">
                    <%--<label id="lblSortedFieldName">
                    </label>--%>
                    &nbsp;
                    <%-- <select id="quickSearchOperator" style="height: 20px;">
                    </select>--%>
                    <%--<input id="txtSearch" type="text" style="width: 98px;" />--%>
                    <%-- <a onclick="OBSettings.QuickSearchOnUserData()">
                        <img src="./images/filter.png" style="margin-left: -5px;" title="Add to filter" /></a>--%>
                    <%--<a onclick="OBSettings.ClearFilterString()">
                        <img src="./images/clear.png" style="margin-left: -8px;" id="btnClearFilter" title="Clear filter" /></a>--%>
                </div>
                <div style="float: right; padding-right: 5px; font: 14px tahoma,arial,helvetica,sans-serif;">
                    <label>
                        Resultaten per pagina:</label>
                    <input type="text" id="txtPageSize" style="width: 30px;" value="25" />
                    <a onclick="OBSettings.RefreshPage()">
                        <img id="btnRefresh" src="./images/refresh.gif" style="padding-top: 5px;" title="Refresh" /></a>
                </div>
            </div>
        </div>
    </div>
    <iframe id="iframUploadRedline" height="0px" width="0px"></iframe>
    </form>
</body>
</html>
