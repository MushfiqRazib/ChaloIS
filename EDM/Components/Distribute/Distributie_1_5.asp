<!-- #include file="./../basket/functions.asp" -->

<%
    Dim sessionValue, oForm,arrSession,DistributeXml,First,Second,Third,Fourth,Fith
    Dim itemVrij, itemStuk, itemGekoppeid, itemGekoppelde,itemAlgemene
    
    '*** Use HTMLForm component because we need binary data for file upload.    
     First = "checked"
     Second = "checked"
    
 IF Request.QueryString("back") = "" Then
  IF Request.Form.Count <> 0 Then
    itemVrij  = Request.Form("Vrijgave")
    itemStuk  = Request.Form("Stuklijst")
    itemGekoppeid  = Request.Form("Gekoppeid")
    itemGekoppelde  = Request.Form("Gekoppelde")
    itemAlgemene   = Request.Form("Algemene")
    'arrSession = Array("Vrijgave=true","Stuklijst=>false","Gekoppeid=>false","Gekoppelde=>false")
    sessionValue = ""
    DistributeXml = "<Distributie><Opties>"
    
    DistributeXml = DistributeXml & "<Vrijgave>"
    IF itemVrij = "on" Then
     sessionValue = "Vrijgave True"
     DistributeXml = DistributeXml & "True"
    Else 
     sessionValue = "Vrijgave False"
     DistributeXml = DistributeXml & "False"
    End IF
    DistributeXml = DistributeXml & "</Vrijgave>"
    sessionValue = sessionValue & ","
    
    DistributeXml = DistributeXml & "<Stuklijst>"
    IF itemStuk = "on" Then
     'session("stuklijstsession") = "Stuklijst"
     sessionValue = sessionValue & "Stuklijst True"
          DistributeXml = DistributeXml & "True"
    Else  sessionValue = sessionValue & "Stuklijst False" 
         DistributeXml = DistributeXml & "False"
    End IF
    DistributeXml = DistributeXml & "</Stuklijst>"
    
    sessionValue = sessionValue & ","
     DistributeXml = DistributeXml & "<Gekoppeid>"
    IF itemGekoppeid = "on" Then
      DistributeXml = DistributeXml & "True"
     sessionValue = sessionValue & "Gekoppeid True"
    Else  sessionValue = sessionValue & "Gekoppeid False" 
    DistributeXml = DistributeXml & "False"
    End IF
     DistributeXml = DistributeXml & "</Gekoppeid>"
    sessionValue = sessionValue & ","
    
    DistributeXml = DistributeXml & "<Gekoppelde>"
    IF itemGekoppelde = "on" Then
     DistributeXml = DistributeXml & "True"
     sessionValue = sessionValue & "Gekoppelde True"
    Else sessionValue = sessionValue & "Gekoppelde False" 
    DistributeXml = DistributeXml & "False"
    End IF    
    DistributeXml = DistributeXml & "</Gekoppelde>"
    sessionValue = sessionValue & ","
    
    DistributeXml = DistributeXml & "<Algemene>"
    IF itemAlgemene = "on" Then
     DistributeXml = DistributeXml & "True"
     sessionValue = sessionValue & "Algemene True"
    Else sessionValue = sessionValue & "Algemene False" 
    DistributeXml = DistributeXml & "False"
    End IF    
    DistributeXml = DistributeXml & "</Algemene></Opties>"
    
    
    'Response.Write("<script>alert('"&sessionValue&"')</script>")
    session("distibute_1_5") = sessionValue
    session("distribute_xml") = DistributeXml
    Response.Redirect("Distributie_2_5.asp")
  End IF 
Else
   Dim FirstValues
  
   FirstValues = Split(session("distibute_1_5"),",")
   IF InStr(FirstValues(0),"True") > 0 Then
     First = "checked"
   Else 
     First = ""
   End IF
   
   IF InStr(FirstValues(1),"True") > 0 Then
     Second = "checked"
   End IF
   
   IF InStr(FirstValues(2),"True") > 0 Then
     Third = "checked"
   Else   
     Third = ""
   End IF
   
   IF InStr(FirstValues(3),"True") > 0 Then
     Fourth = "checked"
   Else  
     Fourth = "" 
   End IF
   IF InStr(FirstValues(4),"True") > 0 Then
     Fith = "checked"
   Else  
     Fith = "" 
   End IF
  
End IF         
    
Function appendComma(sessionValue)
   IF Len(sessionValue) <> "" Then
      sessionValue = sessionValue & ","
   End IF
   appendComma = sessionValue
End Function
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
     
      function submit_1_5()
      { 
      
       var itemArticle = getElementAttrib("Vrijgave", "checked");
	   var itemVersion  = getElementAttrib("Stuklijst", "checked");
	   var itemOmschrijving = getElementAttrib("Gekoppeid", "checked");
	   var fileName = getElementAttrib("Gekoppelde", "checked");        
       var errMsg   = "";
	
	    //*** Now check form data.
	    errMsg += (itemArticle == true) ? "  - Artikelnummer\n" : "";
	    errMsg += (itemOmschrijving == true) ? " - Omschrijving\n" : "";
	    errMsg += (itemVersion == true)  ? "  - Revisie\n"       : "";
	    errMsg += (fileName == true) ? "  - Bestand\n"       : "";
        
        if (errMsg == "")
        alert('select at least one item')
        else document.ItemForm.submit();
        
      }


    </script>
</head>
<body class="BodyStyle">
    
    <form name="ItemForm" action="Distributie_1_5.asp"  method="POST">
     <div style="position:absolute; width: 520px; height: 316px; font-family:Arial;" id="DIV1">                  
       <table >
        <tr><td style="height: 57px">
           <b>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
               &nbsp;&nbsp; Distributie Wizard - <%=Session(BasketName) %></b><br />
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;
               Distributie(1/5)

        </td></tr>
        <tr><td>
          <fieldset  style="width: 510px; height: 210px">
            <legend>Te distribueren informatie:</legend>
            <table>
                <tr><td style="width: 50px"></td><td style="width: 23px"></td><td></td><td></td></tr>
                <tr><td style="width: 50px; height: 28px"></td><td style="height: 28px; width: 23px;"><input name="Vrijgave" type="checkbox" <%=First %> /></td><td style="height: 28px">Vrijgave afdruk(dwf/pdf)</td><td style="height: 28px"></td></tr>
                <tr><td style="width: 50px; height: 28px"></td><td style="height: 28px; width: 23px;"><input name="Stuklijst" type="checkbox" <%=Second %> /></td><td style="height: 28px">Stuklijst</td><td style="height: 28px"></td></tr>
                <tr><td style="width: 50px; height: 26px"></td><td style="height: 26px; width: 23px;"><input name="Gekoppeid" type="checkbox" <%=Third %>/></td><td style="height: 26px">Aanwezig bron document</td><td style="height: 26px"></td></tr>
                <tr><td style="width: 50px; height: 30px"></td><td style="height: 30px; width: 23px;"><input name="Gekoppelde" type="checkbox" <%=Fourth %>/></td><td style="height: 30px">Aanwezig bijlagen</td><td style="height: 30px"></td></tr>
                <tr><td style="width: 50px; height: 30px"></td><td style="height: 30px; width: 23px;"><input name="Algemene" type="checkbox" <%=Fith %>/></td><td style="height: 30px">Algemene bijlagen</td><td style="height: 30px"></td></tr>
                <tr><td style="width: 50px"></td><td style="width: 23px"></td><td></td><td></td></tr>
            </table>
          </fieldset>
        </td></tr>
        <tr><td align='right' style="height: 22px">
            <input id="Button1" style="background-color: #E6E6E6;width: 121px" type="button" value="Volgende" onclick="submit_1_5();" />
           
            </td></tr>            
            
       </table>
     </div>
        
    </form>
</body>
</html>