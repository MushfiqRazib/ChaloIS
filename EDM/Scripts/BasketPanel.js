Ext.namespace('hit.Controls');

hit.Controls.saveWindow = Ext.extend(Ext.Window, {
	constructor : function(config) {
		Ext.apply(config, {
			layout : 'form',
			resizable : false,
			modal : true,
			width : 400,
			height : 410,
			title : config.title || 'Save selected items as collection',
			bodyStyle : {
				'background-color' : 'F4F3EE',
				'padding' : '0px',
				'overflow' : 'hidden',
				'border' : '1px solid black'
			},
			items : [{
						xtype : 'panel',
						border : false,
						layout : 'form',
						defaults : {
							width : 230
						},
						style : {
							'margin-top' : '30px',
							'margin-left' : '25px'
						},
						listeners : {
							render : function() {
								this.ownerCt.ItemPanel = this;
							}

						},
						items : [{
									xtype : 'textfield',
									allowBlank : false,
									fieldLabel : 'Collection Name',
									style : 'margin-bottom:25px',
									listeners : {
										render : function() {
											this.ownerCt.NameItem = this;
										}

									}

								}, {
									xtype : 'textfield',
									fieldLabel : 'Description',
									allowBlank : false,

									listeners : {
										render : function() {
											this.ownerCt.DescriptionItem = this;
										}

									}
								}

						]
					},
					// restore grid
					new Ext.grid.GridPanel({
						id : 'savewinrestoregrid',
						height : 170,
						width : 335,
						viewConfig : {
							autoFill : false,
							forceFit : false
						},
						store : this.getRestoreStore(),
						colModel : new Ext.grid.ColumnModel([{
									header : 'Name',
									width : 100,
									dataIndex : 'name',
									menuDisabled : true
								}, {
									header : 'Description',
									width : 200,
									dataIndex : 'description',
									menuDisabled : true
								},{
									header : '',
									width : 50,
									dataIndex : 'delete',
									menuDisabled : true
					             }]),
						style : {

							'margin-left' : '26px',
							'margin-top' : '25px'

						}

						,
						sm : new Ext.grid.RowSelectionModel({
							singleSelect : true,
							listeners : {
								rowselect : {
									fn : function(sm, index, record) {

										this.ItemPanel.NameItem
												.setRawValue(record.data.name);
										this.ItemPanel.DescriptionItem
												.setRawValue(record.data.description);
									}
								},

								scope : this
							}

						}),
						listeners : {
							render : function() {

								// this.ownerCt.restoreGrid = this;
								/*
								 * this.on('keydown', function(e) {
								 * 
								 * if (e.getKey() == e.ENTER) {
								 * 
								 * var sm = this.getSelectionModel(); if
								 * (sm.hasSelection()) {
								 * ChaloIS.Basket.grid.RestoreBasket(sm.getSelected().id,
								 * sm.getSelected().data.description,
								 * this.ownerCt); } } })
								 */
							},

							rowdblclick : {
								fn : function(gridObj, rowIdx, e) {
									/*
									 * var sm = gridObj.getSelectionModel(); if
									 * (sm.hasSelection()) {
									 * ChaloIS.Basket.grid.RestoreBasket(sm.getSelected().id,
									 * sm.getSelected().data.description,
									 * this.ownerCt); }
									 */
								}
							}

						}
					})

					,

					{
						xtype : 'panel',
						layout : 'column',
						border : false,
						defaults : {
							width : 80
						},
						style : {
							'margin-top' : '35px',
							'margin-right' : '28px',
							'float' : 'right'
						},
						items : [{
									xtype : 'button',
									text : 'Cancel',

									handler : function() {
										this.close();
									},
									scope : this
								}, {
									xtype : 'button',
									text : 'Save',
									style : 'margin-left:10px',

									handler : function() {
										if (this.Save) {
											if (this.ItemPanel.NameItem
													.isValid()
													&& this.ItemPanel.DescriptionItem
															.isValid()) {
                                                debugger;
												this.Save();
											}
										}
									},
									scope : this
								}]
					}],
			listeners : {
				show : function() {

					 this.setTextFieldsValue();
				}

			}

		});
		hit.Controls.saveWindow.superclass.constructor.call(this, config);
	},
	getRestoreStore : function() {

		var val = ChaloIS.Basket.SyncAjaxRequest('GetSavedBasketList',
				"{reportcode:'" + OBSettings.REPORT_CODE + "'}")

		val = eval(val);
        for (var i = 0 ; i < val.length ; i++)
		{
		    
		    var deleteImg = "<img src='./images/delete.png' style='cursor:pointer' title='See partlist' onclick='ChaloIS.Basket.grid.DeleteRestoreGridRow(1)' />";
		    val[i].push(deleteImg)
		}
		var store = new Ext.data.ArrayStore({
					fields : [{
								name : 'name'
							}, {
								name : 'description'
							},{
							    name : 'delete'
							}],
					idIndex : 0
				});

		store.loadData(val);
		return store;

	}
});

hit.Controls.restoreWindow = Ext.extend(Ext.Window, {
	constructor : function(config) {
		Ext.apply(config, {
			layout : 'form',
			resizable : false,
			modal : true,
			width : 460,
			height : 250,
			bodyStyle : {
				'background-color' : 'F4F3EE',

				'overflow' : 'hidden'
			},
			title : config.title || 'Restore a saved collection',
			items : [new Ext.grid.GridPanel({
				id : 'restoregrid',
				height : 170,
				viewConfig : {
					autoFill : true,
					forceFit : true
				},
				store : config.store,
				colModel : config.colModel,
				style : {
					margin : '7px'
				}

				,
				sm : config.sm,
				listeners : {
					render : function() {
						this.on('keydown', function(e) {

									if (e.getKey() == e.ENTER) {

										var sm = this.getSelectionModel();
										if (sm.hasSelection()) {
											ChaloIS.Basket.grid
													.RestoreBasket(
															sm.getSelected().id,
															sm.getSelected().data.description,
															this.ownerCt);
										}
									}
								});
						this.ownerCt.restoreGrid = this;
					},

					rowdblclick : {
						fn : function(gridObj, rowIdx, e) {
							var sm = gridObj.getSelectionModel();
							if (sm.hasSelection()) {
								ChaloIS.Basket.grid.RestoreBasket(sm
												.getSelected().id,
										sm.getSelected().data.description,
										this.ownerCt);
							}
						}

					}
				}
			}), {
				xtype : 'panel',
				layout : 'column',
				border : false,
				style : {
					'margin-top' : '2px',
					'margin-right' : '7px',
					'float' : 'right'
				},
				items : [{
							xtype : 'button',
							text : 'Cancel',
							width : 80,
							handler : function() {

								this.close();
							},
							scope : this
						}, {
							xtype : 'button',
							text : 'Restore',
							id : 'btnRestore',
							style : 'margin-left:10px',
							width : 80,
							disabled : true,
							handler : function() {
								if (this.Restore) {

									this.Restore();
								}
							},
							scope : this
						}]
			}

			]
		});
		hit.Controls.restoreWindow.superclass.constructor.call(this, config);
	}
});

hit.Controls.basketPanel = Ext.extend(Ext.Panel, {
	constructor : function(config) {

		Ext.apply(config, {
			id : 'basketPanel',
			bodyBorder : false,
			height : 220,
			width : '99.2%',
			layout : 'form',
			labelAlign : 'left',
			bodyStyle : {
				'background-color' : 'F4F3EE',
				'padding-left' : '0px',
				'overflow' : 'hidden'
			},
			autoHeight : false,
			items : [

			{
				xtype : 'fieldset',
				title : 'Selected Item(s)',
				height : 218,
				layout : 'column',
				style : 'margin-left:7px;margin-top:2px;padding:0px;',
				items : [{
							xtype : 'panel',
							width: 870,
							border : false,
							items : [
						                
									        ChaloIS.Basket.grid.init(),
									        {
								              xtype: 'button', 
								              height: 25,
								              width: 90,
								              style: 'margin:5px 0px 0px 8px;', 
								              text:'Update',
								              tooltip:'Update all items in the Basket to the current revision.',
								              id: 'btnBasketUpdate',
								              disabled: false ,
								              handler:function(){
								                ChaloIS.Basket.grid.Update();
								              }
							              }
							        ]
						}
						
						, {
							xtype : 'panel',
							layout : 'form',
							border : false,
							items : [
									
							  {
								  xtype: 'button', 
								  height: 25,
								  width: 90,
								  style: 'margin:5px 0px 0px 10px;', 
								  text:'Release',
								  tooltip:'Send current items in the basket from the Release Candidates to the Vrijgegeven Archief.',
								  id: 'btnBasketRelease',
								  disabled: true ,
								  handler : function() {
									basket_release();
								}
							  },
									 
								{
								xtype : 'button',
								height : 25,
								width : 90,
								style : 'margin:5px 0px 0px 10px;',
								text : 'Distribute',
								id : 'btnBasketDistribute',
								disabled : true,
								tooltip:'Start the Distribute Wizard with the current items of the basket.',
								handler : function() {
								    SendBasket();
								    loadDistribute();
								}
							}, {
								xtype : 'button',
								height : 25,
								width : 90,
								style : 'margin:5px 0px 0px 10px;',
								id : 'btnBasketPrint',
								tooltip:'Start the Print Wizard with the current items of the basket.',
								text : 'Print',
								disabled : true,
								handler : function() {
									//OpenBasket();
									 SendBasket();
									 loadPrinten();
								}
							},

							{
								xtype : 'button',
								height : 25,
								width : 90,
								style : 'margin:15px 0px 0px 10px;',
								text : 'Remove All',
								id : 'btnBasketRemoveAll',
								tooltip:'Remove all current items from the basket.',
								disabled : true,
								handler : function() {
									ChaloIS.Basket.grid.ClearBasket();
									ChaloIS.Basket.grid.DisplayButtons();
									DeleteAll();
								}
							}, {
								xtype : 'button',
								id : 'btnBasketSave',
								height : 25,
								width : 90,
								style : 'margin:5px 0px 0px 10px;',
								text : 'Save',
								tooltip:'Save the current basket content for later restore.',
								disabled : true,
								handler : function() {

									if (!ChaloIS.Basket.grid.isEmpty()) {
										var win = new hit.Controls.saveWindow({
													id : 'winSaveBasket'

												});

										win.setTextFieldsValue = function() {
											this.ItemPanel.NameItem
													.setRawValue(ChaloIS.Basket.grid
															.GetBasketName());
											this.ItemPanel.DescriptionItem
													.setRawValue(ChaloIS.Basket.grid
															.GetBasketDescription());
										}

										win.Save = function() {

											var name = this.ItemPanel.NameItem
													.getValue();
											var description = this.ItemPanel.DescriptionItem
													.getValue();
											ChaloIS.Basket.grid.SaveBasket(
													name, description, win);
										}

										win.show(Ext.get('btnBasketSave'));
									}

								}

							}, {
								xtype : 'button',
								height : 25,
								width : 90,
								style : 'margin:5px 0px 0px 10px;',
								text : 'Restore',
								tooltip:'Restore a previous saved collection.',
								handler : function() {

									var val = ChaloIS.Basket.SyncAjaxRequest(
											'GetSavedBasketList',
											"{reportcode:'"
													+ OBSettings.REPORT_CODE
													+ "'}")
									if (val == "[]") {
										var strMsg = 'There is no saved collection to restore.';
										Ext.Msg.show({
													title : 'Restore a saved collection',
													msg : strMsg,
													buttons : Ext.Msg.OK,
													icon : Ext.MessageBox.WARNING
												});
										return;
									};
									
									
									
									val = eval(val);
									for (var i = 0 ; i < val.length ; i++)
									{
									    var deleteImg = "<img src='./images/delete.png' style='cursor:pointer' title='See partlist' onclick='ChaloIS.Basket.grid.DeleteRestoreGridRow(0)' />";
									    val[i].push(deleteImg)
									}
									
									var colModel = new Ext.grid.ColumnModel([{
												header : 'Name',
												width : 100,
												dataIndex : 'name',
												menuDisabled : true
											}, {
												header : 'Description',
												width : 250,
												dataIndex : 'description',
												menuDisabled : true
											},{
												header : '',
												width : 50,
												dataIndex : 'delete',
												menuDisabled : true
											}
											]);

									var store = new Ext.data.ArrayStore({
												fields : [{
															name : 'name'
														}, {
															name : 'description'
														},{
															name : 'delete'
														}
														],
												idIndex : 0
											});

									store.loadData(val);

									var sm = new Ext.grid.RowSelectionModel({
										singleSelect : true,
										listeners : {
											rowselect : {
												fn : function(sm, index, record) {
													this.grid.ownerCt
															.findById('btnRestore')
															.setDisabled(false)
												}
											}

										}

									});
									var win = new hit.Controls.restoreWindow({
												id : 'winRestoreBasket',
												store : store,
												colModel : colModel,
												sm : sm
											});
                                    
                                    
                                    
                                
                                    win.store.loadData(val);
                                   
									win.show(Ext.get('basketGrid'));
                                    
                                   
                                    
									win.Restore = function() {
										var sm = this.restoreGrid
												.getSelectionModel();
										if (sm.hasSelection()) {
											ChaloIS.Basket.grid
													.RestoreBasket(
															sm.getSelected().id,
															sm.getSelected().data.description,
															this);
										}

									}
								}

							}]
						}]
			}],
			
			listeners : {
							render : function(grid) {
							  
							    if (Ext.getCmp('drpReportList').value == "RELEASECANDIDATES" || Ext.getCmp('drpReportList').value == 'Release Candidates')
							    {
                                    Ext.getCmp('btnBasketRelease').disabled = false;
                                    Ext.getCmp('btnBasketDistribute').disabled = true;
								   
								}

							}
						}
		});
		hit.Controls.basketPanel.superclass.constructor.call(this, config);
	}

});
