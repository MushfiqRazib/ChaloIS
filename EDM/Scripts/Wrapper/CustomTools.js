    
     Ext.namespace('chalo');
     chalo.drpDownGroupBy = Ext.extend(Ext.form.ComboBox,{
      id: 'drpGroupByList',
        initComponent:function(){
            Ext.apply(this,{
               
                name:'drpGroupByList',
                renderTo:'drpGroupByContainerDiv',
                width: 130,
                mode:'local',
                typeAhead: true,
                selectOnFocus : true,
                displayField:'caption',
                style:'font-family:Helvetica,sans-serif;font-size:13px;',
                forceSelection:true,
                valueField:'value',
                triggerAction: 'all',
                maskRe:new RegExp('\/?.')
            });
            chalo.drpDownGroupBy.superclass.initComponent.call(this);
        }
     });
     
     
        