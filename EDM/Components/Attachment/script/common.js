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
var charRange = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
var numRange  = "0123456789";
var signRange = "_"


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
    if(!window.opener.opener.SessionExists())
    {
        window.opener.close();
        window.close();
        return;
    }
    var elem = getElement(key);
    
    //*** Element not found.
    if (!elem) return false;
  
    //*** Set value of specified attribute.
    elem[attrib] = value;
}


//********************************************************************************
//*** String functions
//********************************************************************************
function LTrim(str, trimChar)
{
  //*** Trim specified character from the left.
  while (str.substring(0,1) == trimChar)
  {
    str = str.substring(1, str.length);
  }
  
  return str;
}


function RTrim(str, trimChar)
{
  //*** Trim specified character from the right.
  while (str.substring(str.length - 1, str.length) == trimChar)
  {
    str = str.substring(0, str.length - 1);
  }
  
  return str;
}


function Trim(str, trimChar)
{
  //*** Trim specified character from the left and right.
  str = LTrim(str, trimChar);
  str = RTrim(str, trimChar);
  
  return str;
}


//********************************************************************************
//*** Keyboard Functions
//********************************************************************************
function getASCIIKey(e)
{
  //*** IE or other browser?
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


function isNum(e)
{
  var key = getCharKey(e);
  
  return isValid(key, numRange);
}


function isValid(key, range)
{
  if ((key == "") || (range.indexOf(key, 0) >= 0))
    //*** Key found!
    return true;
  else
    return false;
}


function InArray(arr, value)
{ 

     for(var k=0;k<arr.length;k++)
     {
        if(arr[k].toUpperCase()==value.toUpperCase())
        {
          //*** matched so end loop and return true
          return true;
        }            
     }     
     
     //*** didn't match so return false
     return false;     
}


//*** Sends a http request to the provided url     
function httpRequest(url)
{
  var xmlhttp = new XMLHttpRequest();
  
  //*** Set request URL.
  xmlhttp.open("GET", noCacheURL(url), false);
  
  //*** Send request and wait...
  xmlhttp.send(null);
  
  return xmlhttp.responseText;
}


//*** Used to eliminate caching problem    
function noCacheURL(url)
{
	//*** Add 'nocache' argument to URL.
  return (url + ((url.indexOf("?") > 0) ? "&" : "?") + "nocache=" + new Date().getTime());
}      


//*** Opens a new child by provided uri
function openChild(uri, name, replace, width, height, resizable, scrollbars)
{
  var wnd     = null;
  var wndName = parent.name + "_" + name;
  var idx     = wndChilds.length;
  
  //*** Check if window already exists.
  for(var i = 0; i < idx; i++)
  {
    if (wndChilds[i][0] == wndName)
    {
      wnd = wndChilds[i][1];
      idx = i;
    }
  }
  
  if (!wnd || wnd.closed || replace)
  {
    var top      = (screen.availHeight - height) / 2;
    var left     = (screen.availWidth - width) / 2;
    var features = "toolbar=no,directories=no,status=no,scrollbars=" + scrollbars + ",menubar=no,location=no,resizable=" + resizable + ",width=" + width + ",height=" + height + ",left=" + left + ",Top=" + top;
    
    //*** open new window and/or load new URL.
    wnd = window.open(uri, wndName, features, replace);
  }
  
  //*** Check for popup blocker!
  if(!wnd)
  {
      alert("Please disable your popup blocker!");
  }
  else
  {
    //*** Set focus to dialog.
    wnd.focus();
  } 
  
  
}


//*** Removes leading whitespaces
function LTrim( value ) {
	
	var re = /\s*((\S+\s*)*)/;
	return value.replace(re, "$1");
	
}

//*** Removes ending whitespaces
function RTrim( value ) {
	
	var re = /((\s*\S+)*)\s*/;
	return value.replace(re, "$1");
	
}

//*** Removes leading and ending whitespaces
function trim( value ) {	
	return LTrim(RTrim(value));
	
}

function loadProgressBar(id, msg)
    {
        var page = "";	
	    page += '<table height="100%" width="100%">';
	    page += '  <tr>';
	    page += '    <td align="center" style="color: #000000; padding: 30px">';
	    page += '      <b>'+msg+'...</b><br/><img border="0" src="./basket/images/progressbar.gif">';
	    page += '    </td>';
	    page += '  </tr>';
	    page += '</table>';
	    var div = document.getElementById(id);
	    div.innerHTML = page;
    }
