//******************************************************************************
//***                                                                        ***
//*** File       : custom.js                                                 ***
//*** Author     : Edwin Poldervaart                                         ***
//*** Date       : 27-09-2006                                                ***
//*** Copyright  : (C) 2004 HawarIT BV                                       ***
//*** Email      : info@hawarIT.com                                          ***
//***                                                                        ***
//*** Description: Custom Functionality                                      ***
//***                                                                        ***
//******************************************************************************

//******************************************************************************
//*** Local Variables
//******************************************************************************
var m_Busy = false;


//******************************************************************************
//*** Item Functions
//******************************************************************************
function itemAdd()
{
  //*** Open item upload window.
  /// <reference path="../item.asp" />

  openChild("./Components/rc/item.asp", "Item", true, 420, 216, "no", "no");
  //openChild("./item.asp", "Item", true, 820, 816, "no", "no");
  
  return false;
}
//this is for import
function kabiFileUpload()
{
	//*** Open item upload window.
	openChild("./Components/rc/kabifileupload.asp", "Item", true, 420, 216, "no", "no");
	//openChild("./item.asp", "Item", true, 820, 816, "no", "no");
  
	return false;
}
//this is for import
function importExcel() {
    //*** Open item upload window.
    openChild("./Components/rc/ExcelImport.aspx", "Item", true, 420, 450, "no", "no");
    return false;
}

function kabiItemSubmit()
{
	document.kabiItemForm.submit();
}

function itemCheck(itemId, itemRev)
{
  var httpResult = httpRequest("./template/item_uploadcheck.asp?id=" + itemId + "&rev=" + itemRev);
  var params     = httpResult.split(";");
  
  if (params[0] == "1")
  {
    //*** Article found, so ask for permission to overwrite.
    return window.confirm("Artikel " + itemId + " bestaat al.\nWilt u de huidige revisie (" + params[1] + ") overschrijven?");
  }
  else if (params[0] == "2")
  {
    //*** Article found, so ask for permission to overwrite.
    return window.confirm("Artikelnummer " + itemId + " niet gevonden in Glovia. \nWilt u het bestand toch opnemen in het archief?");
  }  
  else if (httpResult != "")
  {
    //*** Something went wrong, show returned error message.
    alert(httpResult);
  }
  
  //*** Return succes/failure.
  return (httpResult == "");
}


function itemDelete(itemId, itemRev)
{
  if (window.confirm("Weet u zeker dat u artikel " + itemId + " Rev. " + itemRev + " en alle bijbehorende documenten wilt verwijderen?") == false)
  {
    //*** Permission denied, so leave!
    return false;
  }
  
  var httpResult = httpRequest("./template/item_delete.asp?id=" + itemId + "&rev=" + itemRev);
  
  if (httpResult == "")
  {
    //*** Everything went ok, now reload page/grid.
    alert("Artikel " + itemId + " Rev. " + itemRev + " is met succes verwijderd.");
    
    refresh();
  }
  else
  {
  	//*** Something went wrong, show returned error message.
    alert(httpResult);
  }
}


function itemRelease(itemId, itemRev)
{
  var request    = "./template/item_release.asp?id=" + itemId + "&rev=" + itemRev;
  var httpResult = httpRequest(request);
  //debugger;
  if (httpResult.toUpperCase() == "OLD_REVISION")
  {
  	//*** Ask permission to release old revision.
    if (window.confirm("Er zijn nieuwere revisies aanwezig, weet u zeker dat u deze revisie wilt vrijgeven?"))
    {
      //*** Do another request, now with permission to release old revision.
      httpResult = httpRequest(request + "&old=1");
    }
  }
  
  if (httpResult == "")
  {
    //*** Everything went ok, now reload page/grid.
    alert("Artikel " + itemId + " Rev. " + itemRev + " is met succes vrijgegeven.");
    
    refresh();
  }
  else if (httpResult.toUpperCase() != "OLD_REVISION")
  {
    //*** Something went wrong, show returned error message.
    alert(httpResult);
  }
}

function itemSubmit()
{
	//*** Get form data.
	
	var itemCode = getElementAttrib("ItemCode", "value");
	var itemRev  = getElementAttrib("ItemRev", "value");
	var fileName = getElementAttrib("FileName", "value");
	var errMsg   = "";
	
	//*** Now check form data.
	errMsg += (itemCode == "") ? "  - Artikelnummer\n" : "";
	errMsg += (itemRev == "")  ? "  - Revisie\n"       : "";
	errMsg += (fileName == "") ? "  - Bestand\n"       : "";
	
	if (errMsg != "")
	{
    //*** Build final error message.
    errMsg = "De volgende verplichte gegevens ontbreken:\n\n" + errMsg;
    }
    else
    {
    //*** Get file extension.
    var ext = fileName.substr(fileName.lastIndexOf(".") + 1);
    var supTypes = document.getElementById("supportedDocs").value;
    var supportedExt = supTypes.split(";"); 
    
    if (! InArray(supportedExt, ext))
    {
      errMsg = "Het geselecteerde bestand is niet van het type "+ replaceAll(supTypes,";"," or ") +"!";
    }
  }
  
  if (errMsg == "")
  {
    //*** Everything ok, so submit form.
    if (itemCheck(itemCode, itemRev) == true) document.ItemForm.submit();
  }
  else
  {
    //*** Some error(s) occured!
    alert(errMsg);
  }
}

function replaceAll(mainstr, find, replace_){
  while(mainstr.indexOf(find)>-1){
    mainstr = mainstr.replace(find,replace_);
  }
  return mainstr;
}
