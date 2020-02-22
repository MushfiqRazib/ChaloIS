// / <reference path="../ext/ext-all.js" />

Ext.namespace('hit.Controls');

hit.Controls.queryBuilder = Ext.extend(Ext.Panel, {
    constructor: function(config) {
        Ext.apply(config, {
            id: 'queryBuilderPanel',
            bodyBorder: false,
            layout: 'form',
            width: '99.2%',
            labelAlign: 'left',
            style: 'background: transparent',
            bodyStyle: {

                'background-color': 'transparent',
                'border': '0px',
                'position': 'relative',
                'overflow': 'hidden'

            },
            autoHeight: false,
            items: [{
                xtype: 'fieldset',
                title: 'Filter',
                id: 'qPanel',
                layout: 'table',
                height: 165,
                style: 'margin-left:7px;margin-top:4px;margin-bottom:0px; padding:0px;',
                bodyStyle: {

                    'background-color': 'transparent'
                },
                layoutConfig: {
                    columns: 5
                },
                items: [{
                    xtype: 'label',
                    id: 'lbfieldName',
                    html: '<span  >Field name</span>',
                    style: {
                        width: '100px',
                        margin: '0px 0px 0px 8px',
                        font: '13px Helvetica,sans-serif'
                    }
                }, {
                    xtype: 'label',
                    id: 'lbComparison',
                    html: '<span >Comparison</span>',
                    style:
                        {
                            'width': '100px',
                            'margin-left': '10px',
                            font: '13px Helvetica,sans-serif'
                        }
                }, {
                    xtype: 'label',
                    id: 'lbValue',
                    html: '<span>Value</span>',
                    style: 'width : 100px; margin-left:10px;font-family:Helvetica,sans-serif;font-size:13px;',
                    colspan: 3
                }, {
                    xtype: 'combo',
                    id: 'cmbFieldName',
                    style: {
                        width: '100px',
                        margin: '0px 0px 0px 8px',
                        font: '13px Helvetica,sans-serif'
                    },
                    mode: 'local',
                    valueField: 'displayValue',
                    displayField: 'displayText',
                    listWidth: 125,
                    typeAhead: true,
                    shadow: false,
                    //forceSelection: true,
                    minChars: 1,
                    triggerAction: 'all',
                    selectOnFocus: true,
                    listeners: {
                        'select': function(ctl, record, index) {

                            var cmbCompValue = Ext
											.getCmp('cmbComparison');
                            var cmbValue = Ext.getCmp('cmbValue');
                            cmbCompValue.setValue('');
                            cmbValue.setValue('');

                            if (typeof (record.data) != 'undefined') {
                                var field_name = record.data.displayValue;
                                var value = field_name.split(';')[1];
                            }
                            else {
                                var field_name = record;
                                var value = field_name;
                            }


                            var fldType = field_name.split(';')[0];

                            var report = OBSettings.REPORT_CODE;
                            var sql_from = OBSettings.SQL_FROM;

                            var params = "{ REPORT_CODE:'"
											+ escape(report) + "', "
											+ "SQL_FROM:'" + escape(sql_from)
											+ "', " + "FIELD_NAME:'"
											+ escape(value) + "'}";

                            var serviceName = "GetFieldValues";

                            var valuesInfo = OBCore.prototype
											.GetSyncJSONResult(serviceName,
													params);
                            valuesInfo = eval('(' + valuesInfo + ')').d; // myMask.hide();
                            var values = valuesInfo.split("###");

                            var data = new Array();
                             
                            for (var k = 0; k < values.length; k++) {
                                if (fldType == "DATE"
												|| fldType == "TIMESTAMP") {
                                    data
													.push(new Array(OBCore.prototype
															.GetDBDateFormat(values[k])));
                                } else {
                                    data.push(new Array(values[k].trim()));
                                }
                            }
                           
                            //cmbValue.store.loadData(data);

                            var optList;
                            if (fldType == "NUMERIC") {
                                optList = new Array("=", "<>", ">",
												"<", ">=", "<=");
                            } else {
                                optList = new Array("=", "<>", ">",
												"<", ">=", "<=", "%LIKE%",
												"%LIKE", "LIKE%");
                            }

                            var d = new Array();
                            for (var k = 0; k < optList.length; k++) {
                                d.push(new Array(optList[k]))
                            }

                            cmbCompValue.store.loadData(d);

                        },
                        'render': function(e) {

                            var fieldList = this.ownerCt.ownerCt
											.GetFieldNames();
                            var field_name = fieldList[0];

                            var data = new Array(fieldList.length);

                            for (var k = 0; k < fieldList.length; k++) {
                                data[k] = new Array(2);
                                var field = fieldList[k].split(';')[1];
                                var text = this.ownerCt.ownerCt
												.GetAlias(field) == ""
												? field
												: this.ownerCt.ownerCt
														.GetAlias(field);

                                data[k][0] = text;
                                data[k][1] = fieldList[k];
                            }

                            var store = new Ext.data.ArrayStore({
                                fields: ['displayText', 'displayValue'],
                                data: data
                            });
                            this.store = store;

                        }
                    }
                }, {
                    xtype: 'combo',
                    id: 'cmbComparison',
                    mode: 'local',
                    store: new Ext.data.ArrayStore({
                        fields: ['dText'],
                        data: []
                    }),
                    listWidth: 125,
                    valueField: 'dText',
                    displayField: 'dText',
                    style: 'width : 100px; margin-left:10px; font-family:Helvetica,sans-serif;font-size:13px;',
                    typeAhead: true,
                    //forceSelection: true,
                    triggerAction: 'all',
                    selectOnFocus: true
                }, {
                    xtype: 'textfield',
                    id: 'cmbValue',
//                    mode: 'local',
//                    store: new Ext.data.ArrayStore({
//                        fields: ['dText'],
//                        data: []
//                    }),
//                    listWidth: 125,
//                    valueField: 'dText',
//                    displayField: 'dText',
                      style: 'width:100px; margin-left:10px; font-family:Helvetica,sans-serif;font-size:13px;',
//                    typeAhead: true,
//                    triggerAction: 'all',

                   // selectOnFocus: true
                }, {
                    xtype: 'box',
                    id: 'boxAdd',
                    style: 'width:20px;font-family:Helvetica,sans-serif;font-size:13px;',
                    autoEl: {
                        tag: 'div',
                        html: '<div style="background:transparent url(./Images/MainFilter.png) no-repeat 0 0;height:23px; width:20px;cursor:pointer;"></div>'
                    },
                    listeners: {
                        'render': function(e) {
                            e.getEl().on('click', function() {
                               

                                var grid = Ext.getCmp('grdExpression');
                                var cmbFieldName = Ext
												.getCmp('cmbFieldName');
                                var cmbCompValue = Ext
												.getCmp('cmbComparison');
                                var cmbValue = Ext.getCmp('cmbValue');


                                if (cmbFieldName.selectedIndex > -1 || cmbFieldName.getValue() != '')
                                //&& cmbValue.selectedIndex > -1)
                                {
                                    var fldNameText = '';
                                    var fldNameValue = '';

                                    if (cmbFieldName.selectedIndex > -1) {
                                        fldNameText = cmbFieldName.store.data.items[cmbFieldName.selectedIndex].data.displayText;
                                        fldNameValue = cmbFieldName.store.data.items[cmbFieldName.selectedIndex].data.displayValue
													.split(';')[1];
                                    }
                                    else {
                                        fldNameText = cmbFieldName.getValue();
                                        fldNameValue = cmbFieldName.getValue();
                                    }

                                    //var fldCompText = cmbCompValue.store.data.items[cmbCompValue.selectedIndex].data.dText;
                                    var fldCompText = cmbCompValue.getValue();
                                    //var fldVal = cmbValue.store.data.items[cmbValue.selectedIndex].data.dText;
                                    var fldVal = cmbValue.getValue();

                                    var expression;
                                    var submitVal;

                                    if (fldCompText.indexOf("LIKE") > -1) {

                                        expression = " LIKE '"
														+ fldCompText.replace(
																'LIKE', fldVal)
														+ "'";
                                        submitVal = " LIKE '"
														+ fldCompText.replace(
																'LIKE',
																fldVal.replace(
																		/'/g,
																		"''"))
														+ "'"
                                    } else {
                                        expression = fldCompText + " '"
														+ fldVal + "'";
                                        submitVal = fldCompText
														+ " '"
														+ fldVal.replace(/'/g,
																"''") + "'";
                                    }

                                    text = fldNameText + " "
													+ expression;
                                    value = fldNameValue + " "
													+ submitVal;

                                    var myMask = new Ext.LoadMask(Ext
															.getBody(), {
															    msg: "Checking...",
															    removeMask: false
															});
                                    myMask.show();
                                    var valuesInfo = this.ownerCt.ownerCt
													.CheckWhereClause(value);
                                    myMask.hide();

                                    if (valuesInfo != "true") {
                                        ShowMessage('Info', valuesInfo, 'i', this.id);

                                        //alert(valuesInfo);
                                        return;
                                    }

                                    if (grid.store.find('dText', text) == -1) {
                                        var u = new grid.store.recordType(
														{
														    dText: text,
														    dValue: value,
														    NameText: fldNameText,
														    NameValue: fldNameValue,
														    CompText: fldCompText,
														    FldValue: fldVal
														});
                                        grid.store.insert(0, u);

                                    } else {
                                        //Ext.Msg.alert('Entry already exists!');
                                        var strMsg = 'Entry already exists!';
                                        ShowMessage('Duplicate Entry', strMsg, 'w', this.id);

                                    }

                                }
                            }, this);
                        }
                    },
                    colspan: 2
                }, {
                    xtype: 'editorgrid',

                    store: new Ext.data.ArrayStore({
                        fields: ['dText', 'dValue'],
                        data: [],
                        autoSave: false
                    }),
                    height: 95,
                    width: 455,
                    sortable: false,
                    style: 'margin-top:8px;margin-left:8px;',
                    columns: [{
                        id: 'dText',
                        dataIndex: 'dText',
                        width: 450
                    }, {
                        id: 'dValue',
                        dataIndex: 'dValue',
                        hidden: true
}],
                        id: 'grdExpression',
                        forceFit: true,
                        autoFill: true,
                        listeners: {
                            render: function(grid) {
                                grid.getView().el.select('.x-grid3-header')
											.setStyle('display', 'none');

                            },
                            afterrender: function(grid) {
                                var whereClausesQB = "";



                                var whereClauses = "";
                                if (OBSettings.SQL_WHERE) {
                                    whereClauses = OBSettings.SQL_WHERE
												.split(/(\s)AND(\s)/ig);

                                }
                                var optionText;

                                if (whereClauses) {

                                    for (var k = 0; k < whereClauses.length; k++) {

                                        var NameTextQB = "";
                                        var NameValueQB = "";
                                        var CompTextQB = "";
                                        var FldValueQB = "";
                                        whereClausesQB = whereClauses[k].split(/\s* \s*/);
                                        NameTextQB = whereClausesQB[0];

                                        NameTextQBAlias = this.ownerCt.ownerCt
														.GetAlias(NameTextQB);
                                        if (NameTextQBAlias == "")
                                            NameTextQBAlias = NameTextQB;
                                        NameValueQB = OBSettings
													.GetFields(NameTextQB);
                                        FldValueQB = whereClausesQB.slice(2).join(' ');

                                        //get compare value and field values
                                        FldValueQB = FldValueQB.slice(1);
                                        FldValueQB = FldValueQB.substring(0, FldValueQB.length - 1)
                                        if (FldValueQB.charAt(0) == '%') {
                                            if (FldValueQB.charAt(FldValueQB.length - 1) == '%') {
                                                CompTextQB = '%LIKE%';
                                                FldValueQB = FldValueQB.slice(1);
                                                FldValueQB = FldValueQB.substring(0, FldValueQB.length - 1);
                                            }
                                            else {
                                                CompTextQB = '%LIKE';
                                                FldValueQB = FldValueQB.slice(1);
                                            }
                                        }
                                        else if (FldValueQB.charAt(FldValueQB.length - 1) == '%') {
                                            CompTextQB = 'LIKE%';
                                            FldValueQB = FldValueQB.substring(0, FldValueQB.length - 1);
                                        }
                                        else
                                            CompTextQB = whereClausesQB[1];
                                        //-------------
                                        var cond = whereClauses[k]
													.split(/(<|>)=|(<>)|[=<>]|(\sLIKE\s)/ig);
                                        cond = OBSettings
													.GetFields(cond[0]);

                                        if (cond.length > 0) {
                                            var alias = this.ownerCt.ownerCt
														.GetAlias(cond[0]);

                                            optionText = whereClauses[k]
														.replace(/''/g, "'")
														.replace('$$$$', '');
                                            if (alias != "") {
                                                optionText = whereClauses[k]
															.replace(cond[0],
																	alias + " ");

                                            }


                                            var u = new grid.store.recordType(
														{
														    dText: optionText,
														    dValue: whereClauses[k],
														    NameText: NameTextQBAlias,
														    NameValue: NameValueQB[0],
														    CompText: CompTextQB,
														    FldValue: FldValueQB
														});
                                            grid.store.insert(0, u);

                                        }

                                    }
                                }

                            }
                        },
                        colspan: 3
                        , sm: new Ext.grid.RowSelectionModel({
                            singleSelect: true,
                            listeners: {
                                rowselect: {
                                    fn: function(sm, index, record) {

                                        var dTexts = record.data.dText.split(/(<|>)=|(<>)|[=<>]|(\sLIKE\s)/ig);
                                        var dValues = record.data.dValue.split(/(<|>)=|(<>)|[=<>]|(\sLIKE\s)/ig);

                                        var cmbFieldName = Ext
                                                .getCmp('cmbFieldName');



                                        var cmbCompValue = Ext
                                                .getCmp('cmbComparison');

                                        var cmbValue = Ext.getCmp('cmbValue');

                                        cmbFieldName.store.clearFilter()

                                        var index = cmbFieldName.store.findExact('displayText', record.data.NameText.trim(), 0);
                                        cmbFieldName.selectedIndex = index;

                                        cmbFieldName.setValue(record.data.NameText.trim());

                                        cmbFieldName.fireEvent('select', cmbFieldName, record.data.NameValue.trim(), null);

                                        cmbValue.setValue(record.data.FldValue);
                                        cmbCompValue.setValue(record.data.CompText.trim());
                                    }
                                }
                            }
                        })
                    }, {
                        xtype: 'box',
                        id: 'boxRemove',
                        style: 'margin-bottom:60px; margin-left:4px;',
                        autoEl: {
                            tag: 'div',
                            html: '<div style="background:transparent url(./Images/removeFilter.png) no-repeat 0 0;height:17px; width:20px;cursor:pointer;"></div>'
                        },
                        listeners: {
                            'render': function(e) {
                                e.getEl().on('click', function() {

                                    var grid = Ext.getCmp('grdExpression');
                                    //                                    var index = grid.getSelectionModel()
                                    //												.getSelectedCell();
                                    var rec = grid.getSelectionModel().getSelections()
                                    if (!rec[0]) {
                                        return false;
                                    }
                                    //var rec = grid.store.getAt(index[0]);
                                    //grid.store.remove(rec);
                                    grid.store.remove(rec[0]);

                                }, this);
                            }
                        }
                    }, {
                        xtype: 'button',
                        id: 'btnApply',
                        text: 'Apply',
                        height: '25px',
                        width: '70px',
                        style: 'margin-top:78px',
                        listeners: {
                            click: function() {

                                var grid = Ext.getCmp('grdExpression');
                                var cmpValue = "";
                                var wherevalue = "";
                                for (var i = 0; i < grid.store.data.length; i++) {
                                    wherevalue = wherevalue
												+ grid.store.data.items[i].data.dValue
												+ " AND ";


                                }
                                if (wherevalue != "") {
                                    wherevalue = wherevalue.substring(0,
												wherevalue.length - 5);

                                }

                                SetReportByWhereFromQB(wherevalue);


                            }
                        }
                    }

				]
}]
                });
                hit.Controls.queryBuilder.superclass.constructor.call(this, config);
            },
            CheckWhereClause: function(value) {
                var report = OBSettings.REPORT_CODE;
                var sql_from = OBSettings.SQL_FROM;

                var params = "{ REPORT_CODE:'" + escape(report) + "', " + "SQL_FROM:'"
				+ escape(sql_from) + "', " + "whereClause:'" + escape(value)
				+ "'}";

                var serviceName = "ValidateWhereClause";
                var valuesInfo = OBCore.prototype
				.GetSyncJSONResult(serviceName, params);

                valuesInfo = eval('(' + valuesInfo + ')').d;
                return valuesInfo;
            },
            GetFieldNames: function() {
                var report = OBSettings.REPORT_CODE;
                var sql_from = OBSettings.SQL_FROM;

                var params = "{ REPORT_CODE:'" + escape(report) + "', " + "SQL_FROM:'"
				+ escape(sql_from) + "'}";

                var serviceName = "GetFieldNameType";
                var valuesInfo = OBCore.prototype
				.GetSyncJSONResult(serviceName, params);
                var fieldList = eval('(' + valuesInfo + ')').d.split('|');
                return fieldList;
            },
            GetAlias: function(field) {
                var capDef;

                capsList = OBSettings.FIELD_CAPS.split(';');
                for (var k = 0; k < capsList.length; k++) {
                    capDef = capsList[k].split('=');
                    if (field.toUpperCase() == capDef[0].toUpperCase()) {
                        return capDef[1];
                    }
                }
                return "";
            }

        });