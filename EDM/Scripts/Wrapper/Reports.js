function GenerateReport()
{
    var whichReport = Ext.getCmp("leftPanelContainer").items.items[0].getValue().inputValue;
    if(whichReport != 'pdf')
    {
        GenerateExcelOrCSVReport(whichReport);
    }
    else{
       
       var config = GetColorOptions();
       GeneratePdfReport(config);
      
    }
}

function GetColorOptions()
{
    var config = {};
    config.colorSettings = {};
   
    config.title = '';
    config.username = '';
    config.date = '';
    config.filter = '';
    config.repSize = '';
    config.colorSettings.enable = false;
    config.colorSettings.chartType = '';
    
    var chkBxColor = Ext.getCmp('chkColourMode');
    var optionPanelItems =Ext.getCmp('optionPanel').items.items[1].items.items;
    
    if(chkBxColor && chkBxColor.checked)
    {
         config.colorSettings.enable = true;
         config.colorSettings.chartType = Ext.getCmp('reportTypePanel').items.items[1].getValue().inputValue;
    }
    
    config.username = 'Test User Name';
    config.title = optionPanelItems[1].checked ? OBSettings.REPORT_NAME : '';
    config.date = optionPanelItems[2].checked ? true : 'null';
    config.filter = optionPanelItems[3].checked ? 'show filter' : 'null';
    
    
    config.format = Ext.getCmp('formatPanel').items.items[1].getValue().inputValue;
    config.repSize = Ext.getCmp('repSizePanel').items.items[1].getValue().inputValue;
    
    return config;
    
}

function GenerateExcelOrCSVReport(extension)
{
    var table = OBSettings.SQL_FROM;
    var fields = GetVisibleFields().replace(/;/g,',');
    var whereclause = OBSettings.SQL_WHERE;
    var groupby = OBSettings.SQL_GROUP_BY;
    var orderby = OBSettings.SQL_ORDER_BY;
    var reportcode = OBSettings.REPORT_CODE;
		
	whereclause = EncodeWhereClause(whereclause);
			
	var uri = "Report/ExcelReport.aspx?";
	var parameter = "table="+table+"&fields="+fields+"&whereclause="+whereclause+"&groupby="+groupby+"&orderby="+orderby+"&reportcode="+reportcode+"&repExtension="+extension;
	
	var wndName = "ExcelReport";
	
	
	var wnd = window.open(uri+parameter,wndName);
	
	if(!wnd)
	{
	    //Ext.Msg.alert("Please disable your popup blocker!");
	    ShowMessage("Popup blocker", "Please disable your popup blocker!", 'i', null);

	}
	
}

function GenerateExcelOrCSVReportForList(paramsArray)
{
    var reportcode = OBSettings.REPORT_CODE;
	var extension = "xls";
	
	var uri = "Report/ExcelReport.aspx?";
	var parameter = "sqlFrom="+ paramsArray[0] +"&repExtension="+ extension+"&whereClause="+paramsArray[1] +"&artCode="+paramsArray[4] +"&listName="+paramsArray[3]+"&reportcode="+reportcode;
	
	var wndName = "ExcelReport";
	
	
	var wnd = window.open(uri+parameter,wndName);
	
	if(!wnd)
	{
	    //Ext.Msg.alert("Please disable your popup blocker!");
	    ShowMessage("Popup blocker", "Please disable your popup blocker!", 'i', null);
	}
}

function GeneratePdfReportForList(paramsArray)
{
    var isGroupColoredID = 1;
    var reportCode = OBSettings.REPORT_CODE;
    var table = OBSettings.SQL_FROM;
    var fieldswidth = GetVisibleFieldsWidth().replace(/;/g, ',');

    var reptype = '';
    
    var params = "table="+ paramsArray[0] +"&fieldswidth="+fieldswidth+"&whereClause="+paramsArray[1] +"&artCode="+paramsArray[4] +"&listName="+paramsArray[3]+"&reportcode="+reportCode+"&LstQuery=lst";
    //params = escape(params);
	
	var uri = "Report/PdfReport.aspx?"+params;
    var parameter = "&username=user"+"&titel="+OBSettings.REPORT_NAME+"_"+paramsArray[3]+"&showfilter=showfilter"+"&curdate=true"+"&paperformat="+"portrait"+"&papersize="+"a4"+"&reporttype=regular";
    parameter = escape(parameter);
	var gbSelectExpression = "count(*) as nr";	
	var p = "&gbselectexpression="+gbSelectExpression+"&reporttype="+reptype;
	parameter += escape(p);
	
    var wndName = "PDFReport";
    var features = "toolbar=no,directories=no,status=no,scrollbars=yes,menubar=no,location=no,resizable=yes,width="+(parseInt(screen.width)-200)+",height="+(parseInt(screen.height)-200);

    var wnd = window.open(uri+parameter, wndName, features);
    wnd.moveTo(0,0);
    //*** Check for popup blocker!
    if(!wnd)
    {
        //Ext.Msg.alert("Please disable your popup blocker!");
        ShowMessage("Popup blocker", "Please disable your popup blocker!", 'i', null);
    }
    else
    {
	   wnd.focus();
    }
	
}


function GeneratePdfReport(config)
{
    var isGroupColoredID = 1;
    var table = OBSettings.SQL_FROM;
    var fields = GetVisibleFields().replace(/;/g, ',');
    var fieldswidth = GetVisibleFieldsWidth().replace(/;/g, ',');    
    var whereclause = OBSettings.SQL_WHERE;
    var groupby = OBSettings.SQL_GROUP_BY;
    var orderby = OBSettings.SQL_ORDER_BY;
    var reportCode = OBSettings.REPORT_CODE;
    var reportName = OBSettings.REPORT_NAME;
    var gb_select = GetGB_SelectFields(OBSettings.QB_GB_SELECT_CLAUSE);
    
    var username = config.username;
    var title = config.title;
    var showfilter = config.filter;
    var curdate = config.date;
   
    var paperformat =config.format;
    var papersize = config.repSize;
    if(config.colorSettings && config.colorSettings.enable)
        var reptype = config.colorSettings.chartType;
   
    fields = fields.replace('+', "%2B");
    fieldswidth = fieldswidth.replace('+', "%2B");
    var params = "table="+table+"&fields="+fields+"&fieldswidth="+fieldswidth+"&whereclause="+whereclause+"&groupby="+groupby+"&orderby="+orderby+"&reportcode="+reportCode+"&gb_select="+gb_select+"&reportName="+reportName;
	params = escape(params);
	
	
	var uri = "Report/PdfReport.aspx?"+params;
    var parameter = "&username="+username+"&titel="+title+"&showfilter="+showfilter+"&curdate="+curdate+"&paperformat="+paperformat+"&papersize="+papersize+"&reporttype=regular";
    parameter = escape(parameter);
	
	var gbSelectExpression = "count(*) as nr";
	if(OBSettings.GB_SQL_SELECT.search("nr")==-1){
	  gbSelectExpression = "";
	}
	if(groupby!=""){
	    if(OBSettings.QB_CUSTOM_FIELDS!=""){	       
	       gbSelectExpression += OBSettings.QB_CUSTOM_FIELDS
	       gbSelectExpression = gbSelectExpression.replace(';',',');
	    }
	}	
	var p = "&gbselectexpression="+gbSelectExpression+"&reporttype="+reptype;
	parameter += escape(p);
	
    var wndName = "PDFReport";
    var features = "toolbar=no,directories=no,status=no,scrollbars=yes,menubar=no,location=no,resizable=yes,width="+(parseInt(screen.width)-200)+",height="+(parseInt(screen.height)-200);

    var wnd = window.open(uri+parameter, wndName, features);
    wnd.moveTo(0,0);
    //*** Check for popup blocker!
    if(!wnd)
    {
        //Ext.Msg.alert("Please disable your popup blocker!");
        ShowMessage("Popup blocker", "Please disable your popup blocker!", 'i', null);
    }
    else
    {
	   wnd.focus();
    }
	
	
}


function GetGB_SelectFields(gb_select_fields)
{
    if(gb_select_fields)
    {
        var selectFieldList = new Array();
        var expressions = gb_select_fields.split(';');
        for(var i=0;i<expressions.length;i++)
        {
            var fieldNames = expressions[i].toUpperCase().split(" AS ");
            selectFieldList.push(expressions[i]+"$$$"+fieldNames[1]);
        }
        
        return selectFieldList.join(",");
    }
    else
    {
        return "";
    }
}

function EncodeWhereClause(whereclause)
{
	var updatedwhereclause = whereclause;
	
	if(updatedwhereclause!="")
	{
		var filters = updatedwhereclause.split("AND");
		var i;
		
		for(i=0; i<filters.length;i++ )
		{
			var filter = filters[i];
			
			var filtervalues = filter.split("LIKE");
			
			if(filtervalues.length==2) // a like '%b'%'
			{
				var orginalfilter = filtervalues[1];
				
				var replorginalfilter = orginalfilter.replace("%","-");
				replorginalfilter = replorginalfilter.replace("%","-");
				
				var replfilter = filter.replace(orginalfilter, replorginalfilter);
				
				updatedwhereclause = updatedwhereclause.replace(filter,replfilter);
			}
		}
	}

	return updatedwhereclause;
}

function GetVisibleFields()
{
    var currentVisibleFields = "";
    
    if(OBSettings.SQL_GROUP_BY == "NONE" ) {
        currentVisibleFields = GetCurrentVisibleFieldNames();
    }
    else {
        currentVisibleFields = OBSettings.SQL_SELECT;

        if (OBSettings.ACTIVE_GRID == 'DETAIL_GRID') {
            currentVisibleFields = GetCurrentVisibleFieldNames();
        }
    }
    
    return currentVisibleFields;
}

function GetVisibleFieldsWidth()
{
    var currentVisibleFieldsWithWidth = "";
 
    if(OBSettings.SQL_GROUP_BY == "NONE" ) {
        currentVisibleFieldsWithWidth = GetCurrentVisibleFieldNamesWithWidth();
    }
    else {
        
        if (OBSettings.ACTIVE_GRID == 'DETAIL_GRID') {
            currentVisibleFieldsWithWidth = GetCurrentVisibleFieldNamesWithWidth();
        }
    }
    
    return currentVisibleFieldsWithWidth;
}
