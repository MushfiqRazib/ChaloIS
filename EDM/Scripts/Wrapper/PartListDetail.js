var lstInfo;
function LoadPartListForTab(keyValuePair)
{
   
    var whereClause = "";
    var keys = keyValuePair[0].split(';');
    var values = keyValuePair[1].split(';');
    for(var i=0; i<keys.length; i++)
    {
      if(values[i] != "")
      {
        whereClause += keys[i] + " = '" + values[i] + "'";
      }
      if((i < keys.length-1) && (values[i+1] !=""))
      {
        whereClause += " AND ";
      }
    }

    var sqlFrom = OBSettings.SQL_FROM;
    
    var params = '{"sqlFrom":"' + sqlFrom + '","whereClause":"'+ whereClause + '","rep_code":"'+ OBSettings.REPORT_CODE +'"}'; 
    
    lstInfo = GetSyncJSONResult_Wrapper("GetAvailableListQueryPair", params);
    lstInfo = eval('(' + lstInfo + ')');
    lstInfo = lstInfo.d.replace(/"/g, "\"");    
    lstInfo = eval('(' + lstInfo + ')');
    
    try
    {
        var listName = lstInfo.listNameQueryPair[0][0];
        LoadListItemInfoByListName(listName, whereClause)
    }
    catch (e) 
    {
        ShowMessage('Error', "No list definition found for report "+OBSettings.REPORT_NAME+" \n\n", null);
        Ext.getCmp('obTabs').setActiveTab(0);
    }
}


function LoadListItemInfoByListName(listName, whereClause) {    
     
    var selectedFields = '';
    if (OBSettings.DB_SELECTED_FIELDS.length > 0) {
        selectedFields = OBSettings.DB_SELECTED_FIELDS.split(';');
    }
    else
    {
        selectedFields = OBSettings.SQL_SELECT.split(';');
    }
    
    if (selectedFields.length > 0) {
        params = '{"sqlFrom":"' + OBSettings.SQL_FROM + '","whereClause":"' + whereClause + '","rep_code":"' + OBSettings.REPORT_CODE + '","listName":"' + listName + '","selectedFields":"' + selectedFields[1] + ";" + selectedFields[2] + '"}';
    }
    else {
        params = '{"sqlFrom":"' + OBSettings.SQL_FROM + '","whereClause":"' + whereClause + '","rep_code":"' + OBSettings.REPORT_CODE + '","listName":"' + listName + '","selectedFields":""}';
    }
    var lstDetailInfo = GetSyncJSONResult_Wrapper("GetListItemInfo", params);
   
    lstDetailInfo = eval('(' + lstDetailInfo + ')');
    lstDetailInfo = lstDetailInfo.d.replace(/"/g, "\"");    
    lstDetailInfo = eval('(' + lstDetailInfo + ')');
   
    var listDescription = lstDetailInfo.Keys[3];
    var omschirijvingValue = lstDetailInfo.Keys[1];
    var materialsOtherInfo = lstDetailInfo.Keys[2];
    var current_rev = lstDetailInfo.Keys[4];
    var revisions = lstDetailInfo.revisions;
    var artCode = lstDetailInfo.Keys[0];
    var listNameQueryPair = lstInfo.listNameQueryPair;
    CreateLabels(artCode, omschirijvingValue,materialsOtherInfo, listDescription);
    if(lstDetailInfo.revisions.length>0)
    {
        CreateRevisionCombo(revisions, current_rev,whereClause,listName);
    }
    else
    {
        Ext.get('revisionLabel').dom.style.display = 'none';
    }
    
    var paramsArray = new Array(5);
    paramsArray[0] = OBSettings.SQL_FROM;
    paramsArray[1] =whereClause;
    paramsArray[2] = OBSettings.REPORT_CODE;
    paramsArray[3] =  listName;
    paramsArray[4] = artCode;
    
    CreateListCombo(listNameQueryPair,whereClause,listName);
    CreateListGrid(lstDetailInfo);
    CreateExportButtons(paramsArray);
}

function GetListDataByListName(listName, whereClause) {    
    var selectedFields = '';
    if (OBSettings.DB_SELECTED_FIELDS.length > 0) {
        selectedFields = OBSettings.DB_SELECTED_FIELDS.split(';');
    }
    else
    {
        selectedFields = OBSettings.SQL_SELECT.split(';');
    }

    if (selectedFields.length > 0) {
        params = '{"sqlFrom":"' + OBSettings.SQL_FROM + '","whereClause":"' + whereClause + '","rep_code":"' + OBSettings.REPORT_CODE + '","listName":"' + listName + '","selectedFields":"' + selectedFields[1] + ";" + selectedFields[2] + '"}';
    }
    else {
        params = '{"sqlFrom":"' + OBSettings.SQL_FROM + '","whereClause":"' + whereClause + '","rep_code":"' + OBSettings.REPORT_CODE + '","listName":"' + listName + '","selectedFields":""}';
    }
    var lstDetailInfo = GetSyncJSONResult_Wrapper("GetListItemInfo", params);
    
    lstDetailInfo = eval('(' + lstDetailInfo + ')');
    lstDetailInfo = lstDetailInfo.d.replace(/"/g, "\"");    
    lstDetailInfo = eval('(' + lstDetailInfo + ')');
    
    return lstDetailInfo;
}


var PartlistGridforDetail;
function CreateListGrid(partListInfo) 
{
    var partlistGridContainer = "partlistGridContainer";
    Ext.fly(partlistGridContainer).update('');
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
        fields: partListInfo.columnInfo,
        autoDestroy: true
    });

    if (this.PartlistGridforDetail) Ext.destroy(this.PartlistGridforDetail.view.hmenu);
    this.PartlistGridforDetail = new Ext.grid.GridPanel({
        id: "PartList",
        scroll:'true',
        autoDestroy:'true',
        listeners: { 
            headerClick:function(){
                            return false;
                        },
            headerMouseOver:function(){
                            return false;
                        }        
        }
    });
 
    store2.loadData(partListInfo.gridInfo);
    PartlistGridforDetail.store = store2;
    PartlistGridforDetail.colModel = new Ext.grid.DynamicColumnModel(store2);
    if(Ext.isIE)
    {
        PartlistGridforDetail.height = document.body.clientHeight - 350;
    }
    else
    {
        PartlistGridforDetail.height = window.innerHeight-320;
    }

    PartlistGridforDetail.width = "90%";
    PartlistGridforDetail.title = '';
    PartlistGridforDetail.viewConfig = { autoFill: true, forceFit: true };
    PartlistGridforDetail.render(partlistGridContainer);
   
}

function CreateLabels(artCode, omschirijving,otherLabelInfo, listDescription)
{
    if (Ext.getCmp("lblArticleNo")) Ext.destroy(Ext.getCmp("lblArticleNo"));

    var lblArticleNo = new Ext.form.Label({
                    id: 'lblArticleNo',
                    html: '<span  style="font-family:Helvetica,sans-serif;font-size:12px;">' +artCode + '</span>',
                    renderTo:'articleIdValueContainer',
                    style: {
                        width: '140px'
                        }
                    });
    
    if (Ext.getCmp("lblOmschirijving")) Ext.destroy(Ext.getCmp("lblOmschirijving"));
    var lblOmschirijving = new Ext.form.Label({
                    id: 'lblOmschirijving',
                    html: '<span  >' + omschirijving + '</span>',
                    renderTo:'omschirijvingValueContainer',
                    style: {
                        width: '250px'
                    }
                    });
     
    if (Ext.getCmp("otherMaterialInfo")) Ext.destroy(Ext.getCmp("otherMaterialInfo"));
    var otherMaterialInfo = new Ext.form.Label({
                    id: 'otherMaterialInfo',
                    html: '<span  >' + otherLabelInfo + '</span>',
                    renderTo:'otherMaterialInfoContainer',
                    style: {
                        width: '250px'
                    }
                    });
                    
    if (Ext.getCmp("lblPartlistDescription")) Ext.destroy(Ext.getCmp("lblPartlistDescription"));
    var lblOmschirijving = new Ext.form.Label({
                    id: 'lblPartlistDescription',
                    html: '<span style="font-family:Helvetica,sans-serif;font-size:13px; >' + listDescription + '</span>',
                    renderTo:'partListDescriptionContainer'
                    });
                    
         
}

function CreateRevisionCombo(revisions, current_rev,whereClause,listName)
{
    if (Ext.getCmp("revisionCombo")) Ext.destroy(Ext.getCmp("revisionCombo"));
    var revisionCombo = new Ext.form.ComboBox({
            id: 'revisionCombo',
            name: 'revisionCombo',
            width: 130,
            mode: 'local',
            typeAhead: true,
            selectOnFocus: true,
            forceSelection: true,
            style: 'font-family:Helvetica,sans-serif;font-size:13px;',
            triggerAction: 'all',
            renderTo: 'revComboContainer',
            store:revisions,
            listeners: {
                'render': function(ctl) {
                     var indx = GetItemIndexFromRevCombo(current_rev, ctl.store.data);
                     this.value = ctl.store.data.items[indx].data.field1;
                },
                'select': function(ctl, record) {
                    
                    var wc = whereClause.split('=') ;
                    whereClause = wc[0] + "=" + wc[1] + "='" + record.data.field1 + "'" ;
                    
                    LoadListItemInfoByListName(listName,whereClause);
                    
                }
            }
        });
}

function CreateListCombo(listNameQueryPair,whereClause,listName)
{
    var nameQueryPair = new Array();

    var length = listNameQueryPair.length;
    for (var k = 0;listNameQueryPair[k]; k++) {
        nameQueryPair[k] = new Array(2);
        nameQueryPair[k][0] = listNameQueryPair[k][0];
        nameQueryPair[k][1] = listNameQueryPair[k][1];
    }
    
    var listStore = new Ext.data.ArrayStore({
        fields: ['Name', 'listQuery'],
        autoDestory: true
    });
        listStore.loadData(nameQueryPair);
    if (Ext.getCmp("listCombo")) Ext.destroy(Ext.getCmp("listCombo"));
    var listCombo = new Ext.form.ComboBox({
            id: 'listCombo',
            name: 'listCombo',
            width: 130,
            mode: 'local',
            typeAhead: true,
            selectOnFocus: true,
            forceSelection: true,
            style: 'font-family:Helvetica,sans-serif;font-size:13px;',
            triggerAction: 'all',
            renderTo: 'listComboContainer',
            displayField:'Name',
            valueField:'Name',
            store:listStore,
            listeners: {
                'render': function(ctl) {
                     var indx = 0;
                     indx = GetItemIndexFromListCombo(listName, ctl.store.data);
                     this.value = ctl.store.data.items[indx].data.Name;
                     Ext.get('listFieldSetLegend').dom.textContent =  this.value;
                },
                'select': function(ctl, record) {
                   
                    Ext.get('listFieldSetLegend').dom.textContent = this.getValue();
                    LoadListItemInfoByListName(this.getValue(), whereClause);
                }
            }
        });
}

function GetItemIndexFromListCombo(item, data) {
    for (var i = 0; i < data.length; i++) {
        if (data.items[i].data.Name.toUpperCase() === item.toUpperCase()) {
            return i;
        }
    }
}

function GetItemIndexFromRevCombo(item, data) {
    for (var i = 0; i < data.length; i++) {
        if (data.items[i].data.field1.toUpperCase() === item.toUpperCase()) {
            return i;
        }
    }
}


function CreateExportButtons(paramsArray)
{
    if (Ext.getCmp("btnExportAsXls")) Ext.destroy(Ext.getCmp("btnExportAsXls"));
    var btnExportAsXls = new Ext.Button({
                id:'btnExportAsXls',
                renderTo:'exportasXlsBtnContainer',
				height : 25,
				width : 100,
				style : 'margin-bottom:0px;font-family:Helvetica,sans-serif;font-size:13px;',
				text : 'Export as XLS',
				listeners:{
			                  'click':function(button,e)
			                   {
			                        GenerateExcelOrCSVReportForList(paramsArray);
			                   }
			              },
				handler : function(btn, e) {
							}
																				
					});
	
	if (Ext.getCmp("btnExportAsPdf")) Ext.destroy(Ext.getCmp("btnExportAsPdf"));
    var listCombo = new Ext.Button({
                id:'btnExportAsPdf',
                renderTo:'expotasPdfBtnContainer',
				height : 25,
				width : 100,
				style : 'margin-bottom:0px;font-family:Helvetica,sans-serif;font-size:13px;',
				text : 'Export as PDF',
				listeners:{
			                  'click':function(button,e)
			                   {
			                        GeneratePdfReportForList(paramsArray);
			                   }
			              },
				handler : function(btn, e) {
							}
																				
					});
}