function LoadTheFiles()
{  
  var url = "basketing.asp?getXmlFiles=true";     
  var httpResult = httpRequest(url); 
  
  if(httpResult == "Error"){
      alert(httpResult)
   document.getElementById('listDiv').style.visibility = 'hidden'
  }
  else
  {  
    var select = document.getElementById("drpFilelist");
    while(select.options.length>0)
    {
      select.remove(select.options.length-1);
    }
   
    var printerArr = httpResult.split("*");
    var nameParts;
    for(var i=0;i<printerArr.length;i++)
    {          
      nameParts = printerArr[i].split(".xml");      
      addOption(select,nameParts[nameParts.length-2],'');
    }    
   }
}

function createFormatPrinterString()
{
  
 var formatPrinterString ="", count, format,newformat, printer;
 count = document.getElementById("countRow").value;
 count++;
 for(var i=0;i<count;i++)
 { 
   format = document.getElementById("format_"+i).innerText;
   //newformat = document.getElementById("drpFormatList_"+i)[document.getElementById("drpFormatList_"+i).selectedIndex].text;   
   printer = document.getElementById("drpPrinterList_"+i)[document.getElementById("drpPrinterList_"+i).selectedIndex].text;
   formatPrinterString = formatPrinterString + format +"@"+ printer+ "*"
 }
  formatPrinterString = formatPrinterString.substring(0,formatPrinterString.length-1);   
  var url = "../Basket/basketing.asp?formatPrinterString="+formatPrinterString;     
  var httpResult = httpRequest(url); 
  if(httpResult == "Error"){
      alert(httpResult)
   return false;
  }
  else
  {
   return true;
  }
}

// input is format and get output corresponding printer
function sendformatgetprinter(format,drpObj)
{ 
  if(format=="") format = 'unknown';
  var url = "../basket/basketing.asp?getPrinter="+format;     
  var httpResult = httpRequest(url); 
  
  if(httpResult == "Error"){
      alert(httpResult)
  }
  else
  {
    var row = drpObj.parentNode.parentNode;
    var select = row.childNodes[2].childNodes[0];
    while(select.options.length>0)
    {
      select.remove(select.options.length-1);
    }
   
   var printerArr = httpResult.split("*")
   for(var i=0;i<printerArr.length;i++)
   {
      addOption(select,printerArr[i],'');
   }
  }
}

function addOption(selectbox,text,value)
{
    var optn = document.createElement("OPTION");
    optn.text = text;
    optn.value = value;
    selectbox.options.add(optn);
}

function basket_release()
{
    //debugger;
  var url = "./Components/Basket/basket_release.asp"; 
  //window.location = url;
  var httpResult = httpRequest(url);   
  
  //***refresh the browser page...
  //window.opener.document.forms[0].submit();  
  var me = OBSettings;
  if (me.SQL_GROUP_BY != 'NONE') {
      setTimeout(function() {
          me.CreateGroupByGrid();
      }, 1);
  } else {
      setTimeout(function() {
          me.CreateNormalGrid();
      }, 1);
  }
  ChaloIS.Basket.grid.ClearBasket();
  ChaloIS.Basket.grid.DisplayButtons();
  alert(httpResult);  
  //document.ItemForm.submit();   
  InitReport();
}

//*** This method upgrades the datagrid for basket,
//*** Takes confirmation from user the basket has 
//*** already a name
function updateTable()
{ 
   
     var name = document.getElementById("BasketName") ;
     if(name.innerHTML.split("Unnamed").length==1)
     {
         var msg = "Weet u zeker dat u de hoogste versie van alle documenten wilt?";  
         var agree=confirm(msg);
         if(!agree)return;         
     }              
     
     var url = "./basketing.asp?upgrade=true"; 
     var httpResult = httpRequest(url);   
     alert( httpResult);         
     if(httpResult=="Error")
     {
         alert("Problem occurs. Try again..." + httpResult);
     }
     //*** Reload grid
     document.ItemForm.submit();
     
     
}

/*function sendItem(artikelNr, revision,format,reltable,keyfields,sid,kitServerPath){   
    //alert(fileName);    
    var iteminfo = artikelNr+"@@@@"+revision+"@@@@"+format+"@@@@"+reltable + "@@@@" + keyfields;           
    iteminfo = iteminfo.replace("&","%%%")
    iteminfo = iteminfo.replace('\\','*')
    var url = "./Components/Basket/basketing.asp?iteminfo="+iteminfo+"&sid="+sid+"&kitServerPath="+kitServerPath+"&printserverlocation="+printSeverLocation;   // printSeverLocation is global var. difined in default.aspx

    var httpResult = httpRequest(url);
              
    //alert(httpResult);return;
     if(httpResult=="duplicate")    
     {    
         //alert("Duplicate item selected");
         return;
     }
     else {      
      
       var respTx = httpResult.split('@@')
       if(respTx.length == 0)
       {
           alert(httpResult);            
          return;
       }
       else if(respTx[0] == "success")
       { 
         //var curName = document.getElementById("btnBasket").value.split("(")[0];         
         //document.getElementById("btnBasket").value = trim(curName) + "("+respTx[1]+")";
       }
     }   
} */

function sendRelatedItems(artikelNr, revision){   
    
    var agree=confirm("Wilt u het document inclusief alle onderliggende documenten toevoegen ?");
    if(!agree)return;
           
    artikelNr = artikelNr.replace("&","%%%")
    artikelNr = artikelNr.replace('\\','**')

    var url = "../Basket/basketing.asp?setRelItem=true&artikelNr="+artikelNr+ "&versionNr=" + revision;   
    
    var httpResult = httpRequest(url); 
 
     if(httpResult=="duplicate")    
     {    
         //alert("Duplicate item selected");
         return;
     }
     else {      
       var respTx = httpResult.split('@@')
       if(respTx.length == 0)
       {
           alert(httpResult);            
          return;
       }
       else if(respTx[0] == "success")
       {
         document.getElementById("btnBasket").value = "Basket Unnamed("+respTx[1]+")"
       }
     }   
}



function loadFileList(name){
    
     //name = name.substring(0,name.indexOf("."))
     var url = "./basketing.asp?fileList="+name;    
     var httpResult = httpRequest(url);                      
     
     if(httpResult=="success")    
     {    
         document.ItemForm.submit();
     }
     else {
         alert("Problem occurs. Try again..." + httpResult);
     }
}

 function loadDistribute(){
     
       var name = prompt("Type distribute name", distName);
       if(name == null ) return false;
       name = trim(name);
       
       if(checkValue(name) == false)
       {
          //alert('special char not allowed')
          alert("Following Characher not allowed...\n"+"          "+"\\ "+" / "+" * "+" ? "+" \" "+" < "+" > "+" | ")
          loadDistribute();
          return false;        
       }    
       var distName =  name;
       
       var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
       OpenChild(COMPONENT_BASE_PATH +"Distribute/Distributie_5_5.asp?distributename="+name+"&frombasket=true", "Distribute", true, 535, 350, "no", "no");                   
       //OpenChild(COMPONENT_BASE_PATH + "Basket/Basket.asp?rc=false", "Basket", true, 665, 350, "no", "no");           
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

//*** This function deletes all the rows from the  
//*** basket, also resets the session of basket status  
function DeleteAll(){
        
        var url = "./Components/Basket/basketing.asp?reset=true";                              
        var httpResult = httpRequest(url);                   
        if (httpResult == "success")
        {
             var table = document.getElementById("FileInfo");
             if(table != null){
                 while(table.rows.length>1)
                 {                
                    table.deleteRow(table.rows.length-1);        
                 }  
             
                 //*** Update the basket size in main window...           
                var curBasket = document.getElementById("curBasket").value;                
                opener.document.getElementById("btnBasket").value = "Basket " + curBasket + "(" +(table.rows.length-1)+")";      
            }                      
        }
        else
        { 
            //*** Something went wrong, show returned error message.
            alert(httpResult);
        }   
}

//*** This method is used to delete the selected artikel 
//*** from the grid as well as deleting the document from disk
//*** and then reload the grid
function deleteRow(artikelNr,versionNr)
{ 
		//var artikelNr,versionNr;
        var deleteRow;        
        
//        var table = item.parentNode.parentNode.parentNode.parentNode;        
//		for(k=0;k<table.rows.length;k++)
//        { 
//            var deleteRow = table.rows[k].children[7].children[0]; 
//            if(deleteRow==item)
//            {   
//                artikelNr = table.rows[k].cells[0].innerHTML;
//                artikelNr = artikelNr.replace("&","%%%")
//                artikelNr = artikelNr.replace('\\','**')
//                versionNr = table.rows[k].cells[1].innerHTML;
//                break;       
//            }
//        }
        
		
        var url = "./Components/Basket/basketing.asp?artikelNr="+artikelNr+"&versionNr="+versionNr;                              
        var httpResult = httpRequest(url);                   
        if (httpResult == "success")
        {
            // table.deleteRow(k);   
             //*** Update the basket size in main window...                        
             //var curBasket = document.getElementById("curBasket").value;                
             //opener.document.getElementById("btnBasket").value = "Basket " + curBasket + "("+(table.rows.length-1)+")";
                            
        }
        else
        { 
            //*** Something went wrong, show returned error message.
            alert(httpResult);
        }   
    }
 

    function SaveBasket(msg,onload)
    {
            
       var name, table, basketName,titleParts,url,httpResult,rowNum,rcORva;        
       table = document.getElementById("FileInfo");
       if(table.rows.length<2)
       {
           //alert("You can't save an empty basket")       
           return;               
       }
       
       basketName = getElement("BasketName");                      
       titleParts = basketName.innerHTML.split("-");       
       titleParts[1] = trim(titleParts[1])              
       if(onload != true)
       {
           if(titleParts[1]== "Unnamed") 
           {       
              name = prompt("Type a file name", msg);
           }else{
              name = prompt("Type a file name", titleParts[1]);
           }
       
           if(name == null ) return false;
           name = trim(name);
           
           if(name.toUpperCase() == "UNNAMED" )
           {
               alert("This name isn't allowed");       
             return false;
           }
           
           if(checkValue(name) == false)
           {
            //alert('special char not allowed')
               alert("Following Characher not allowed...\n" + "          " + "\\ " + " / " + " * " + " ? " + " \" " + " < " + " > " + " | ")
            SaveBasket(name);
            return false;        
           }
       }else
       {
          name = titleParts[1];
       }
       
      
      rcORva = document.getElementById("rc").value; 
      url = "./basketing.asp?fileName="+name + "&rcORva="+rcORva;                             
      httpResult = httpRequest(url);       
                 
      if (httpResult == "success")
      {        
        basketName.innerHTML = "Basket - " + name;
        //*** Everything went ok, now reload page/grid.
        if(onload != true)
        {
            //alert("Basket saved");
      }
      
        
        //*** Change Obrowser basket buttons counter
        rowNum = opener.document.getElementById("btnBasket").value.split("(")[1];
        opener.document.getElementById("btnBasket").value = "Basket " + name + "("+rowNum;       
                                
      }
//      else if(httpResult == "duplicate")
//      {
//        //createCustomAlert("File Name \""+name+"\" already exists\n\n- - Please type another one...")
//        alert("File Name \""+name+"\" already exists\n\n- - Please type another one...")
//        SaveBasket(name);                       
//      }
      else{
       //*** Something went wrong, show returned error message.
        alert(httpResult);
      }  
    }


function SavePrintXML(myText)
    {
   
       var url = "../basket/basketing.asp?printFileName=true";                             
       var httpResult = httpRequest(url);  
       //debugger;           
       if (httpResult == "success")
       { 
           //*** Everything went ok, now reload page/grid.
           //alert("De documenten zijn naar de printer gestuurd.");    
           window.close();                                
           
           var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
           openChild("../PrintReport.asp", "Report", true, 500, 350, "no", "no");    
           
           //window.open("../Reporting.asp");
       }       
       else{
           //*** Something went wrong, show returned error message.
           alert(httpResult);
       }
    }


    function SaveDistributeXML(myText) {      
   
    var url = "../Basket/basketing.asp?ditributeFileName=true";                             
       var httpResult = httpRequest(url);             
       //debugger;
       if (httpResult == "success")
       { 
           //*** Everything went ok, now reload page/grid.
           //alert("De distributie is gereed");                                    
           window.close();
           var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
           openChild("../DistributeReport.asp", "Report", true, 500, 350, "no", "no");                         
       }       
       else{
           //*** Something went wrong, show returned error message.
          alert(httpResult);
       }  
    }


    
  function checkValue(name)
  {
    var strArr = new Array("\\","/","*","?","\"","<",">","|")
    for(var i=0;i<strArr.length;i++)
    {
     var charM =  name.indexOf(strArr[i])
     if(charM >= 0) return false;
    }
  }
function trim( value ) {return LTrim(RTrim(value));}
function LTrim( value ) {var re = /\s*((\S+\s*)*)/;return value.replace(re, "$1");}
function RTrim( value ) {var re = /((\s*\S+)*)\s*/;	return value.replace(re, "$1");}

  
//*** Used to eliminate caching problem    
function noCacheURL(url)
{
	//*** Add 'nocache' argument to URL.
  return (url + ((url.indexOf("?") > 0) ? "&" : "?") + "nocache=" + new Date().getTime());
}

function sendItem(artikelNr, revision,format,reltable,keyfields,sid,kitServerPath){   
    //alert(fileName);   
   
    var iteminfo = artikelNr+"@@@@"+revision+"@@@@"+format+"@@@@"+reltable + "@@@@" + keyfields;           
    iteminfo = iteminfo.replace("&","%%%")
    iteminfo = iteminfo.replace('\\','*')
    var url = "./Components/Basket/basketing.asp?iteminfo="+iteminfo+"&sid="+sid+"&kitServerPath="+kitServerPath+"&printserverlocation="+printSeverLocation;   // printSeverLocation is global var. difined in default.aspx

    var httpResult = httpRequest(url);
              
    //alert(httpResult);return;
     if(httpResult=="duplicate")
     {
         //alert("Duplicate item selected");
         return;
     }
     else
     {
        var loadedRows = httpResult.split('****');
        if(loadedRows.length <= 0)
        {
            alert(httpResult);
            return;
        }
        else
        {
            ChaloIS.Basket.grid.ClearBasketData();
            for (var i = 0; i < loadedRows.length; i++)
            {                
                var rowRecords = loadedRows[i].split('@@@@');
                ChaloIS.Basket.grid.AddRow(rowRecords);
            }
        }
     }
     ChaloIS.Basket.grid.DisplayButtons();
}