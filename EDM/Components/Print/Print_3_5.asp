<!-- #include file="../Basket/functions.asp" -->

<%
   Dim arrNumber,arrSession,flag,printCopies
   
   'Response.Write Session("GridRowNumber")
   
   IF Request.Form.Count <> 0  Then
     IF Session("GridRowNumber")>=0 Or session("stuklijstsession")<> "" Then
        
        IF Session("GridRowNumber")>=0 Then
         flag=0
         For i=0 to Session("GridRowNumber")
		  printCopies = Trim(Request.Form("txtBx_"&i))
          arrSession = Request.Form("chkBx_"&i)
          IF arrSession = "on" Then
           arrNumber = arrNumber  &i &"@@"&printCopies&"," 
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
        
        
        Response.Redirect("Print_4_5.asp")
     End IF    
           
   End IF
   
%> 



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>  
<head id="Head1" runat="server">
    <title>Print Wizard</title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
    
    <script type="text/javascript" src="../Attachment/script/common.js"></script>
    <script type="text/javascript" src="../Attachment/script/sarissa.js"></script>
    <script type="text/javascript" src="../Attachment/script/window.js"></script>    
    <link href="../../styles/datagrid.css" rel="stylesheet" type="text/css" />
    
  <script language="javascript">
      
      function submit_3_5()
      { 
       document.ItemForm.submit();
      }
      
	  function Back()
      {
        var url = "Print_2_5.asp?back=true";
        location.href = url;
      } 
     

    </script>
</head>
<body  class='BodyStyle'>
    <form name="ItemForm" action='Print_3_5.asp' method="POST">
     <div style="position:absolute;width: 479px; height: 316px;" id="DIV1" class='BodyStyle'>
       <table>
        <tr align='center'><td style="height: 57px">
           <b>
               Print Wizard - <%=Session(BasketName) %></b><br />
            <b>3/5</b>

        </td></tr>
        <tr><td style="height: 207px">
          <fieldset  style="width: 468px; height: 210px">
            <legend>Overzicht te distribueren documenten:</legend>
            <div id="myGrid" style="overflow:auto;height:167px; width: 98%;">
               <%= CreatePrintenDataGrid("myGrid")%>  
            </div>
            
          </fieldset>
        </td></tr>
        <tr><td align='right' style="height: 22px">
            <input id="Button2" style="width: 121px" type="button" value="Vorige" onclick="javascript:history.go(-1)" />
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
            &nbsp; &nbsp; &nbsp; &nbsp;<input id="Button1" style="width: 121px" type="button" value="Volgende" onclick="submit_3_5()" /></td></tr>
       </table>
       <input type=text name="tt" value="ee" style="display:none"/>
     </div>
    </form>
</body>
</html>