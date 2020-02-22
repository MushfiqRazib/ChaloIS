//******************************************************************************
//***                                                                        ***
//*** File       : datagrid.js                                               ***
//*** Author     : Edwin Poldervaart                                         ***
//*** Date       : 14-07-2006                                                ***
//*** Copyright  : (C) 2004 HawarIT BV                                       ***
//*** Email      : info@hawarIT.com                                          ***
//***                                                                        ***
//*** Description: Datagrid Functionality                                    ***
//***                                                                        ***
//******************************************************************************

//******************************************************************************
//*** Color Constants                                                       ***
//******************************************************************************
var CLR_HIGHLIGHT     = "#555555";
var CLR_HIGHLIGHTTEXT = "#FFFFFF";
var CLR_WINDOW        = "#E6E6E6";
var CLR_WINDOWTEXT    = "#000000";


//******************************************************************************
//*** Grid Variables
//******************************************************************************
var m_ActiveGrid = null;
var m_GridArray  = new Array();


//******************************************************************************
//*** Grid Images
//******************************************************************************
var m_GridImage = new Array();

m_GridImage["+"]     = new Image();
m_GridImage["+"].src = "./image/expand.gif";
m_GridImage["-"]     = new Image();
m_GridImage["-"].src = "./image/collapse.gif";


//******************************************************************************
//*** Grid Functions
//******************************************************************************
function Grid()
{
	//*** Add grid members.
	this.AllowExpand = false;
	this.BOF         = 0;
	this.ChildURL    = "";
	this.Container   = "";
	this.Element     = null;
	this.EOF         = 0;
	this.ExpandOn    = "";
	this.Group       = "";
	this.Id          = "";
	this.RowCount    = 0;
	this.RowExpanded = 0;
	this.RowIndex    = 0;
	this.URL         = "";
}


function grid_add(id, containerId)
{
  //*** Try to get grid element (table).
  var oGrid = getElement(id);
  
	if (oGrid)
	{
	  //*** Split grid summary into paramaters.
	  var params = oGrid.summary.split(";");
	  
	  //*** Add instance of Grid to array.
	  m_GridArray[id] = new Grid();
	  
	  //*** Set grid members.
	  m_GridArray[id].AllowExpand = ((params[4] == "1") || (params[4].toUpperCase() == "TRUE"));
	  m_GridArray[id].BOF         = parseInt(params[0]);
	  m_GridArray[id].ChildURL    = params[9];
	  m_GridArray[id].Container   = containerId;
	  m_GridArray[id].Element     = oGrid;
	  m_GridArray[id].EOF         = parseInt(params[1]);
	  m_GridArray[id].Group       = params[5];
	  m_GridArray[id].Id          = id;
	  m_GridArray[id].OrderBy     = params[6];
	  m_GridArray[id].OrderDir    = params[7];
	  m_GridArray[id].RowIndex    = parseInt(params[2]);
	  m_GridArray[id].RowCount    = parseInt(params[3]);
	  m_GridArray[id].URL         = params[8];
	  
	  //*** Select row.
	  if (m_GridArray[id].RowIndex > 0) row_select(m_GridArray[id].Id, m_GridArray[id].RowIndex);
  }
}


function grid_childToggle(gridId, rowNumber)
{
	//*** Select row.
	row_select(gridId, rowNumber);
	
	if (m_ActiveGrid.RowExpanded == m_ActiveGrid.RowIndex)
	{
	  //*** Row is expanded, so collapse.
	  grid_collapse();
  }
  else
  {
  	//*** Row is collapsed, so expand.
    grid_expand();
  }
	
	return false;
}


function grid_clear(containerId)
{
  //*** Get container for grid.
  var container = getElement(containerId);
  
  //*** Clear container which contains grid.
  if (container) container.innerHTML = "";
}


function grid_collapse()
{
	//*** No grid or expanded row; return immediately!
  if (!m_ActiveGrid || (m_ActiveGrid.RowExpanded == 0)) return false;
  
  setImage(m_ActiveGrid.RowExpanded, "+");
  
  //*** Clear specified row.
  grid_clear("Container_CGrid" + m_ActiveGrid.RowExpanded);
  
  m_ActiveGrid.RowExpanded = 0;
}


function grid_expand()
{
  //*** No grid or row already expanded; return immediately!
  if (!m_ActiveGrid || !m_ActiveGrid.AllowExpand || (m_ActiveGrid.RowExpanded == m_ActiveGrid.RowIndex)) return false;
  
  //*** First collapse current expanded row.
  grid_collapse();
  
  //*** Change image.
  setImage(m_ActiveGrid.RowIndex, "-");
  
  //*** Load grid.
  grid_load("Container_CGrid" + m_ActiveGrid.RowIndex, m_ActiveGrid.ChildURL, "CGrid", m_ActiveGrid.ExpandOn, "", "", 1)
  
  //*** Remind this row as expanded.
  m_ActiveGrid.RowExpanded = m_ActiveGrid.RowIndex;
}


function grid_load(containerId, gridURL, gridId, group, orderBy, orderDir, rowNumber)
{
  //*** Return immediately if no URL.
  if (gridURL == "") return;
  
  //*** Get container for grid.
  var container = getElement(containerId);
  
  if (container)
  {
  	//*** Show "Loading..." page.
    container.innerHTML = getWaitPage("#000000");
    
    var xmlhttp = new XMLHttpRequest();
    var request = noCacheURL(gridURL + "?Id=" + gridId + "&Row=" + rowNumber + "&Group=" + group + "&OrderBy=" + orderBy + "&OrderDir=" + orderDir);
    
    //*** Set request URL.
    xmlhttp.open("GET", request, true);
    
    //*** Set handler.
    xmlhttp.onreadystatechange = function()
    {
      if (xmlhttp.readyState == 4)
      {
      	//*** Put grid into container.
        container.innerHTML = xmlhttp.responseText;
        
        //*** Add grid info to array.
        grid_add(gridId, containerId);
      }
    }
    
    //*** Send request.
    xmlhttp.send(null);
    
    //*** Reset current active grid.
	  if (m_ActiveGrid && m_ActiveGrid.Id == gridId) m_ActiveGrid = null;
  }
}


function grid_orderBy(gridId, orderKey)
{
  //*** Try to set selected grid active.
  if (grid_setActive(gridId) == true)
  {
    if (m_ActiveGrid.OrderBy == orderKey)
    {
      //*** Same order key, so toggle direction (ASC/DESC).
      m_ActiveGrid.OrderDir = (m_ActiveGrid.OrderDir == "ASC") ? "DESC" : "ASC";
    }
    else
    {
      //*** Different order key, set direction to ASC.
      m_ActiveGrid.OrderBy  = orderKey;
      m_ActiveGrid.OrderDir = "ASC";
    }
    
    //*** Goto first page/record of active grid.
    page_goto(1);
  }
}


function grid_setActive(gridId)
{
  var oGrid = m_GridArray[gridId];
  
  if (oGrid)
  {
    //*** Grid found and has rows, so activate.
    m_ActiveGrid = oGrid;
    
    //*** Return succes.
    return true;
  }
  else
  {
  	alert("Geen grid info gevonden!");
  }
  
  //*** Return failure.
  return false;
}


//******************************************************************************
//*** Page Functions
//******************************************************************************
function page_goto(rowNumber)
{
	//*** Do nothing if row number out of range.
	if ((rowNumber < 1) || (rowNumber > m_ActiveGrid.RowCount)) return false;
	
	//*** Replace current active grid.
	grid_load(m_ActiveGrid.Container, m_ActiveGrid.URL, m_ActiveGrid.Id, m_ActiveGrid.Group, m_ActiveGrid.OrderBy, m_ActiveGrid.OrderDir, rowNumber);
}


function page_first()
{
  //*** No grid, return immediately!
  if (!m_ActiveGrid) return false;
  
  //*** Go to first page (if not already there).
  if (m_ActiveGrid.BOF > 1) page_goto(1);
}


function page_last()
{
  //*** No grid, return immediately!
  if (!m_ActiveGrid) return false;
  
  //*** Go to last page (if not already there).
  if (m_ActiveGrid.EOF < m_ActiveGrid.RowCount) page_goto(m_ActiveGrid.RowCount);
}


function page_next()
{
  //*** No grid, return immediately!
  if (!m_ActiveGrid) return false;
  
  //*** Go to next page (if current is not last one).
  if (m_ActiveGrid.EOF < m_ActiveGrid.RowCount) page_goto(m_ActiveGrid.EOF + 1);
}


function page_previous()
{
  //*** No grid, return immediately!
  if (!m_ActiveGrid) return false;
  
  //*** Go to previous page (if current is not first one).
  if (m_ActiveGrid.BOF > 1) page_goto(m_ActiveGrid.BOF - 1);
}


//******************************************************************************
//*** Row Functions
//******************************************************************************
function row_deselect()
{
  //*** Something selected?
  if (m_ActiveGrid && m_ActiveGrid.Element && (m_ActiveGrid.RowIndex > 0))
  {
  	var oRow = getElement(m_ActiveGrid.Id + "_Row" + m_ActiveGrid.RowIndex);
  	
    //*** Change row color.
    row_status(oRow, CLR_WINDOW, CLR_WINDOWTEXT);
  }
}


function row_getExpandValue()
{
	var oRow = getElement(m_ActiveGrid.Id + "_Expansion" + m_ActiveGrid.RowIndex);
	alert(oRow.chOff);
	//*** Row object found, so get value to expand on.
	return (oRow) ? oRow.ch : "";
}


function row_next()
{
  //*** No grid, return immediately!
  if (!m_ActiveGrid) return false;
  
  //*** Number within range?
  if (m_ActiveGrid.RowIndex < m_ActiveGrid.EOF)
  {
    //*** Goto next row.
    row_select(m_ActiveGrid.Id, m_ActiveGrid.RowIndex + 1);
	}
  else
  {
    //*** Last row, so go to next page.
    page_next();
  }
}


function row_previous()
{
  //*** No grid, return immediately!
  if (!m_ActiveGrid) return false;
  
  //*** Index within range?
  if (m_ActiveGrid.RowIndex > m_ActiveGrid.BOF)
  {
    //*** Goto previous row.
    row_select(m_ActiveGrid.Id, m_ActiveGrid.RowIndex - 1);
  }
  else
  {
    //*** First row, so go to previous page.
    page_previous();
  }
}


function row_select(gridId, rowNumber)
{
  //*** Do nothing if row already selected.
	if (m_ActiveGrid && (gridId == m_ActiveGrid.Id) && (rowNumber == m_ActiveGrid.RowIndex)) return;
	
  //*** First deselect previous row (if exist).
  row_deselect();
  
  if (grid_setActive(gridId) == true)
  {
    //*** Grid found, now get specified row.
    var oRow = getElement(gridId + "_Row" + rowNumber);
    var oDiv = getElement(m_ActiveGrid.Container);
    
    //*** Change row color.
    row_status(oRow, CLR_HIGHLIGHT, CLR_HIGHLIGHTTEXT);
    
    if (oRow.offsetTop < oDiv.scrollTop)
    {
      //*** Scroll up.
      oDiv.scrollTop = oRow.offsetTop - 19;
    }
    else if ((oRow.offsetTop + oRow.offsetHeight) > (oDiv.scrollTop + oDiv.offsetHeight))
    {
    	//*** Scroll down.
      oDiv.scrollTop = (oRow.offsetTop + oRow.offsetHeight - oDiv.offsetHeight);
    }
    
    //*** Remind current selected row.
    m_ActiveGrid.RowIndex = rowNumber;
    
    //*** Extract extra info from row.
    m_ActiveGrid.ExpandOn = getCellContent(oRow.cells[1], "GROUP");
    g_DocumentURL         = getCellContent(oRow.cells[1], "DOCUMENT");
    g_DetailURL           = getCellContent(oRow.cells[2], "DETAIL");
    
    //*** Display record status.
    setElementAttrib("RecordNumber", "value", m_ActiveGrid.RowIndex);
    setElementAttrib("RecordCount", "innerHTML", "van " + m_ActiveGrid.RowCount);
    
    //*** Update content of visible tab.
    tab_update();
  }
}


function row_setByNumber(rowNumber)
{
  //*** No grid, return immediately!
  if (!m_ActiveGrid) return false;
  
  if ((rowNumber >= m_ActiveGrid.BOF) && (rowNumber <= m_ActiveGrid.EOF))
  {
    //*** Specified row number lies on current page, so select.
    row_select(m_ActiveGrid.Id, rowNumber);
  }
  else if ((rowNumber >= 1) && (rowNumber <= m_ActiveGrid.RowCount))
  {
    //*** Get page which contains specified row number.
    page_goto(rowNumber);
  }
  else
  {
    alert("Geef een rijnummer tussen 1 en " + m_ActiveGrid.RowCount + ".");
  }
}


function row_setDisplay(rowNumber, displayStatus)
{
	var oRow = getElement(m_ActiveGrid.Id + "_Expansion" + rowNumber);
	
	//*** Row object found, so change display status.
	if (oRow)
	{
		//oRow.style.display = displayStatus;
		
		return oRow.ch;
	}
	
	return "";
}


function row_status(oRow, backgroundColor, color)
{
  //*** Object exist?
  if (!oRow) return;
  
  //*** Set object properties.
  oRow.style.backgroundColor = backgroundColor;
  oRow.style.color           = color;
}


//******************************************************************************
//*** Misc Functions
//******************************************************************************
function getCellContent(oCell, id)
{
  if (oCell.id.toUpperCase() == id.toUpperCase() && oCell.firstChild)
  {
    //*** Correct id and cell has content.
    return oCell.firstChild.nodeValue;
	}
  
	return "";
}


function setImage(rowNumber, imgType)
{
  var oImg = getElement(m_ActiveGrid.Id + "_Img" + rowNumber);
  
  //*** Change image.
  if (oImg) oImg.src = m_GridImage[imgType].src;
}


//******************************************************************************
//*** Event Handlers
//******************************************************************************
function checkKey(e)
{
	var key = getASCIIKey(e);
	
	//*** Act on pressed key.
	switch (key)
  {
    case 37:
      //*** Left arrow.
      grid_collapse();
      break;
    
    case 38:
      //*** Up arrow.
      row_previous();
      break;
    
    case 39:
      //*** Right arrow.
      grid_expand();
      break;
    
    case 40:
      //*** Down arrow.
      row_next();
      break;
    
    default:
      //*** Do nothing!
      return true;
  }
  
  return false;
}