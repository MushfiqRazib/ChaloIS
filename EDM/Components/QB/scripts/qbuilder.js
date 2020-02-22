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


String.prototype.insertSpacesBothSideOfOparator = function()
{
    var retString;
    if( this.search(/ like /i) > 0)
    {
        return this;
    }
    else
    {
        retString = this.replace(' ','');
        retString = retString.replace('=',' = ').replace('<>',' <> ').replace('<',' < ').replace('>',' > ').replace('<=',' <= ').replace('>',' >= ');
        return retString;
    }
}


//******************************************************************************
//*** List functions
//******************************************************************************
function optionToCSV(selectName, delimeter)
{
  var oSelect = getElement(selectName);
  var csvList = "";
  
  if (oSelect)
  {
    for (var i = 0; i < oSelect.options.length; i++)
    {
      //*** Add option (value) to CSV list.
      if (csvList != "") csvList += delimeter;
      
      csvList += oSelect.options[i].value;
    }
  }  
  return csvList;
}



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
        
    //*** convert to html encode
    fldVal = replaceAll(fldVal,"<","&lt");
    fldVal = replaceAll(fldVal,">","&gt");
    
    if(fldVal=='')
    return;
    
    //*** TODO: Check with Sarissa if this will give a valid query...

    //*** Add quotes in case of string.
    if (fldType == adVarChar || fldVal.indexOf('/')>-1) 
    {     
		fldVal = sqlEnc(fldVal);
	}else
    {
        fldVal = replaceAll(fldVal,",",".");       
        if(isNaN(fldVal))
        {
            alert("Invalid Number");        
            return;
        }
    }  
                   
	if(fldComp == "LIKE" )
	{
	    fldVal = "'" + fldVal.substr(1,fldVal.length-2) + "'";
	}    
    
    oOption.text = (fldName + " " + fldComp + " " + fldVal);
    oOption.value = (fldName + " " + fldComp + " " + fldVal);
    
    //*** Add option to 'Where' list.
    oList.options.add(oOption);
  }
}


function getCulture()
{
    var culture = window.opener.document.getElementById("culture").value;
    return culture;
}


function checkWhereClause()
{
  var whereClause = optionToCSV("WhereList", ") AND (");
  
  //*** Add closing "tags"?
  if (whereClause != "") whereClause = ("(" + whereClause + ")");
       
  //*** Put list into (hidden) form element.
  setElementAttrib("WhereClause", "value", whereClause);
  //alert(whereClause);
   
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
//*** Field Selection functions
//******************************************************************************
function checkSelectClause()
{
  var fieldList = optionToCSV("Fields_V", ",");
  
  //*** Put list into (hidden) form element.
  setElementAttrib("SelectClause", "value", fieldList);
  
  return true;
}


function optionMove(source, destination)
{
  var oSrc  = getElement(source);
  var oDest = getElement(destination);
  
  if (oSrc && oDest)
  {
    if (oSrc.selectedIndex >= 0)
    {
      var oOption = document.createElement("OPTION");
      
      oOption.text = oOption.value = oSrc.options[oSrc.selectedIndex].value;
      
      //*** Remove option from source list.
      oSrc.remove(oSrc.selectedIndex);
      
      //*** Add option to destination list.
      oDest.options.add(oOption);
    }
    else
    {
        alert(getElementAttrib("movemsg", "value"));
    }
  }
}


function optionMoveAll(source, destination)
{
  var oSrc  = getElement(source);
  var oDest = getElement(destination);
  
  if (oSrc && oDest)
  {
    while (oSrc.options.length >= 0)
    {
      var oOption = document.createElement("OPTION");
      
      oOption.text  = oSrc.options[0].text;
      oOption.value = oSrc.options[0].value;
      
      //*** Remove option from source list.
      oSrc.remove(0);
      
      //*** Add option to destination list.
      oDest.options.add(oOption);
    }
  }
}


function optionSwap(list, direction)
{
  var oList = getElement(list);
  
  //*** Element (SELECT control) found and option selected?
  if (oList && oList.selectedIndex > -1)
  {
    var oldIndex = oList.selectedIndex;
    var newIndex = oldIndex + direction;
    
    //*** New index within index range?
    if ((newIndex > -1) && (newIndex < oList.options.length))
    {
      var oldText  = oList.options[newIndex].text;
      var oldValue = oList.options[newIndex].value;
      
      oList.options[newIndex].text  = oList.options[oldIndex].text;
      oList.options[newIndex].value = oList.options[oldIndex].value;
      
      oList.options[oldIndex].text  = oldText;
      oList.options[oldIndex].value = oldValue;
      
      //*** Keep current option selected.
      oList.selectedIndex = newIndex;
    }
  }
}



//******************************************************************************
//*** Grouping functions
//******************************************************************************
function checkGBSelectClause()
{
  var clause = optionToCSV("GroupList", ",");
  
  //*** Put list into (hidden) form element.
  setElementAttrib("GBSelectClause", "value", clause);
  
  return true;
}


function removeGrouping()
{
  var oList = getElement("GroupList");
  
  if (oList && oList.selectedIndex > -1)
  {
    //*** Remove selected option from 'Where' list.
    oList.remove(oList.selectedIndex);
  }
}



//******************************************************************************
//*** Misc. functions
//******************************************************************************
function checkGBSqlCustom()
{
	//*** Put list into (hidden) form element.
	setElementAttrib("SqlCustom", "value", getElementAttrib("sql_custom","value"));
	return true;
}

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
    var request = noCacheURL("includes/opt_distinct.asp?table=" + tablename + "&field=" + fieldname + "&max=" + maxresults);
    
    //*** Request URL.
    xmlhttp.open("GET", request, false);
    
    xmlhttp.send(null);

    var list = xmlhttp.responseText.split("\r\n");
    //debugger
    oTarget.options[0] = new Option("", "");
    for(var i = 0; i < list.length; i++)
    {
      //*** Do not add empty values to option list.
      if (list[i] != "") oTarget.options[i+1] = new Option(list[i], list[i]);
    }
    
    oTarget.disabled     = false;
    oTarget.style.cursor = oldCursor;
  }
}

/*
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
*/

function sqlEnc(str)
{
  //*** SQL Encode string.
  var result = "";
  if((str.charAt(0) == "'") && (str.charAt(str.length - 1) == "'"))
  {
    str = str.substr(1,str.length-2);
    str = EncodeQuote(str);
	result = "'" + str + "'";
  }
  else
  {    
    str = EncodeQuote(str);
	result = "'" + str + "'";
  }
  return result;
}


function EncodeQuote(str)
{
    str = replaceAll(str,"'","&quot");
    str = replaceAll(str,"&quot","''");    
    return str;

}

//******************************************************************************
//*** Events
//******************************************************************************
function addGrouping()
{
  var oList = getElement("GroupList");
  
  if (oList)
  {
    var oOption  = document.createElement("OPTION");
    var fldName  = getElementAttrib("GroupingField", "value");
    var grpType  = getElementAttrib("GroupingType",  "value");
    var grpAlias = getElementAttrib("GroupAs",       "value");
    
    if (grpAlias == "")
    {
      //*** Empty alias not allowed...
      //alert("'Weergeven als' is een verplicht veld!");
       alert(getElementAttrib("emptyvaluemsg", "value"));
    }
    else if (isValid(grpAlias.charAt(0), numRange))
    {
      //*** Alias can not start with numeric character.
      //alert("'Weergeven als' mag niet met een numeriek karakter beginnen!");
        alert(getElementAttrib("numvaluemsg", "value"));
    }
    else
    {
      oOption.text = oOption.value = (grpType + "(" + fldName + ")" + " AS " + grpAlias);
      
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



function ShowElement(id,tableName)
{   
    var oList = getElement("WhereList");  
    var selected = false;
    var selectedText;
    if (oList && oList.selectedIndex > -1)
    {     
        selectedText  = oList.options[oList.selectedIndex].text;     
        if(selectedText.toString().search(/ and /i) < 1 && selectedText.toString().search(/ or /i) < 1)
        {
            selected = true;
        }
    }
    
    if(selected)
    {
         var comList = getElement("edtFieldComp"); 
        var k=0;                    
        
        selectedText = selectedText.insertSpacesBothSideOfOparator();
        var items = selectedText.split(' ');        
        for(k=0;k<comList.options.length;k++)
        {
            if(comList.options[k].text==items[1])
            break;     
        }
        
        document.getElementById("edtFieldName").value = items[0];                
        comList.selectedIndex = k;                
        comList.disabled= "";
        //*** Get a list of distinct values for selected field.
        getDistinctValues(tableName, items[0], 1000, "ValueEditList");
        document.getElementById("edtFieldValue").value = replaceAll(items[2],"'","");        
            
         
         //*** make visible the div  
         var div = document.getElementById(id);
         div.style.visibility = "visible";                
    }
}

function EditWhereClause(id)
{
    var oList = getElement("WhereList");  
    var selectedText;
    selectedText  = oList.options[oList.selectedIndex].text;     
    var oList = getElement("WhereList");
    var comList = getElement("edtFieldComp");
    var name = document.getElementById("edtFieldName").value;
    var comp = comList.options[comList.selectedIndex].text;
    var value = document.getElementById("edtFieldValue").value;     
    value     = replaceAll(value,"'","@");    
    value     = replaceAll(value,"@","''");
    if(!selectedText.startsWith("hitSoundsas"))
    {               
        oList.options[oList.selectedIndex].text = name + " " + comp + " '" + value+"'" ;
        oList.options[oList.selectedIndex].value = name + " " + comp + " '" + value+"'" ;
    }else{
        oList.options[oList.selectedIndex].text = "hitSoundsas(ipoint_description,'"+value + "')>0";
        oList.options[oList.selectedIndex].value = "hitSoundsas(ipoint_description,'"+value + "')>0";        
    }    
    HideElement(id);

}

function HideElement(id)
{           
    var div = document.getElementById(id);    
    div.style.visibility = "hidden";                                           
}

