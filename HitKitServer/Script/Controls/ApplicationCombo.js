(function() {
    Ext.namespace("hit.excel.Controls");

    hit.excel.Controls.ApplicationCombo = Ext.extend(
			Ext.form.ComboBox, {
			    constructor: function(config) {
			        config.mode = config.mode || 'remote';
			        config.forceSelection = config.forceSelection || true;
			        config.store = config.store
							|| new hit.excel.Data.Stores.ApplicationComboStore({});
			        config.valueField = config.valueField || 'baseurl';
			        config.displayField = config.displayField || 'name';
			        config.typeAhead = config.typeAhead || true;
			        config.triggerAction = config.triggerAction || 'all';
			        config.minChars = config.minChars || 1;
			        config.emptyText = "Select Application";
			        config.shadow = false;
			        config.allowBlank = config.allowBlank || false;
			        config.blankText = "Select Application";
			        config.tpl = config.tpl || '<tpl for="."><div class="x-combo-list-item">{' + config.displayField + '}</div></tpl>',
			        config.autoLoad = true;
			        config.hideLabel=true;
			        //config.width = '180px';
			        //config.cls =config.cls || 'combo2d';
			        hit.excel.Controls.ApplicationCombo.superclass.constructor
							.call(this, config);
			    },
			    initComponent: function() {
			        hit.excel.Controls.ApplicationCombo.superclass.initComponent
							.call(this);
			        		        this.on("render", function() {
			        //			            this.mode = 'local';
			        //			            //
			                    this.wrap.select('.x-form-element').removeClass('x-form-element');
			        			        });

			    },
			    onDestroy: function() {

			        hit.excel.Controls.ApplicationCombo.superclass.onDestroy
							.call(this);
			    }

			});
    Ext.reg('ApplicationCombo', hit.excel.Controls.ApplicationCombo);
} ());
