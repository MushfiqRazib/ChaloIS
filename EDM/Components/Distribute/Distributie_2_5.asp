<!-- #include file="./../basket/functions.asp" -->

<%
   Dim arrNumber,arrSession
                   
   IF Request.Form.Count <> 0 Then
     IF Session("GridRowNumber")>=0  Then
      
        IF Session("GridRowNumber")>= 0 Then
         For i=0 to Session("GridRowNumber") 
         arrSession = Request.Form("chkBx_"&i)
         IF arrSession = "on" Then
           arrNumber = arrNumber  &i  &"@@"&"1"&","   
           flag=1  
          End IF
         Next
                           
         IF flag=1 Then
          arrNumber = Left(arrNumber,Len(arrNumber)-1)
          
         End If
          
          Session("GridIndexSelected") = arrNumber
          
        Else 
         Session("GridIndexSelected")="" 
        End IF
        
        Response.Redirect("Distributie_3_5.asp")
    End IF      
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
         
      function Back()
      {
        var url = "Distributie_1_5.asp?back=true";        
        location.href = url; 
      }
      
      
      function submit_2_5()
      { 
       document.ItemForm.submit();
      }

    </script>
    
</head>
<body class="BodyStyle">
    <form name="ItemForm" action='Distributie_2_5.asp' method="POST">
     <div style="position:absolute;  width: 520px; height: 316px;background-color:#E6E6E6; font-family:Arial;" id="DIV1" >
       <table>
        <tr><td style="height: 57px">
           <b>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
               &nbsp;&nbsp; Distributie Wizard - <%=Session(BasketName) %></b><br />
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; Distributie(2/5)

        </td></tr>
        <tr><td>
          <fieldset  style="width: 510px; height: 210px;">
            <legend>Overzicht te distribueren documenten:</legend>
            <div id="myGrid" style="overflow:auto;height:167px; width: 100%;">
               <%=CreateDistributeDataGrid("myGrid")%>  
            </div>
            
          </fieldset>
        </td></tr>
        <tr><td align='left' style="height: 22px">
            <input id="Button2" style="background-color: #E6E6E6;width: 121px" type="button" value="Vorige" onclick="javascript:Back()" />
            <span style="width:265px"></span><input id="Button1" style="background-color: #E6E6E6;width: 121px" type="button" value="Volgende" onclick="submit_2_5()" /></td></tr>
       </table>
       <input type=text name="tt" value="ee" style="display:none"/>
     </div>
    </form>
</body>
</html>