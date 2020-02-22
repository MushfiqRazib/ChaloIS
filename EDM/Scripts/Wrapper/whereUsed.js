var baseMatGrid;
var vmargin = 14 / 100;
var hmargin = 8 / 100;

Ext.onReady(function() {
    CreateBaseMaterialDetail();
});

function CreateBaseMaterialDetail() {
    var keyNameValues = opener.OBSettings.GetDelimittedKeyValuePair('$');
    var params = '{"keyNameValues":"' + keyNameValues + '","rep_code":"'+ opener.OBSettings.REPORT_CODE +'"}'; 
    var serviceName = "GetBaseMaterialDetail";

    var result = GetSyncJSONResult_Wrapper(serviceName, params);
    var baseMatdataSet = eval('(' + result + ')');
    baseMatdataSet = baseMatdataSet.d.replace(/"/g, "\"");
    baseMatdataSet = eval('(' + baseMatdataSet + ')');
    
    baseMatGrid = Ext.getCmp('baseMatGrid');
    if (baseMatGrid) Ext.destroy(baseMatGrid.view.hmenu);
    Ext.fly('WhereUsedDiv').update('');
    var nameValue = keyNameValues.split('$');

    // var eventAction = "opener.OpenAttachment('Attachment/BaseAttachment.asp?artikelnr=" + nameValue[1] + "')";
    var height = GetGridHeight();
    var width = GetGridWidth();
    var top = document.documentElement.clientHeight * vmargin / 2;
    var left = document.documentElement.clientWidth * hmargin / 2;
    var layoutText = '<table style="margin-left:' + left + 'px;margin-top:10px;height:' + top + 'px;width:' + width + 'px;"><tr style="height:20px;"><td>Matcode : ' + nameValue[1] + '</td></tr><tr><td><div id="baseMaterialGrid"/></td></tr><tr><td style="text-align:right;"><input type="button" value="Close" onclick="self.close()"/> </td></tr></table>';
    Ext.fly('WhereUsedDiv').update(layoutText);

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
baseMatGrid.width = width;
baseMatGrid.title = '';
baseMatGrid.viewConfig = { autoFill: true, forceFit: true };
baseMatGrid.render('baseMaterialGrid');
}

window.onresize = function() {
    SetGridSize();
}

function GetGridHeight() {
    var height = document.documentElement.clientHeight;
    var top = height * vmargin;
    height = height - top;
    return height;
}

function GetGridWidth() {
    var width = document.documentElement.clientWidth;
    var left = width * hmargin;
    width = width - left;
    return width;
}

function SetGridSize() {
    var height = GetGridHeight();
    var width = GetGridWidth();

    // Ext.get("WhereUsedDiv").setHeight(height); 
    baseMatGrid.setSize(width, height);

}




Ext.override(Ext.grid.GridPanel, {
    applyState: function(state) {
        try {
            var cm = this.colModel;
            var cs = state.columns;
            if (cs) {
                for (var i = 0, len = cs.length; i < len; i++) {
                    var s = cs[i];
                    var c = cm.getColumnById(s.id);
                    if (c) {
                        c.hidden = s.hidden;
                        c.width = s.width;
                        var oldIndex = cm.getIndexById(s.id);
                        if (oldIndex != i) {
                            cm.moveColumn(oldIndex, i);
                        }
                    }
                }
            }
            if (state.sort && this.store) {
                this.store[this.store.remoteSort ? 'setDefaultSort' : 'sort'](state.sort.field, state.sort.direction);
            }
            delete state.columns;
            delete state.sort;
            Ext.grid.GridPanel.superclass.applyState.call(this, state);
        } catch (e) {
        }
    }
});
