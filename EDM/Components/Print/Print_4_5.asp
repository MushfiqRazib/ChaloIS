<!-- #include file="../Basket/functions.asp" -->


<%
    Dim i,k,kk, formatArray,printerArray,allFormats,all,unknownFormat,stuklijstForamt    
    formatArray = getDistinctFormat() 
    allFormats  = getFormat()
    unknownFormat = getFormat4UnknownOrStuklijst("unknown")
    stuklijstForamt = getFormat4UnknownOrStuklijst("stuk")
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>  
<head id="Head1" runat="server">
    <title>Print Wizard</title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">

    <script src="../Attachment/script/common.js" type="text/javascript"></script>

    <script src="../Attachment/script/sarissa.js" type="text/javascript"></script>

    <script src="../Attachment/script/window.js" type="text/javascript"></script>

    <script src="../Basket/script/basket.js" type="text/javascript"></script>

    <link href="../../styles/datagrid.css" rel="stylesheet" type="text/css" />
 
  <script language="javascript">
      
      function submit_4_5()
      { 
         if(createFormatPrinterString())
         document.ItemForm.submit();
      }
	   
	  function Back()
		{
			var url = "Print_3_5.asp";
			location.href = url;
		} 
	   
      function ChangePrinters(obj)
      { 
        sendformatgetprinter(obj.getElementsByTagName('option')[obj.selectedIndex].text,obj);
      }
    </script>
</head>
<body class='BodyStyle' >
    <form name="ItemForm" action='Print_5_5.asp?frombasket=false' method="POST">
    <div style="position:absolute; width: 479px; height: 316px;" id="DIV1">
       <table cellspacing='0' cellpadding='0' class='Datagrid'>
        <tr align='center'><td style="height: 57px; width: 474px;">
           <b>Print Wizard - <%=Session(BasketName) %></b><br />           
            <b>4/5</b>
        </td></tr>
        <tr><td style="width: 474px">
          <fieldset  style="width: 468px; height: 210px">
            <legend>Printers Definieren:</legend>
            <div id="GridSpecific" style="overflow:auto;height:192px; width: 98%;">
			<table>
			<thead>
			<TR>
			<th class= "ScrollGridSpecific" style="text-align: center; width: 100px;cursor: default" nowrap>Doc Form.</th>
			<th class= "ScrollGridSpecific" style="text-align: center; width: 100px;cursor: default" nowrap>Print Form.</th>
			<th class= "ScrollGridSpecific" style="text-align: center; width: 200px;cursor: default" nowrap>Printer</th>
			</TR>
			</thead>
	    <%  
			  '*** For selected documents
			 For k=0 to UBound(formatArray)  %>
			  <tr>
			  
			  
                <td name="format_<%=k %>" id="format_<%=k %>" style=" padding-left:10px;"><%= formatArray(k) %></td>
				
				<td align="center">
		         <select  name="drpFormatList_<%=k %>" style="width:100px; height:40px; size:4; " onchange="ChangePrinters(this)">
		          <% Dim unknown
		             unknown = "unknown"
		             For i=0 to UBound(allFormats)
		               IF Trim(allFormats(i)) = Trim(formatArray(k)) Then%>
		                 <option selected><%=allFormats(i)%></option>
		                <%Elseif  LCase((formatArray(k))) = unknown and Trim(allFormats(i)) = Trim(unknownFormat(1))Then %>
		                 <option selected><%=allFormats(i)%></option>
		                 <%Else 
		                    IF allFormats(i)<>"" Then%>
		                 <option ><%=allFormats(i)%></option> 
		                <%
		                    End IF
		                End IF 
		            Next%>
		         </select>
		        </td>
				
				<td align="center">
		         <select id="drpPrinterList_<%=k %>"  name="drpPrinterList_<%=k %>" style="width:200px; height:40px; size:4;">
		          <% 
		             printerArray =  getPrinters(formatArray(k))
		             For i=0 to UBound(printerArray)%>
		                 <option ><%=printerArray(i)%></option>
		             <%Next%>
		         </select>
		        </td>
              </tr>
        <%  Next
            
            '*** For kopblad or stuklijst              
              If UBound(Split(Session("Print_1_5"),"Stuklijst"))>0 OR Session("koblad_on")<>""  Then
              %>
              
			  <tr>
                <td id="format_<%=k %>" style=" padding-left:10px;">kopblad/stuklijst</td>
                <td align="center">
		         <select name="drpFormatList_<%=k %>" style="width:100px; height:40px; size:4;" onchange="ChangePrinters(this)">
		          <% 
		             For i=0 to UBound(allFormats)
		             IF Trim(allFormats(i)) = Trim(stuklijstForamt(1)) Then%>
		                 <option selected><%=allFormats(i)%></option>
		              <%Else
		                    IF allFormats(i)<>"" Then %>    
		                 <option ><%=allFormats(i)%></option>
		              <%
		                     End IF
		              End IF
		          Next%>
		         </select>
		        </td>
				<td align="center">
		         <select id="drpPrinterList_<%=k %>"   name="drpPrinterList_<%=k %>" style="width:200px; height:40px; size:4;">
		          <% kk = k
		             printerArray = getPrinters("stuk_kop")
		             For i=0 to UBound(printerArray)%>
		                 <option ><%=printerArray(i)%></option>
		             <%Next%>
		         </select>
		         
		        </td>
              </tr>
              <%
               End If
               %>
			  
			  
			</table>   
          </div>
          </fieldset>
        </td></tr>
        <tr><td align='right' style="height: 22px; width: 474px;">
           <%IF k = kk Then %>
           <input type=text id="countRow" name=countRow value=<%=k%> style="display:none"/>
           <%Else k=k-1%>
           <input type=text id="countRow" name=countRow value=<%=k%> style="display:none"/>
           <%End IF %>
            <input id="Button2" style="width:121px" type="button" value="Vorige" onclick="javascript:history.go(-1)" />
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
            &nbsp; &nbsp; &nbsp; &nbsp;<input id="Button3" style="width: 121px" type="button" value="Volgende" onclick="submit_4_5()" /></td></tr>
	   </table>
     </div>
    </form>
</body>
</html>