    
Ext.onReady(function() 
{    
    var sqlFrom = document.getElementById("sqlFrom").value;
    var whereClause = document.getElementById("whereClause").value; 
    var rep_code = document.getElementById("reportCode").value;  
    var params = '{"sqlFrom":"' + sqlFrom + '","whereClause":"'+ whereClause + '","rep_code":"'+ rep_code +'"}';    
    var serviceName = "GetPartListInfo";
    var partListInfo = GetSyncJSONResult_Wrapper(serviceName, params);
    partListInfo = eval('(' + partListInfo + ')');
    partListInfo = partListInfo.d.replace(/"/g, "\"");    
    partListInfo = eval('(' + partListInfo + ')');
    var artCode = partListInfo.Keys[0];
    var revision = partListInfo.Keys[1];
    document.getElementById("lblMatCode").innerText = artCode;
    document.getElementById("lblRevision").innerText = revision;
    CreatePartListGrid(partListInfo);
    
});


var PartlistGrid;
function CreatePartListGrid(partListInfo) 
{
                   
    Ext.fly('partlistgrid').update('');
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

    if (this.PartlistGrid) Ext.destroy(this.PartlistGrid.view.hmenu);
    this.PartlistGrid = new Ext.grid.GridPanel({
        id: "PartList",
        cm:new Ext.grid.DynamicColumnModel(store2)
    });
 
    store2.loadData(partListInfo.gridInfo);
    PartlistGrid.store = store2;
    //PartlistGrid.colModel = new Ext.grid.DynamicColumnModel(store2);
    PartlistGrid.height = 520;
    PartlistGrid.width = "100%";
    PartlistGrid.title = '';
    PartlistGrid.viewConfig = { autoFill: true, forceFit: true };
    PartlistGrid.render('partlistgrid');
   
}