//******************************************************************************
//***                                                                        ***
//*** File       : common.js                                                 ***
//*** Author     : Edwin Poldervaart                                         ***
//*** Date       : 14-07-2006                                                ***
//*** Copyright  : (C) 2004 HawarIT BV                                       ***
//*** Email      : info@hawarIT.com                                          ***
//***                                                                        ***
//*** Description: Common Functionality                                      ***
//***                                                                        ***
//******************************************************************************

//********************************************************************************
//*** Local defines
//********************************************************************************
var numRange  = "0123456789";
var charRange = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
var signRange = "_";



//********************************************************************************
//*** Element functions
//********************************************************************************
function getElement(key)
{
  //*** First check if specified key is element id.
  var elem = document.getElementById(key);
  
  if (!elem)
  {
    //*** Now check if specified key is element name.
    elem = document.getElementsByName(key);
    
    //*** Element array found, set element to first one.
    if (elem.length > 0) elem = elem[0];
  }
  
  if (!elem)
  {
    //*** Element not found, raise error message.
      alert("Could not find element '" + key + "'");
    
    return false;
  }
  
  return elem;
}

function getRadioValue(key)
{
	var elem = document.getElementsByName(key);
	var check = false;
	var passed = false;
  
	//*** Element not found.
	if (!elem)
	{
	    alert("no key: " + key + " found!");
		return false;
	}
	else 
	{
		for(var i = 0; i < elem.length;i++)
		{
			if(elem[i].checked)
			{
				passed = true;
				check = true;
				return elem[i].value;
			}
		}
	}
	
	if(!check && !passed)
	{
	    alert("unexpected error");
		return false;
	}
	else if(!check && passed)
	{
	    alert("no selection is made");
		return false;
	}
}


function getElementAttrib(key, attrib)
{
  var elem = getElement(key);
  
  //*** Element not found.
  if (!elem) return false;
  
  //*** Return value of specified attribute.
  return elem[attrib];
}


function setElementAttrib(key, attrib, value)
{
  var elem = getElement(key);
  
  //*** Element not found.
  if (!elem) return false;
  
  //*** Set value of specified attribute.
  elem[attrib] = value;
}


function setElementDisplay(key, value)
{
  var elem = getElement(key);
  
  //*** Element not found.
  if (!elem) return false;
  
  //*** Set value of display (eg. none, block, inline).
  elem.style.display = value;
}


//********************************************************************************
//*** String functions
//********************************************************************************


function itemExists(tableName, whereClause, pkFields)
{ 

    var url = "./itemcheck.asp?tablename=" + tableName + "&whereClause=" + whereClause + "&pkFields=" + pkFields + "&Flag=itemExist";    
    var httpResult = httpRequest(url);    
    if(httpResult=="Exists")
    return true
    else
    return false;  
}

function valueExists(tableName, whereClause)
{ 
    var url = "./itemcheck.asp?tablename=" + tableName + "&whereClause=" + whereClause + "&Flag=valueExist";    
    var httpResult = httpRequest(url);       
    if(httpResult=="Exists")
    return true
    else
    return false;  
}



//*** Compares two dates and returns 
//*** true if first one is bigger
//*** otherwise false
function CompareDate(date1, date2)
{
   var std_format = date1.split("-");     
   s_dt= new Date(std_format[1]+"-"+std_format[0]+"-"+std_format[2]);
   var etd_format = date2.split("-");     
   e_dt= new Date(etd_format[1]+"-"+etd_format[0]+"-"+etd_format[2]);
   if(s_dt>e_dt)
   return true;
   else 
   return false;
}


function IsValidDate(date)
{
    dateParts = date.split('-');
    if(dateParts.length==3 && 
        !isNaN(parseInt(dateParts[0]))&&
        dateParts[0] != 0 && 
        dateParts[0] <= 31 && 
        !isNaN(parseInt(dateParts[1]))&&
        dateParts[1] != 0 && 
        dateParts[1] <=12 && 
        !isNaN(parseInt(dateParts[2]))&&
        dateParts[2] != 0 &&
        dateParts[2]>999 &&
        dateParts[2]<10000)
        return true;
        else
        return false;
    
}
 

//********************************************************************************
//*** Keyboard Functions
//********************************************************************************
function getASCIIKey(e)
{
  //*** IE or other event?
  //return (window.event) ? window.event.keyCode : e.which;
  return (navigator.appName.indexOf("Microsoft") != -1) ? e.keyCode : e.which;
}


function getCharKey(e)
{
  //*** Return char.
  return String.fromCharCode(getASCIIKey(e));
}


function isAlpha(e)
{  
  var key = getCharKey(e);  
  return isValid(key, numRange + charRange);
}

function isValidField(e)
{
  var key = getCharKey(e);  
  return isValid(key, numRange + charRange + signRange);
}

function isValidRef(e)
{
  var key = getCharKey(e);  
  return isValid(key, numRange + charRange + " '-,_.;{}()?|+*&%#@$%");
}

function isValidWhere(e)
{
  var key = getCharKey(e);  
  return isValid(key, numRange + charRange + " '-,_.<>;?+*&%#@$%\"");
}

function isValidDesc(e)
{
  var key = getCharKey(e);  
  return isValid(key, numRange + charRange + " <>-,_.;{}?()|+*&%#@$%");
}

function isFloat(e, item)
{ 
  var language = document.getElementsByName("language")[0].value;        
  var decPointChar = '.';
  if(language.indexOf("NL")>-1)
  {
     decPointChar = ',';
  }
  var key = getCharKey(e);  
  var dotstat = key=='.'?(item.value.indexOf(".", 0) < 1?true:false):true;  
  var negstat = key=='-'?(item.value.length == 0?true:false):true;
  return isValid(key, numRange + decPointChar + "-" + numRange) && dotstat && negstat   ;
}

function isNum(e)
{
  var key = getCharKey(e);
  
  return isValid(key, numRange);
}

function isBool(e)
{
  var key = getCharKey(e);  
  return isValid(key, "01");
}

function IsInteger(control)
{      
    if(!isNum(event)) return false;
    var number = parseInt(control.value+getCharKey(event));        
    if(number>32767)return false;
    return isNum(event);      
}

function isFirstBlank(e,item)
{     
  var key = getCharKey(e);  
  if(isValid(key, ' ') && item.value.length <1)
  return false;
  else      
  return true;  
}

function isValid(key, range)
{
  if ((key == "") || (range.indexOf(key, 0) >= 0))
    //*** Key found!
    return true;
  else
    return false;
}

function replaceAll(mainstr, find, replace_)
{
      while(mainstr.indexOf(find)>-1)
      {
        mainstr = mainstr.replace(find,"$$");
      }
      
      while(mainstr.indexOf("$$")>-1)
      {
        mainstr = mainstr.replace("$$",replace_);
      }      
      return mainstr;
}


//******************************************************************************
//*** Misc. Functions
//******************************************************************************
function noCacheURL(url)
{
	//*** Add 'nocache' argument to URL.
  return (url + ((url.indexOf("?") > 0) ? "&" : "?") + "nocache=" + new Date().getTime());
}

function getIEVersion()
{
    return parseInt(navigator.appVersion.split("MSIE")[1]);
}

var getPick = false;
function CheckCloseEvent(fromObrowser)
{    
    if(event.clientY<0){ 
        CloseWindow();      
    }
}   

var windowClosed = false;
function CloseWindow()
{       
    if(!windowClosed)
    {
       windowClosed = true;  
       try
       {      
          window.opener.focus();               
          self.close();
       }catch(e){}
    }    
}

function MinimizeWindow()
{
    window.opener.focus();   
    minimizable = true;            
}


/*    
    (longitude recognized when direction ==X)
    If the coordinate is  longitude 
    a negative means "West(W)"; positive is "East(E)". 
    
    (latitude recognized when direction ==Y)
    If the coordinate is latitude 
     a negative means "South(S)"; positive is "North(N)".
*/

function ConvertDDToDMS(DD,direction)
    {
       var DMSDirection=null;
        if(direction=="X")
        {
            if(DD.indexOf("-")==0)
            {
             
                DMSDirection="W";
                DD=DD.substring(1,DD.length);               
            }
            else
            {
                DMSDirection="E";               
            }
         }
         else
         {
            if(DD.indexOf("-")==0)
            {
                DMSDirection="S";
                DD=DD.substring(1,DD.length);               
            }
            else
            {
                DMSDirection="N";               
            }         
        }
         
        var D=intpart(DD);
        var temp=""+(DD-D)*60;       
        var M=intpart(temp);
        var S= ((DD-D)-(M/60))*3600;
        var temps=S+"";
        return D+"º "+M+"' "+makeFormatedDecimal(temps)+"'' "+DMSDirection;                
        //return D+"-"+M+"-"+makeFormatedDecimal(temps)+" "+DMSDirection;                
        
    }
    
    
    function GetSplittableDMS(DD,direction)
    {
       var DMSDirection=null;
        if(direction=="X")
        {
            if(DD.indexOf("-")==0)
            {
             
                DMSDirection="W";
                DD=DD.substring(1,DD.length);               
            }
            else
            {
                DMSDirection="E";               
            }
         }
         else
         {
            if(DD.indexOf("-")==0)
            {
                DMSDirection="S";
                DD=DD.substring(1,DD.length);               
            }
            else
            {
                DMSDirection="N";               
            }         
        }
         
        var D=intpart(DD);
        var temp=""+(DD-D)*60;       
        var M=intpart(temp);
        var S= ((DD-D)-(M/60))*3600;
        var temps=S+"";
        //return D+"º "+M+"' "+makeFormatedDecimal(temps)+"'' "+DMSDirection;                
        return (D+"-"+M+"-"+makeFormatedDecimal(temps)+"-"+DMSDirection).toString().split('-');                
        
    }
    
    function convertDMSToDD(D,M,S,Direction)
    {
        var retCode="";
        if(Direction=="W"||Direction=="S")
        {
            retCode+="-";
        }
        DD=D+(M/60)+S/3600;
        retCode+=DD;        
        return retCode; 
    }
    
    
    function intpart(decm)
    {
       
        var dotpos=decm.indexOf(".");
        var intvalue=decm.substring(0,dotpos);
        return intvalue*1;    
    }
    
    function makeFormatedDecimal(nonFormatValue)
    {
       return parseFloat(nonFormatValue).toFixed(2);               
    }
        
    String.prototype.startsWith = function(str) 
    {        
       try
       {             
          //return (this.match(str+"*")==str)
          if(this.indexOf(str)==0)
          return true;
          else 
          return false;
       }catch(e)
       {
          return false;
       }
    } 
    
    

    


  
      