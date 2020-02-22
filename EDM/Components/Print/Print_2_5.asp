<!-- #include file="../config.asp"     -->
<!-- #include file="../qb/includes/common.asp"  -->
<!-- #include file="../qb/includes/postgres.asp"  -->
<!-- #include file="../Attachment/htmlform.asp" -->

<%
    Dim sessionValue, oForm,arrSession,stuklijstsession,First,Second,Third
    Dim itemVrij, itemStuk, itemBijlagen 
    stuklijstsession=""
    First  = "checked"
    Second = "checked"
	Third  = "checked"
	
  IF Request.QueryString("back") = "" Then    
      IF Request.Form.Count <> 0 Then   
         '*** Use HTMLForm component because we need binary data for file upload.
         itemVrij  = Request.Form("Vrijgave")
         itemStuk  = Request.Form("Stuklijst")
		 itemBijlagen  = Request.Form("Bijlagen")
              
         sessionValue = IIf(itemVrij = "on", "Vrijgave,", ",")
		 sessionValue = sessionValue & IIf(itemBijlagen = "on", "Bijlagen,", ",")
         sessionValue = sessionValue & IIf(itemStuk = "on", "Stuklijst,", ",")
         stuklijstsession = IIf(itemStuk = "on", "Stuklijst,", "")
         'session("stuklijstsession") = stuklijstsession        
         session("Print_1_5") = sessionValue         
         Response.Redirect("Print_3_5.asp")
      End IF 
   Else
    
    Dim FirstValues
	
    FirstValues = Split(Session("Print_1_5"),",")
      
    IF FirstValues(0)= "Vrijgave" Then
     First = "checked"
    Else 
     First = ""
    End IF
   
    IF FirstValues(1)= "Bijlagen" Then
     Third = "checked"
    Else 
     Third = ""
    End IF
	
    IF FirstValues(2)= "Stuklijst" Then
     Second  = "checked"
    Else 
     Second = ""
    End IF
   
   End If
   
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head id="Head1">
     <title>Print Wizard</title>
     <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">

     <script src="../Attachment/script/common.js" type="text/javascript"></script>

    <script src="../Attachment/script/sarissa.js" type="text/javascript"></script>

    <script src="../Attachment/script/window.js" type="text/javascript"></script>
    <link href="../../styles/datagrid.css" rel="stylesheet" type="text/css" />
    
    
 
    <script language="javascript">
     
      function submit_2_5()
      { 
      
       var itemArticle = getElementAttrib("Vrijgave", "checked");
	   var itemVersion  = getElementAttrib("Stuklijst", "checked");
	   var itemAppendices  = getElementAttrib("Bijlagen", "checked");   
		  
       var errMsg   = "";
	
	    //*** Now check form data.
	    errMsg += (itemArticle == true) ? "  - Artikelnummer\n" : "";
	    errMsg += (itemVersion == true)  ? "  - Revisie\n"       : "";
	    errMsg += (itemAppendices == true)  ? "  - Bijlagen\n"       : "";
        
        if (errMsg == "")
        alert('select at least one item');
        else document.ItemForm.submit();
        
      }
	  function Back()
      {
        var url = "Print_1_5.asp?back=true";
        location.href = url;
      }
     </script>
</head>
<body class='BodyStyle'>
    
    <form name="ItemForm" action="Print_2_5.asp"  method="POST">
     <div style="position:absolute; width: 479px; height: 316px;" id="DIV1">
       <table>
        <tr align='center'><td style="height: 57px">
           <b> Print Wizard - <%=Session(BasketName) %></b><br />
               <b>2/5</b>

        </td></tr>
        <tr><td style="height: 214px">
          <fieldset  style="width: 468px; height: 210px">
            <legend>Opties:</legend>
            <table>
                <tr><td style="width: 54px"></td><td></td><td></td><td></td></tr>
                <tr><td style="width: 54px; height: 28px"></td><td style="height: 28px"><input name="Vrijgave" type="checkbox" <%=First %> /></td><td style="height: 28px">
                <% If (Session(whichBasket)="rc") Then %>
                Geselecteerde RC document(en) (dwf/pdf/tiff)
                <% Else %>
                Geselecteerde VA document(en) (dwf/pdf/tiff)
                <% End If %>
                </td><td style="height: 28px"></td></tr>
				<tr><td style="width: 54px; height: 28px"></td><td style="height: 28px"><input name="Bijlagen" type="checkbox" <%=Third%>/></td><td style="height: 28px">Bijlagen</td><td style="height: 28px"></td></tr>
                <tr><td style="width: 54px; height: 28px"></td><td style="height: 28px"><input name="Stuklijst" type="checkbox" <%=Second %> /></td><td style="height: 28px">Stuklijst</td><td style="height: 28px"></td></tr>
                
            </table>
          </fieldset>
        </td></tr>
        <tr><td align='right' style="height: 22px">
			<input id="Button2" name="btn" style="width: 121px" type="button" value="Vorige" onclick="Back()" />
            <span style="width:220px"></span>
            <input id="Button1" style="width: 121px" type="button" value="Volgende" onclick="submit_2_5();" />
           
            </td></tr>
            
       </table>
     </div>
        
    </form>
</body>
</html>