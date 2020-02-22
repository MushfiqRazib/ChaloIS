<!-- #include file="./basket/functions.asp" -->

<html>
<head>
<link href="./Attachment/styles/datagrid.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="./Attachment/script/common.js"></script>
  <script>
     function submit()
     {
       document.reportForm.submit();
     }
  </script>
</head>

<%
Dim normalDoc,printNomalDoc,stuklijst 
printNomalDoc =  Split(session("distibute_1_5"),",")
If lcase(trim(split(printNomalDoc(0))(1))) = "true" Then
    normalDoc = "True"
Else
    normalDoc = "False"    
End If

If lcase(trim(split(printNomalDoc(1))(1))) = "true" Then
    stuklijst = "True"
Else
    stuklijst = "False"    
End If

 %>

 <body class='BodyStyle' onload="loadProgressBar('progressGrid','Distributing');submit()">
   <form name="reportForm" action="StuklijstWriter.aspx" method="post">     
      
      <input name="printingdir" type="hidden" value='<%=DISTRIBUTION_DIR &  Session("DistOutputDirectory") %>' />
      
      <input type=hidden name=secondPage value=<%=Replace(Session("GridIndexSelected")," ","*")%>/>
      <input type=hidden name=firstPage value=<%=stuklijst%>/>
      <input type=hidden name=thirdPage value=<%=Replace(Session("opmarking")," ","*")%>/>
      <input name="koblad" type="hidden" value='<%=Session("koblad_on")%>' />
      <input name="constring" type="hidden" value=' <%= DB_CONNSTRING%>' />
      <input name="normaldoc" type="hidden" value=' <%= normalDoc %>' />
      <input name="basketPath" type="hidden" value='<%=BASKET_OUTPUT  %>' />
      <input name="basketName" type="hidden" value='<%=Session(BasketName)%>' />
       <input name="tablename" type="hidden" value="<%=Session("relfiletable") %>" />
      <input name="keyfields" type="hidden" value="<%=Session("keyfields") %>" />
      <input name="distributepagereport" type="hidden" value='yes' />
      <input name="rcORva" type="hidden" value="<%=Session(whichBasket) %>" />
      <input name="sid" type="hidden" value="<%=Session("sid") %>" />
      
      <div id="progressGrid"></div>
       <%
           Dim myString,opmerking
           myString = ""
           opmerking = ""
           IF Session("GridIndexSelected") <> "" Then
           myString = getIndexSetRowValues(Session("GridIndexSelected"))
           End IF
           
           IF Session("koblad_on") <> "" Then
            opmerking = Session("opmarking") 
           End IF  	 
      %>
      <input type=hidden name=rows value=<%=Replace(myString," ","*")%>/> 
      <input type=hidden name=opmerking value=<%=Replace(opmerking," ","@**@")%>/> 
   </form> 
 </body>
</html>
