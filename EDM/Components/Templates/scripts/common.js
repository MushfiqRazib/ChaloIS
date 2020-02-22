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