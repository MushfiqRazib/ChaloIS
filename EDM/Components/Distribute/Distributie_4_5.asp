<!-- #include file="./../basket/functions.asp" -->

<%
Dim outputDir
 outputDir =  getRevDate() & "_" & Session(DistributionName)
 
 If Not FolderExists(DISTRIBUTION_DIR & outputDir) Then                          
     Session("DistOutputDirectory") = outputDir
 Else
     'outputDir = GetDir(DISTRIBUTION_DIR&outputDir)             
     outputDir = DISTRIBUTION_DIR&outputDir             
     Session("DistOutputDirectory") = split(outputDir,"\")(UBound(split(outputDir,"\")))
 End If
           
            
 
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>  
<head id="Head1" runat="server">
     <title>Distributie Wizard</title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
    
    <script type="text/javascript" src="../rc/script/common.js"></script>
  <script type="text/javascript" src="../rc/script/sarissa.js"></script>
  <script type="text/javascript" src="../rc/script/window.js"></script>
 <link href="../Attachment/styles/datagrid.css" type="text/css" rel="stylesheet" />
 
    <script language="javascript">
      
      function submit_4_5()
      { 
       document.ItemForm.submit();
      }

	  function Back()
       {
        var url = "Distributie_3_5.asp";        
        location.href = url; 
       }
	   
    </script>
</head>
<body class="BodyStyle">
    <form name="ItemForm" action='Distributie_5_5.asp?frombasket=false' enctype="multipart/form-data" method="POST">
     <div style="position:absolute;  width: 520px; height: 316px; background-color: #E6E6E6; font-family:Arial;" id="DIV1">
       <table>
        <tr><td style="height: 57px">
           <b>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
               &nbsp;&nbsp; Distributie Wizard - <%=Session(BasketName) %></b><br />
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; Distributie(4/5)

        </td></tr>
        <tr><td>
          <fieldset  style="width: 510px; height: 210px">
            <legend>Output directory:</legend>
            <div id="myGrid" style="overflow:auto;height:167px; width: 98%;">
               <br />
               <span>&nbsp;&nbsp; <%=Session("DistOutputDirectory") %></span>
            </div>
            
          </fieldset>
        </td></tr>
        <tr><td align='left' style="height: 22px">
            <input id="Button2" style="background-color: #E6E6E6;width:121px" type="button" value="Vorige" onclick="javascript:history.go(-1)" />
            <span style="width:265px"></span><input id="Button1" style="background-color: #E6E6E6;width: 121px" type="button" value="Volgende" onclick="submit_4_5()" /></td></tr>
       </table>
     </div>
    </form>
</body>
</html>