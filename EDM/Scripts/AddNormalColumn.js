Ext.namespace('hit.Controls');

hit.Controls.AddNormalColumnWindow = Ext.extend(Ext.Window, {
    id: 'aNormalColWidow',

    initComponent: function()
    {
        Ext.applyIf(this, {
            width: 255,
            height: 170,
            layout: 'column',
            closable: true,
            closeAction: 'close',
            draggable: false,
            plain: true,
            title: 'Add Column',
            bodyStyle: {
                margin: ' 5px 5px 0px 5px'
            },
            items: [{
                xtype: 'label',
                html: '<span>Expression</span>',
                width: 100,
                style: 'margin:0px 0px 10px 0px;'
            }, {
                xtype: 'textarea',
                id: 'txtExpression',
                autoScroll:true,
                hideLabel: true,
                emptyText: '',
                style: 'margin:0px 0px 10px 0px;',
                width: 230,
                height: 40,
                style : {          
                                    
                                      overflow:'auto'
                                     }

            }, {
                xtype: 'label',
                html: '<span>Caption</span>',
                style: 'margin:0px 0px 10px 0px;',
                width: 100
            }, {
                xtype: 'textfield',
                id: 'txtCaption',
                hideLabel: true,
                emptyText: '',
                width: 150
            }, {
                xtype: 'button',
                text: 'Ok',
                width: 80,
                style: 'margin:0px 0px 0px 5px;',
                handler: function()
                {
                   
                    var caption = trim(Ext.getCmp('txtCaption').getValue());
                    var expression = trim(Ext.getCmp('txtExpression')
									.getValue());

                    if (caption != "" && expression != "")
                    {

                        var myMask = new Ext.LoadMask(Ext
								 .getBody(), {
								     msg: "Checking...",
								     removeMask: false
								 });
                        myMask.show();
                        var capExpress = expression + ' AS ' + caption;
                        var msg = this.ownerCt
										.CheckCustomField(capExpress);
                        var nlgridid = Ext.getCmp('nrgridid');
                        var duplicateEntry = false;
                        var rec;
                        for (i = 0; i < nlgridid.store.getCount(); i++)
                        {
                            rec = nlgridid.store.getAt(i);
                            if (rec.data.expression == capExpress)
                            {
                                ShowMessage("Duplicate Entry", "Duplicate Entry", 'w', this.id);
                                duplicateEntry = true;
                                break;
                            }
                        }
                        myMask.hide();
                        if (!duplicateEntry)
                        {
                            if (msg == 'true')
                            {
                                Ext.getCmp('mainSettingsPanel').normalWindow = false;
                                var width = 75;

                                var u = new nlgridid.store.recordType({
                                    fieldName: capExpress,
                                    width: width,
                                    expression: capExpress,
                                    caption: caption
                                });
                              
                                //nlgridid.store.insert(0, u);
                                nlgridid.store.insert(nlgridid.store.getCount(), u);

                                Ext.getCmp('aNormalColWidow').close();
                            } else
                            {

                                ShowMessage('Error', msg, 'e', this.id);


                            }
                        }
                    } else
                    {
                        Ext.Msg.show({
                            title: '',
                            msg: 'Please Enter Expression and Caption!',
                            buttons: Ext.Msg.OK,
                            icon: Ext.MessageBox.INFO
                        });
                    }
                }

}]

            });
            hit.Controls.AddNormalColumnWindow.superclass.initComponent.call(this);
        }, onDestroy: function()
        {

            Ext.getCmp('mainSettingsPanel').normalWindow = false;
            hit.Controls.AddNormalColumnWindow.superclass.onDestroy.call(this);

        },
        CheckCustomField: function(clause)
        {

            var reportCode = OBSettings.REPORT_CODE;
            var sqlFrom = OBSettings.SQL_FROM;
            var groupBy = OBSettings.SQL_GROUP_BY ;
            if (groupBy != 'NONE')
            {
                
                clause += "," + groupBy ;
                var params = "{ REPORT_CODE:'" + escape(reportCode) + "', "
				    + "SQL_FROM:'" + sqlFrom + "', " + "customFields:'"
				     + escape(clause) + "', " + "groupBy:'"+ groupBy +"'}";
				var serviceName = "CheckCustomFieldValidation";        
            }
            else if (groupBy == 'NONE')
            {
                var params = "{ REPORT_CODE:'" + escape(reportCode) + "', "
				    + "SQL_FROM:'" + sqlFrom + "', " + "customFields:'"
				    + escape(clause) + "', " + "groupBy:''}";
				var serviceName = "CheckCustomFieldValidation";    
			}

            //var serviceName = "CheckCustomFieldValidation";
            var result = OBSettings.GetSyncJSONResult(serviceName, params);
            result = eval('(' + result + ')').d;
            return result;
        }

    });