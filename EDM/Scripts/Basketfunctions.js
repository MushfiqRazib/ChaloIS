Ext.namespace('ChaloIS.Basket','ChaloIS.Basket.BasketService');
ChaloIS.Basket.BasketService = GetBasketServiceUrl();

Array.prototype.isCoontainColumn = function(value){
   
    for(var i=0;i<this.length;i++)
    {
        if(this[i].name != undefined && value.name != undefined && (this[i].name == value.name))
        {
            return true;
        }
        else if(this[i] == value)
        {
            return true;
        }
        
    }
    
    return false;
}

ChaloIS.Basket.SyncAjaxRequest = function(serviceName,postData)
{
    var url =  ChaloIS.Basket.BasketService + "/" + serviceName;
    
    var xmlhttp = null;
    if (window.XMLHttpRequest)
        xmlhttp = new XMLHttpRequest();
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
    xmlhttp.send(postData);
    var responseText = "";
    
    try
    {
        responseText = eval('('+xmlhttp.responseText+')').d;
    }
    catch(e)
    {
        responseText = "Json parse error !";
    }
    return responseText;
}

ChaloIS.Basket.DynamicColumnModel = Ext.extend(Ext.grid.ColumnModel,{
    constructor:function(store)
    {
        var cols = [];
        var recordType = store.recordType;
        var fields = recordType.prototype.fields;
        var colWidth = 25;
        
        //*** Define grid columns and their properties
        for (var i = 0; i < fields.keys.length; i++) {
            var fieldName = fields.keys[i];           
            var field = recordType.getField(fieldName);
            var colHeader = field.name;            
            
            if(colHeader == "#" || colHeader == ""|| colHeader == " ")
            {
                cols[i] = { header: colHeader, dataIndex: field.name, width: 25, sortable: false,menuDisabled:true }; 
            }           
            else
            {
                cols[i] = { header: colHeader, dataIndex: field.name, sortable: false,menuDisabled:true }; 
            }
        }
        ChaloIS.Basket.DynamicColumnModel.superclass.constructor.call(this, cols);
    }
});

ChaloIS.Basket.grid = function() {
    var store;
    var grid;
    var basketData = [];
    var basketFields = ['Artikelnr', 'Revisie', 'Stuklijst', 'Bron document', 'Algemene bijlagen', 'Revisie bijlagen', 'Te printen bijlagen', 'Delete'];
    //var bFields = ['Artikelnr', 'Revisie', 'Stuklijst', 'Brondocument', 'Algemene bijlagen', 'Revisie bijlagen', 'Te printen bijlagen', 'Delete'];
   
    var keyFieldObjs = [];
    var basketName = "";
    var basketDescription = "";
    var previous_report_name = "";

    var CollectFieldsFromReportGrid = function() {
        
        var settings = GetCurrentReportSettings();
        var fieldObjArr = eval('(' + settings + ')').visible_fields;
        var keyFields = OBSettings.GetDelimittedKeyValuePair('$*$').split('$*$')[0].split(';');

        for (var i = 0; i < keyFields.length; i++) {
            var keyFldName = OBSettings.GetAlias(keyFields[i])
            basketFields.push({ name: keyFldName });
            keyFieldObjs.push({ name: keyFldName, originalname: keyFields[i] });
        }


        for (var i = 0; i < fieldObjArr.length; i++) {
            if (basketFields.length == 6) {
                break;
            }

            var fldName = OBSettings.GetAlias(fieldObjArr[i].Name);
            if (!basketFields.isCoontainColumn({ name: fldName })) {
                basketFields.push({ name: fldName });
            }

        }
        basketFields.push({ name: ' ' });
        //basketFields.unshift({ name: '#' });
        basketFields.push({ name: '' });

        return basketFields;
    }

    return { 

        init: function() {
            //CollectFieldsFromReportGrid();
            this.CreateStore();

            if (previous_report_name !== OBSettings.REPORT_NAME) {
                previous_report_name = OBSettings.REPORT_NAME;
                this.ClearBasket();
            }
            store.loadData(basketData);

            var colModel = new Ext.grid.ColumnModel
            ([{
                header: basketFields[0],
                width: 30,
                dataIndex: basketFields[0],
                menuDisabled: true
            }, {
                header: basketFields[1],
                width: 50,
                dataIndex: basketFields[1],
                menuDisabled: true
            }, {
                header: basketFields[2],
                width: 50,
                dataIndex: basketFields[2],
                menuDisabled: true
            }, {

                header: basketFields[3],
                width: 50,
                dataIndex: basketFields[3],
                menuDisabled: true

            }, {
                header: basketFields[4],
                width: 50,
                dataIndex: basketFields[4],
                menuDisabled: true

            }, {
                header: basketFields[5],
                width: 50,
                dataIndex: basketFields[5],
                menuDisabled: true
            }, {
                header: basketFields[6],
                width: 50,
                dataIndex: basketFields[6],
                menuDisabled: true
            }, {
                header: '',
                width: 20,
                dataIndex: basketFields[7],
                menuDisabled: true
            }
		]);

            grid = new Ext.grid.GridPanel({
                id: 'basketGrid'
                , style: 'margin-left:8px;margin-top:3px;'
                , height: 160
                //, width: 660
                , sortable: false
                , store: store
                //, colModel: new ChaloIS.Basket.DynamicColumnModel(store)
                , colModel: colModel
                , viewConfig: { autoFill: true, forceFit: true }
                , listeners:
                {
                    afterrender: function() {
                        setTimeout(this.removeRightMostGridHeaderSpace, 1);
                    }
                    , scope: this
                }
            });

            return grid;
        },
        removeRightMostGridHeaderSpace: function() {
            var tableEl = Ext.get(Ext.getCmp('basketGrid').getView().getHeaderCell(0)).findParent('table');
            var curWidth = Ext.get(tableEl).getWidth();
            var fixedWidth = parseInt(curWidth) + 24;
            Ext.get(tableEl).setWidth(fixedWidth);
            Ext.get(Ext.get(tableEl).findParent('div')).setWidth(fixedWidth);
        },
        removeRightMostGridViewSpace: function() {
            var recCount = grid.store.getCount();

            for (var i = 0; i < recCount; i++) {
                var recEl = Ext.get(Ext.getCmp('basketGrid').getView().getRow(i));
                var curWidth = recEl.getWidth();
                var fixedWidth = parseInt(curWidth) + 24;
                recEl.setWidth(fixedWidth);
                recEl.child('table').setWidth(fixedWidth);

            }
        }
        ,
        CreateStore: function() {
            // First 6 fields including PK
            store = new Ext.data.ArrayStore({
                fields: basketFields,
                autoDestroy: true
            });
        },
        DeleteRow: function(artNo,revNo,rowNo) {
            /*var index = -1;
            var i = 0;
            store.each(function(record)
            {
            if (record.get("#") == rowNo)
            {
            index = i;
            }
            i++;
            });

            store.removeAt(index);
            basketData.splice(index, 1);
            this.DisplayButtons();
            */

            store.removeAt(rowNo - 1);
            basketData.splice(rowNo - 1, 1);
            this.DisplayButtons();
            deleteRow(artNo,revNo);
        },
        ExpandPartlist: function() {
            ShowMessage('Info', "Not yet implemented ", 'i', null);
        },
        AddRow: function(newGridRecordParam)
        {
           
            // MAKE SURE LOADED DATA IS IN THIS ORDER ..!!
            //0 = artikelnr (id)
            //1 = revisie (revision)
            //2 = stuklijst
            //3 = bron document
            //4 = algemene bijlagen
            //5 = revisie bijlagen
            //6 = te printen bijlagen
            //7 = delete
            
            // Set the last item as the delete image
           // newGridRecordParam[newGridRecordParam.length -1] = "<img src='./images/delete.png' style='cursor:pointer' title='See partlist' onclick='ChaloIS.Basket.grid.DeleteRow(" + (basketData.length + 1) + ")' />";

            newGridRecordParam[newGridRecordParam.length] = "<img src='./images/delete.png' style='cursor:pointer' title='See partlist' onclick='ChaloIS.Basket.grid.DeleteRow(\"" +
                  newGridRecordParam[0]+"\",\"" +  newGridRecordParam[1]+"\"," +  (basketData.length + 1) + ")' />";

            basketData.push(newGridRecordParam);
            store.loadData(basketData);

            if (store.data.length < 7)
                this.removeRightMostGridViewSpace();
        },
        AddRowWithPartlist: function(newGridRecordParam)
        {
            // WORK ON THIS
           
            for (var i = 0; i < basketFields.length; i++) {
                if (basketFields[i] == "#" || basketFields[i] == "") {
                    continue;
                }
                else if (basketFields[i] == " ") {                    
                    var lstInfo = this.GivePartlistData();
                    if(lstInfo != null){
                        if (lstInfo.gridInfo.length > 0) {
                            var partlistImage = "<img " + (basketData.length + 1) + " src='./images/attachparts.png' style='cursor:pointer' title='Partlist items' onclick='ChaloIS.Basket.grid.OpenPartlistTab(" + (basketData.length + 1) + ")' />";
                            basketData.push(partlistImage);
                        }
                    }
                    else {
                        //basketRecordValue.push("");
                    }
                    continue;
                }
                //var originalFldName = OBSettings.GetOriginalFieldName(basketFields[i]);
                //basketData.push(newGridRecordParam[originalFldName]);
            }

               newGridRecordParam[newGridRecordParam.length] = "<img src='./images/delete.png' style='cursor:pointer' title='See partlist' onclick='ChaloIS.Basket.grid.DeleteRow(\"" +
                                       newGridRecordParam[0]+"\",\"" +  newGridRecordParam[1]+"\"," +  (basketData.length + 1) + ")' />";

               basketData.push(newGridRecordParam);           
              
              //basketData.push(basketData);

            // basketRecordValue.unshift(basketData.length + 1);
            //basketData.push(basketRecordValue);
            if(lstInfo !=null) {
            if (lstInfo.gridInfo.length > 0) {
                for (var i = 0; i < lstInfo.gridInfo.length; i++) {
                    var bitem = newGridRecordParam["item"];
                    if (bitem != lstInfo.gridInfo[i][4]) {
                        var selectedFields = '';
                        var whereClause = " item = '" + lstInfo.gridInfo[i][4] + "'";
                        if (OBSettings.DB_SELECTED_FIELDS.length > 0) {
                            selectedFields = OBSettings.DB_SELECTED_FIELDS.split(';');
                        }
                        else {
                            selectedFields = OBSettings.SQL_SELECT.split(';');
                        }


                        if (selectedFields.length > 0) {
                            var selFields = selectedFields[0] + "," + selectedFields[1] + "," + selectedFields[2] + "," + selectedFields[3] + "," + selectedFields[4] + "," + selectedFields[5];
                        }

                        if (selectedFields.length > 0) {
                            //params = '{"sqlFrom":"' + OBSettings.SQL_FROM + '","whereClause":"' + whereClause + '","selectedFields":"' + selectedFields.join(",") + '"}';
                            params = '{"sqlFrom":"' + OBSettings.SQL_FROM + '","whereClause":"' + whereClause + '","selectedFields":"' + selFields + '"}';
                        }
                        else {
                            params = '{"sqlFrom":"' + OBSettings.SQL_FROM + '","whereClause":"' + whereClause + '","selectedFields":""}';
                        }
                        var lstDetailInfo = GetSyncJSONResult_Wrapper("GetItemInfoByItemNo", params);

                        lstDetailInfo = eval('(' + lstDetailInfo + ')');
                        lstDetailInfo = lstDetailInfo.d.replace(/"/g, "\"");
                        lstDetailInfo = eval('(' + lstDetailInfo + ')');

                        if (lstDetailInfo.ItemInfo.length > 0) {
                            var deleteImg = "<img src='./images/delete.png' style='cursor:pointer' title='Remove item' onclick='ChaloIS.Basket.grid.DeleteRow(\"" +
                                       newGridRecordParam[0]+"\",\"" +  newGridRecordParam[1]+"\"," + (basketData.length + 1) + ")' />";
                            var iteminfo = lstDetailInfo.ItemInfo[0];
                            iteminfo.push(deleteImg);
                            basketData.push(iteminfo);
                        }
                    }
                }
              }
            }
            store.loadData(basketData);

            if (store.data.length < 7) {
                this.removeRightMostGridViewSpace();
            }
        },
        GivePartlistData: function() {
            var keyValues = OBSettings.GetDelimittedKeyValuePair('$').split('$');
            var whereClause = "";
            var keys = keyValues[0].split(';');
            var values = keyValues[1].split(';');
            for (var j = 0; j < keys.length; j++) {
                if (values[j] != "") {
                    whereClause += keys[j] + " = '" + values[j] + "'";
                }
                if ((j < keys.length - 1) && (values[j + 1] != "")) {
                    whereClause += " AND ";
                }
            }

            return GetListDataByListName("Partlist", whereClause);
        }
        ,
        OpenPartlistTab: function(selectedIndx) {

            Ext.getCmp('obTabs').setActiveTab(4);
            var keyValuePair = new Array();
            var revision = "";
            var item = "";
            for (var i = 0; i < basketFields.length; i++) {
                if (basketFields[i] == "item") {
                    item = basketData[selectedIndx - 1][i];
                }
                else if (basketFields[i] == "revision") {
                    revision = basketData[selectedIndx - 1][i];
                }
            }
            keyValuePair[0] = "item;revision";
            keyValuePair[1] = item + ";" + revision;
            LoadPartListForTab(keyValuePair);
        }
        ,
        GetBasketName: function() {
            return basketName;
        },
        GetBasketDescription: function() {
            return basketDescription;
        },
        GetKeyFields: function() {
            return keyFieldObjs;
        },
        InitAjaxSaveRequest: function(postData) {
            return ChaloIS.Basket.SyncAjaxRequest("SaveBasketToXML", postData);
        },

        InitAjaxDeleteRequest: function(postData) {
            return ChaloIS.Basket.SyncAjaxRequest("DeleteBasketFromXML", postData);
        },
        InitAjaxRestoreRequest: function(postData) {
            return ChaloIS.Basket.SyncAjaxRequest("RestoreBasket", postData);
        }
        ,
        SaveBasket: function(filename, description, saveWindow) {
            
            var paramRecords = "";
            //var keyFldObj = this.GetKeyFields();
            var keyFldObj = basketFields;
            store.each(function(record) {

                var params = "";
                var originalfieldname = "";
                if (paramRecords != "") {
                    paramRecords += ";";
                }
                
                 /*for (var i = 0 ; i <basketFields.length; i++)
                 {
                    var keyValue = record.get(keyFldObj[i].name);
                 } */
                
                
                for (var i = 0; i < keyFldObj.length; i++) {
                    //var keyValue = record.get(keyFldObj[i].name);
                    var keyValue = record.get(keyFldObj[i]);
                    if (keyFldObj[i] != "Delete")
                    {
                        if (params != "") {
                           // params += "," + OBSettings.GetOriginalFieldName(keyFldObj[i].name) + ":" + keyValue;
                           // params += "," + OBSettings.GetOriginalFieldName(keyFldObj[i]) + ":" + keyValue;
                            originalfieldname = OBSettings.GetOriginalFieldName(keyFldObj[i]);         
                            params += "," + this.CheckforSpaceinColumnName(originalfieldname) + ":" + keyValue;                           
                        }
                        else {
                           // params += OBSettings.GetOriginalFieldName(keyFldObj[i].name) + ":" + keyValue;
                            //params += OBSettings.GetOriginalFieldName(keyFldObj[i]) + ":" + keyValue;
                            originalfieldname = OBSettings.GetOriginalFieldName(keyFldObj[i]);
                            params += this.CheckforSpaceinColumnName(originalfieldname) + ":" + keyValue;
                        }
                    }
                }
                /*
                if (record.get(' ')) {
                    params += "," + "parts:exists";
                }*/

                paramRecords += params;

            }, this);
           
            var postData = "{basketitems:'" + paramRecords + "',reportcode:'" + OBSettings.REPORT_CODE + "',filename:'" + filename + "',description:'" + description + "',overwrite:false}";
            var response = this.InitAjaxSaveRequest(postData);

            if (response == "exist") {
                Ext.MessageBox.buttonText.yes = "Overwrite";
                Ext.Msg.show({
                    title: 'Collection already exist',
                    msg: 'Do you want to overwrite the previous collection ?',
                    buttons: Ext.Msg.YESNO,
                    icon: Ext.MessageBox.QUESTION,
                    fn: function(btn) {
                        if (btn == 'yes') {
                            response = this.InitAjaxSaveRequest(postData.replace("overwrite:false", "overwrite:true"));
                            if (response == "saved") {
                                saveWindow.close();
                            }
                            else this.ShowErrorMsg(response);
                        }
                    },
                    scope: this
                });
            }
            else if (response == "saved") {
                saveWindow.close();
                basketName = filename;
                basketDescription = description;
            }
            else this.ShowErrorMsg(response);

        },
        CheckforSpaceinColumnName: function(colName){
            if(colName.search(' ') > -1){
              return colName.replace(/ /g,'_');
            }
            else
                colName; 
        },
        ClearBasket: function() {
            store.removeAll();
            basketData = [];
            basketName = "";
            basketDescription = "";
        },
        ClearBasketData: function(){
            basketData = [];
        },
        RestoreBasket: function(filename, description, wnd) {
           
            this.ClearBasket();
            DeleteAll();
            var postData = "{reportcode:'" + OBSettings.REPORT_CODE + "',basketname:'" + filename + "'}";
            var response = this.InitAjaxRestoreRequest(postData);
            var mainArr = response.split(',');
            
            for (var i = 0 ; i < mainArr.length; i++)
            {
                var counter = 0;
                var keyFields = "";
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
               
                
                var iteminfo = mainArr[i].split('#') ;
                sendItem(iteminfo[0],iteminfo[1],"",OBSettings.SQL_FROM,keyFields,SECURITY_KEY,kitServerPath);
                             
                //this.AddRow(mainArr[i].split('#'));
            }
            
//            var records = eval('(' + response + ')');
//            for (var i = 0; i < records.length; i++) {
//                this.AddRow(records[i]);
//            }
            basketName = filename;
            basketDescription = description;
            wnd.close();
            ChaloIS.Basket.grid.DisplayButtons();

        },
        Update: function() {
            //SELECT item,revision,file_format,file_name FROM va_item_hit WHERE item in ('90150741','90150753','90150802')
            DeleteAll();

            Ext.Msg.confirm('Confirm upgrade', 'Are you sure you want to upgrade all documents to the latest revision?', function(btnResult) {
                if (btnResult == 'yes' && store.data.length > 0) {
                    var itemin = [];
                    for (var i = 0; i < basketData.length; i++) {
                        itemin.push("'" + basketData[i][0] + "'");

                    }


                    var params = '{"sqlFrom":"' + 'SELECT item,revision,description,relfilename,file_subpath,file_name,file_format FROM ' + OBSettings.SQL_FROM + ' WHERE item in (' + itemin.join(",") + ')" }';
                    var lstDetailInfo = GetSyncJSONResult_Wrapper("UpdateBusket", params);

                    lstDetailInfo = eval('(' + lstDetailInfo + ')');
                    lstDetailInfo = lstDetailInfo.d.replace(/"/g, "\"");
                    lstDetailInfo = eval('(' + lstDetailInfo + ')');
                    
                    if (lstDetailInfo.ItemInfo.length > 0) {
                        this.ClearBasket();
                        for (var i = 0; i < lstDetailInfo.ItemInfo.length; i++) {
                            var deleteImg = "<img src='./images/delete.png' style='cursor:pointer' title='Remove item' onclick='ChaloIS.Basket.grid.DeleteRow(" + (basketData.length + 1) + ")' />";
                          
                             var counter = 0;
                             var keyFields = "";
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
                           
                            var iteminfo = lstDetailInfo.ItemInfo[i];
                             sendItem(iteminfo[0],iteminfo[1],iteminfo[6],OBSettings.SQL_FROM,keyFields,SECURITY_KEY,kitServerPath);
                            //sendItem(
                            //iteminfo.push(deleteImg);
                            //basketData.push(iteminfo);
                        }
                    }



//                    store.loadData(basketData);

//                    if (store.data.length < 7) {
//                        this.removeRightMostGridViewSpace();
//                    }

                }
            }, this);



        },
        ShowErrorMsg: function(errmsg) {
            Ext.Msg.show({
                title: "Error !",
                msg: errmsg,
                buttons: Ext.Msg.OK,
                icon: Ext.MessageBox.ERROR
            });
        },
        isEmpty: function() {
            if (store.getCount()) return false;
            else return true;
        },
        DestroyGrid: function() {
            grid.getStore().destroy();
            grid.getSelectionModel().destroy();
            Ext.destroy(grid.view.hmenu);
            Ext.destroy(grid);
            grid = null;
            store = null;
            basketData = [];
            keyFieldObjs = [];
            basketName = "";
        },

        DeleteRestoreGridRow: function(wintype) {
           
            var RestoreGridStore;
            var deleteItem;
            if (wintype == 0) {
                RestoreGridStore = Ext.getCmp('restoregrid').store;
                deleteItem = Ext.getCmp('restoregrid').selModel.getSelected();
            }
            else if (wintype == 1) {
                RestoreGridStore = Ext.getCmp('savewinrestoregrid').store;
                deleteItem = Ext.getCmp('savewinrestoregrid').selModel.getSelected();
            }

            RestoreGridStore.remove(deleteItem);
            var filename = deleteItem.data.name;
            var postData = "{reportcode:'" + OBSettings.REPORT_CODE + "',filename:'" + filename + "'}";
            var response = this.InitAjaxDeleteRequest(postData);



        },
        DisplayButtons: function() {

            var grid = Ext.getCmp('basketGrid');
            if (grid.store.data.items.length > 0) {
                grid.ownerCt.ownerCt.ownerCt.findById('btnBasketSave').setDisabled(false);
                grid.ownerCt.ownerCt.ownerCt.findById('btnBasketRemoveAll').setDisabled(false);
                //grid.ownerCt.ownerCt.ownerCt.findById('btnBasketRelease').setDisabled(false);
                grid.ownerCt.ownerCt.ownerCt.findById('btnBasketDistribute').setDisabled(false);
                grid.ownerCt.ownerCt.ownerCt.findById('btnBasketPrint').setDisabled(false);
                if (Ext.getCmp('drpReportList').value == 'RELEASECANDIDATES' || Ext.getCmp('drpReportList').value == 'Release Candidates') {
                    grid.ownerCt.ownerCt.ownerCt.findById('btnBasketRelease').setDisabled(false);
                    grid.ownerCt.ownerCt.ownerCt.findById('btnBasketDistribute').setDisabled(true);


                }
            }
            else {
                grid.ownerCt.ownerCt.ownerCt.findById('btnBasketSave').setDisabled(true);
                grid.ownerCt.ownerCt.ownerCt.findById('btnBasketRemoveAll').setDisabled(true);
                //grid.ownerCt.ownerCt.ownerCt.findById('btnBasketRelease').setDisabled(true);
                grid.ownerCt.ownerCt.ownerCt.findById('btnBasketDistribute').setDisabled(false);
                grid.ownerCt.ownerCt.ownerCt.findById('btnBasketPrint').setDisabled(true);
                grid.ownerCt.ownerCt.ownerCt.findById('btnBasketRelease').setDisabled(true);


            }

        }
    }


} ();









