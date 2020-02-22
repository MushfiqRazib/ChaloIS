<!-- #include file="../config.asp"     -->
<!-- #include file="../qb/includes/common.asp"  -->
<!-- #include file="../qb/includes/postgres.asp"  -->


<%
  Dim isCheck, textAreaValue, kopbladNumber
    isCheck = ""
	kopbladNumber = 1
	textAreaValue = ""
	
	If Request.QueryString("fromadvance") = "true" Then
		Session("koblad_on") = "" 
  	    Session("opmarking") = ""
		Session("kopbladNumber") = "1"
		isCheck = ""
	End If
	
    IF Request.Form.Count <> 0 Then
  	    IF Request.Form("checkBox1") = "on"  Then 
		   isCheck = "checked"
  	       Session("koblad_on") = "on"
  	       Session("opmarking") = Request.Form("textArea") 
		   Session("kopbladNumber") = IIF(Trim(Request.Form("txtAantal"))<>"",Request.Form("txtAantal"),0)
  	    Else   
  	        Session("koblad_on") = "" 
  	        Session("opmarking") = ""
			Session("kopbladNumber") = "1"
			isCheck = ""
	    End IF
	    'Response.Write("<script>alert('"&Request.Form("checkBox1")&"')</script>")
	    Response.Redirect("Print_2_5.asp")
    End IF
    
	If Session("koblad_on") <> "" Then
		isCheck = "checked"
		textAreaValue = Session("opmarking")
		kopbladNumber = Session("kopbladNumber")
	End If
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>  
<head id="Head1" runat="server">
     <title>Print Wizard</title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
    

   <script src="../Attachment/script/common.js" type="text/javascript"></script>

    <script src="../Attachment/script/sarissa.js" type="text/javascript"></script>

    <script src="../Attachment/script/window.js" type="text/javascript"></script>
    <link href="../../styles/datagrid.css" rel="stylesheet" type="text/css" />
    
<script language="javascript">
      
   function submit_1_5()
   { 
       document.ItemForm.submit();
   }
   function EnableDisableTextBox(obj)
   {
     if(obj.checked)
	 {
		document.getElementById("TextArea1").disabled = '';
		document.getElementById("txtAantal").disabled = '';
	 }
     else 
	 {
		document.getElementById("TextArea1").disabled = 'disabled';
		document.getElementById("txtAantal").disabled = 'disabled';
	 }
   }
   function RefreshFistTime(textArea)
   { 
     if(textArea.innerText == "Opmerkingen...")
     textArea.innerText = "";
   }


</script>
</head>
<body class='BodyStyle'>
    <form name="ItemForm" action='Print_1_5.asp'  method="POST">
     <div style="position:absolute; width: 479px; height: 316px;" id="DIV1">
       <table>
        <tr align='center'><td style="height: 57px">
           <b> Print Wizard - <%=Session(BasketName) %></b><br />
         
            <b>1/5</b>

        </td></tr>
        <tr><td>
          
          <fieldset  style="width: 468px; height: 210px">
            <legend>Kopblad:</legend>
             <table style="width:100%">
               <tr><td ><input id="Checkbox1" name="checkBox1" type="checkbox" <%=isCheck%> style="width: 15px" onclick="EnableDisableTextBox(this)"/> Kopblad met overzicht documenten</td></tr>
               <tr>
					<td>
						Aantal/Afdrukken -
						<input id="txtAantal" name="txtAantal" type="textbox" style="width:50px;text-align:center;" value="<%=kopbladNumber%>"  onkeypress='return isNum(event)' ></input>
					</td>
			   </tr>
			   <tr></tr>
			   <tr>
				   <td>
					Opmerkingen:
				   </td>
			   </tr>
			   <tr ><td  style="overflow:auto; height: 100%;">
                <TEXTAREA id="TextArea1" name="textArea" cols="53" rows="6" value="<%=textAreaValue%>"  onfocus="RefreshFistTime(this)" onclick="RefreshFistTime(this)"><%=textAreaValue%></TEXTAREA>
               </td></tr>
             </table>
          </fieldset>
        </td></tr>
        <tr><td align='right' style="height: 8px">
            <!--<input id="Button2" name="btn" style="width: 121px" type="button" value="Vorige" onclick="javascript:history.go(-1)" />-->
            <span style="width:220px"></span>
            <input id="Button1" name="nextbtn" style="width: 121px" type="button" value="Volgende" onclick="submit_1_5()"/></td></tr>
       </table>
       <input type="text" name="hidden" style="display:none" />
     </div>
     
    </form>
</body>
</html>