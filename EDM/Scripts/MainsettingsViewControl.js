(function() {
	Ext.namespace('hit.Controls');

	hit.Controls.mainsettingsViewControl = Ext.extend(Ext.Panel, {
		constructor : function(config) {
			config = Ext.apply(config, {
						hieght : config.height || '100%',
						width : config.width || '100%',
						id : config.id || 'vcontrol',
						style : config.style || '',
						lgridid : config.lgridid,
						rgridid : config.rgridid,
						txfcaptionid : config.txfcaptionid,
						txfwidthid : config.txfwidthid,
						lblExpId : config.lblExpId,
						btnsetcaptionId : config.btnsetcaptionId
					});
			hit.Controls.mainsettingsViewControl.superclass.constructor.call(
					this, config);
		},
		initComponent : function() {
			Ext.applyIf(this, {
				layout : 'table',
				layoutConfig : {
					columns : 6
				},
				items : [{
					xtype : 'label',

					html : '<span style="font-family:Helvetica,sans-serif; font-size:13px;">Columns not used</span>',
					style : 'margin:0px 0px 0px 8px',
					width : 200,
					colspan : 2
				}, {
					xtype : 'label',

					html : '<span style="font-family:Helvetica,sans-serif; font-size:13px;">Columns  used</span>',
					width : 200,
					colspan : 2
				}, {
					xtype : 'label',

					html : '<span style="font-family:Helvetica,sans-serif; font-size:13px;"></span>',
					style : 'margin:0px 0px 0px 5px',
					width : 200,
					colspan : 2
				}, {
					xtype : 'editorgrid',
					id : this.lgridid,
					store : new Ext.data.ArrayStore({
						fields : ['fieldName', 'width', 'expression', 'caption'],
						data : [],
						autoSave : false
					}),
					// store : this.getStore(),
					style : 'margin-left:8px;margin-top:6px;',
					height : 130,
					width : 116,
					sortable : false,
					border : true,
					columns : [{
								id : 'caption',
								dataIndex : 'caption',
								width : 92
							}, {
								id : 'fieldName',
								dataIndex : 'fieldName',
								hidden : true
							}, {
								id : 'width',
								dataIndex : 'width',
								hidden : true
							}, {
								id : 'expression',
								dataIndex : 'expression',
								hidden : true
							}],

					forceFit : true,
					autoFill : true,
					listeners : {
						render : function(grid) {

							grid.getGridEl().removeClass('x-panel-body ')
									.setStyle('border', '1px solid black');
							grid.getView().el.select('.x-grid3-header')
									.setStyle('display', 'none');

						},
						keydown : function(e) {
							var key = e.getKey();							
							if (key == 40 || key == 38) {								
								var grid = Ext.getCmp('nlgridid');
								var SQL_GROUP_BY = OBSettings.SQL_GROUP_BY;
								var index = Ext.getCmp('nlgridid').selModel.selection.cell[0];
								if (key == 38) {
									if (index != 0) {
										Ext.getCmp('nlgridid').selModel.select(
												index, 0);
									} else {
										Ext.getCmp('nlgridid').selModel.select(
												0, 0);
										Ext.getCmp('nlgridid').getView()
												.focusRow(0);

									}

								} else if (key == 40) {
									if (index != Ext.getCmp('nlgridid').store.data.length
											- 1) {
										Ext.getCmp('nlgridid').selModel.select(
												index, 0);
									} else {
										Ext.getCmp('nlgridid').selModel
												.select(
														Ext.getCmp('nlgridid').store.data.length
																- 1, 0);
									}
								}

								e.stopEvent();
							}

						},
						afterrender : function(grid) {

							var SQL_GROUP_BY = OBSettings.SQL_GROUP_BY;

							if (grid.id == 'nlgridid') {
								var caption;
								var fildName;
								var expression;
								if (SQL_GROUP_BY == 'NONE') {
									var hiddenFieldsWidth = GetCurrentHiddenFieldNamesNLGrid()
											.split(';');
									if (trim(hiddenFieldsWidth[0]) != "") {
										for (i = 0; i < hiddenFieldsWidth.length; i++) {
											var hiddenFandWidth = hiddenFieldsWidth[i]
													.split('#');

											if (hiddenFandWidth[0]
													.indexOf(" AS ") > 0) {
												caption = hiddenFandWidth[0]
														.split(" AS ")[1];
												expression = hiddenFandWidth[0];
												// fildName =
												// hiddenFandWidth[0];
											} else {
												alias = this.ownerCt
														.GetAlias(hiddenFandWidth[0]);
												caption = alias != ""
														? alias
														: hiddenFandWidth[0];
												// fildName =
												// hiddenFandWidth[0];
												expression = '';
											}
											var u = new grid.store.recordType({
														fieldName : hiddenFandWidth[0],
														width : hiddenFandWidth[1],
														expression : expression,
														caption : caption
													});

											grid.store.insert(0, u);
										}
									}
								} else if (SQL_GROUP_BY != 'NONE') {

									var hiddenFieldsWidth = GetCurrentHiddenFieldGNames()
											.split(';');

									if (trim(hiddenFieldsWidth[0]) != "") {
										for (i = 0; i < hiddenFieldsWidth.length; i++) {
											var hiddenFandWidth = hiddenFieldsWidth[i]
													.split('#');

											if (hiddenFandWidth[0]
													.indexOf(" AS ") > 0) {
												caption = hiddenFandWidth[0]
														.split(" AS ")[1];
												expression = hiddenFandWidth[0];
												// fildName =
												// hiddenFandWidth[0];
											} else {
												alias = this.ownerCt
														.GetAlias(hiddenFandWidth[0]);
												caption = alias != ""
														? alias
														: hiddenFandWidth[0];
												// fildName =
												// hiddenFandWidth[0];
												expression = '';
											}
											var u = new grid.store.recordType({
														fieldName : hiddenFandWidth[0],
														width : hiddenFandWidth[1],
														expression : expression,
														caption : caption
													});

											grid.store.insert(0, u);
										}
									}

								}

							}
						},
						rowclick : function(grid, rowindex, e) {

							/*if (grid.id == 'nlgridid') {

								var nrgridid = Ext.getCmp('nrgridid');

								var index = nrgridid.getSelectionModel()
										.getSelectedCell();
								if (!index) {
									return;
								} else {
									rec = nrgridid.store.getAt(index[0]);
									nrgridid.getSelectionModel().select(-1, 0,
											false, false, rec);
									Ext.getCmp('ntxfcaptionid').setValue('');
									Ext.getCmp('ntxfwidthid').setValue('');
								}
							}*/
						}
					}
				}, {
					xtype : 'panel',

					bodyStyle : {
						'background' : 'transparent',
						'margin' : '0 15px 5px 15px'
					},
					layout : 'form',
					items : [{
						xtype : 'box',

						autoEl : {
							tag : 'div',
							html : '<div style="background:transparent url(./Images/shift_item_ltor.png) no-repeat 0 0;height:17px; width:17px;cursor:pointer;margin:0px 0px 5px 0px;"></div>'
						},
						listeners : {
							'render' : function(e) {
								e.getEl().on('click', function() {

									var nlgridid = Ext.getCmp('nlgridid');
									if (nlgridid.store.getCount() > 0) {
										var nrgridid = Ext.getCmp('nrgridid');
										var index = nlgridid
												.getSelectionModel()
												.getSelectedCell();
										if (!index) {
											return;
										}
										var rec = nlgridid.store
												.getAt(index[0]);

										if (rec != undefined) {
											nlgridid.store.remove(rec);
											var u = new nrgridid.store.recordType(
													{
														fieldName : rec.data.fieldName,
														width : rec.data.width,
														expression : rec.data.expression,
														caption : rec.data.caption
													});
											nrgridid.store.insert(
													nrgridid.store.getCount(),
													u);
											nrgridid
													.getSelectionModel()
													.select(
															nrgridid.store
																	.getCount(),
															0, false, false, u);

											rec = nlgridid.store
													.getAt(index[0]);
											if (Ext.isDefined(rec)) {
												nlgridid.getSelectionModel()
														.select(index[0],
																index[1],
																false, false,
																rec);

											}
										}
									}

								});
							}
						}
					}

					, {
						xtype : 'box',

						autoEl : {
							tag : 'div',
							html : '<div style="background:transparent url(./Images/shift_item_rtol.png) no-repeat 0 0;height:17px; width:17px;cursor:pointer;margin:0px 0px 15px 0px;"></div>'
						},
						listeners : {
							'render' : function(e) {
								e.getEl().on('click', function() {

									var nrgridid = Ext.getCmp('nrgridid');
									if (nrgridid.store.getCount() > 0) {
										var nlgridid = Ext.getCmp('nlgridid');
										var index = nrgridid
												.getSelectionModel()
												.getSelectedCell();
										if (!index) {
											return;
										}
										var rec = nrgridid.store
												.getAt(index[0]);
										if (rec != undefined) {
											nrgridid.store.remove(rec);
											var u = new nlgridid.store.recordType(
													{
														fieldName : rec.data.fieldName,
														width : rec.data.width,
														expression : rec.data.expression,
														caption : rec.data.caption
													});
											nlgridid.store.insert(
													nlgridid.store.getCount(),
													u);
											nlgridid
													.getSelectionModel()
													.select(
															nlgridid.store
																	.getCount(),
															0, false, false, u);

											rec = nrgridid.store
													.getAt(index[0]);
											if (Ext.isDefined(rec)) {
												Ext
														.getCmp('ntxfcaptionid')
														.setValue(rec.data.caption);
												Ext
														.getCmp('ntxfwidthid')
														.setValue(rec.data.width);
												nrgridid.getSelectionModel()
														.select(index[0],
																index[1],
																false, false,
																rec);
											} else {
												Ext.getCmp('ntxfcaptionid')
														.setValue('');
												Ext.getCmp('ntxfwidthid')
														.setValue('');
											}
										}
									}

								});
							}
						}
					}, {
						xtype : 'box',

						autoEl : {
							tag : 'div',
							html : '<div style="background:transparent url(./Images/shift_items_ltor.png) no-repeat 0 0;height:17px; width:17px;cursor:pointer;margin:0px 0px 5px 0px;"></div>'
						},
						listeners : {
							'render' : function(e) {
								e.getEl().on('click', function() {

									var nlgridid = Ext.getCmp('nlgridid');
									if (nlgridid.store.getCount() > 0) {
										var nrgridid = Ext.getCmp('nrgridid');
										var leftGridLength = nlgridid.store
												.getCount();
										var rec;
										for (i = leftGridLength - 1; i >= 0; i--) {
											rec = nlgridid.store.getAt(i);

											var u = new nrgridid.store.recordType(
													{
														fieldName : rec.data.fieldName,
														width : rec.data.width,
														expression : rec.data.expression,
														caption : rec.data.caption
													});
											nlgridid.store.remove(rec);
											nrgridid.store.insert(0, u);
										}

									}
								});
							}
						}
					}, {
						xtype : 'box',

						autoEl : {
							tag : 'div',
							html : '<div style="background:transparent url(./Images/shift_items_rtol.png) no-repeat 0 0;height:17px; width:17px;cursor:pointer;"></div>'
						},
						listeners : {
							'render' : function(e) {
								e.getEl().on('click', function() {

									var nrgridid = Ext.getCmp('nrgridid');
									if (nrgridid.store.getCount() > 0) {
										var nlgridid = Ext.getCmp('nlgridid');
										var rightGridLength = nrgridid.store
												.getCount();
										var rec;
										for (i = rightGridLength - 1; i >= 0; i--) {
											rec = nrgridid.store.getAt(i);

											var u = new nlgridid.store.recordType(
													{
														fieldName : rec.data.fieldName,
														width : rec.data.width,
														expression : rec.data.expression,
														caption : rec.data.caption
													});
											nrgridid.store.remove(rec);
											nlgridid.store.insert(0, u);
										}

										Ext.getCmp('ntxfcaptionid')
												.setValue('');
										Ext.getCmp('ntxfwidthid').setValue('');

									}

								});
							}
						}
					}]
				}, {
					xtype : 'editorgrid',
					id : this.rgridid,
					style : 'margin-right:8px;margin-top:6px;',
					store : new Ext.data.ArrayStore({
						fields : ['fieldName', 'width', 'expression', 'caption'],
						data : [],
						autoSave : false
					}),
					height : 130,
					width : 115,

					sortable : false,
					border : true,
					columns : [{
								id : 'caption',
								dataIndex : 'caption',
								width : 92
							}, {
								id : 'fieldName',
								dataIndex : 'fieldName',
								hidden : true
							}, {
								id : 'width',
								dataIndex : 'width',
								hidden : true
							}, {
								id : 'expression',
								dataIndex : 'expression',
								hidden : true
							}],
					setValues : function(index) {						
						if (Ext.getCmp('ntxfcaptionid') != undefined
								&& Ext.getCmp('ntxfwidthid') != undefined) {
							var grid = Ext.getCmp('nrgridid');
							var rec = Ext.getCmp('nrgridid').store.getAt(index).data;
							var caption = rec.caption;
							var width = parseInt(rec.width);

							Ext.getCmp('ntxfcaptionid').setValue(caption);

							Ext.getCmp('ntxfwidthid').setValue(width);

							if (rec.expression != "")
								Ext.getCmp('lblLexp').setValue(rec.expression);
							else
								Ext.getCmp('lblLexp').setValue(rec.fieldName);
						}
					},

					forceFit : true,
					autoFill : true,
					listeners : {
						render : function(grid) {
							grid.getGridEl().removeClass('x-panel-body ')
									.setStyle('border', '1px solid black');
							grid.getView().el.select('.x-grid3-header')
									.setStyle('display', 'none');

						},
						keydown : function(e) {
							var key = e.getKey();
							if (key == 40 || key == 38) {
								// debugger;
								//alert(this.id);
								if (this.id == 'nrgridid') {
									var grid = Ext.getCmp('nrgridid');
									var SQL_GROUP_BY = OBSettings.SQL_GROUP_BY;
									var index = Ext.getCmp('nrgridid').selModel.selection.cell[0];
									if (key == 38) {
										if (index != 0) {
											Ext.getCmp('nrgridid').selModel
													.select(index, 0);
										} else {
											Ext.getCmp('nrgridid').selModel
													.select(0, 0);
											Ext.getCmp('nrgridid').getView()
													.focusRow(0);

										}
										if(!Ext.isIE)
										index = (index == 0) ? index : --index;

									} else if (key == 40) {
										if (index != Ext.getCmp('nrgridid').store.data.length
												- 1) {
											Ext.getCmp('nrgridid').selModel
													.select(index, 0);
										} else {
											Ext.getCmp('nrgridid').selModel
													.select(
															Ext
																	.getCmp('nrgridid').store.data.length
																	- 1, 0);
										}
										if(!Ext.isIE)
										index = (index == Ext
												.getCmp('nrgridid').store.data.length
												- 1) ? index : ++index;
									}

									this.setValues(index);
								}
							}
							e.stopEvent();
						},
						keypress : function(e) {
							// alert('keypress');
							// if (e.getKey() == 40 || e.getKey() == 38) {
							// var grid = Ext.getCmp('nrgridid');
							// var SQL_GROUP_BY = OBSettings.SQL_GROUP_BY;

							// if (grid.id == 'nrgridid') {

							// if (Ext.getCmp('ntxfcaptionid') != undefined
							// && Ext.getCmp('ntxfwidthid') != undefined) {
							// var caption =
							// grid.getSelectionModel().selection.record.data.caption;
							// var width = Math
							// .round(grid.getSelectionModel().selection.record.data.width);

							// Ext.getCmp('ntxfcaptionid')
							// .setValue(caption);

							// Ext.getCmp('ntxfwidthid')
							// .setValue(width);

							// if
							// (grid.getSelectionModel().selection.record.data.expression
							// != "")
							// Ext
							// .getCmp('lblLexp')
							// .setValue(grid
							// .getSelectionModel().selection.record.data.expression);
							// else
							// Ext
							// .getCmp('lblLexp')
							// .setValue(grid
							// .getSelectionModel().selection.record.data.fieldName);
							// }

							// var nlgridid = Ext.getCmp('nlgridid');

							// var index = nlgridid.getSelectionModel()
							// .getSelectedCell();
							// if (!index) {
							// return;
							// } else {
							// rec = nlgridid.store.getAt(index[0]);
							// nlgridid.getSelectionModel().select(-1,
							// 0, false, false, rec);
							// }
							// }
							// }
						},

						afterrender : function(grid) {

							var SQL_GROUP_BY = OBSettings.SQL_GROUP_BY;
							var grp = OBSettings.groupedGrid;
							var gr = OBSettings.grid;

							if (SQL_GROUP_BY != 'NONE' && grid.id == 'nrgridid') {
								var caption = '';
								var u;
								var alias;

								var visibleFieldsWidth = GetCurrentVisibleFieldNamesGGrid()
										.split(';');
								var fildName = '';
								var expression = '';

								for (i = visibleFieldsWidth.length - 1; i >= 0; i--) {
									var visibleFandWidth = visibleFieldsWidth[i]
											.split('#');
									if (visibleFandWidth[0].indexOf(" AS ") > 0) {
										caption = visibleFandWidth[0]
												.split(" AS ")[1];
										expression = visibleFandWidth[0];
										fildName = visibleFandWidth[0];
									} else {
										alias = this.ownerCt
												.GetAlias(visibleFandWidth[0]);
										caption = alias != ""
												? alias
												: visibleFandWidth[0];
										fildName = visibleFandWidth[0];
										expression = '';
									}
									u = new grid.store.recordType({
												fieldName : fildName,
												width : visibleFandWidth[1],
												expression : expression,
												caption : caption
											});
									grid.store.insert(0, u);
								}
							} else if (grid.id == 'nrgridid') {

								var caption = '';
								var u;
								var alias;

								var visibleFieldsWidth = GetCurrentVisibleFieldNamesWithWidthNrGrid()
										.split(';');
								var fildName = '';
								var expression = '';

								for (i = visibleFieldsWidth.length - 1; i >= 0; i--) {
									var visibleFandWidth = visibleFieldsWidth[i]
											.split('#');
									if (visibleFandWidth[0].indexOf(" AS ") > 0) {
										caption = visibleFandWidth[0]
												.split(" AS ")[1];
										expression = visibleFandWidth[0];
										fildName = visibleFandWidth[0];
									} else {
										alias = this.ownerCt
												.GetAlias(visibleFandWidth[0]);
										caption = alias != ""
												? alias
												: visibleFandWidth[0];
										fildName = visibleFandWidth[0];
										expression = '';
									}
									u = new grid.store.recordType({
												fieldName : fildName,
												width : visibleFandWidth[1],
												expression : expression,
												caption : caption
											});
									grid.store.insert(0, u);
								}

								if (OBSettings.SQL_SEARCH_COLUMN_GRID_INDEX
										&& OBSettings.SQL_SEARCH_COLUMN_GRID_INDEX != 'undefined'
										&& OBSettings.SQL_GROUP_BY == 'NONE') {
									for (var i = 0; i < Ext.getCmp('nrgridid')
											.getView().ds.data.items.length; i++) {
										var item = Ext.getCmp('nrgridid').store.data.items[i];
										if (item.data.caption == Ext
												.getCmp('NormalGrid').view.cm.config[OBSettings.SQL_SEARCH_COLUMN_GRID_INDEX].header) {
											// debugger;
											setTimeout(
													"Ext.getCmp('nrgridid').selModel.select("
															+ i + ", 0)", 100);
											// Ext.getCmp('nrgridid').selModel.select(i,
											// 0);
											Ext
													.getCmp('ntxfcaptionid')
													.setValue(item.data.caption);
											Ext.getCmp('ntxfwidthid')
													.setValue(item.data.width);
											Ext
													.getCmp('lblLexp')
													.setValue(item.data.fieldName);
										}
									}
								}

							}
						},
						rowclick : function(grid, rowindex, e) {

							var SQL_GROUP_BY = OBSettings.SQL_GROUP_BY;

							if (grid.id == 'nrgridid') {

								if (Ext.getCmp('ntxfcaptionid') != undefined
										&& Ext.getCmp('ntxfwidthid') != undefined) {
									var caption = grid.store.data.items[rowindex].data.caption;
									var width = Math
											.round(grid.store.data.items[rowindex].data.width);

									Ext.getCmp('ntxfcaptionid')
											.setValue(caption);
									// Ext
									// .getCmp('ntxfwidthid')
									// .setValue(grid.store.data.items[rowindex].data.width);
									Ext.getCmp('ntxfwidthid').setValue(width);
									var exp = "Field Name :"
											+ grid.store.data.items[rowindex].data.fieldName
											+ '\n'
											+ "Expression :"
											+ grid.store.data.items[rowindex].data.expression
											+ '\n'
											+ "Caption :"
											+ grid.store.data.items[rowindex].data.caption;

									if (grid.store.data.items[rowindex].data.expression != "")
										Ext
												.getCmp('lblLexp')
												.setValue(grid.store.data.items[rowindex].data.expression);
									else
										Ext
												.getCmp('lblLexp')
												.setValue(grid.store.data.items[rowindex].data.fieldName);

									if (SQL_GROUP_BY == 'NONE') {

										var g = Ext.getCmp('NormalGrid');
										var rowindex = 0;
										for (var i = 0; i < g.store.data.items[0].fields.items.length; i++) {
											// debugger;
											var item = g.store.data.items[0].fields.items[i];
											if (item.name == caption) {
												rowindex = i;
											}
										}

										if (rowindex == 0
												|| (g.view.cm.config[rowindex].header === "")) {
											return false;
										}
										if (g.oldSelectedColumn) {
											g
													.getView()
													.getHeaderCell(g.oldSelectedColumn).children[0].style.backgroundColor = '';
										}
										g.oldSelectedColumn = rowindex;

										OBSettings.SQL_SEARCH_COLUMN = g
												.getView().cm
												.getDataIndex(rowindex);

										OBSettings.SQL_SEARCH_COLUMN_GRID_INDEX = rowindex;
										g.getView().getHeaderCell(rowindex).children[0].style.backgroundColor = '#dfe8f6';
									}
									
									
									if (SQL_GROUP_BY != 'NONE') {
                                       
										var g = Ext.getCmp('GroupGrid');
										var rowindex = 0;
										for (var i = 0; i < g.store.data.items[0].fields.items.length; i++) {
											// debugger;
											var item = g.store.data.items[0].fields.items[i];
											if (item.name == caption) {
												rowindex = i;
											}
										}

										if (rowindex == 0
												|| (g.view.cm.config[rowindex].header === "")) {
											return false;
										}
										if (g.oldSelectedColumn) {
											g
													.getView()
													.getHeaderCell(g.oldSelectedColumn).children[0].style.backgroundColor = '';
										}
										g.oldSelectedColumn = rowindex;

										OBSettings.SQL_SEARCH_COLUMN = g
												.getView().cm
												.getDataIndex(rowindex);

										OBSettings.SQL_SEARCH_COLUMN_GRID_INDEX = rowindex;
										g.getView().getHeaderCell(rowindex).children[0].style.backgroundColor = '#dfe8f6';
									}
								
								}
								
								
								

								/*var nlgridid = Ext.getCmp('nlgridid');

								var index = nlgridid.getSelectionModel()
										.getSelectedCell();
								if (!index) {
									return;
								} else {
									rec = nlgridid.store.getAt(index[0]);
									nlgridid.getSelectionModel().select(-1, 0,
											false, false, rec);
								}*/
							}
						}
					}

				}, {
					xtype : 'panel',

					bodyStyle : {
						'background' : 'transparent',
						'margin' : '0px 25px 70px 0px'
					},
					layout : 'form',
					items : [{
						xtype : 'box',

						autoEl : {
							tag : 'div',
							html : '<div style="background:transparent url(./Images/set_order_up.png) no-repeat 0 0;height:17px; width:17px;cursor:pointer;margin:0px 0px 5px 0px;"></div>'
						},
						listeners : {
							'render' : function(e) {
								e.getEl().on('click', function() {

									var nrgridid = Ext.getCmp('nrgridid');

									if (nrgridid != undefined) {

										var index = nrgridid
												.getSelectionModel()
												.getSelectedCell();
										if (!index) {
											return;
										}

										var rec = nrgridid.store
												.getAt(index[0]);
										var recPrev = nrgridid.store
												.getAt(index[0] - 1);
										if (recPrev != undefined) {
											nrgridid.store.remove(recPrev);
											nrgridid.store.insert(index[0],
													recPrev);
											nrgridid.store.remove(rec);
											nrgridid.store.insert(index[0] - 1,
													rec);
											nrgridid.getSelectionModel()
													.select(index[0] - 1, 0,
															false, false, rec);

										}
									}
								});
							}
						}
					}, {
						xtype : 'box',

						autoEl : {
							tag : 'div',
							html : '<div style="background:transparent url(./Images/set_order_down.png) no-repeat 0 0;height:17px; width:17px;cursor:pointer;margin:0px 0px 15px 0px;"></div>'
						},
						listeners : {
							'render' : function(e) {
								e.getEl().on('click', function() {

									var nrgridid = Ext.getCmp('nrgridid');

									if (nrgridid != undefined) {

										var index = nrgridid
												.getSelectionModel()
												.getSelectedCell();
										if (!index) {
											return;
										}

										var rec = nrgridid.store
												.getAt(index[0]);
										var recPrev = nrgridid.store
												.getAt(index[0] + 1);
										if (recPrev != undefined) {
											nrgridid.store.remove(recPrev);
											nrgridid.store.insert(index[0],
													recPrev);
											nrgridid.store.remove(rec);
											nrgridid.store.insert(index[0] + 1,
													rec);
											nrgridid.getSelectionModel()
													.select(index[0] + 1, 0,
															false, false, rec);

										}
									}
								});
							}
						}
					}]
				}, {
					xtype : 'panel',

					bodyStyle : {
						'background' : 'transparent',
						'margin' : '0 5px 36px 5px'
					},
					layout : 'form',
					items : [{
						xtype : 'panel',
						layout : 'column',
						style : 'padding:2px',
						items : [{
									xtype : 'label',
									text : 'Set caption:',
									width : 85
								}, {

									xtype : 'textfield',
									id : this.txfcaptionid,
									hideLabel : true,
									emptyText : '',
									width : 150,
									maxLength : 50

								}, {
									xtype : 'box',
									id : this.btnsetcaptionId,
									autoEl : {
										tag : 'div',
										html : '<div style="background:transparent url(./Images/set_caption_or_width.png) no-repeat 0 0;height:17px; width:18px;cursor:pointer;margin-left:10px;"></div>'
									},
									listeners : {
										'render' : function(e) {
											e.getEl().on('click',
													function(event, sender) {

														if (e.getEl().id == 'gbtnsetcaptionId') {
															/*
															 * txfcaptionid:
															 * 'gtxfcaptionid'
															 * txfwidthid:
															 * 'gtxfwidthid',
															 * lblExpId :
															 * 'lblRexp'
															 */
															var caption = Ext
																	.getCmp('gtxfcaptionid')
																	.getValue();
															var grgridid = Ext
																	.getCmp('grgridid');

															var index = grgridid
																	.getSelectionModel()
																	.getSelectedCell();
															if (caption != ""
																	&& index) {

																var rec = grgridid.store
																		.getAt(index[0]);
																var expression;
																var fieldName;

																if (rec.data.expression
																		.indexOf(" AS ") > 0) {
																	fieldName = expression = rec.data.expression
																			.split(" AS ")[0]
																			+ " AS "
																			+ trim(caption);
																} else {
																	fieldName = rec.data.fieldName;
																	expression = rec.data.expression;
																}

																// nrgridid.getSelectionModel().selection.record.data.caption
																// = caption;
																var u = new grgridid.store.recordType(
																		{
																			fieldName : fieldName,
																			width : rec.data.width,
																			expression : expression,
																			caption : caption
																		});
																grgridid.store
																		.remove(rec);
																grgridid.store
																		.insert(
																				index[0],
																				u);
																grgridid
																		.getSelectionModel()
																		.select(
																				index[0],
																				0,
																				false,
																				false,
																				u);
															}

														} else if (e.getEl().id == 'nbtnsetcaptionId') {
															var caption = Ext
																	.getCmp('ntxfcaptionid')
																	.getValue();
															var nrgridid = Ext
																	.getCmp('nrgridid');

															var index = nrgridid
																	.getSelectionModel()
																	.getSelectedCell();
															if (caption != ""
																	&& index) {

																var rec = nrgridid.store
																		.getAt(index[0]);
																var expression;
																var fieldName;
																// nrgridid.getSelectionModel().selection.record.data.caption
																// = caption;
																if (rec.data.expression
																		.indexOf(" AS ") > 0) {
																	fieldName = expression = rec.data.expression
																			.split(" AS ")[0]
																			+ " AS "
																			+ trim(caption);
																} else {
																	fieldName = rec.data.fieldName;
																	expression = rec.data.expression;
																}
																var u = new nrgridid.store.recordType(
																		{
																			fieldName : fieldName,
																			width : rec.data.width,
																			expression : expression,
																			caption : caption
																		});
																nrgridid.store
																		.remove(rec);
																nrgridid.store
																		.insert(
																				index[0],
																				u);
																nrgridid
																		.getSelectionModel()
																		.select(
																				index[0],
																				0,
																				false,
																				false,
																				u);
															}
														}
													});
										}
									}
								}]
					}, {
						xtype : 'panel',
						layout : 'column',
						style : 'padding:2px',
						items : [{
									xtype : 'label',
									text : 'Set width:',
									width : 85
								}, {
									xtype : 'numberfield',
									id : this.txfwidthid,
									fieldLabel : 'Set width',
									width : 150,
									decimalPrecision : 0,
									emptyText : ''
								}, {
									xtype : 'box',

									autoEl : {
										tag : 'div',
										html : '<div style="background:transparent url(./Images/set_caption_or_width.png) no-repeat 0 0;height:17px; width:18px;cursor:pointer;margin:0px 0px 0px 10px;"></div>'
									},
									listeners : {
										'render' : function(e) {
											e.getEl().on('click', function() {

												var width = Ext
														.getCmp('ntxfwidthid')
														.getValue();
												var nrgridid = Ext
														.getCmp('nrgridid');

												var index = nrgridid
														.getSelectionModel()
														.getSelectedCell();

												if (width != ""
														&& IsInteger(width)
														&& index) {
													// nrgridid.getSelectionModel().selection.record.data.width
													// =
													// parseInt(width).toString();
													var rec = nrgridid.store
															.getAt(index[0]);
													var u = new nrgridid.store.recordType(
															{
																fieldName : rec.data.fieldName,
																width : parseInt(width),
																expression : rec.data.expression,
																caption : rec.data.caption
															});
													nrgridid.store.remove(rec);
													nrgridid.store.insert(
															index[0], u);
													nrgridid
															.getSelectionModel()
															.select(index[0],
																	0, false,
																	false, u);
												}
											});
										}
									}
								}]
					}, {
						xtype : 'panel',
						layout : 'column',
						style : 'padding:2px',
						items : [{
									xtype : 'label',
									text : 'Expression:',
									width : 85
								}, {
									xtype : 'textarea',
									id : this.lblExpId,
									hideLabel : true,
									width : 145,
									autoScroll : true,
									height : 50,
									emptyText : '',
									readOnly : true,
									style : {
										backgroundColor : '#f4f3ee',
										'background-image' : 'none',
										overflow : 'auto',
										padding : 0
									},
									setValue : function(v) {
										setTimeout("Ext.getCmp('" + this.id
														+ "').changeStyle(\""
														+ v + "\")", 100);

										return Ext.form.TextArea.superclass.setValue
												.call(this, v);

									},
									changeStyle : function(v) {
										if ((Ext.getCmp('ntxfcaptionid')
												.getValue() != v)
												&& v.indexOf(" AS ") > 0) {
											Ext.getCmp('lblLexp').getEl().dom
													.removeAttribute('readOnly');
											this.el
													.setStyle(
															'background-color',
															'white');
											Ext.getCmp('expressionField')
													.show();
										} else {
											Ext.getCmp('lblLexp').getEl().dom
													.setAttribute('readOnly',
															true);
											this.el.setStyle(
													'background-color',
													'#f4f3ee');
											Ext.getCmp('expressionField')
													.hide();
										}
									}
								}, {
									xtype : 'box',
									id : 'expressionField',
									hidden : true,
									autoEl : {
										tag : 'div',
										html : '<div style="background:transparent url(./Images/set_caption_or_width.png) no-repeat 0 0;height:17px; width:18px;cursor:pointer;margin:0px 0px 0px 9px;"></div>'
									},
									listeners : {
										'render' : function(e) {
											e.getEl().on('click', function() {

												var exp = Ext.getCmp('lblLexp')
														.getValue();
												var grgridid = Ext
														.getCmp('nrgridid');
												var index = grgridid
														.getSelectionModel()
														.getSelectedCell();
												var rec = grgridid.store
														.getAt(index[0]);
												var u = new grgridid.store.recordType(
														{
															fieldName : exp,
															width : rec.data.width,
															expression : exp,
															caption : rec.data.caption
														});

												grgridid.store.remove(rec);
												grgridid.store.insert(index[0],
														u);
												grgridid
														.getSelectionModel()
														.select(index[0], 0,
																false, false, u);
											});
										}
									}
								}]
					}]
				}]
			});
			hit.Controls.mainsettingsViewControl.superclass.initComponent
					.call(this);
		},
		GetAlias : function(field) {
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

	Ext.reg('ViewControl', hit.Controls.mainsettingsViewControl);
}());