// / <reference path="../ext/ext-all.js" />

Ext.namespace('hit.Controls');

hit.Controls.leftPanelContainer = Ext.extend(Ext.Panel,{
	constructor:function(config)
	{
		Ext.apply(config,{
			layout: 'column',
			items: [new Ext.form.RadioGroup({  
				fieldLabel: 'Report ',
				columns: 1,
				width: 200,
				style: { 'background-color': 'F4F3EE','margin-top': '10px','width':'200px' },
				items: [  
		                {
		                    boxLabel: 'Office Excel (.xls)',
		                    name: 'report', 
		                    checked:true,
		                    inputValue: 'xls'
		                },
		                {
		                    boxLabel: 'Comma-separated value (.csv)', name: 'report', inputValue: 'csv'
		                },
		                {
		                 boxLabel: 'Acrobat Reader (.pdf)', name: 'report', inputValue: 'pdf',
		                 listeners:
		                 {   
		                    scope:this,
		                   'check':function(caller)
		                    {
		                       if(caller.checked){
		                            Ext.getCmp('optionPanel').expand();
		                            Ext.getCmp('formatPanel').expand();
		                            Ext.getCmp('repSizePanel').expand();
		                            if( OBSettings.SQL_GROUP_BY != "NONE")
		                            {
		                                 Ext.getCmp('lblColorHint').show();
		                                 var chkColor = Ext.getCmp('chkColourMode');
		                                 chkColor.show();
		                                 if(chkColor.checked)
		                                 {
		                                    Ext.getCmp('reportTypePanel').expand();
		                                 }
		                            }
		                       }
		                       else
		                       {
		                            Ext.getCmp('optionPanel').collapse();
		                            Ext.getCmp('formatPanel').collapse();
		                            Ext.getCmp('repSizePanel').collapse();
		                            
		                            if(Ext.getCmp('chkColourMode').isVisible()){
		                                 Ext.getCmp('lblColorHint').hide();
		                                 Ext.getCmp('chkColourMode').hide();
		                                 var charTypePanel = Ext.getCmp('reportTypePanel');
		                                 if(Ext.isDefined(charTypePanel))
		                                 {
		                                    charTypePanel.collapse();
		                                 }
		                            }
		                       }  
		                    }
		                } 
		            }  
		           ]
				}),
				
				
				 {
		           xtype:'checkbox',
		           fieldLabel: 'Colour Mode',
		           width: 150,
		           hidden:true,
				   height:80,
		           id: 'chkColourMode',
				   boxLabel: 'Enable colour mode',
		           checked: false ,
				   style: {'margin-top':'65px'},
				   listeners:{
				    scope:this,
				    'check':function(caller){
				        if(caller.checked)
				        {
				             Ext.getCmp('reportTypePanel').expand();
				        }
				        else{
				             Ext.getCmp('reportTypePanel').collapse();
				        }
				    }
				   }		   
		        }
					 
			]
		});
		
		hit.Controls.leftPanelContainer.superclass.constructor.call(this,config);
	}

});

 
 hit.Controls.reportPanel = Ext.extend(Ext.Panel,{
 	constructor:function(config)
 	{
 		Ext.apply(config,{
 			 bodyBorder: false,
 			 border:false,
             height: 150,
			 width: 400,
			 labelAlign: 'left',
			 bodyStyle: {
                 'background-color': 'F4F3EE',
                 'padding-left': '0px',
				 'margin-left': '10px',
                 'overflow': 'hidden'
                 
             },
			 items: [new hit.Controls.leftPanelContainer({id: 'leftPanelContainer',border:false}),
					 {
						xtype: 'label',
						hidden:true,
						id: 'lblColorHint',
						html: '<span  >Hint: with colour mode enable you can create more <br />specific reports and generate management information.</span>',
						style: { 'width': '200px','font-size': '12px'}
					 }
			 
			]
 		});
 		hit.Controls.reportPanel.superclass.constructor.call(this,config);
 	}
 });
 

 
 
 hit.Controls.optionPanel =  Ext.extend(Ext.Panel,{
    constructor:function(config)
    {
        Ext.apply(config,{
             bodyBorder: false,
             height: 150,
			 labelAlign: 'left',
			 bodyStyle: {
                 'background-color': 'F4F3EE',
                 'padding-left': '0px',
                 'overflow': 'hidden',
				 'font-size': '14px'
             },
			 items: [{
						xtype: 'label',
						id: 'lblOptions',
						html: '<span  >Options</span>',
						style: { width: '150px'}
						},
						new Ext.form.CheckboxGroup({  
							fieldLabel:'Options',
							columns: 1, //showing two columns of checkboxes
							style: { 'margin-top': '10px','width':'150px' },
							items:[  
								{boxLabel: 'Add username', name: 'username', checked: true}, //field checked from the beginning  
								{boxLabel: 'Add title', name: 'title', checked: true},  
								{boxLabel: 'Add date', name: 'date', checked: true},  
								{boxLabel: 'Display filter', name: 'filter', checked: true}  
							]  
						})
			 
			 ]
        });
        hit.Controls.optionPanel.superclass.constructor.call(this,config);
    }
 
 });
 
 hit.Controls.formatPanel = Ext.extend(Ext.Panel,{
 	constructor:function(config)
 	{
 		Ext.apply(config,{
 			
             bodyBorder: false,
             height: 150,
             
			 labelAlign: 'left',
			 bodyStyle: {
                 'background-color': 'F4F3EE',
                 'padding-left': '0px',
                 'overflow': 'hidden'
             },
			 items: [
				        {
						xtype: 'label',
						id: 'lblFormat',
						html: '<span  >Format</span>',
						style: { width: '150px'}
						},
						new Ext.form.RadioGroup({
							fieldLabel: 'Report Format',
							columns: 1,
							width: 150,
							style: { 'background-color': 'F4F3EE','margin-top': '10px','width':'150px' },
							items: [
								    { boxLabel: 'Portrait', name: 'reportSize', inputValue: 'portrait', checked: true },
								    { boxLabel: 'Landscape', name: 'reportSize', inputValue: 'landscape' }
								    
							       ]
						})
						
			 
				   ]
 		});
 		hit.Controls.formatPanel.superclass.constructor.call(this,config);
 	}
 
 });
 
 hit.Controls.papersizePanel = Ext.extend(Ext.Panel,{
 	constructor:function(config)
 	{
 		Ext.apply(config,{
 			 bodyBorder: false,
	         height: 150,
	         labelAlign: 'left',
			 bodyStyle: {
	             'background-color': 'F4F3EE',
	             'padding-left': '0px',
	             'overflow': 'hidden'
	         },
			 items: [
				        {
						xtype: 'label',
						id: 'lblRepSize',
						html: '<span  >Report Size</span>',
						style: { width: '150px'}
						},
						new Ext.form.RadioGroup({
							fieldLabel: 'Report Size',
							columns: 1,
							width: 150,
							style: { 'background-color': 'F4F3EE','margin-top': '10px','width':'150px' },
							items: [
								    { boxLabel: 'A3', name: 'paperSize', inputValue: 'a3' },
								    { boxLabel: 'A4', name: 'paperSize', inputValue: 'a4' , checked: true }
								    
							       ]
						})
						
			 
				   ]
 		});
 		
 		hit.Controls.papersizePanel.superclass.constructor.call(this,config);	
 	}
 
 });

 
 hit.Controls.reportTypePanel = Ext.extend(Ext.Panel,{
    constructor:function(config)
    {
    	Ext.apply(config,{
    		 bodyBorder: false,
             height: 150,
			 labelAlign: 'left',
			 bodyStyle: {
                 'background-color': 'F4F3EE',
                 'padding-left': '0px',
                 'overflow': 'hidden'
             },
			 items: [
						{
						   xtype: 'label',
						   id: 'lbType',
						   html: '<span>Report Type</span>',
						   style: { width: '150px' }
							
						},
						new Ext.form.RadioGroup({
							fieldLabel: 'Report Type',
							columns: 1,
							width: 150,
							style: { 'background-color': 'F4F3EE','margin-top': '10px','width':'150px' },
							items: [
								{ boxLabel: 'Regular', name: 'reportType', inputValue: 'regular', checked: true },
								{ boxLabel: 'Piechart', name: 'reportType', inputValue: 'piechart' },
								{ boxLabel: 'Histogram', name: 'reportType', inputValue: 'histogram' }
            
							]
						})
			 	 ]
    	});
    	
    	hit.Controls.reportTypePanel.superclass.constructor.call(this,config);        
    }
 
 });
 
 
 hit.Controls.mainReport = Ext.extend(Ext.Panel, {
     constructor: function(config) {
         Ext.apply(config, {
             id: 'mainReportPanel',
             bodyBorder: false,
             
             height: 180,
             width: '99%',
             layout: 'form',
             labelAlign: 'left',
             bodyStyle: {
                 'background-color': 'F4F3EE',
                 'padding-left': '0px',
                 'overflow': 'hidden'
             },
             autoHeight: false,
             items: [{
                 xtype: 'fieldset',
                 title: 'Report Layout',
                 height: 170,
                 layout: 'column',
                 style: 'margin-left:10px;',
                 layoutConfig: { columns: 5 },
                 items: [new hit.Controls.reportPanel({ id: 'reportLeftPanel'}),
				 		 new hit.Controls.optionPanel({id: 'optionPanel',collapsed:true}),
						 new hit.Controls.papersizePanel({id: 'repSizePanel',collapsed:true}),
						 new hit.Controls.formatPanel({id: 'formatPanel',collapsed:true}),
						 new hit.Controls.reportTypePanel({id: 'reportTypePanel',collapsed:true}),				
						 {
						    xtype: 'button',
						    id: 'btnGenerate',
						    text: 'Generate',
						    height: '25px',
						    width: '70px',
						    style: {'margin-top':'100px', 'float':'right'},
						    listeners:{
						          'click':function(button,e)
						           {
						                GenerateReport();
						           }
						    }
						 }
					    ]
				}]
             });
             hit.Controls.mainReport.superclass.constructor.call(this,
						config);
         }
     });
     
     
    