Ext.namespace('hit.Controls');

hit.Controls.SaveAsWindow = Ext.extend(Ext.Window, {
	id : 'saveAsWindow1',
	constructor : function(config) {
		Ext.apply(config, {
			width : 350,
			height : 285,
			closable : true,
			layout : 'form',
			title : 'Save As New Report',
			bodyStyle : {
				margin : '15px 0px 15px 0px'
			},
			items : [{
						xtype : 'textfield',
						id : 'saveAsReportName',
						fieldLabel : 'Report name',
						width : 150,
						labelStyle : 'margin:0px 0px 10px 10px;',
						allowBlank : false
					}, new Ext.grid.GridPanel({
						id : 'deletereportgrid',
						height : 150,
						emptyText : 'No reports',
						viewConfig : {

							forceFit : true
						},
						store : config.store,
						colModel : config.colModel,
						sm : config.sm
					})],

			buttons : [{
				text : 'Save',
				handler : function() {
					if (this.getComponent('saveAsReportName').validate()) {
						this.SaveAsNewReport(this
								.getComponent('saveAsReportName').getValue());
					}
				},
				scope : this

			}, {
				text : 'Cancel',
				handler : function() {
					Ext.getCmp('mainSettingsPanel').saveAsWindow = false;
					this.close();
				},
				scope : this
			}]

		});
		hit.Controls.SaveAsWindow.superclass.constructor.call(this, config);
	},
	onDestroy : function() {

		Ext.getCmp('mainSettingsPanel').saveAsWindow = false;
		hit.Controls.SaveAsWindow.superclass.onDestroy.call(this);

	} /*
		 * , SaveAsNewReport : function(reportName) { alert(reportName); }
		 */

});
