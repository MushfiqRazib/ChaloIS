//******************************************************************************
//***  File    :   window.js                                                 ***
//***                                                                        ***
//***  Included:                                                             ***
//***                                                                        ***
//***  Function:   Window functions                                          ***
//***                                                                        ***
//***  Revision:   1.00.00                                                   ***
//***                                                                        ***
//******************************************************************************

//*** Indicator for Internet Explorer ***
var gIExplorer = (navigator.appName.indexOf("Microsoft") != -1);

//*** Container for window handlers ***
var wndChilds = new Array();

//*** Indicator for closing viewer ***
var closing = false;


window.clientHeight = function()
{
  if (typeof(window.innerHeight) == 'number')
  {
    //*** Non-IE.
    return window.innerHeight;
  }
  else if(document.documentElement && document.documentElement.clientHeight)
  {
    //*** IE6+ in 'standards compliant mode'.
    return document.documentElement.clientHeight;
  }
  else if(document.body && document.body.clientHeight)
  {
    //*** IE4 compatible.
    return document.body.clientHeight;
  }
  
  //*** Browser not supported!
  alert("Browser not supported!");
  return 0;
};


window.clientWidth = function()
{
  if (typeof(window.innerWidth) == 'number')
  {
    //*** Non-IE.
    return window.innerWidth;
  }
  else if(document.documentElement && document.documentElement.clientWidth)
  {
    //*** IE6+ in 'standards compliant mode'.
    return document.documentElement.clientWidth;
  }
  else if(document.body && document.body.clientWidth)
  {
    //*** IE4 compatible.
    return document.body.clientWidth;
  }
  
  //*** Browser not supported!
  return 0;
};


function closeChilds()
{
  closing = true;
  
  //*** Kill all childs opened by this mechanism.
  for(var i = 0; i < wndChilds.length; i++)
  {
    var w = wndChilds[i][1];
    
    if (w.open && !w.closed) w.close();
  }
}


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
    wnd = window.open(noCacheURL(uri), wndName, features, replace);
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
  
  //*** Add or update to array.
  wndChilds[idx] = Array(wndName, wnd);
}


function toolbox(uri, name, width, height, resizable, scrollbars)
{
	var wndName  = parent.name + "_" + name;
  var top      = (screen.availHeight - height) / 2;
  var left     = (screen.availWidth - width) / 2;
  var features = "toolbar=no,directories=no,status=no,scrollbars=" + scrollbars + ",menubar=no,location=no,resizable=" + resizable + ",width=" + width + ",height=" + height + ",left=" + left + ",Top=" + top;
  
  //*** Open dialog.
  var wnd = window.open(uri, wndName, features);
  
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


//******************************************************************************
//*** Misc. Functions
//******************************************************************************
function httpRequest(url)
{
  var xmlhttp = new XMLHttpRequest();
  
  //*** Set request URL.
  xmlhttp.open("GET", noCacheURL(url), false);
  
  //*** Send request and wait...
  xmlhttp.send(null);
  
  return xmlhttp.responseText;
}


function noCacheURL(url)
{
	//*** Add 'nocache' argument to URL.
  return (url + ((url.indexOf("?") > 0) ? "&" : "?") + "nocache=" + new Date().getTime());
}