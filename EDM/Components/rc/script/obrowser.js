//******************************************************************************
//***                                                                        ***
//*** File       : obrowser.js                                               ***
//*** Author     : Edwin Poldervaart                                         ***
//*** Date       : 14-07-2006                                                ***
//*** Copyright  : (C) 2004 HawarIT BV                                       ***
//*** Email      : info@hawarIT.com                                          ***
//***                                                                        ***
//*** Description: General Functionality                                     ***
//***                                                                        ***
//******************************************************************************

//******************************************************************************
//*** Global Variables
//******************************************************************************
var g_DocumentURL = "";
var g_DetailURL   = "";


//******************************************************************************
//*** TabStrip
//******************************************************************************
var m_ActiveTab  = 0;
var m_TabImage   = new Array();
var m_TabStrip   = new Array();


//******************************************************************************
//*** Local Variables
//******************************************************************************
var m_Busy       = false;
var m_InitViewer = true;


//******************************************************************************
//*** Misc. functions
//******************************************************************************
function getWaitPage(textColor)
{
	var page = "";
	
	page += '<table height="100%" width="100%">';
	page += '  <tr>';
	page += '    <td align="center" style="color: ' + textColor + '; padding: 30px">';
	page += '      <b>Loading...</b><br/><img border="0" src="./image/progressbar.gif">';
	page += '    </td>';
	page += '  </tr>';
	page += '</table>';
	
	return page;
}


function loadDetail(detailURL)
{
  //*** Return immediately if no detail tab.
  if (!m_TabStrip[2]) return;
  
  if (detailURL != "")
  {
  	//*** Show wait page.
    m_TabStrip[2].innerHTML = getWaitPage("#000000");
    
    var xmlhttp = new XMLHttpRequest();
    
    //*** Set request URL.
    xmlhttp.open("GET", noCacheURL(detailURL), true);
    
    //*** Set handler.
    xmlhttp.onreadystatechange = function()
    {
      if (xmlhttp.readyState == 4)
      {
      	//*** Put detail info into container.
        m_TabStrip[2].innerHTML = xmlhttp.responseText;
      }
    }
    
    //*** Send request.
    xmlhttp.send(null);
  }
  else
  {
    //*** Clear tab.
    m_TabStrip[2].innerHTML = "";
  }
}

function replaceAll(mainstr, find, replace_){
  while(mainstr.indexOf(find)>-1){
    mainstr = mainstr.replace(find,replace_);
  }
  return mainstr;
}

function getfilename(url){
  var splitter = url.split("$$$$");  
  var filename = splitter[splitter.length-1];
  return filename;
}


function loadDocument(url)
{  
  //*** Return immediately if no document tab.
  if (!m_TabStrip[3]) return;
   
  if (url != "")
  { 
    url = replaceAll(url,"\\","$$$$");    
    var file = getfilename(url);            
    file = file.split(".");
    file[1] = Trim(file[1],' ');
    
    url = "./loader.asp?docpath="+url+"&name="+file[0]+"&ext="+ file[1]+ "&nocache=" + new Date().getTime(); 
    //*** Load document.
    m_TabStrip[3].innerHTML = '<embed src="' + url + '" href="' + url + '" height="99%" width="100%">' +
                              '  <noembed>Your browser does not support embedded DWF/PDF files.</noembed>' +
                              '</embed>';
    
    
    //*** in Old version    
    //*** Load document.
    //    m_TabStrip[3].innerHTML = '<embed src="' + url + '" href="' + url + '" height="99%" width="100%">' +
    //                              '  <noembed>Your browser does not support embedded PDF files.</noembed>' +
    //                              '</embed>';

  }
  else
  {
  	//*** No document!
    m_TabStrip[3].innerHTML = '<table height="100%" width="100%"><tr><td align="center"><b>Geen document beschikbaar.<b></td></tr></table>';
  }
}


function loadGraphic(url)
{
  var vwr = getElement("DWFViewer");
	
  if (vwr)
  {
    //*** Disable toolbars?
    if (m_InitViewer)
    {
      vwr.Viewer.ToolbarVisible = false;
      vwr.Viewer.PaperVisible   = false;
      m_InitViewer              = false;
    }
    
  	//*** Show graphic.
  	vwr.SourcePath = url;
  }
  else
  {
    //*** Viewer not found?!?.
  	alert("DWF Viewer kan niet gevonden worden.");
  }
}


function loadNavigation(navURL)
{
  //*** Return immediately if no URL.
  if (navURL == "") return;
  
  //*** Get container for grid.
  var container = getElement("NavigationPanel");
  
  if (container)
  {
  	var xmlhttp = new XMLHttpRequest();
    
    //*** Set request URL.
    xmlhttp.open("GET", noCacheURL(navURL), true);
    
    //*** Set handler.
    xmlhttp.onreadystatechange = function()
    {
      if (xmlhttp.readyState == 4)
      {
      	//*** Put panel into container.
        container.innerHTML = xmlhttp.responseText;
      }
    }
    
    //*** Send request.
    xmlhttp.send(null);
  }
}


function refresh(groupBy)
{
  //*** Set 'Group By' value.
  if (groupBy) setElementAttrib("GroupBy", "value", groupBy);
  
  //*** Submit form.
  document.Browser.submit();
}


function showTheme(layerName)
{
  var vwr = window.opener;
  
  if (vwr && !vwr.closed && vwr.addLayer)
  {
    //*** Add layer to viewer.
    vwr.focus();
    vwr.addLayer(layerName);
  }
}


//******************************************************************************
//*** TabStrip Functions
//******************************************************************************
function tab_init()
{
	//*** Fill array with tabs.
	m_TabStrip[1] = getElement("TabPage_Grid");
	m_TabStrip[2] = getElement("TabPage_Detail");
	m_TabStrip[3] = getElement("TabPage_Viewer");
	
  m_TabImage["Tab1On"]      = new Image();
  m_TabImage["Tab1On"].src  = "./image/overzicht_active.png";
  m_TabImage["Tab1Off"]     = new Image();
  m_TabImage["Tab1Off"].src = "./image/overzicht.png";
  m_TabImage["Tab2On"]      = new Image();
  m_TabImage["Tab2On"].src  = "./image/detail_active.png";
	m_TabImage["Tab2Off"]     = new Image();
  m_TabImage["Tab2Off"].src = "./image/detail.png";
	m_TabImage["Tab3On"]      = new Image();
	m_TabImage["Tab3On"].src  = "./image/graphics_active.png";
	m_TabImage["Tab3Off"]     = new Image();
  m_TabImage["Tab3Off"].src = "./image/graphics.png";
  
	//*** Set default tab (1).
	tab_set(1);
}


function tab_set(tabIndex)
{
  for (var i = 1; i <= 3; i++)
  {
  	var tabImg   = getElement("Tab" + i + "Img");
  	var tabImgId = (i == tabIndex) ? ("Tab" + i + "On") : ("Tab" + i + "Off");
  	
  	//*** Image element found?
  	if (tabImg) tabImg.src = m_TabImage[tabImgId].src;
  	
  	if (m_TabStrip[i])
  	{
      //*** Enable/Disable tab.
  		m_TabStrip[i].style.display = (i == tabIndex) ? "block" : "none";
    }
  }
  
  //*** Remind selected tab.
  m_ActiveTab = tabIndex;
  
  //*** Update content of visible tab.
  tab_update();
}


function tab_update()
{
  switch (m_ActiveTab)
  {
    case 1:
      //*** Show overview.
      break;
    
    case 2:
      //*** Show details.
      loadDetail(g_DetailURL);
      break;
    
    case 3:
      //*** Show drawing (if present).
      loadDocument(g_DocumentURL);
      //loadGraphic(g_DocumentURL);
      break;
    
    default:
      //*** Unknown tab!
      alert("Unknown tab!");
  }
}


//******************************************************************************
//*** Event Handlers
//******************************************************************************
function isRownum(e)
{
  if (isValid(getCharKey(e), numRange))
  {
    //*** Numeric key.
    return true;
  }
  else if (getASCIIKey(e) == 13)
  {
  	//*** <ENTER> means "submit".
    row_setByNumber((gIExplorer) ? e.srcElement.value : e.target.value);
  }
  
  return false;
}


function openQueryBuilder()
{
  //*** Open query builder.
  openChild("./qb/qb_select.asp", "QueryBuilder", true, 518, 390, "no", "no");
  
  return false;
}


function openQuickSearch()
{
  //*** Open query builder.
  openChild("./qb/qb_quick.asp", "QuickSearch", true, 374, 134, "no", "no");
  
  return false;
}


function resizeTo(elementKey, newWidth, newHeight)
{
	var oElem = getElement(elementKey);
  
  if (oElem && width >= 0 && height >= 0)
  {
    //*** Set element dimensions.
    oElem.style.width  = newWidth + "px";
    oElem.style.height = newHeight + "px";
  }
}


function resizeElement(elementId, width, height)
{
  var oElem = getElement(elementId);
  
  if (oElem && width >= 0 && height >= 0)
  {
    //*** Get window dimensions.
    oElem.style.width  = width + "px";
    oElem.style.height = height + "px";
  }
}


function resizeElements()
{
  //*** Leave if busy.
  if (m_Busy) return false;
  
  //*** Busy!
  m_Busy = true;
  
  //*** Get window dimensions.
  var w = window.clientWidth();
  var h = window.clientHeight();
  
  resizeElement("TabPage_Grid",   w, h - 64);
	resizeElement("TabPage_Detail", w, h - 64);
	//resizeElement("TabPage_Viewer", winW, winH - 64);
	
	//*** Finished!
	m_Busy = false;
}