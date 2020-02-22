 function OpenBasket()
 {
     if (SessionExists())
    {
        var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
        OpenChild(COMPONENT_BASE_PATH + "Basket/Basket.asp?rc=false", "Basket", true, 665, 350, "no", "no");           
    }
 } 
 
 
  function SendBasket()
 {
     if (SessionExists())
    {
        var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
        //OpenChild(COMPONENT_BASE_PATH + "Basket/Basket.asp?rc=false", "Basket", true, 665, 350, "no", "no");           
        var url = COMPONENT_BASE_PATH + "Basket/Basket.asp?rc=false";
         var httpResult = httpRequest(url);                      
     
    }
 } 
 
    function loadPrinten(){
      var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
      openChild(COMPONENT_BASE_PATH +"Print/Print_5_5.asp?frombasket=true", "Printen", true, 520, 350, "no", "no");     
      //openChild("../Print/Print_1_5.asp", "Printen", true, 700,750, "no", "no");     
    } 
 
 function httpRequest(url)
{
  var xmlhttp = new XMLHttpRequest();
  
  //*** Set request URL.
  xmlhttp.open("GET", noCacheURL(url), false);
  
  //*** Send request and wait...
  xmlhttp.send(null);
  
  return xmlhttp.responseText;
}

 function loadDistribute(){
     
       var name = prompt("Type distribute name", distName);
       if(name == null ) return false;
       name = trim(name);
       
       if(checkValue(name) == false)
       {
          //alert('special char not allowed')
          alert("Following Characher not allowed...\n"+"          "+"\\ "+" / "+" * "+" ? "+" \" "+" < "+" > "+" | ")
          loadDistribute();
          return false;        
       }    
       var distName =  name;
       
       var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
       OpenChild(COMPONENT_BASE_PATH +"Distribute/Distributie_5_5.asp?distributename="+name+"&frombasket=true", "Distribute", true, 535, 350, "no", "no");                   
       //OpenChild(COMPONENT_BASE_PATH + "Basket/Basket.asp?rc=false", "Basket", true, 665, 350, "no", "no");           
    } 

function GetCurrentReportSettings()
{
    var fieldWidth;
    var selectedFieldsWidths = GetCurrentVisibleFieldWidths().split(';');
    var vis_fields = '{"visible_fields":[';
    for(var i=0;i<selectedFieldsWidths.length;i++)
    {
        fieldWidth = selectedFieldsWidths[i].split("=");
        vis_fields += '{"Name":"'+fieldWidth[0]+'","Width":"'+fieldWidth[1]+'"},';
    }
    
    vis_fields = vis_fields.substring(0,vis_fields.length-1);
    vis_fields += ']';
         
    vis_fields +=   ',"qb_custom_fields":"'+OBSettings.QB_CUSTOM_FIELDS+
                    '","qb_gb_select":"'+OBSettings.QB_GB_SELECT_CLAUSE+
                    '","sql_group_by":"'+OBSettings.SQL_GROUP_BY+
                    '","page_size":'+OBSettings.PAGE_SIZE+'}';
 
    return vis_fields;
}

function SaveUsersCurrentSettings(configObj)
{    
    
    var reportName = "";
    var newReportName = "";
    var report_settings = configObj.report_settings;
    if(configObj.mode == "new")
    {
    	newReportName = configObj.report_name;
        reportName = OBSettings.REPORT_CODE;
    }
    else
    {
        reportName = OBSettings.REPORT_CODE;
    }
    
    try
    {    
        var currentGrid = OBSettings.GetActiveGrid(); 
        //debugger;
        var params = "{REPORT_CODE:'"
								+ escape(reportName)
								+ "', " + "REPORT_NAME:'"
								+ escape(newReportName)
								+ "', " + "SQL_WHERE:\""
								+ escape(OBSettings.SQL_WHERE)
								+ "\", " + "GROUP_BY:'"
								+ escape(OBSettings.SQL_GROUP_BY)
								+ "', " + "ORDER_BY:'"
								+ escape(OBSettings.SQL_ORDER_BY)
								+ "', " + "ORDER_BY_DIR:'"
								+ escape(OBSettings.SQL_ORDER_DIR)
								+ "', " + "field_caps:'"
								+ escape(OBSettings.FIELD_CAPS)
								+ "', " + "report_settings:'"
								+ escape(report_settings)
								+ "', " + "sid:'"
								+ escape(SECURITY_KEY)
								+ "', " + "reports:'"
								+ authInformation.REPORT.toString() + "," + newReportName
								+ "', " + "obs:'"
								+ authInformation.OB.toString()
								+ "', " + "mode:'"
								+ configObj.mode +"' }";
										
        var serviceName = "SaveUserDefinedReportSettings";
        var isSuccess = GetSyncJSONResult_Wrapper(serviceName, params);
        if(isSuccess)
        {
            //Ext.Msg.alert("Report settings saved to database successfully");

            ShowMessage("successfully", "Report settings saved to database successfully", 'i', null);
            //debugger;
            
            if (configObj.mode == 'new') {
                Ext.getCmp('saveAsWindow1').close();
                LoadReportList(newReportName);
            }
        }
        
     }
     catch(e)
     {
         //Ext.Msg.alert("Failed to save report setings. ");
         ShowMessage("Failed", "Failed to save report setings. ", 'w', null);

     }   
}

function SaveSelectedThemeColors(HeaderChekBoxName)
{	              
    var currentGrid = OBSettings.GetActiveGrid(); 
    if(currentGrid)
    {
        var groupCode = '';
        var colorCode = '';
        var selectedRecords = OBSettings.groupedGrid.getSelectionModel().getSelections();                                
        //*** Add field data to the collection 
        for(var i=0; i<selectedRecords.length; i++)
        {
            colorCode += selectedRecords[i].data.THEME_COLOR.split('colorcode=')[1].split('>')[0].replace(/"/,'').replace(/"/,'') + ",";
            groupCode += selectedRecords[i].data[OBSettings.SQL_GROUP_BY] + ",";                          
        }    
       
        if(colorCode == '')
        {
            return;
        }

        var params  =  "{ REPORT_CODE:'" + OBSettings.REPORT_CODE + "', " +
                        "GROUP_BY:'" + OBSettings.SQL_GROUP_BY + "', " +
                        "GROUP_CODE:'" + groupCode + "', " +
                        "COLOR_CODE:'" + colorCode +  "' }";	

        var serviceName = "InsertGroupColor";
        var reportInfo = GetSyncJSONResult_Wrapper(serviceName, params);
        reportInfo = eval('(' + reportInfo + ')');
        reportInfo = eval('(' + reportInfo.d + ')');
        if(reportInfo.result)
        {
            //Ext.Msg.alert("Color saved successfully.");
            ShowMessage("Color saved", "Color saved successfully.", 'i', null);

        }  
    }else
    {
        //Ext.Msg.alert("No color information available to save");
        ShowMessage("Color saved", "No color information available to save", 'w', null);
    }
}

function OpenQueryBuilder() 
{   
   var popup = OpenChild("./Query Builder/QueryBuilder.aspx", "QueryBuilder", true, 518, 395, "no", "no", false);
   popup.focus();
}


function ShowThemeColor()
{	
    var currentGrid = OBSettings.GetActiveGrid(); 
    if(currentGrid)
    {
	    document.getElementById("divThemeColor").style.display = 'block';       	
        OBSettings.COLOR_MODE = OBSettings.COLOR_MODE ? 0 : 1;
        
//        if(OBSettings.COLOR_MODE)
//        {
//            Ext.get("divSaveColor").setStyle('display','block');  
//        }else
//        {
//            Ext.get("divSaveColor").setStyle('display','none');    
//        }

        OBSettings.ShowMainLoadingImage();
        setTimeout(function(){
                    OBSettings.CreateGroupByGrid();
                       }, 1);
    }else
    {
        //Ext.Msg.alert("Unable to continue");
        ShowMessage("Unable", "Unable to continue", 'w', null);

    }
}


//**************************** Report section ***************************
// will be obsolate.....
function OpenReportOption()
{
    var currentVisibleFields = "";
    var currentVisibleFieldsWithWidth = "";
 
    if(OBSettings.SQL_GROUP_BY == "NONE" ) {
        currentVisibleFields = GetCurrentVisibleFieldNames();
        currentVisibleFieldsWithWidth = GetCurrentVisibleFieldNamesWithWidth();
    }
    else {
        currentVisibleFields = OBSettings.SQL_SELECT;

         //currentVisibleFields = GetCurrentVisibleFieldNamesWithWidth();
        if (OBSettings.ACTIVE_GRID == 'DETAIL_GRID') {
            currentVisibleFields = GetCurrentVisibleFieldNames();
            currentVisibleFieldsWithWidth = GetCurrentVisibleFieldNamesWithWidth();
        }

                
    }
    
    if(OBSettings.COLOR_MODE == 1)
    {
        OpenChild('./Report/common_template.html?isGroupColoredID=1&fields='+currentVisibleFields+'&fieldswidth='+currentVisibleFieldsWithWidth, 'PDFReportOptions', true, 330, 150, 'no', 'no');
    }
    else
    {
        OpenChild('./Report/common_template.html?isGroupColoredID=null&fields='+currentVisibleFields+'&fieldswidth='+currentVisibleFieldsWithWidth, 'PDFReportOptions', true, 330, 150, 'no', 'no');
    }
}
