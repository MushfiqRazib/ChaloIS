//JScript File
//*** Upload general and version specific attachments
function itemSubmit() {

  	if(!window.opener.opener.SessionExists())
  	{
  	    window.opener.close();
  	    window.close();
  	    return;
  	}
  	//*** Get form data.
	var itemOmschrijving = getElementAttrib("omschrijving", "value");
	var fileName = getElementAttrib("FileName", "value");
	
	var errMsg   = "";
	
	//*** Now check form data.
	errMsg += (fileName == "") ? "  - Bestand\n"       : "";
	errMsg += (itemOmschrijving =="") ? " - Omschrijving\n" : "";
	
	if (errMsg != "")
	{
        //*** Build final error message.
        errMsg = "De volgende verplichte gegevens ontbreken:\n\n" + errMsg;
    }
    /*
    else{  
        //*** Get file extension.
        var ext = fileName.substr(fileName.lastIndexOf(".") + 1);        
        if (ext.toUpperCase() != "DWF" && ext.toUpperCase() != "PDF" && ext.toUpperCase() != "TIFF" && ext.toUpperCase() != "TIF")        
        errMsg = "Het geselecteerde bestand is niet van het type DWF of PDF of TIFF!";        
        }*/
  
  if (errMsg == "")
  {

      //*** check for duplication

    var itemArticle = getElementAttrib("artikelnr", "value");
	var itemVersion  = getElementAttrib("version", "value");
	var docpath  = getElementAttrib("docpath", "value");
	var fileParts = fileName.split(".");
	
	if(itemVersion==""){
	    docpath = docpath + itemArticle + "_" + itemOmschrijving + "." + fileParts[1];
	}
	else
	{
	    docpath = docpath + itemArticle + "_" + itemVersion + "_" + itemOmschrijving + "." + fileParts[1];
    }
	docpath = docpath.replace(/\\/g, "@");
	docpath = docpath.replace(/:/g, "$");

	var url = "./ajaxAttachment.asp?itemcheck=true&docPath=" + docpath;
  
	var httpResult = httpRequest(url);
	
	
    if(httpResult=="duplicate")
    {
        alert( 'Bijlage met deze omschrijving bestaat al');
        
     return;    
    }
    
    //*** Everything ok, so submit form.    
    document.ItemForm.submit();
  }
  else
  {
      //*** Some error(s) occured!
      alert(errMsg);
     
    
  }
}

//*** Upload src attachment
function srcItemSubmit()
{   
  	//*** Get form data.
    var fileName = getElementAttrib("FileName", "value");
    //alert(fileName);
	var errMsg   = "";
	
	//*** Now check form data.
	errMsg += (fileName == "") ? "  - Bestand\n"       : "";
		
	if (errMsg != "")
	{
        //*** Build final error message.
        errMsg = "De volgende verplichte gegevens ontbreken:\n\n" + errMsg;
    }else{
  
        //*** Get file extension.
        var ext = fileName.substr(fileName.lastIndexOf(".") + 1);        
        if (ext.toUpperCase() != "DWG")
        {
          errMsg = "Het geselecteerde bestand is niet van het type DWG!";
        }
  }   
  
  if (errMsg == "")
  {
  
    //*** check for duplication
    var itemArticle = getElementAttrib("artikelnr", "value");
	var itemVersion  = getElementAttrib("version", "value");
	var docpath1  = getElementAttrib("docpath", "value");
	var fileParts = fileName.split(".");

	docpath1 = docpath1 + itemArticle + "_" + itemVersion + "." + fileParts[1];
	docpath1 = docpath1.replace("\\", "@")
	
    var url = "./ajaxAttachment.asp?itemcheck=true&docpath="+docpath1;
    var httpResult = httpRequest(url);
    if (httpResult == "duplicate")
    {
        alert('Bijlage met deze omschrijving bestaat al');
        
        return;
    }
    

    
    //*** Everything ok, so submit form.    
    document.ItemForm.submit();
  }
  else
  {
      //*** Some error(s) occured!
      alert(errMsg);
    
  }
}

function CheckValues(e) {
	    document.getElementById("myDiv").style.visibility = 'hidden';
	    var code;
	    if (e.keyCode) code = e.keyCode;
	    else if (e.which) code = e.which;
	    var character = String.fromCharCode(code);
	    returnVal = true;
	    switch(character)
	    {
	      case "\\":
	      case "/":
	      case ":":
	      case "*":
	      case "?":
	      case "\"":
	      case "<":
	      case ">":
	      case "|":
	      returnVal = false;
	      document.getElementById("myDiv").style.visibility = 'visible';
	      break;	       
	    }
	    if(!returnVal) setTimeout("SetMsg();",1500);
	    return returnVal;
     }
     function SetMsg(){
         document.getElementById("myDiv").style.visibility = 'hidden'; 
     }
     
     
     
