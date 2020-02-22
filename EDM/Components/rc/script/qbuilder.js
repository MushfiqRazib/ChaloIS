//******************************************************************************
//*** ADO DataTypeEnum
//******************************************************************************
var adEmpty    =   0;
var adBoolean  =  11;
var adNumeric  = 131;
var adVarChar  = 200;

//******************************************************************************
//*** Local Variables
//******************************************************************************
var m_GroupingField = "";
var m_GroupingType  = 0;



//******************************************************************************
//*** 'Where Clause' functions
//******************************************************************************
function addWhereClause(wcChar)
{
  var oList = getElement("WhereList");
  
  if (oList)
  {
    var oOption = document.createElement("OPTION");
    var fldName = getElementAttrib("FieldName", "value");
    var fldType = getElementAttrib("FieldType", "value");
    var fldComp = getElementAttrib("FieldComp", "value");
    var fldVal  = getElementAttrib("FieldValue", "value");
    
    //*** TODO: Check with Sarissa if this will give a valid query...
        
    //*** Add quotes in case of string.
    if (fldType == adVarChar) 
    {
		fldVal = sqlEnc(fldVal);
	}
    
    //*** Add wildcards if LIKE-value contains no wildcards.
    if(wcChar != null)
    {
		if((fldComp == "LIKE") && (fldVal.IndexOf(wcChar) == -1))
		{
			fldVal = "'" + wcChar + fldVal.substr(1,fldVal.length-2) + wcChar + "'";
		}
    }

    
    oOption.text = oOption.value = (fldName + " " + fldComp + " " + fldVal);
    
    //*** Add option to 'Where' list.
    oList.options.add(oOption);
  }
}


function checkWhereClause()
{
  var whereClause = optionToCSV("WhereList", ") AND (");
  
  //*** Add closing "tags"?
  if (whereClause != "") whereClause = ("(" + whereClause + ")");
  
  //*** Put list into (hidden) form element.
  setElementAttrib("WhereClause", "value", whereClause);
  
  return true;
}


function removeWhereClause()
{
  var oList = getElement("WhereList");
  
  if (oList && oList.selectedIndex > -1)
  {
    //*** Remove selected option from 'Where' list.
    oList.remove(oList.selectedIndex);
  }
}



//******************************************************************************
//*** Misc. functions
//******************************************************************************
function getDistinctValues(tablename, fieldname, maxresults, targetName)
{
  var oTarget = getElement(targetName);
  
  if (oTarget)
  {
    var oldCursor = oTarget.style.cursor;
    
    //*** Disable destination control (SELECT) during fetch procedure.
    oTarget.style.cursor = "wait";
    oTarget.disabled     = true;
    
    //*** Clear options.
    oTarget.options.length = 0;
    
    var xmlhttp = new XMLHttpRequest();
    var request = "../include/opt_distinct.asp?table=" + tablename + "&field=" + fieldname + "&max=" + maxresults;

    //*** Request URL.
    xmlhttp.open("GET", request, false);
    
    xmlhttp.send(null);

	var list = xmlhttp.responseText.split("\r\n");
    
    for(var i = 0; i < list.length; i++)
    {
      //*** Do not add empty values to option list.
      if (list[i] != "") oTarget.options[i] = new Option(list[i], list[i]);
    }
    
    oTarget.disabled     = false;
    oTarget.style.cursor = oldCursor;
  }
}


function optionToCSV(selectName, delimeter)
{
  var oSelect = getElement(selectName);
  var csvList = "";
  
  if (oSelect)
  {
    //var lst = oSelect.options;
    
    for (var i = 0; i < oSelect.options.length; i++)
    {
      //*** Add option (value) to CSV list.
      if (csvList != "") csvList += delimeter;
      
      csvList += oSelect.options[i].value;
    }
  }
  
  return csvList;
}


function sqlEnc(str)
{
  //*** SQL Encode string.
  var result = "";
  if((str.charAt(0) == "'") && (str.charAt(str.length - 1) == "'"))
  {
	result = "'" + str.substr(1,str.length-2).replace("'", "''") + "'";
  }
  else
  {
	result = "'" + str.replace("'", "''") + "'";
  }
  return result;
}


//******************************************************************************
//*** Events
//******************************************************************************
function addGrouping()
{
  var oList = getElement("GroupList");
  
  if (oList)
  {
    var oOption = document.createElement("OPTION");
    var fldName = getElementAttrib("GroupingField", "value");
    var grpType = getElementAttrib("GroupingType",  "value");
    var display = getElementAttrib("FieldAs",  "value");
    
    if(display == "")
	{
		alert("'Weergeven als' is een verplicht veld!");
	}
	else
	{
		oOption.text = oOption.value = (grpType + "(" + fldName + ")" + " AS " + display);
		oList.options.add(oOption);
	}
    
    //*** TODO: Check with Sarissa if this will give a valid query...
  }
}


function selectGroupingField(elem)
{
  var oSelect = getElement("GroupingType");
  var oAction = getElementAttrib("FieldAction","value");
  var fieldProps = oAction.split(';')
  var fldType = fieldProps[0];
  var fldName = fieldProps[1];
   
  if (oSelect == null)
  {
    alert("Combobox 'GroupingType' niet gevonden!");
    
    return false;
  }
  
  //*** Set list of available options.
  if (fldType == adNumeric)
  {
    //*** Numeric field totals.
    var optList = new Array("AVG", "COUNT", "SUM");
  }
  else if (fldType == adVarChar)
  {
  	//*** VarChar/String field totals.
    var optList = new Array("COUNT");
  }
  else
  {
    //*** No supported type.
    var optList = new Array("");
  }
  
  //*** Clear options.
  oSelect.options.length = 0;
  
  for(var i = 0; i < optList.length; i++)
  {
    oSelect.options[i] = new Option(optList[i], optList[i]);
    
    //alert(oSelect.options[i]);
  }
  
  //*** Select first option.
  oSelect.selectedIndex = 0;
  
  //*** Set grouping field.
  setElementAttrib("GroupingField", "value", fldName);
}