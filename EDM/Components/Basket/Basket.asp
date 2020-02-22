<!-- #include file="./functions.asp"                   -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head name="Head1" runat="server">
    <title>Basket</title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
    <link href="../../styles/datagrid.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../Attachment/script/AddAttachment.js"></script>
    <script src="../Attachment/script/sarissa.js" type="text/javascript"></script>

    <script src="../Attachment/script/window.js" type="text/javascript"></script>
    <script src="../Attachment/script/attachment.js" type="text/javascript"></script>
    <script src="script/sarissa.js" type="text/javascript"></script>
    <script type="text/javascript" src="./script/basket.js"></script>

   

    <script type="text/javascript" src="../Attachment/script/common.js"></script>

    <script type="text/javascript" language="javascript">
    
    function submit_2_5()
    { 
      document.ItemForm.submit();
    }
    
    
    var distName="";  
    function loadDistribute(){
        debugger;
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
       distName =  name;
    
       var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
       openChild("../Distribute/Distributie_5_5.asp?distributename="+name+"&frombasket=true", "Distribute", true, 535, 350, "no", "no");                   
    } 
    
    function loadPrinten(){
      var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
      openChild("../Print/Print_5_5.asp?frombasket=true", "Printen", true, 520, 350, "no", "no");     
      //openChild("../Print/Print_1_5.asp", "Printen", true, 700,750, "no", "no");     
    } 
       
    function SelectList()
    {
        
        document.getElementById('listDiv').style.display = 'block';
        
        LoadTheFiles();
    }
    
    function HideDiv()
    {   
        if(document.getElementById('drpFilelist').selectedIndex >= 0)
        {
           
            var name = document.getElementById('drpFilelist').children[document.getElementById('drpFilelist').selectedIndex].text+".xml";         
            if(name!=null && name!="")
            {
                loadFileList(name);
            }         
        }
        
        document.getElementById('listDiv').style.visibility = 'hidden'
      
    }
    
    function HandleOnClose() {
      
      /*
       if (event.clientY < 0) {
          var url = "./basketing.asp?newAdd="+true;    
          var httpResult = httpRequest(url);            
         
          if(httpResult == "Added")    
          {    
             event.returnValue = "Weet u zeker dat u dit scherm wilt afsluiten, er kunnen gegevens verloren gaan." ;
          }
       }*/
    }
    
    function init()
    { 
        //*** Change Obrowser basket buttons counter
        var rowNum = document.getElementById("FileInfo").rows.length-1;                
        var basketname = document.getElementById("curBasket").value;
        //var rowNum = document.getElementById("btnBasket").value.split("(")[1];
        opener.document.getElementById("btnBasket").value = "Basket " + basketname + "("+rowNum + ")";               
        
        SaveBasket("Save Unnamed basket",true)
    }
    
    
    </script>

    <%
       
       If Request.Form.Count=0 Then                    
           '*** set default basket name
           If( Session(BasketName) = "") Then 
              Session(BasketName) = "Unnamed"
           End If
                  
           '*** Set the status of basket either 'rc' or 'va'
           If Request.Item("rc")="true" Then
                Session(whichBasket) = "rc" '*** Used in basketing.asp                   
           Else
                Session(whichBasket) = "va" '*** Used in basketing.asp                
           End If           
       End If    

              
    %>
</head>
<body class="BodyStyle" onbeforeunload="HandleOnClose()" onload="init();">
    <form name="ItemForm" action="Basket.asp" method="post" style="background-color: #eeffdd;">
    <div style="background-color: #eeffdd; width: 479px; height: 316px; font-family: Arial;" name="DIV1">
        <table>
            <tr>
                <td id="BasketName" style="height: 27px; font-weight: bold" align="center" colspan="5">
                    Basket -
                    <%=Session(BasketName) %>
                </td>
            </tr>
            <tr>
                <% If Request.Item("rc")="true" AND Session("loggedIn")="TRUE" Then%>
                <td style="height: 21px">
                    <input id="btnVrij" style="width: 80px; background-color: #E6E6E6;" type="button"
                        value="Vrijgeven" onclick="basket_release()" />
                </td>
                <%End If %>
                <td style="height: 21px; width: 210px;">
                    <input id="Button2" style="background-color: #E6E6E6; width: 80px;" type="button"
                        value="Printen" onclick="loadPrinten()" />
                </td>
                <% If Request.Item("rc")<>"true" Then%>
                <td style="height: 21px; width: 40px;">
                    <input id="btnDistribute" style=" background-color: #E6E6E6;width: 80px;" type="button" value="Distributie" onclick="loadDistribute()" /></td>
                        <td style="height: 21px;width: 200px;">
                </td>
                <td style="height: 21px; width: 200px;">
                    <input id="Button4" style="background-color: #E6E6E6; width: 80px;" type="button"
                        value="Opslaan" onclick='SaveBasket("Type a File Name","false")' />
                </td>
                <td style="width: 20px;">
                    <input id="Button5" style="background-color: #E6E6E6; width: 80px;" type="button"
                        value="Open" onclick="SelectList()" />
                </td>
                <% End If %>
                <td style="width: 0px; height: 21px">
                    <div id='listDiv' style="position: absolute; border: 0.001px #333333 solid; border-color: #003399; border-width: medium; display: none; background-color: #eeffdd; left: 122px;
                        width: 173px; top: 96px; height: 145px; z-index: 10;">
                        <table>
                            <tr>
                                <td style="width: 158px">
                                    Select a file to load...
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 158px">
                                    
                                    <% =CreateListWithNameofXmlFile() %>
                                    
                                </td>
                            </tr>
                            <tr>
                                <td style="height: 23px; width: 158px;">
                                </td>
                            </tr>
                            <tr>
                                <td style="height: 30px; width: 158px;" align='right'>
                                    <input type='button' value='Ok' style="width: 63px" onclick='HideDiv()' />
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
            <tr>
                <td style="width: 650px" colspan="5">
                    <fieldset style="width: 640px; height: 192px">
                        <legend>Overzicht te distribueren documenten:</legend>
                        <div name="myGrid" style="overflow: auto; height: 167px; width: 98%;">
                            <%= CreateBasketDataGrid("myGrid")%>
                        </div>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td>
                    <input name="btnDeleteAll" style="background-color: #E6E6E6; width: 150px;" type="button"
                        value="Basket leegmaken" onclick="DeleteAll()" />
                </td>
                <td colspan="1">
                </td>
                <% If Request.Item("rc")<>"true" Then%>
                <td style="height: 22px; text-align: right" colspan="6" align='right'>
                  <input name="btnUpdate" style="background-color: #E6E6E6;width: 231px;"  type="button" value="Hoogste versie voor alle documenten" onclick="updateTable()" />
                </td>
                <%End If %>
            </tr>
        </table>
    </div>
    <input type="text" name="hidden" style="display: none" />
    <input type="hidden" id="rc" name="rc" value="<%=Request.Item("rc") %>" />
    <input type="hidden" id="curBasket" value='<%=Session(BasketName) %>' />
    </form>
</body>
</html>
<!--

var xmlDoc=Server.CreateObject("MICROSOFT.FreeThreadedXMLDOM");
 xmlDoc.async="false";
 xmlDoc.load(Server.MapPath("Person.xml"));

 // Get the current root  
 var nodeList = xmlDoc.getElementsByTagName("PersonList");
 if(nodeList.length > 0){
   var parentNode = nodeList(0) ;

   // Create the required nodes
   var personNode = xmlDoc.createElement("Person");
   var nameNode = xmlDoc.createElement("Name");
   var ageNode = xmlDoc.createElement("Age");
   var genderNode = xmlDoc.createElement("Gender");
   var pcodeNode = xmlDoc.createElement("PostalCode");

   // Assign the variables, which we have retrieved in  
   step 2 to the xml variables
   nameNode.text = name;
   ageNode.text = age;
   genderNode.text= gender;
   pcodeNode.text = pcode;

-->
