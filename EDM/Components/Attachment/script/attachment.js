
//This method is fired on close event
var wndChilds = new Array();
window.onunload = function()
{      
    closeChilds();
}
    

//*** This method is called from default page
//*** to pop up the attachmentment screen    
function loadAttachmentScreen(artikelnr,version,File_Subpath){      
    //for Default.asp
    var  artikelNr = getElement("txtArtikelNr").value;    
    openChild("./Attachment.asp?artikelNr="+artikelNr+"&version=11&File_Subpath=10@11@", "Attachment", true, 750, 677, "no", "no");
}

//*** This method is used to delete the selected artikel 
//*** from the grid as well as deleting the document from disk
//*** and then reload the grid
function deleteRow(item,filePath){          
             
        var deleteRow,filename;        
        var table = item.parentNode.parentNode.parentNode.parentNode;
        for(k=0;k<table.rows.length;k++){ 
            var deleteRow = table.rows[k].children[3].children[0];     
            if(deleteRow==item){
            filename = table.rows[k].children[0].innerHTML;            
            if (window.confirm("Weet u zeker dat u artikel:" + filename + " en alle bijbehorende documenten wilt verwijderen?") == false)
            {
                //*** Permission denied, so leave!
                return false;
            } 
            
            
            var artikelNr = getArtikel();
            var url = "./itemdelete.asp?filePath=" + filePath;  
            var httpResult = httpRequest(url);   
            
            if (httpResult == "")
            {
                //*** Everything went ok, now reload page/grid.
            
                alert("Artikel " + filename + " is met succes verwijderd.");                    
            }
            else
            {
  	            //*** Something went wrong, show returned error message.
                alert(httpResult);
            }
                table.deleteRow(k);        
                
            }
        }    
    }
    
//*** This method is used to open the pop of viewer to
//*** view the selected artikel
var viewFilePath;
var counter = 0;
function viewFile(filePath)
{
    var ext = filePath.substr(filePath.lastIndexOf(".") + 1);                
    if (ext.toUpperCase() != "DWF" && ext.toUpperCase() != "PDF")
    {
        alert("Viewer ondersteunt dit type document niet");
       return;
    }
    
	if(filePath!=null)
    {        
       
      viewFilePath = filePath;

      counter = counter+1;
      var name = "viewer_"+ counter;
      openChild("./Viewer.aspx", name, true, 650, 550, "yes", "no");             
        
    }else
    {
        alert("Invalid file");
    }
}

function Download(filePath)
{
    document.getElementById('downloadpath').value = filePath;	
	document.form1.submit();
}


//*** Loads the stream of selected document for the viewer
//*** It will only work for DWF file    
function loadFile(){    
    var url = "Loader.ashx?filepath="+ opener.viewFilePath;
    var status = httpRequest(url);       
    var viewerDiv = document.getElementById("viewerDiv");   
    viewerDiv.innerHTML = '<embed src="' + url + '" href="' + url + '" height="99%" width="100%">' +
                              '  <noembed>Your browser does not support embedded files.</noembed>' +
                              '</embed>';                              
}


function reloadVersieGrid(){
//debugger;
    if(window.opener.SessionExists())
    {
        var version = getVersion("");    
        var artikelNr = getArtikel();
        var RCorVA = getElement("RCorVA").value;
        var File_Subpath = getElement("File_Subpath").value;
        File_Subpath = File_Subpath.replace("\\","@")
        var url = "./ajaxAttachment.asp?reload=true&gridId=GridSpecific&version="+version+"&artikelnr="+artikelNr+"&File_Subpath="+File_Subpath+"&rc="+RCorVA;
        var httpResult = httpRequest(url);
        var specGrid = getElement("GridSpecific");
        specGrid.innerHTML = httpResult;     
        
        var elem = document.getElementsByName("version")[0];      
        //*** Set value of specified attribute.
        elem["value"] = version;
    }
    else
    {
        window.close();
    }
    
}    

function printableAttachment(combo, appendix)
{
	var format = combo.value;
	var appendixname = appendix;
	var url = "./ajaxAttachment.asp?appendixname="+appendixname+"&format="+format;
	var httpResult = httpRequest(url); 
	
	if(httpResult!="")
	{
		
	}
	else
	{
		
	}
	
	
}

function reloadTasksGrid(){
//debugger;
    if(window.opener.SessionExists())
    {
        var version = "";    
        var artikelNr = getArtikel();
        var RCorVA = getElement("RCorVA").value;
        var File_Subpath = getElement("File_Subpath").value;
        File_Subpath = File_Subpath.replace("\\","@")
        var url = "./ajaxAttachment.asp?task=true&gridId=GridTask&version="+version+"&artikelnr="+artikelNr+"&File_Subpath="+File_Subpath.replace("\\","@")+"&rc="+RCorVA;
       
        var httpResult = httpRequest(url);
        var taskGrid = getElement("GridTask");
        taskGrid.innerHTML = httpResult;     
        
        //var elem = document.getElementsByName("version")[0];      
        //*** Set value of specified attribute.
        //elem["value"] = version;
    }
    else
    {
        window.close();
    }
    
}    

function reloadGeneralGrid(){
//debugger;
    var version = "XX";    
    var artikelNr = getArtikel();
    var RCorVA = getElement("RCorVA").value;
    var File_Subpath = getElement("File_Subpath").value;
    File_Subpath = File_Subpath.replace("\\","@")
    var url = "./ajaxAttachment.asp?reload=true&gridId=GridGeneral&version="+version+"&artikelnr="+artikelNr+"&File_Subpath="+File_Subpath+"&rc="+RCorVA;  

    var httpResult = httpRequest(url);
        
    var genGrid = getElement("GridGeneral");
    genGrid.innerHTML = httpResult;     
    
}   

//*** returns the selected version from drop-downlist of version   
function getVersion(type){
  //debugger;
   var drpVersie = getElement("drpVersie");   
   var versie;
   if(drpVersie.children.length==0 && type!="General")
   {
       versie = getElement("version").value;              
       if(versie=="")
       {
           versie = prompt("Type the version", "");                     
           if(versie=="")
           {
               return getVersion(type);            
           }
        }   
       return versie;
   }
   versie = (type=="General")?"General":(trim(drpVersie.options[drpVersie.selectedIndex].value));
   return versie;
}

//*** This method returns the artikel number for which the 
//*** attachment screen was poped up
function getArtikel(){
   return trim(getElement("artikelNr").innerHTML);
}

//*** opens a new pop up for adding a new attachment
function addAttachment(docpath, type){          
  
    if(window.opener.SessionExists())
    {
        var artikelNr = getArtikel();        
        var version;
       if(type=="tasks")
             version = "";
       else
       {
           if(type!="general")
                version  = getVersion(type);  
            else
                version = "X";
       }
        
        var docPath = getElement("docPath").value;
       
        var settings  = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
        openChild("./AddAttachment.asp?docPath="+docPath+"&artikelNr="+artikelNr+"&version="+version, "AddAttachment", true, 420, 257, "no", "no");             
    }
    else
    {
        window.close();
    }
}

function addTaskAttachment(docpath, type){          
  
    if(window.opener.SessionExists())
    {
        var artikelNr = getArtikel();        
        var version = "";
       
        var docPath = getElement("docPath").value;
       
        var settings  = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
        openChild("./AddTaskAttachment.asp?docPath="+docPath+"&artikelNr="+artikelNr+"&version="+version, "AddAttachment", true, 420, 257, "no", "no");             
    }
    else
    {
        window.close();
    }
}

//*** opens a new pop up for adding a new src attachment
function addSrcAttachment(type){          

    if(window.opener.SessionExists())
    {
        var artikelNr = getArtikel();        
        var version;
        version  = getVersion(type);  
        var docPath = getElement("docPath").value;     
        var settings  = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
        openChild("./AddSrcAttachment.asp?docPath="+docPath+"&artikelNr="+artikelNr+"&version="+version, "AddSrcAttachment", true, 420, 257, "no", "no");             
    }
    else
    {
        window.close();
    }
}



//*** Closes the child windows.
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
