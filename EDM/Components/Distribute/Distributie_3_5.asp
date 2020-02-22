<!-- #include file="../rc/common.asp"                   -->
<!-- #include file="./../app_constants.asp"               -->
<%
  
    IF Request.Form.Count <> 0 Then
  	    IF Request.Form("checkBox") = "on" & Request.Form("textArea") <> "Opmerkingen..." Then 
  	     Session("opmarking") = Request.Form("textArea")
  	     Session("koblad_on") = "on"
  	    Else 
  	     Session("opmarking") = "" 
  	     Session("koblad_on") = "" 
	    End IF
	    Response.Redirect("Distributie_4_5.asp")
    End IF
     
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
      
   function submit_3_5()
   { 
       document.ItemForm.submit();
   }
   
   function EnableDisableTextBox(obj)
   {
     if(obj.checked)
     document.getElementById("TextArea1").disabled = '';
     else document.getElementById("TextArea1").disabled = 'disabled';
   }
   
   function RefreshFistTime(textArea)
   { 
     if(textArea.innerText == "Opmerkingen...")
     textArea.innerText = "";
   }

   function Back()
       {
        var url = "Distributie_2_5.asp";        
        location.href = url; 
       }

</script>
</head>
<body class="BodyStyle">
    <form name="ItemForm" action='Distributie_3_5.asp'  method="POST">
     <div style="position:absolute;width: 520px; height: 316px; background-color:#E6E6E6;  font-family:Arial;" id="DIV1" >
       <table>
        <tr><td style="height: 57px">
           <b>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
               &nbsp;&nbsp; Distributie Wizard - <%=Session(BasketName) %></b><br />
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; Distributie(3/5)

        </td></tr>
        <tr><td>
          
          <fieldset  style="width: 510px; height: 210px">
            <legend>Kopblad:</legend>
             <table style="width:100%">
               <tr><td ><input id="Checkbox1" name="checkBox" type="checkbox" style="width: 15px" onclick="EnableDisableTextBox(this)"/> <span>kopblad met overzicht documenten</span></td></tr>
               <tr>
					<td>
					</td>
			   </tr>
			   <tr>
				   <td>
					Opmerkingen:
				   </td>
			   </tr>
			   <tr height="100%"><td  style="overflow:auto; height: 100%;">
                <TEXTAREA id="TextArea1" name="textArea" cols="57" rows="8" onfocus="RefreshFistTime(this)" onclick="RefreshFistTime(this)"></TEXTAREA>
                <input type=text style="display:none" value="ee"/>
               </td></tr>
             </table>
          </fieldset>
        </td></tr>
        <tr><td align='left' style="height: 8px">
            <input id="Button2" name="btn" style="background-color: #E6E6E6;width: 121px" type="button" value="Vorige" onclick="javascript:history.go(-1)" />
            <span style="width:265px"></span>
            <input id="Button1" name="nextbtn" style="background-color: #E6E6E6;width: 121px" type="button" value="Volgende" onclick="submit_3_5()"/></td></tr>
       </table>
       <input type="text" name="hidden" style="display:none" />
     </div>
    </form>
</body>
</html>