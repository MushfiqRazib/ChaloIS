<!-- #include file="./basket/functions.asp" -->

<html>
<head>
<link href="./Attachment/styles/datagrid.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="./Attachment/script/common.js"></script>

<script src="Attachment/script/common.js" type="text/javascript"></script>

    <script>
     function submit()
     {
       document.reportForm.submit();
     }
    
  </script>
</head>

<%
Dim normalDoc,stuklijstDoc  
If Split(session("print_1_5"),",")(0)="Vrijgave" Then
    normalDoc = "True"
Else
    normalDoc = "False"    
End If


 %>

 <body class='BodyStyle' onload="loadProgressBar('progressGrid','Printing');submit();">
   <form name="reportForm" action="StuklijstWriter.aspx" method="post">
      <input type=hidden name=firstPage value=<%=session("Print_1_5")%>/>
	  <input type="hidden" name="tprintnumber" value='<%=Session("TotalprintNumber")%>'/>
      <input type=hidden name=secondPage value=<%=Replace(Session("GridIndexSelected")," ","*")%>/>
      <input type=hidden name=thirdPage value=<%=Replace(Session("opmarking")," ","*")%>/>
      <input name="basketName" type="hidden" value='<%=Session(BasketName)%>' />
      <input name="basketPath" type="hidden" value='<%=BASKET_OUTPUT%>' /> 
      <input name="formatPrinter" type="hidden" value='<%=Session("formatPrinterString")%>' />
      <input name="koblad" type="hidden" value='<%=Session("koblad_on")%>' />
      <input name="constring" type="hidden" value='<%= DB_CONNSTRING %>' />
      <input name="printingdir" type="hidden" value='<%= Session("printingdir")%>' />
      <input name="normaldoc" type="hidden" value='<%= normalDoc%>' />
      <input name="printpagereport" type="hidden" value='yes' />
      <input name="rcORva" type="hidden" value="<%=Session(whichBasket) %>" />
      <input name="sid" type="hidden" value="<%=Session("sid") %>" />
      <input name="kitServerPath" type="hidden" value="<%=Session("kitServerPath") %>" />
      <input name="tablename" type="hidden" value="<%=Session("relfiletable") %>" />
      <input name="keyfields" type="hidden" value="<%=Session("keyfields") %>" />
      <div id="progressGrid"></div>
            
      
       <%
       Dim myString,opmerking
       myString = ""
       opmerking = ""
       IF Session("GridIndexSelected") <> "" Then
          myString = getIndexSetRowValues(Session("GridIndexSelected"))
          myString = Replace(myString,"\","|")
       End IF
       
       IF Session("koblad_on") <> "" Then
        opmerking = Session("opmarking") 
       End IF  	 
      
      
      %>
      <input type=hidden id="rows" name=rows value=<%=Replace(myString," ","*")%>/> 
      <input type=hidden id="opmerking" name=opmerking value=<%=Replace(opmerking," ","@**@")%>/> 
   </form> 
 </body>
</html>
