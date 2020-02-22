Ext.namespace('hit.Controls');

hit.Controls.AddGroupColumnWindow = Ext.extend(Ext.Window, {
	id : 'addGroupColWidow',
	initComponent : function() {
		Ext.applyIf(this, {
					width : 280,
					height : 170,
					layout : 'table',
					layoutConfig : {
									columns : 2
								},
					plain : true,
					title : 'Add Column',
					bodyStyle : {
						margin : ' 5px 5px 0px 5px'
					},
					items : [{
								xtype : 'panel',
								colspan:2,
								bodyBorder : false,
								bodyStyle : {
									'background' : 'transparent',
									'border' : 'none',
									'margin' : '10px 0px 0px 0px'
								},
								layout : 'table',
								layoutConfig : {
									columns : 3
								},
								items : [{
											xtype : 'label',
											html : '<span>Function</span>',
											width : 100,
											style : 'margin:10px 0px 10px 0px;'
										}, {
											xtype : 'label',
											html : '<span></span>',
											width : 30,
											style : 'margin:10px 0px 10px 15px;'
										}, {
											xtype : 'label',
											html : '<span>Field</span>',
											style : 'margin:10px 0px 10px 0px;',
											width : 100
										}, {
											xtype : 'combo',
											id : 'cmbCaption',
											mode : 'local',
											width : 110,
											store : new Ext.data.ArrayStore({
														fields : ['dText'],
														data : []
													}),
											listWidth : 110,
											valueField : 'dText',
											displayField : 'dText',
											style : {
												margin : '0px 0px 10px 0px'
											}
										}, {
											xtype : 'label',
											html : '<span></span>',
											width : 30,
											style : 'margin:0px 0px 10px 15px;'
										}, {
											xtype : 'combo',
											id : 'cmbField',
											mode : 'local',
											store : new Ext.data.ArrayStore({
														fields : ['dText'],
														data : []
													}),
											listWidth : 110,
											width : 110,
											valueField : 'dText',
											displayField : 'dText',
											style : {
												margin : '0px 0px 10px 0px'
											}
										}]
							}, {
								xtype : 'panel',
								bodyBorder : false,
								bodyStyle : {
									'background' : 'transparent',
									'border' : 'none',
									'margin' : '10px 0px 0px 0px'
								},
								layout : 'form',
								
								items : [{
											xtype : 'label',
											html : '<span>Caption</span>',
											style : 'margin:0px 0px 10px 0px;',
											width : 100
										}, {
											xtype : 'textfield',
											id : 'txtCaption',
											hideLabel : true,
											style : 'margin:10px 0px 0px 0px;',
											emptyText : '',
											width : 130
										}]
							}, {
								xtype : 'button',
								text : 'Ok',
								width : 100,
								style : 'margin:25px 0px 0px 5px;',
								handler : function() {
								   
									Ext.getCmp('mainSettingsPanel').groupWindow = false;
									Ext.getCmp('addGroupColWidow').close();
								}
							}]

				});
		hit.Controls.AddGroupColumnWindow.superclass.initComponent.call(this);
	}, onDestroy: function() {
	
        Ext.getCmp('mainSettingsPanel').groupWindow = false;
        hit.Controls.AddGroupColumnWindow.superclass.onDestroy.call(this);
    }
});