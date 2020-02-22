Ext.namespace('hit.Controls');

hit.Controls.mainsettings = Ext.extend(Ext.Panel, {
	deleteReport : function() {
		var grid = Ext.getCmp('deletereportgrid');
		var selectedReport = grid.selModel.getSelected();

		Ext.Ajax.request({
			url : 'WrapperServices.asmx/DeleteReport',
			headers : {
				'Content-Type' : 'application/json; charset=utf-8'
			},
			jsonData : {
				rep_code : selectedReport.data.reportcode
			},
			success : function(response, request) {
				var result = Ext.decode(response.responseText).d;
				if (result == true) {
					grid.store.remove(selectedReport);
					var reload = false;
					Ext.each(Ext.getCmp('drpReportList').store.data.items,
							function(item) {
								debugger;
								if (selectedReport.data.reportcode == GetSelectedReport()) {
									reload = true;
									return;
								}

							});
					if (reload) {
						LoadReportList();
					} else {

						Ext.each(Ext.getCmp('drpReportList').store.data.items,
								function(item) {
									debugger;
									if (item.data.report_code == selectedReport.data.reportcode){
										Ext.getCmp('drpReportList').store.remove(item);
										return;
									}
								});
					}

				} else {
					ShowMessage(
							"REPORT",
							"Error occured in deleting the report. Please try again.",
							'e', null);
				}
			},
			failure : function(response, request) {
				ShowMessage(
						"REPORT",
						"Error occured in deleting the report. Please try again.",
						'e', null);
			},
			scope : this
		});

	},
	constructor : function(config) {
		Ext.apply(config, {
			id : 'mainSettingsPanel',
			normalWindow : false,
			groupWindow : false,
			saveAsWindow : false,
			width : '99.2%',
			// height: 250,
			bodyBorder : false,
			layout : 'form',

			style : 'margin-left:8px;width:100%;',
			bodyStyle : {
				'background-color' : 'transparent',
				'margin-top' : '3px',
				'border' : 'none',
				'position' : 'relative',
				'overflow' : 'hidden'

			},
			items : [{
				xtype : 'panel',
				id : 'viewContainer',
				layout : 'column',
				bodyBorder : false,
				layoutConfig : {
					columns : 2
				},
				items : [{
					xtype : 'fieldset',
					id : 'nomalView',
					title : this.GetTitle(),
					layout : 'form',
					width : '49.1%',
					style : 'height:210px;float:left;',
					bodyStyle : {
						'background-color' : 'transparent'
					},
					items : [{
						xtype : 'ViewControl',
						id : 'leftNormalVcontrol',
						height : 162,
						width : '100%',
						style : 'margin-top:2px;margin-left:0px;font-size:14px;',
						lgridid : 'nlgridid',
						rgridid : 'nrgridid',
						txfcaptionid : 'ntxfcaptionid',
						txfwidthid : 'ntxfwidthid',
						lblExpId : 'lblLexp',
						btnsetcaptionId : 'nbtnsetcaptionId'

					}, {
						xtype : 'button',
						height : 25,
						width : 70,
						id : 'btnAddNormal',
						style : 'margin:0px 0px 5px 170px;',
						text : 'Add Column',
						listeners : {

							click : function(btn, e) {

								if (!this.ownerCt.ownerCt.ownerCt.normalWindow) {
									new hit.Controls.AddNormalColumnWindow({
												resizable : false,
												x : e.xy[0],
												y : e.xy[1]
											}).show();
									this.ownerCt.ownerCt.ownerCt.normalWindow = true;
								}
							}
						}

					}]
				}]
			}, {
				xtype : 'panel',
				bodyBorder : false,
				style : 'float:right;margin-right:8px;',
				id : 'fButtonPanel',

				layout : 'table',
				layoutConfig : {
					columns : 3
				},
				items : [{
							xtype : 'button',
							height : 25,
							width : 70,
							style : 'margin:10px 0px 0px 0px;',
							text : 'Save',
							listeners : {
								scope : this,
								click : function(btn, e) {
									this.SaveSettings();
								}
							}

						}, {
							xtype : 'button',
							height : 25,
							width : 70,
							style : 'margin:10px 0px 0px 10px;float:right;',
							text : 'Save as',
							listeners : {
								scope : this,
								click : function(btn, e) {

									var storeValues = [];
									Ext
											.each(
													Ext.getCmp('drpReportList').store.data.items,
													function(item) {
														var tempArray = [];
														if(item.data.report_code!='RELEASECANDIDATES' && item.data.report_code!='VRIJGEGEVENARCHIEF'){
														tempArray
																.push(item.data.report_code);
														tempArray
																.push(item.data.report_name);
														tempArray
																.push("<img src='./images/delete.png' style='cursor:pointer' title='See partlist' onclick='hit.Controls.mainsettings.prototype.deleteReport()' />");
														storeValues
																.push(tempArray);
														}
													});

									var store = new Ext.data.ArrayStore({
												fields : [{
															name : 'reportcode'
														}, {
															name : 'reportname'
														}, {
															name : 'delete'
														}],
												idIndex : 0
											});
									var colModel = new Ext.grid.ColumnModel([{
												header : 'Report name',
												width : 260,
												dataIndex : 'reportname',
												menuDisabled : true
											}, {
												header : '',
												width : 30,
												dataIndex : 'delete',
												menuDisabled : true
											}]);

									store.loadData(storeValues);
									var sm = new Ext.grid.RowSelectionModel({
												singleSelect : true
											});

									if (!this.saveAsWindow) {
										var saveAsWin = Ext
												.getCmp('saveAsWindow1');
										if (!Ext.isDefined(saveAsWin)) {
											saveAsWin = new hit.Controls.SaveAsWindow(
													{
														resizable : false,
														x : e.xy[0] - 300,
														y : e.xy[1] - 150,
														store : store,
														colModel : colModel,
														sm : sm
													});
											this.saveAsWindow = true;
											var mainSettingsObj = this;
											saveAsWin.SaveAsNewReport = function(
													reportName) {
												mainSettingsObj
														.SaveAsNewReport(reportName);
											}
										}

										saveAsWin.show();
									}
								}

							}
						}, {
							xtype : 'button',
							height : 25,
							width : 70,
							style : 'margin:10px 0px 0px 10px;float:right;',
							text : 'Apply',
							listeners : {
								click : function(btn, e) {
									this.ownerCt.ownerCt.ApplyTheSettings();
								}
							}
						}]

			}]

		});
		hit.Controls.mainsettings.superclass.constructor.call(this, config);
	},
	ApplyTheSettings : function() {

		var nrgridid = Ext.getCmp('nrgridid');
		if (nrgridid.store.getCount() > 0) {
			var customFields = "", newField;
			var rec;
			var fieldcaps = "";
			var fcap;
			var SQL_GROUP_BY = "";

			OBSettings.COOKIE_SELECTED_FIELDS = "";
			for (k = 0; k < nrgridid.store.getCount(); k++) {
				rec = nrgridid.store.getAt(k);

				newField = rec.data.expression;
				customFields += customFields == ""
						? newField
						: (";" + newField);
				if (// rec.data.fieldName.toUpperCase() != rec.data.caption
				// .toUpperCase()
				rec.data.fieldName != rec.data.caption
						&& trim(rec.data.fieldName) != ""
						&& trim(rec.data.expression) == "") {
					fcap = rec.data.fieldName + "=" + rec.data.caption;
					fieldcaps += fieldcaps == "" ? fcap : (";" + fcap);
				}
				OBSettings.COOKIE_SELECTED_FIELDS += OBSettings.COOKIE_SELECTED_FIELDS == ""
						? rec.data.fieldName
						: (";" + rec.data.fieldName);
				OBSettings.FIELD_SIZE_IN_COOKIE[rec.data.fieldName] = parseInt(rec.data.width);
				/*
				 * if (OBSettings.SQL_GROUP_BY != 'NONE') { if (SQL_GROUP_BY ==
				 * "") SQL_GROUP_BY += rec.data.fieldName ; else SQL_GROUP_BY +=
				 * ","+ rec.data.fieldName ; }
				 */

			}
			// if (OBSettings.SQL_GROUP_BY != 'NONE')
			// OBSettings.SQL_GROUP_BY = SQL_GROUP_BY ;

			if (OBSettings.FIELD_CAPS != "") {
				newCapsList = fieldcaps.split(';');
				oldCapsList = OBSettings.FIELD_CAPS.split(';');
				for (var j = 0; j < oldCapsList.length; j++) {
					capOldDef = oldCapsList[j].split('=');
					if (j >= newCapsList.length) {
						newCapsList.push(oldCapsList[j]);
					} else {
						capNewDef = newCapsList[j].split('=');
						if (capNewDef[0].toUpperCase() != capOldDef[0]
								.toUpperCase()) {
							if (newCapsList[0] == "") {
								newCapsList[0] = oldCapsList[j];

							} else {
								newCapsList.push(oldCapsList[j]);
							}
						}
					}
				}

				// OBSettings.FIELD_CAPS = fieldcaps;

				OBSettings.FIELD_CAPS = newCapsList.toString().replace(/,/g,
						';');
			} else {
				OBSettings.FIELD_CAPS = fieldcaps;
			}
			// OBSettings.GB_SQL_SELECT = "" ;

			if (customFields != OBSettings.QB_GB_SELECT_CLAUSE) {
				customFields = customFields.replace(
						OBSettings.QB_GB_SELECT_CLAUSE, '');
				OBSettings.GB_SQL_SELECT = OBSettings.GB_SQL_SELECT.replace(
						OBSettings.QB_GB_SELECT_CLAUSE, '');
				OBSettings.QB_GB_SELECT_CLAUSE = '';
			}

			ExecuteCustomFieldAction(customFields);

			newField = "";
			customFields = "";

			var nlgridid = Ext.getCmp('nlgridid');
			for (k = 0; k < nlgridid.store.getCount(); k++) {
				rec = nlgridid.store.getAt(k);

				newField = rec.data.expression;
				if (trim(newField) != "") {
					customFields += customFields == ""
							? newField
							: (";" + newField);
				}
				OBSettings.FIELD_SIZE_IN_COOKIE[rec.data.fieldName] = parseInt(rec.data.width);
			}
			if (OBSettings.SQL_GROUP_BY == 'NONE') {
				var currentFields = OBSettings.SQL_SELECT.split(';');
				var currentCustomFields = customFields.split(';');
				for (var k = 0; k < currentCustomFields.length; k++) {
					currentFields.push(currentCustomFields[k]);
				}

				OBSettings.SQL_SELECT = currentFields.join(';');
			} else
				OBSettings.gridStore = nlgridid.store;
		} else {
			ShowMessage("Info",
					"'Please Use at least one field for applying!!'", 'w', null);

			// alert('Please Use at least one field for applying!!');
		}
	},
	GetConfiguredReportSettings : function() {
		var fieldNameandWidth;
		var selectedFWs = '';
		var selectedFieldsWidths; // =
		var customFields = "", newField;
		var rec;
		var fieldcaps = "";
		var fcap;

		var currentFields = OBSettings.SQL_SELECT.split(';');
		for (var k = 0; k < currentFields.length; k++) {
			if (currentFields[k].indexOf(" AS ") > 0) {
				currentFields.splice(k, 1);
				k--;
			}
		}

		var nrgridid = Ext.getCmp('nrgridid');
		for (k = 0; k < nrgridid.store.getCount(); k++) {
			rec = nrgridid.store.getAt(k);

			fieldNameandWidth = rec.data.fieldName + "=" + rec.data.width;
			selectedFWs += selectedFWs == ""
					? fieldNameandWidth
					: (";" + fieldNameandWidth);

			newField = rec.data.expression;
			customFields += customFields == "" ? newField : (";" + newField);
			if (// rec.data.fieldName.toUpperCase() != rec.data.caption
			// .toUpperCase()
			rec.data.fieldName != rec.data.caption
					&& trim(rec.data.fieldName) != ""
					&& trim(rec.data.expression) == "") {
				fcap = rec.data.fieldName + "=" + rec.data.caption;
				fieldcaps += fieldcaps == "" ? fcap : (";" + fcap);
			}

			// OBSettings.COOKIE_SELECTED_FIELDS +=
			// OBSettings.COOKIE_SELECTED_FIELDS == ""
			// ? rec.data.fieldName
			// : (";" + rec.data.fieldName);
			//
			// OBSettings.FIELD_SIZE_IN_COOKIE[rec.data.fieldName] =
			// parseInt(rec.data.width);
		}
		OBSettings.FIELD_CAPS = fieldcaps;

		var nlgridid = Ext.getCmp('nlgridid');
		for (k = 0; k < nlgridid.store.getCount(); k++) {
			rec = nlgridid.store.getAt(k);

			newField = rec.data.expression;
			if (trim(newField) != "") {
				customFields += customFields == ""
						? newField
						: (";" + newField);
			}
			// OBSettings.FIELD_SIZE_IN_COOKIE[rec.data.fieldName] =
			// parseInt(rec.data.width);
		}

		var currentCustomFields = customFields.split(';');
		for (var k = 0; k < currentCustomFields.length; k++) {
			currentFields.push(currentCustomFields[k]);
		}

		OBSettings.SQL_SELECT = currentFields.join(';');
		OBSettings.QB_CUSTOM_FIELDS = customFields;

		selectedFieldsWidths = selectedFWs.split(';');
		var vis_fields = '{"visible_fields":[';
		for (var i = 0; i < selectedFieldsWidths.length; i++) {
			fieldWidth = selectedFieldsWidths[i].split("=");
			vis_fields += '{"Name":"' + fieldWidth[0] + '","Width":"'
					+ fieldWidth[1] + '"},';
		}

		vis_fields = vis_fields.substring(0, vis_fields.length - 1);
		vis_fields += ']';

		vis_fields += ',"qb_custom_fields":"' + OBSettings.QB_CUSTOM_FIELDS
				+ '","qb_gb_select":"' + OBSettings.QB_GB_SELECT_CLAUSE
				+ '","sql_group_by":"' + OBSettings.SQL_GROUP_BY
				+ '","page_size":' + OBSettings.PAGE_SIZE + '}';

		return vis_fields;
	},
	SaveSettings : function() {

		var nrgridid = Ext.getCmp('nrgridid');
		var currentGrid = OBSettings.GetActiveGrid();
		if (currentGrid && nrgridid.store.getCount() > 0) {
			// this.ApplyTheSettings();

			var report_settings = this.GetConfiguredReportSettings();
			// OBSettings.SQL_SELECT = report_settings.SQL_SELECT;
			var confgObj = {};

			confgObj.report_settings = report_settings;
			confgObj.mode = 'update';
			// confgObj.mode = 'new';
			SaveUsersCurrentSettings(confgObj);

			// Set_Cookie("REPORT_CODE", OBSettings.REPORT_CODE);
			// Set_Cookie("REPORT_SETTINGS", report_settings);
			// Set_Cookie("SQL_GROUP_BY", OBSettings.SQL_GROUP_BY);
			// Set_Cookie("SQL_ORDER_BY", OBSettings.SQL_ORDER_BY);
			// this.ApplyTheSettings();
			LoadReportList();
			// InitReport();
			Set_Cookie("REPORT_CODE", OBSettings.REPORT_CODE);
			Set_Cookie("REPORT_SETTINGS", report_settings);
			Set_Cookie("SQL_GROUP_BY", OBSettings.SQL_GROUP_BY);
			Set_Cookie("SQL_ORDER_BY", OBSettings.SQL_ORDER_BY);

		} else {
			ShowMessage('Settings', "No settings available to save", 'w', null);

			// Ext.Msg.alert("No settings available to save");
		}
	},
	SaveAsNewReport : function(reportName) {
		var availableReportCode = GetSyncJSONResult_Wrapper(
				'CheckForReportCodeAvailability', '{"rep_code":"' + reportName
						+ '"}');
		if (Ext.decode(availableReportCode).d == true) {
			var nrgridid = Ext.getCmp('nrgridid');
			var currentGrid = OBSettings.GetActiveGrid();
			if (currentGrid && nrgridid.store.getCount() > 0) {
				this.ApplyTheSettings();
				var report_settings = this.GetConfiguredReportSettings();
				var confgObj = {};

				confgObj.report_settings = report_settings;
				confgObj.mode = 'new';
				confgObj.report_name = reportName;
				SaveUsersCurrentSettings(confgObj);

			} else {
				ShowMessage('Settings', "No settings available to save", 'w',
						null);

				// Ext.Msg.alert("No settings available to save");
			}
		} else {
			ShowMessage('Settings',
					"Report code already used! try with another name.", 'w',
					null);
		}
	},
	GetTitle : function() {
		if (OBSettings.SQL_GROUP_BY != 'NONE') {
			return 'Group By';
		} else {
			return 'Columns'
		}
	}
});