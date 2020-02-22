

Ext.namespace('hit.excel.Controls');

hit.excel.Controls.LoginPanel = Ext.extend(Ext.Panel, {
	constructor : function(config) {
		Ext.apply(config, {
			id : 'loginpanel',
			title : 'Login to ChaloIS',

			width : 369,
			height : 207,
			layout : 'form',
			labelAlign : 'left',

			bodyStyle : {
				'background-color' : 'white',
				'padding-left' : '0px',
				'overflow' : 'hidden'
			},
			autoHeight : false,
			items : [new Ext.form.ComboBox({
						store : new hit.excel.Data.Stores.ApplicationComboStore(
								{}),
						id : 'cboApplication',
						blankText : 'Application name is required',
						allowBlank:false,
						msgTarget : 'side',
						mode : 'local',
						hideLabel : true,
						displayField : 'name',
						valueField : 'baseurl',
						typeAhead : true,
						triggerAction : 'all',
						emptyText : 'Select Application',
						selectOnFocus : true,
						listeners : {
							afterRender : function() {
								Ext.getCmp('cboApplication').store.load();
							},
							specialkey : function(field, e) {
								if (e.getKey() == e.ENTER) {
									this.ValidateUser();
								}
							},
							scope : this
						}
					}), {
				xtype : 'textfield',
				id : 'txtUserId',
				hideLabel : true,
				msgTarget : 'side',
				blankText : 'User Name is required',
				fieldLabel : 'User Name',
				// labelStyle: 'width:105px;margin-left:15px',
				emptyText : 'Username',
				width : '175px',
				cls : 'textfield',
				emptyClass : 'textfield-empty',
				allowBlank : false,
				listeners : {
					specialkey : function(field, e) {
						if (e.getKey() == e.ENTER) {
							this.ValidateUser();
						}
					},
					scope : this
				}
			}, {
				xtype : 'textfield',
				hideLabel : true,
				id : 'txtPassword',
				validationEvent : true,
				fieldLabel : 'Password',
				inputType : 'password',
				msgTarget : 'side',
				blankText : 'Password is required',
				// emptyText: 'Password',
				// labelStyle: 'width:105px;margin-left:15px',
				hidden : true,
				width : '175px',
				cls : 'textfield',
				emptyClass : 'textfield-empty',
				allowBlank : false,
				listeners : {
					specialkey : function(field, e) {
						if (e.getKey() == e.ENTER) {
							this.ValidateUser();
						}
					},
					scope : this
				}

			}, {
				xtype : 'textfield',
				hideLabel : true,
				id : 'txtPassword1',
				validationEvent : true,
				fieldLabel : 'Password',
				emptyText : 'Password',
				emptyClass : 'textfield-empty',
				// labelStyle: 'width:105px;margin-left:15px',
				msgTarget : 'side',
				blankText : 'Password is required',
				width : '175px',
				cls : 'textfield',
				allowBlank : false,
				listeners : {
					afterRender : function() {
						this.on("focus", function() {

							this.hide();
							this.ownerCt.getComponent('txtPassword').show()
									.focus();
								// .setValue();
							})

					}
				}

			},

			{

				xtype : 'box',
				id : 'btnSendOrder',
				validationEvent : true,
				anchor : '',
				autoEl : {
					tag : 'div',
					cls : '',
					html : ' <input type="button" class="loginbutton" value="Login" id="btnLogin" />'
					// + ' <span
					// class="raquowhite">&raquo;</span>'
				},
				listeners : {
					render : {
						fn : function(container) {
							Ext.get('btnLogin').on('click', function() {
										// container.el.on('click',
										// function() {

										this.ValidateUser();
									}, this);
						}
					},
					scope : this
				}
			}, {
				xtype : 'box',
				id : 'divMsg',
				validationEvent : true,
				anchor : '',
				autoEl : {
					tag : 'div',
					cls : 'loginMsg',
					html : '<span id="lblMsg"></span> '
					// + ' <span
					// class="raquowhite">&raquo;</span>'
				}
			}]
		});
		hit.excel.Controls.LoginPanel.superclass.constructor.call(this, config);
	},
	onLayout : function() {
		hit.excel.Controls.LoginPanel.superclass.onLayout.call(this);
		this.el.select('#ext-gen12').setStyle('margin-top', '19px');
		this.el.select('#ext-gen12').setStyle('width', '183px');

		// this.el.select('.x-form-item').setStyle('margin-bottom','13px');
		this.el.select('.x-form-item').setStyle('text-align', 'left');

		if (Ext.isIE7) {
			this.el.select('#ext-gen12').setStyle('margin-left', '46px');
			this.el.select('#ext-gen13').setStyle('margin-top', '-1px');
			this.el.select('#x-form-el-txtPassword1').setStyle('margin-top',
					'-7px');
			this.el.select('#ext-gen12').setStyle('display', 'inline');
			this.el.select('#ext-gen12').setStyle('margin-left', '92px');
			this.el.select('#ext-gen12').setStyle('width', '187px');

		} else if (Ext.isIE) {
			this.el.select('#ext-gen12').setStyle('margin-left', '92px');
			this.el.select('#x-form-el-txtPassword1').setStyle('margin-top',
					'-4px');
		}
		if (Ext.isGecko3) {
			this.el.select('#ext-gen12').setStyle('margin-left', '92px');
			this.el.select('#x-form-el-txtPassword1').setStyle('margin-top',
					'-4px');
		}
		if (Ext.isSafari) {
			this.el.select('#ext-gen12').setStyle('margin-left', '93px');
		}

		this.el.select('#x-form-el-txtUserId').setStyle('margin-left', '92px');
		// this.el.select('#x-form-el-txtUserId').setStyle('margin-bottom',
		// '13px');
		// this.el.select('#x-form-el-txtUserId').setStyle('margin-bottom','0px');
		this.el.select('#x-form-el-txtPassword')
				.setStyle('margin-left', '92px');
		this.el.select('#x-form-el-txtPassword').setStyle('margin-top', '17px');
		// this.el.select('#x-form-el-txtPassword').setStyle('margin-bottom',
		// '13px');
		// this.el.select('#x-form-el-txtPassword1').ownerCt().setStyle('margin-bottom',
		// '0px');

		this.el.select('#x-form-el-txtPassword1').setStyle('margin-left',
				'92px');
		this.el.select('#x-form-el-txtPassword1').setStyle('margin-bottom',
				'11px');
		this.el.select('#x-form-el-txtPassword').setStyle('margin-bottom',
				'4px');

		this.el.select('#ext-gen8').setStyle('text-align', 'left');
		this.el.select('#cboApplication').setStyle('width', '158px');
		this.el.select('#x-form-el-cboApplication').setStyle('margin-bottom',
				'13px');

		this.el.select('.x-form-text').setStyle('background-image', 'none');

	},
	ValidateUser : function() {

		if (!this.getComponent('cboApplication').validate()
				|| !this.getComponent('txtUserId').validate()
				|| !this.getComponent('txtPassword').validate()

		) {
			this.getComponent('cboApplication').validate()
			this.getComponent('txtUserId').validate()
			this.getComponent('txtPassword1').validate()
			// this.el.select('#ext-gen14').setStyle('left', '276px');
			return;
		}

		var applicationName = this.getComponent('cboApplication').getRawValue();
		var baseUrl = this.getComponent('cboApplication').getValue();
		var userName = this.getComponent('txtUserId').getValue();
		var password = this.getComponent('txtPassword').getValue();
		var pathName = window.location.pathname;

		// if(Ext.isGecko3){
		// pathName = pathName.substring(1,pathName.length-1);
		// }
		var kitServerurl = window.location.protocol + "//"
				+ window.location.host + pathName;

		Ext.Ajax.request({
			url : 'HITWebService.asmx/ValidateUser',
			method : 'POST',
			headers : {
				'Content-Type' : 'application/json; charset=utf-8'
			},
			jsonData : {
				applicationName : applicationName,
				baseUrl : baseUrl,
				userName : userName,
				password : password,
				kitServerurl : kitServerurl
			},
			success : function(response, request) {

				var d = Ext.decode(response.responseText);
				if (d.d != 'invalid') {

					window.location = d.d;
				} else {

					document.getElementById('lblMsg').innerHTML = "Login failed!"

				}
			},
			failure : function(response, opts) {
				var d = Ext.decode(response.responseText);

				/*
				 * Ext.Msg .alert( 'Quick Order', '"{0}".', 'Oops ! could not
				 * communicate with the server.If this problem persist then
				 * please try again or refresh this page.');
				 */
			},
			scope : this
		});

	}

});

Ext.reg('LoginPanel', hit.excel.Controls.LoginPanel);

/*
 * Ext.override(Ext.form.ComboBox, { onLoad: function() { if (!this.hasFocus) {
 * return; } if (this.store.getCount() > 0) {
 * 
 * this.expand(); this.restrictHeight();
 * 
 * if(Ext.isIE){ this.list.setStyle('left', this.el.getLeft()-2 + 'px'); }else{
 * this.list.setStyle('left', this.el.getLeft() + 'px'); }
 * 
 * if (this.lastQuery == this.allQuery) { if (this.editable) {
 * this.el.dom.select(); } if (!this.selectByValue(this.value, true)) {
 * this.select(0, true); } } else { this.selectNext(); if (this.typeAhead &&
 * this.lastKey != Ext.EventObject.BACKSPACE && this.lastKey !=
 * Ext.EventObject.DELETE) { this.taTask.delay(this.typeAheadDelay); } } } else {
 * this.onEmptyResults(); }
 *  } // do stuff } );
 */