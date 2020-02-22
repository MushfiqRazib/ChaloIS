//******************************************************************************
//***                                                                        ***
//*** Author     : Rashidul                                                  ***
//*** Date       : 02-08-2009                                                ***
//*** Copyright  : (C) 2004 HawarIT BV                                       ***
//*** Email      : info@hawarIT.com                                          ***
//***                                                                        ***
//*** Description:                                                           ***
//*** This file is only used for Wrapper functions only                      ***
//*** No Object browser functions allowed to put here.                       ***
//******************************************************************************

var COMPONENT_BASE_PATH = "./Components/";
var PROPERTY_EDITOR_VIRTUALDIRECTORY = "PropertyEditor";
//var COMPONENT_BASE_PATH = "http://localhost/obrowser/Components/";
var viewableDocMode = "Server";

function LoadReportList(update) {
    var params = '{"dummyParam":"dummydata"}';
    var serviceName = "GetReportList";
    var result = GetSyncJSONResult_Wrapper(serviceName, params);
    result = eval('(' + result + ')');
    result = eval('(' + result.d + ')');
    var reportList = result.reportList;

    if (!update) {
        reportList = UpdateReportListBySecurityAssignment(reportList);
    }
    else {
        var arr = [];

        for (var i = 0; i < reportList.length; i++) {
            arr.push(reportList[i].report_code);
        };
        //debugger;
        authInformation.REPORT = arr;
        Set_Cookie("REPORT_CODE", update);
    }
    LoadSearchTextBoxAndInitiateGroupByCombo();
    LoadReportListComboBox(reportList);

    if (deepLinkStatus == 'invalid' && deepLinkReport) {
        ClearDeeplinkInfo();
        //Ext.MessageBox.alert("Info", "Invalid report in deeplink");
        ShowMessage("Info", "Invalid report in deeplink", 'i', null);

    }
    
}

function LoadSearchTextBoxAndInitiateGroupByCombo() {
    if (!Ext.getCmp('txtSearch')) {

        var searchTxtField = new Ext.form.TextField({
            id: 'txtSearch',
            hideLabel: true,
            renderTo: 'searchDiv',
            emptyText: 'Enter search string',
            style: 'font-family:Helvetica,sans-serif;font-size:13px;',
            width: '150px',
            height: '18px',
            cls: 'textfield',
            emptyClass: 'textfield-empty',
            allowBlank: true,
            listeners: {
                'focus': function(ctl) {
                    this.el.dom.style.color = 'black';
                    this.el.dom.style.fontStyle = 'normal';
                }
                ,
                'blur': function(ctl) {
                    if ((this.el.dom.value == "") && ((!OBSettings.SQL_LAST_QUICK_SEARCH_STRING) || (OBSettings.SQL_LAST_QUICK_SEARCH_STRING == "undefined") || (OBSettings.SQL_LAST_QUICK_SEARCH_STRING == ""))) {
                        this.el.dom.style.color = 'gray';
                        this.el.dom.style.fontStyle = 'italic';
                    }
                    else if ((OBSettings.SQL_LAST_QUICK_SEARCH_STRING) && (this.el.dom.value == "")) {
                        //this.el.dom.value = OBSettings.SQL_LAST_QUICK_SEARCH_STRING;
                        //this.el.dom.style.color = 'black';
                        //this.el.dom.style.fontStyle = 'normal';
                        this.el.dom.style.color = 'gray';
                        this.el.dom.style.fontStyle = 'italic';
                    }
                }
            }
        });
    }
    if (!Ext.getCmp('drpGroupByList')) {
        new chalo.drpDownGroupBy();
    }
}

function LoadReportListComboBox(reportList) {
    var repCode_Cookie = Get_Cookie("REPORT_CODE");
    var reportNameCodePair = new Array(reportList.length);
    for (var k = 0; k < reportList.length; k++) {
        reportNameCodePair[k] = new Array(2);
        reportNameCodePair[k][0] = reportList[k].report_name;
        reportNameCodePair[k][1] = reportList[k].report_code;
    }

    var reportListStore = new Ext.data.ArrayStore({
        fields: ['report_name', 'report_code'],
        autoDestory: true,
        data: reportNameCodePair
    });

    if (Ext.getCmp('drpReportList')) {
        Ext.destroy(Ext.getCmp('drpReportList'));
    }
   
    var reportDrpDown = new Ext.form.ComboBox({
        id: 'drpReportList',
        name: 'drpReportList',
        width: 130,
        mode: 'local',
        typeAhead: true,
        selectOnFocus: true,
        forceSelection: true,
        displayField: 'report_name',
        style: 'font-family:Helvetica,sans-serif;font-size:13px;',
        valueField: 'report_code',
        triggerAction: 'all',
        store: reportListStore,
        renderTo: 'drpReportListConainerDiv',
        listeners: {
            'render': function(ctl) {
                
                var indx = 0;
                if (deepLinkReport) {
                    indx = SelectCookieReport(deepLinkReport, ctl.store.data);
                } else if (repCode_Cookie) {
                    indx = SelectCookieReport(repCode_Cookie, ctl.store.data);
                }
                this.value = ctl.store.data.items[indx].data.report_name;
                
                if (ctl.store.data.items[indx].data.report_code == "RELEASECANDIDATES")
                {
                    Ext.get('btnAdd').setStyle('display','block');
                    Ext.get('btnImport').setStyle('display','block');
                    
                }
                else
                {
                     Ext.get('btnAdd').setStyle('display','none');
                    Ext.get('btnImport').setStyle('display','none');
                   
                }
                    
                LoadReportArguments(ctl.store.data.items[indx].data.report_code);
                
            },
            'select': function(ctl, record) {                
                ClearDeeplinkInfo();
                
                if (record.data.report_code == "RELEASECANDIDATES")
                {
                     Ext.get('btnAdd').setStyle('display','block');
                    Ext.get('btnImport').setStyle('display','block');
                    
                }
                else
                {
                    Ext.get('btnAdd').setStyle('display','none');
                    Ext.get('btnImport').setStyle('display','none');
                }
                   
                LoadReportArguments(record.data.report_code);
                DeleteAll();
            }
        }
    });
}

function ReLoadComponentPanels() {
    var componentPanelIds = ['queryBuilderPanel', 'mainReportPanel', 'mainSettingsPanel', 'basketPanel'];
    var relaodedPanelId = null;
    Ext.each(componentPanelIds, function(id) {
        var el = Ext.getCmp(id);
        if (Ext.isDefined(el) && el.isVisible()) {
            relaodedPanelId = id;
            el.destroy();
        }
    });

    if (relaodedPanelId) {
        ShowHideMainFilter(relaodedPanelId);
    }
}

function LoadReportArguments(record) 
{        

    //*** Call wrapper for report arguments/parameters
    var reportCode = record;

    if (reportCode == "TASKS") {
        Ext.get("divAddNewTask").setStyle('display', 'block');
    } else {
        Ext.get("divAddNewTask").setStyle('display', 'none');
    }

    var params = '{"reportCode":"' + reportCode + '"}';
    var serviceName = "GetReportArguments";
    var reportArgs = GetSyncJSONResult_Wrapper(serviceName, params);

    var reportArgs = eval('(' + reportArgs + ')');
    reportArgs = reportArgs.d.replace(/"/g, "\"");
    reportArgs = eval('(' + reportArgs + ')');
    var fieldList = reportArgs.fieldList;

    PopulateFieldList(fieldList, reportArgs.settings.field_caps);
    reportArgs = UpdateFunctionListBySecurityAssignment(reportArgs);
    SetOBSettings(reportArgs);
}

function SetOBSettings(reportArgs) {
    var dbSettings = reportArgs.settings;
    var sqlmandatory = reportArgs.sqlmandatory;
    var functionlist = reportArgs.functionlist;
    var sqlkeyfields = reportArgs.sqlkeyfields;
    OBSettings.REPORT_CODE = dbSettings.report_code;
    OBSettings.REPORT_NAME = dbSettings.report_name;

    OBSettings.FIELD_CAPS = dbSettings.field_caps;
    OBSettings.SQL_SELECT = dbSettings.sql_select;
    OBSettings.GIS_THEME_LAYER = dbSettings.gis_theme_layer;
    OBSettings.SQL_FROM = dbSettings.sql_from;
    OBSettings.MULTI_SELECT = dbSettings.multiselect;
    OBSettings.DEEPLINK = dbSettings.deeplink;
    OBSettings.DETAIL_KEY_FIELDS = sqlkeyfields;
    OBSettings.SQL_MANDATORY = sqlmandatory;
    OBSettings.FUNCTION_LIST = functionlist;
    OBSettings.SQL_FIELD_TYPE = reportArgs.fieldTypes;
    OBSettings.RENDER_DIV = "";

    try {
        if (dbSettings.report_settings) {
            dbSettings.report_settings = eval('(' + dbSettings.report_settings.replace(/@@@/g, '"') + ')');
        }
    } catch (e) {
        dbSettings.report_settings = null;
    }

    //*** Reset/keep a backup of database settings    
    SetDatabaseFieldSettings(dbSettings);
   
    var cookieSettings = GetSettingsFromCookie();
    if (cookieSettings) {
        var cookieCheckResult = CheckSettings(cookieSettings);
        var cookie_set_stat = SetSettingsToCore(cookieSettings, cookieCheckResult);
    }
   
    if (cookie_set_stat != -1) {
        dbCheckResult = CheckSettings(dbSettings);
        var db_set_stat = SetSettingsToCore(dbSettings, dbCheckResult);
    }

    //*** Destroy all grids if exists       
    OBSettings.DeleteExpandedRow();
    OBSettings.DestoryGrid('NormalGrid');
    OBSettings.DestoryGrid('GroupGrid');

    if (cookie_set_stat == -1 || db_set_stat == -1)   //-1 means set somehow
    {

        OBSettings.COOKIE_CHECKED = true;
        SetDefaultGroupBy(OBSettings.SQL_GROUP_BY);
        ReOrderSqlSelectFields();

        //*** Obrowser starts up    
        setTimeout(function() {
         InitReport() 
        }, 1);


    } else {
        var errorMsg = "";
        if (cookie_set_stat != undefined) {
            errorMsg = "Cookie error: " + SETTING_CHECK_MESSAGE[cookie_set_stat];
        }
        var dbMessage = "Database error: " + SETTING_CHECK_MESSAGE[db_set_stat];
        errorMsg += (errorMsg == "") ? dbMessage : ("\n" + dbMessage);
        //alert("Report could not create due to: \n\n" + errorMsg);
        ShowMessage('Error', "Report could not create due to: \n\n" + errorMsg, 'e', null);

    }
}


function SetDefaultGroupBy(sqlGroupBy) {
    if (sqlGroupBy) {
        var drpGroupBy = Ext.getCmp("drpGroupByList");
        for (k = 0; k < drpGroupBy.store.data.length; k++) {
            if (drpGroupBy.store.data.items[k].data.value.toUpperCase() == sqlGroupBy.toUpperCase()) {
                drpGroupBy.setValue(drpGroupBy.store.data.items[k].data.value, true);
                break;
            }
        }
    }
}

function GetSelectedReport() {
    var drpReportList = Ext.getCmp('drpReportList');
    return drpReportList.value;
}

function GetGroupByField() {
    var drpGroupBy = Ext.getCmp("drpGroupByList");
    return drpGroupBy.value;
}

function PopulateFieldList(fieldList, fieldCaps) {


    var fieldCaps = fieldCaps.split(';');
    var caption, fieldCapPair;


    groupByCaptionValuePair = [];

    groupByCaptionValuePair[0] = new Array(2);
    groupByCaptionValuePair[0][0] = 'No Selection';
    groupByCaptionValuePair[0][1] = 'NONE';
    for (var k = 0; k < fieldList.length; k++) {
        caption = fieldList[k];
        for (var i = 0; i < fieldCaps.length; i++) {
            fieldCapPair = fieldCaps[i].split('=');
            if (fieldCapPair[0] == caption) {
                caption = fieldCapPair[1];
                break;
            }
        }
        groupByCaptionValuePair[k + 1] = new Array(2);
        groupByCaptionValuePair[k + 1][0] = caption;
        groupByCaptionValuePair[k + 1][1] = fieldList[k];
    }

    var storeGroupByFieldList = new Ext.data.ArrayStore({
        fields: ['caption', 'value'],
        autoDestroy: true,
        data: groupByCaptionValuePair
    });

    //storeArray.loadData(data);

    var groupByDrpDown = Ext.getCmp('drpGroupByList');
    if (Ext.isDefined(groupByDrpDown)) {
        groupByDrpDown.destroy();
        new chalo.drpDownGroupBy();
    }
    groupByDrpDown = Ext.getCmp('drpGroupByList');

    groupByDrpDown.store = storeGroupByFieldList;

        groupByDrpDown.addListener('select', function() {
            //debugger;
           // if (Ext.getCmp('drpGroupByList').getValue() != 'NONE') {
                OBSettings.groupByEvent = true;
           // }
            InitReport();
        });
    
    //groupByDrpDown.addListener('select', InitReport);
}

/*
this function is no more needed as we replace select control by ExtJs Combo
//*** This method add's an option to the
//*** supplied dropdownlist box.
function addDrpOption(reportList, value, text) 
{
var optn = document.createElement("OPTION");
optn.text = text;
optn.value = value;
reportList.options.add(optn);
}
*/

function ExecuteCustomFieldAction(customFields) {

    var currentFields = OBSettings.SQL_SELECT.split(';');
    for (var k = 0; k < currentFields.length; k++) {
        if (currentFields[k].indexOf(" AS ") > 0) {
            currentFields.splice(k, 1);
            k--;
        }
    }
    if (OBSettings.SQL_GROUP_BY == 'NONE')
    {
        var currentCustomFields = customFields.split(';');
        for (var k = 0; k < currentCustomFields.length; k++) {
            currentFields.push(currentCustomFields[k]);
        }
    }


    OBSettings.QB_ACTION = true;
    OBSettings.SQL_SELECT = currentFields.join(';');
    OBSettings.QB_CUSTOM_FIELDS = customFields;
    if (OBSettings.SQL_GROUP_BY == 'NONE')
    {
        OBSettings.SQL_GROUP_BY = "NONE";
        OBSettings.ACTIVE_GRID = 'MAIN_GRID';

        //    var drpGroupList = document.getElementById("drpGroupBy");
        //    setSelectedIndex(drpGroupList, OBSettings.SQL_GROUP_BY);  
        SetDefaultGroupBy(OBSettings.SQL_GROUP_BY);

        if(OBSettings.COOKIE_SELECTED_FIELDS == ""){
            OBSettings.ShowMainLoadingImage();
        }
               setTimeout(function() {
            OBSettings.CreateNormalGrid();
        }, 1);
    }
    else
    {
        //OBSettings.SQL_GROUP_BY = "NONE";
        OBSettings.ACTIVE_GRID = 'MAIN_GRID';

        //    var drpGroupList = document.getElementById("drpGroupBy");
        //    setSelectedIndex(drpGroupList, OBSettings.SQL_GROUP_BY);  
        //SetDefaultGroupBy(OBSettings.SQL_GROUP_BY);
        
        if(OBSettings.COOKIE_SELECTED_FIELDS == ""){
            OBSettings.ShowMainLoadingImage();
        }
        setTimeout(function() {
            OBSettings.CreateGroupByGrid();
        }, 1);
    }
}

function SetReportByWhereCmpFromQB(sqlwhere, cmpValue)
{
    OBSettings.SQL_WHERE_CMPVALUE = cmpValue;
    OBSettings.SQL_WHERE = sqlwhere;
    Ext.get('txtSearch').dom.value = "";
    OBSettings.ACTIVE_GRID = 'MAIN_GRID';
    if (OBSettings.SQL_GROUP_BY != "NONE")
    {
        setTimeout(function()
        {
            OBSettings.CreateGroupByGrid();
        }, 1);
    } else
    {
        setTimeout(function()
        {
            OBSettings.CreateNormalGrid();
        }, 1);
    }
}

function SetReportByWhereFromQB(sqlwhere) {
//debugger;
    OBSettings.SQL_WHERE = sqlwhere;
    Ext.get('txtSearch').dom.value = "";
    OBSettings.ACTIVE_GRID = 'MAIN_GRID';
    if (OBSettings.SQL_GROUP_BY != "NONE") {
        setTimeout(function() {
            OBSettings.CreateGroupByGrid();
        }, 1);
    } else {
        setTimeout(function() {
            OBSettings.CreateNormalGrid();
        }, 1);
    }
}

function SetReportGroupByFromQB(sqlorderby, qbgbselectclause, sqlgroupby) {
//debugger;
    OBSettings.SQL_ORDER_BY = sqlorderby;
    OBSettings.QB_GB_SELECT_CLAUSE = qbgbselectclause;
    OBSettings.QB_ACTION = true;

    OBSettings.SQL_GROUP_BY = sqlgroupby;
    Ext.get('txtSearch').dom.value = "";
    //var drpGroupList = document.getElementById("drpGroupBy");
    OBSettings.ACTIVE_GRID = 'MAIN_GRID';
    if (qbgbselectclause) {
        SetDefaultGroupBy(OBSettings.SQL_GROUP_BY);
        //setSelectedIndex(drpGroupList, OBSettings.SQL_GROUP_BY);
        OBSettings.GB_SQL_SELECT = OBSettings.SQL_GROUP_BY + ';' + OBSettings.QB_GB_SELECT_CLAUSE;
        OBSettings.COOKIE_SELECTED_FIELDS = OBSettings.GB_SQL_SELECT;
        setTimeout(function() {
            OBSettings.CreateGroupByGrid();
        }, 1);
    } else {
        OBSettings.SQL_GROUP_BY = "NONE";
        OBSettings.SQL_ORDER_BY = "";
        SetDefaultGroupBy("NONE");
        OBSettings.ShowMainLoadingImage();
        setTimeout(function() {
            OBSettings.CreateNormalGrid();
        }, 1);
    }
}

/*
this function is no more needed as we replace select control by ExtJs Combo
function setSelectedIndex(drpDownList, value) {
for ( var i = 0; i < drpDownList.options.length; i++ ) {
if ( drpDownList.options[i].value == value ) {
drpDownList.options[i].selected = true;
return;
}
}
}
*/

function ShowReportTab() {
    Ext.fly('nonReportTabPanel1').update('');
    var headerDiv = Ext.DomQuery.select("div[id='header-wrap']");
    var obrowserDiv = Ext.DomQuery.select("div[id='Obrowser']");
    headerDiv[0].className = 'showDiv';
    obrowserDiv[0].className = 'showDiv';

    var tabItems = Ext.getCmp('obTabs').items.items;
    for (var k = 1; k < tabItems.length; k++) {
        var nonReportTabPanel = Ext.DomQuery.select("div[id='nonReportTabPanel" + k + "']");
        nonReportTabPanel[0].className = 'hideDiv';
    }
}

function ShowDetailTab() {
    var tabIndex = 1;
    ShowOtherTabsLoadingImage(tabIndex);
    UpdateTabPanelVisibility(tabIndex);
    setTimeout(function() {
        ShowDetailTabContent();
    }, 1);
}

function ShowPDFTab() {
    var tabIndex = 3;
    ShowOtherTabsLoadingImage(tabIndex);
    UpdateTabPanelVisibility(tabIndex);
    setTimeout(function() {
        LoadViewerContent('pdf', 'nonReportTabPanel' + tabIndex)
    }, 1);
}

function ShowPartlistTab() {
    var tabIndex = 4;
    
    ShowOtherTabsLoadingImage(tabIndex);
    UpdateTabPanelVisibility(tabIndex);
    ShowPartlistTabContent();
}

function ShowOfficeTab() {
    var tabIndex = 5;
    ShowOtherTabsLoadingImage(tabIndex);
    UpdateTabPanelVisibility(tabIndex);

    setTimeout(function() {
        LoadViewerContent('doc', 'nonReportTabPanel' + tabIndex)
    }, 1);
}


function ShowODTTab() {
    var tabIndex = 6;
    ShowOtherTabsLoadingImage(tabIndex);
    UpdateTabPanelVisibility(tabIndex);

    setTimeout(function() {
        LoadViewerContent('odt', 'nonReportTabPanel' + tabIndex)
    }, 1);
}

function ShowDWFTab() {
    var tabIndex = 2;
    ShowOtherTabsLoadingImage(tabIndex);
    UpdateTabPanelVisibility(tabIndex);
    setTimeout(function() {
        LoadViewerContent('dwf', 'nonReportTabPanel' + tabIndex, false)
    }, 1);
}

function UpdateTabPanelVisibility(tabId) {

    var headerDiv = Ext.DomQuery.select("div[id='header-wrap']");
    var obrowserDiv = Ext.DomQuery.select("div[id='Obrowser']");
    headerDiv[0].className = 'hideDiv';
    obrowserDiv[0].className = 'hideDiv';
   
    var tabItems = Ext.getCmp('obTabs').items.items;
    for (var k = 1; k < tabItems.length; k++) {
        var nonReportTabPanel = Ext.DomQuery.select("div[id='nonReportTabPanel" + k + "']");
        if (tabId == k) {
            nonReportTabPanel[0].className = 'showDiv';
            nonReportTabPanel[0].style.height = OBSettings.GetOtherTabPanelHeight();
        } else {
            nonReportTabPanel[0].className = 'hideDiv';
        }
    }
}

function LoadWordDoc(fileName) {
    var ifrm = document.createElement("IFRAME");
    var url = "http://" + location.host + location.pathname.substring(0, location.pathname.lastIndexOf("/") + 1) + fileName;
    // alert(url);
    ifrm.setAttribute("src", url);
    ifrm.style.width = "100%";
    ifrm.style.height = "100%";
    document.getElementById('nonReportTabPanel4').innerHTML = "";
    document.getElementById('nonReportTabPanel4').appendChild(ifrm);
}

function LoadWordOdt(fileName) {
    var ifrm = document.createElement("IFRAME");
    var url = "http://" + location.host + location.pathname.substring(0, location.pathname.lastIndexOf("/") + 1) + fileName;
    window.open(url);
}

function LoadViewerContent(docType, tabId, isRedline) {

    if (OBSettings.DETAIL_KEY_FIELDS != '') {
        var keyValues = OBSettings.GetDelimittedKeyValuePair('$').split('$');
        var url = './DocLoadHandler.ashx?REPORT_CODE=' + OBSettings.REPORT_CODE + '&KEYLIST=' + keyValues[0]
                    + '&VALUELIST=' + keyValues[1] + '&TYPE=' + docType + '&SQL_FROM=' + OBSettings.SQL_FROM + '&GETSTATUS=true';
        if (isRedline) {
            url = url + "&Redline=true";
        }        
        var statusCode = HttpRequest(url);
        var html;
        if (statusCode.indexOf("$$$$$") == -1) {
            var statusCodeParts = statusCode.split("$$$");
            if (docType == 'doc') {
                LoadWordDoc(statusCodeParts[0]);
            } else if (docType == 'odt') {
                LoadWordOdt(statusCodeParts[0]);
            }
            else {
                if (viewableDocMode == "Server") {
                    url = './DocLoadHandler.ashx?RELFILEPATH=' + statusCodeParts[0] + '&TYPE=' + docType;
                } else {
                    url = kitServerPath + '/DocLoadHandler.ashx?RELFILEPATH=' + statusCodeParts[0] + '&TYPE=' + docType;
                }
                html = GetObjectTag(url, docType, isRedline, statusCodeParts[1]);
            }
        }
        else {
            html = BuildFailureMessage(statusCode.replace("$$$$$:", ""));
        }


        Ext.fly(tabId).update(html);
    }
    else {
        var html = BuildFailureMessage('No data found. <br/>Key fields may not be set for the report.');
        Ext.fly(tabId).update(html);
    }
}

var drawingUrl;
function GetObjectTag(url, docType, isRedline, redlineDocExists) {
    var tag;
    if (docType == "pdf") {
        tag = '<object id="viewer" classid="clsid:CA8A9780-280D-11CF-A24D-444553540000" width="100%"' +
                    'height="100%">' +
                    '<param name="SRC" value="' + url + '"/>' +
                    '<embed src="' + url + '"' +
                    '   width="100%" height="100%">' +
                    '<noembed> Your browser does not support embedded PDF files. </noembed>' +
                '</embed>' +
                '</object>';
    }
    else {
        var height = "75%";
        var buttonHtml = "";
        if (OBSettings.REPORT_CODE != 'TASKS') {
            var caption = "OriginalVersion";
            if (!isRedline) {
                caption = "RedlineVersion";
            }
            var redlineDisabled = redlineDocExists == 'true' || isRedline ? "" : "disabled";
            buttonHtml = '<div style="padding-top:5px;"><input id="btnVersionController" type="button" ' + redlineDisabled + ' value="' + caption + '" onclick="ToggleVersion()" />';
            if (OBSettings.HasPermission('ADD')) {
                buttonHtml += '&nbsp;&nbsp;<input type="button" value="Post UpdateRequest" onclick="OpenPostUpdate()" />';
            }
            
            if (OBSettings.HasPermission('SAVEREDLINE')) {
                buttonHtml += '&nbsp;&nbsp;<input type="button" value="Save As Redline" onclick="SaveAsRedline()" />';
            }
            buttonHtml += '</div>';
        } else {
            height = "100%";
        }

        drawingUrl = url;
        tag = '<object id="ADViewer" classid="clsid:a662da7e-ccb7-4743-b71a-d817f6d575df" width="100%"' +
                    'height=' + height + '">' + '<param name="SRC" value="' + url + '"/>' +
                    '<param name="ToolbarVisible" value="true"/>' +
                    '<param name="MarkupsVisible" value="true"/>' +
                    '<embed id="ADViewer" src="' + url + '"' +
                     'width="100%" height="' + height + '">' +
                     '<param name="ToolbarVisible" value="true"/>' +
                    '<param name="MarkupsVisible" value="true"/>' +
                    '<noembed> Your browser does not support embedded DWF files. </noembed>' +
                '</embed>' +
                '</object>' + buttonHtml;
    }    
    return tag;
}

function ShowPartlistTabContent(){
        if (OBSettings.DETAIL_KEY_FIELDS != '') {
            var keyValues = OBSettings.GetDelimittedKeyValuePair('$').split('$');
            var url = "PartlistDetail.aspx?REPORT_CODE=" + OBSettings.REPORT_CODE + "&KEYLIST=" + keyValues[0] + "&VALUELIST=" + keyValues[1];
            var result = HttpRequest(url);
            Ext.fly('nonReportTabPanel4').update(result);
            LoadPartListForTab(keyValues);
        }
        else {
            var html = BuildFailureMessage('No data found. <br/>Key fields may not be set for the report.');
            Ext.fly('nonReportTabPanel4').update(html);
        }   
}



function ShowDetailTabContent() {
    var tpl;
    if (OBSettings.DETAIL_KEY_FIELDS != '') {
        var keyValues = OBSettings.GetDelimittedKeyValuePair('$').split('$');
        var url = "Details.aspx?REPORT_CODE=" + OBSettings.REPORT_CODE + "&KEYLIST=" + keyValues[0] + "&VALUELIST=" + keyValues[1];
        var result = HttpRequest(url);
        Ext.fly('nonReportTabPanel1').update(result);

        if (OBSettings.DEEPLINK) {
            Ext.get("deeplink").dom.value = GetDeepLink();
        } else {
            var row = document.getElementById('deepLinkRow')
            row.parentNode.removeChild(row);
        }
    }
    else {
        var html = BuildFailureMessage('No data found. <br/>Key fields may not be set for the report.');
        Ext.fly('nonReportTabPanel1').update(html);
    }
}

function GetDeepLink() {
    //location.href.split('?')[0] + "?report=" + deepLinkReport + "&tab=" + deepLinkTab + "&" + unescape(deepLinkWhere);
    return location.href.split('?')[0] + "?report=" + OBSettings.REPORT_CODE + "&tab=" + 1 + "&" + OBSettings.GetKeyValuesAsQueryString();

}

function CreateBaseMaterialDetail() {
    var keyNameValues = OBSettings.GetDelimittedKeyValuePair('$');
    var params = "{ keyNameValues:'" + escape(keyNameValues) + "'}";
    var serviceName = "GetBaseMaterialDetail";

    var result = GetSyncJSONResult_Wrapper(serviceName, params);
    var baseMatdataSet = eval('(' + result + ')');
    baseMatdataSet = baseMatdataSet.d.replace(/"/g, "\"");
    baseMatdataSet = eval('(' + baseMatdataSet + ')');

    var baseMatGrid = Ext.getCmp('baseMatGrid');
    if (baseMatGrid) Ext.destroy(baseMatGrid.view.hmenu);
    Ext.fly('nonReportTabPanel1').update('');
    var nameValue = keyNameValues.split('$');
    var eventAction = "OpenAttachment('Attachment/BaseAttachment.asp?artikelnr=" + nameValue[1] + "')";
    var height = OBSettings.GetMainGridHeight() - 50;
    var width = document.documentElement.clientWidth;
    var margin = width * 10 / 100;
    width = width - margin * 2;
    var layoutText = '<table style="margin-left:' + margin + 'px;margin-top:10px;height:' + (height - 40) + 'px;width:' + width + 'px;"><tr style="height:20px;"><td>Matcode : ' + nameValue[1] + '</td></tr><tr><td><div id="baseMaterialGrid"/></td></tr><tr><td style="text-align:right"><input type="button" value="Appendices" onclick="' + eventAction + '"/></td></tr></table>';
    Ext.fly('nonReportTabPanel1').update(layoutText);
    Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
    Ext.grid.DynamicColumnModel = function(store) {
        var cols = [];
        var recordType = store.recordType;
        var fields = recordType.prototype.fields;
        var colWidth = Ext.lib.Dom.getViewWidth() / fields.keys.length;

        //*** Define grid columns and their properties
        for (var i = 0; i < fields.keys.length; i++) {
            var fieldName = fields.keys[i];
            var field = recordType.getField(fieldName);
            var colHeader = field.name;
            cols[i] = { header: colHeader, dataIndex: field.name, width: colWidth, sortable: true };
        }
        Ext.grid.DynamicColumnModel.superclass.constructor.call(this, cols);
    };

    Ext.extend(Ext.grid.DynamicColumnModel, Ext.grid.ColumnModel, {});

    var store2 = new Ext.data.ArrayStore({
        fields: baseMatdataSet.columnInfo,
        autoDestroy: true
    });

    baseMatGrid = new Ext.grid.GridPanel({
        id: "baseMatGrid",
        listeners: {
    }
});

store2.loadData(baseMatdataSet.gridInfo);
baseMatGrid.store = store2;
baseMatGrid.colModel = new Ext.grid.DynamicColumnModel(store2);
baseMatGrid.height = height;
baseMatGrid.width = "100%";
baseMatGrid.title = '';
baseMatGrid.viewConfig = { autoFill: true, forceFit: true };
baseMatGrid.render('baseMaterialGrid');

}

function ShowOtherTabsLoadingImage(tabId) {
    //*** Show loading image
    Ext.get('nonReportTabPanel' + tabId).setHeight(OBSettings.GetOtherTabPanelHeight());
    Ext.fly('nonReportTabPanel' + tabId).update(OBSettings.GetLoadingPage("#000000"));
}


function BuildFailureMessage(msg) {
    var msgContent = "";
    msgContent += '<table height="100%" width="100%" >';
    msgContent += '  <tr>';
    msgContent += '    <td align="center" style="background-color:#eeffdd; color:#000000;">';
    msgContent += '      <b>' + msg + '</b>';
    msgContent += '    </td>';
    msgContent += '  </tr>';
    msgContent += '</table>';

    return msgContent;
}

function EDIT(event) {
    OBSettings.StopPropagation(event);
    if (OBSettings.REPORT_CODE == "TASKS") {
        var fieldValPair = OBSettings.GetDelimittedFunctionParamValuePair('EDIT', '$').split('$');
        var taskId = fieldValPair[1];
        var tableNameParts = OBSettings.SQL_FROM.split('_');
        if (tableNameParts[tableNameParts.length - 1] == 'v') {
            tableNameParts.pop();
        }
        var tableName = tableNameParts.join('_');
        OpenChild("TaskDetail.aspx?taskId=" + taskId, "PropertyEditor", true, 525, 435, "no", "no", false);
    } else {
    //Ext.Msg.alert("Not implemented yet");
    ShowMessage('Info', "Not implemented yet", 'i', null);


        //        var fieldValPair = OBSettings.GetDelimittedFunctionParamValuePair('EDIT', '$').split('$');
        //        var tableNameParts = OBSettings.SQL_FROM.split('_');
        //        if (tableNameParts[tableNameParts.length - 1] == 'v') {
        //            tableNameParts.pop();
        //        }
        //        var tableName = tableNameParts.join('_');
        //        OpenChild(PROPERTY_EDITOR_VIRTUALDIRECTORY + "/Wrapper.aspx?tableName=" + OBSettings.SQL_FROM + "&fieldNames=" + fieldValPair[0] + "&fieldValues=" + fieldValPair[1] + "&groupName=" + tableName, "PropertyEditor", true, 800, 520, "no", "no", false);
    }

}

function VIEW(event) {
    var values = OBSettings.GetCurrentRowValues('VIEW');
    //Ext.Msg.alert("Not implemented yet for this application");
    ShowMessage('Info', "Not implemented yet for this application", 'i', null);
}
function DELETE(event) {
    OBSettings.StopPropagation(event);
    var values = OBSettings.GetCurrentRowValues('DELETE');
    //Ext.Msg.alert("Not implemented yet for this application");
    ShowMessage('Info', "Not implemented yet for this application", 'i', null);
}

function ZOOM(event) {

    OBSettings.StopPropagation(event);
    //Ext.Msg.alert("Not implemented yet for this application");
    ShowMessage('Info', "Not implemented yet for this application", 'i', null);
    /*
    var values = OBSettings.GetCurrentRowValues('ZOOM');	
    //var tmpValues = value.split(',');
    var centerX = parseFloat(values[0]);
    var centerY = parseFloat(values[1]);
    var zoomScale = parseFloat(values[2]);	
    window.opener.parent.parent.parent.window.frames["mainview"].ZoomToView(centerX,centerY,zoomScale);     
    */
}

function GetValues() {
    var result1 = OBSettings.GetMultiSelectValues('Operation1');
    var result2 = OBSettings.GetMultiSelectValues('Operation2');
    var result3 = OBSettings.GetFunctionParams('Operation2');
}

function BASKET(event) {
    OBSettings.StopPropagation(event);
    
    if (!Ext.getCmp("basketPanel")) {
        //Ext.get("containerDiv").hide();
        var basket = new hit.Controls.basketPanel({});
        //basket.hide();
        basket.render('containerDiv');
        //basket.hide();
        //Ext.get("containerDiv").hide();
    }
    
    //ChaloIS.Basket.grid.AddRow(OBSettings.grid.getSelectionModel().getSelected().data);
    //ChaloIS.Basket.grid.DisplayButtons();
    
    var keyFields = "";
    var value = OBSettings.GetCurrentRowValues('BASKET');        
    var artNr = value[0];
    var verNr = value[1];
    var fileFormat = value[2];
    var relfiletable = OBSettings.SQL_FROM;
    var counter = 0;
    for(var field in OBSettings.DETAIL_KEY_FIELDS)
    {
    if(counter == 0)
    {
    keyFields = field;  
    }
    else
    {
    keyFields += "@@" + field
    }
    counter++;
    }
    //var subPath = artNr.substring(0,2) + "\\"+ artNr.substring(2,4) + "\\";
    //var fileName = artNr + "_" + verNr + ".dwf";
    sendItem(artNr,verNr,fileFormat,relfiletable,keyFields,SECURITY_KEY,kitServerPath);
    

}

function BASKETWITHPARTLIST(event) {
    OBSettings.StopPropagation(event);
    
    if (!Ext.getCmp("basketPanel")) {
        //Ext.get("containerDiv").hide();
        var basket = new hit.Controls.basketPanel({});
        basket.render('containerDiv');
        //basket.hide();
    }
    
   // ChaloIS.Basket.grid.AddRowWithPartlist(OBSettings.grid.getSelectionModel().getSelected().data);
   // ChaloIS.Basket.grid.DisplayButtons();
    
    var keyFields = "";
    var value = OBSettings.GetCurrentRowValues('BASKET');        
    var artNr = value[0];
    var verNr = value[1];
    var fileFormat = value[2];
    var relfiletable = OBSettings.SQL_FROM;
    var counter = 0;
    for(var field in OBSettings.DETAIL_KEY_FIELDS)
    {
    if(counter == 0)
    {
    keyFields = field;  
    }
    else
    {
    keyFields += "@@" + field
    }
    counter++;
    }
    //var subPath = artNr.substring(0,2) + "\\"+ artNr.substring(2,4) + "\\";
    //var fileName = artNr + "_" + verNr + ".dwf";
    //debugger;
    //ChaloIS.Basket.grid.ClearBasket();	 
	 //DeleteAll();
	 
     var lstInfo = ChaloIS.Basket.grid.GivePartlistData();     
     if (lstInfo.gridInfo.length > 0) {
       for(var i=0;i<lstInfo.gridInfo.length; i++){
          artNr = lstInfo.gridInfo[i][1];
          verNr = lstInfo.gridInfo[i][2];  
          sendItem(artNr,verNr,fileFormat,relfiletable,keyFields,SECURITY_KEY,kitServerPath);
       }        
     }
     else{
        sendItem(artNr,verNr,fileFormat,relfiletable,keyFields,SECURITY_KEY,kitServerPath);     
     }
    
    //sendItem(artNr,verNr,fileFormat,relfiletable,keyFields,SECURITY_KEY,kitServerPath);
}

//    for (var i = 0; i < loadedRows.length; i++)
//    {                
//        var rowRecords = loadedRows[i].split('@@@@');
//        ChaloIS.Basket.grid.AddRowWithPartlist(rowRecords);
//    }
         

function SelectCookieReport(repCode, data) {
    for (var i = 0; i < data.length; i++) {
        if (data.items[i].data.report_code.toUpperCase() === repCode.toUpperCase()) {
            return i;
        }
    }
}


function ClearDeeplinkInfo() {
    deepLinkReport = "";
    deepLinkTab = "";
    deepLinkWhere = "";
}

//**************************** Refresh section ***************************

function refresh_notify() {

    //*** set refresh click status
    setElementAttrib("btnRefresh", "blinkstat", "start");

    //*** Change refresh button caption.
    setElementAttrib("btnRefresh", "value", "Refresh!");

    //*** Blink refresh button.
    blink_button("btnRefresh", "on");

    //*** Set focus to this window.
    window.focus();
}

function blink_button(key, state) {

    //*** Get button element/object.
    var oBtn = getElement(key);
    var refreshStat = getElementAttrib("btnRefresh", "blinkstat");

    if (!oBtn || refreshStat == "stop") {
        oBtn.style.backgroundColor = "Transparent";
        //*** Change refresh button caption.
        setElementAttrib("btnRefresh", "value", "Refresh");
        return false;
    }

    //***
    if (state == "on") {
        //*** Set 'on' interface.
        oBtn.style.backgroundColor = "#00334F";

        //*** Keep blinking...
        setTimeout("blink_button('" + key + "', 'off')", 500);

    }
    else {
        //*** Set 'off' interface.
        oBtn.style.backgroundColor = "Transparent";

        //*** Keep blinking...
        setTimeout("blink_button('" + key + "', 'on')", 500);
    }
}


function getElementAttrib(key, attrib) {
    var elem = getElement(key);

    //*** Element not found.
    if (!elem) return false;

    //*** Return value of specified attribute.
    return elem[attrib];
}

function setElementAttrib(key, attrib, value) {
    var elem = getElement(key);

    //*** Element not found.
    if (!elem) return false;

    //*** Set value of specified attribute.
    elem[attrib] = value;
}

function getElement(key) {
    //*** First check if specified key is element id.
    var elem = document.getElementById(key);

    if (!elem) {
        //*** Now check if specified key is element name.
        elem = document.getElementsByName(key);

        //*** Element array found, set element to first one.
        if (elem.length > 0) elem = elem[0];
    }

    if (!elem) {
        //*** Element not found, raise error message.
        //Ext.Msg.alert("Could not find element '" + key + "'");
        ShowMessage('Info', "Could not find element '" + key + "'", 'i', null);

        return false;
    }

    return elem;
}