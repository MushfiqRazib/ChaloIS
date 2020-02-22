
var LOGIN_URL = kitServerPath + "/Login.aspx";
var NO_PERMISSION_MSG = "Access Denied!";

(function CheckAuthentication() {
    //    var currentUrl = window.location.href.replace(window.location.search, '');
    //    if (window.location.search != "") {
    //        var qStrings = window.location.search.substring(1).split('&');
    //        for (var i = 0; i < qStrings.length; i++) {
    //            var keyValPair = qStrings[i].split('=');
    //            if (keyValPair[0] == "sid") {
    //                SECURITY_KEY = keyValPair[1];
    //                break;
    //            }
    //        }
    //    }    
    if (!SIDValid && kitServerPath != 'undefined' && kitServerPath != '') {
        window.location.href = LOGIN_URL;
    } else if (!SIDValid) {        
        window.location.href = defaultconnectionkit;
    }

})();


function UpdateReportListBySecurityAssignment(reportList) 
{
    var matchFound = false;
    for (var i = 0; i < reportList.length; i++) {
        matchFound = false;
        for (var k = 0; k < authInformation.REPORT.length; k++) {            
                if (reportList[i].report_code == authInformation.REPORT[k]) {
                    matchFound = true;
                    break;
                }            
        }
        if (!matchFound) {
            reportList.splice(i, 1);
            i--;
        }
    }
    return reportList;
}

function UpdateFunctionListBySecurityAssignment(reportArgs) {
   // document.getElementById("btnBasket").style.display = 'none';
    Ext.get("divSaveReportSettings").setStyle('display', 'none');
       
    var matchFound = false;
    for (var i = 0; i < reportArgs.functionlist.length; i++) {
        matchFound = false;
        if (authInformation.OB) {
            for (var k = 0; k < authInformation.OB.length; k++) {
                if (reportArgs.functionlist[i][0] == authInformation.OB[k]) {
                    matchFound = true;
//                    if (authInformation.OB[k] == 'BASKET') {
//                         document.getElementById("btnBasket").style.display = 'block';    
//                    }
//                    
                    if (authInformation.OB[k] == 'SAVESETTINGS') {
                         Ext.get("divSaveReportSettings").setStyle('display', 'block');
                    }
                    
                    break;          
                }               
            }            
        }
        if (!matchFound) {
            reportArgs.functionlist.splice(i, 1);
            i--;
        }
    }    
    return reportArgs;
}


function SessionExists() 
{
    if (!REPEATER || BYPASSED_USER)
    {
        return true;
    }
    
    var url = "./EdmServicesForKit.asmx/UpdateLastAccessTime";
    var param = "{'securityKey':'" + SECURITY_KEY + "'}";
    var sessionExist = CallServiceMethodSync(url, param);
    
    if(sessionExist == false)
    {
        window.location.replace(LOGIN_URL);
        return false;
    }    
    return true;
}

function LogOut()
{

    var kitServerLogouturl = window.location.protocol + "//" + window.location.host + defaultconnectionkit;

    window.location.href = kitServerLogouturl;
   
}
function CallServiceMethodSync(fullServiceURL, serviceJSONParams) {

    var url = fullServiceURL;
    var param = serviceJSONParams;
    var xmlhttp = null;
    if (window.XMLHttpRequest) {
        xmlhttp = new XMLHttpRequest();
    }
    else if (window.ActiveXObject) {
        if (new ActiveXObject("Microsoft.XMLHTTP"))
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        else
            xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
    }
    // to be ensure non-cached version of response
    url = url + "?rnd=" + Math.random();

    xmlhttp.open("POST", url, false); //false means synchronous
    xmlhttp.setRequestHeader("Content-Type", "application/json; charset=utf-8");
    try {
        if (param != "")
            xmlhttp.send(param);
        else
            xmlhttp.send();
    }
    catch (e) {
        return e;
    }

    return eval("(" + xmlhttp.responseText + ")").d;

}


Array.prototype.removeItem = function(item)
{
    for(var i=0; i<this.length;i++)
    {
        if(item.toString().toLowerCase() == this[i].toString())
        {
            this.splice(i,1);
        }
    }
}

function ShowHideMainFilter(cmpName)
{
    if (Ext.get('GroupGrid') != null )
        var grid = Ext.get('GroupGrid').select('.x-grid3-scroller').elements[0];
    else if (Ext.get('NormalGrid')!= null)
        grid = Ext.get('NormalGrid').select('.x-grid3-scroller').elements[0];

    Ext.QuickTips.init();
    var curComp = Ext.getCmp(cmpName);
    //set height
    
    if (Ext.isDefined(curComp))
    {

        var height = document.documentElement.clientHeight - Ext.get('containerDiv').getHeight();
            
        switch (cmpName)
        {
            case 'queryBuilderPanel':
                if (grid)
                    grid.style.height = height + "px";
                break;
            case 'mainReportPanel':
                if (grid)
                    grid.style.height = height + 5 + "px";
                break;
            case 'mainSettingsPanel':
                if (grid)
                    grid.style.height = height + 85 + "px";
                break;
            case 'basketPanel':
                if (grid)
                    grid.style.height = height + 45 + "px";
                break;
        }
        
    }
    switch(cmpName)
    {
        case 'queryBuilderPanel':
            HideOtherVisiblePanel('queryBuilderPanel');
            if (!Ext.isDefined(curComp))
            {
                var MainFilter = new hit.Controls.queryBuilder({
                    renderTo: 'containerDiv'
                });

                var height = document.documentElement.clientHeight - MainFilter.getHeight();
                
                if (grid)
                    grid.style.height = height - 170 +"px";
            }
            else SetComponentVisibility(curComp);
            break;
        case 'mainReportPanel':
            HideOtherVisiblePanel('mainReportPanel');
            if (!Ext.isDefined(curComp))
            {
                var MainReport = new hit.Controls.mainReport({
                    renderTo: 'containerDiv'
                });

                var height = document.documentElement.clientHeight - MainReport.getHeight();
                if (grid)
                    grid.style.height = height - 170 + "px";
            }
            else SetComponentVisibility(curComp);
            break;
        case 'mainSettingsPanel':
            HideOtherVisiblePanel('mainSettingsPanel');
            if (!Ext.isDefined(curComp))
            {
                var MainSettings = new hit.Controls.mainsettings({
                    renderTo: 'containerDiv'
                });
                var height = document.documentElement.clientHeight - MainSettings.getHeight();
                if (grid)
                    grid.style.height = height - 170 + "px";
            }
            else SetComponentVisibility(curComp);
            break;
        case 'basketPanel':
            HideOtherVisiblePanel('basketPanel');
            if (!Ext.isDefined(curComp))
            {
                var BasketPanel = new hit.Controls.basketPanel({
                    renderTo: 'containerDiv'
                });

                var height = document.documentElement.clientHeight - BasketPanel.getHeight();
                if (grid)
                    grid.style.height = height - 170 + "px";
            }
            else SetComponentVisibility(curComp);
            break;   
            default:
                break;
        
    }
}

function  HideOtherVisiblePanel(panelToSkip)
{
    var componentPanelIds = ['queryBuilderPanel','mainReportPanel','mainSettingsPanel','basketPanel'];
    Ext.each(componentPanelIds,function(id){
       if(id != panelToSkip)
       {
           var el = Ext.getCmp(id);
           if(Ext.isDefined(el) && el.isVisible())
           {
                //el.hide();
                el.destroy();
           }
       }
    });
}

function SetComponentVisibility(curComp)
{
    if(curComp.isVisible())
    {
        curComp.hide();
        curComp.destroy();
    }
    else
    {
        curComp.show();
    }
}

function DestroyCustomPanels()
{
    var componentPanelIds = ['queryBuilderPanel','mainReportPanel','mainSettingsPanel','basketPanel'];
    Ext.each(componentPanelIds,function(id){
        
        var el = Ext.getCmp(id);
        switch(id)
        {
            case 'queryBuilderPanel':
            case 'mainReportPanel':
            case 'mainSettingsPanel':
               
                if(Ext.isDefined(el))
                {
                    el.destroy();
                }
                break;
                
            case 'basketPanel':  
                
                if(Ext.isDefined(el))
                {
                    ChaloIS.Basket.grid.DestroyGrid();
                    el.destroy();
                }
                
                break;  
            default:
                break;    
        }
        
       
    });
}