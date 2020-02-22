<!-- #include file="../Basket/functions.asp" -->
<%
  Dim article_version,xtmlString,formatArray,basketInfo,GridIndicesSelected    
  Dim i,k,printableNumber, appendices
  Dim  stuklijstSession, appendicesinfo,appendix,appendixnumber
  Dim formatPrinter,fp, article_path, path, selectedSession,stuklistPrintNumber,stuklistNumber,printNumber
  Dim myFormt,myStr,rows_,k_,article_version_,getFormatPrinter,ch,kopbladNumber,vrijgaveNumber,selectedCategories
  Dim printerArray,stuklijstForamt,formatPrinterString,articlePcpies,selectedStuklijst
  
  '*** save the printing directory
  Session("printingdir") =  BASKET_OUTPUT & "Printing" & getTimeStamp()
 
  selectedCategories = Split(Session("Print_1_5"),",")
  stuklijstSession = Split(Session("stuklijstSession"),",") 
  
  If Session(BasketSession) <> "" Then
  If Request("frombasket")="true" Then 'straight printting
	
		printableNumber = 1  'Bijlagen Number
		stuklistNumber = 0
		printNumber = 0
		
		If Session("stuklistPrintNumber")<>"" Then
			stuklistPrintNumber= Split(Session("stuklistPrintNumber"),"@")
			stuklistNumber = stuklistPrintNumber(0)
			printNumber    = stuklistPrintNumber(1)
			Session("TotalprintNumber") = printNumber 'Total number the Bijlagen to be printted
		End If

		basketInfo = split(Session(BasketSession),"****")
		vrijgaveNumber = UBound(basketInfo)+1
		
		Session("Print_1_5") = "Vrijgave,Bijlagen,Stuklijst"
		
		'By default koblad should be off
		Session("koblad_on") = ""		
		kopbladNumber  = 0
		
		Session("opmarking") = ""
		
		selectedCategories = Split(Session("Print_1_5"),",")
		
		FOR i=0 to UBound(basketInfo)
			GridIndicesSelected = GridIndicesSelected & i & "@@" & "1" & ","
		NEXT
		
		If GridIndicesSelected<>"" Then
			GridIndicesSelected = Left(GridIndicesSelected,Len(GridIndicesSelected)-1)
			Session("GridIndexSelected") = GridIndicesSelected
			articlePcpies = Split(Session("GridIndexSelected"),",")
			formatArray = getDistinctFormat()
		
		On Error Resume Next
		For k=0 to UBound(formatArray)
			printerArray =  getPrinters(formatArray(k))
			formatPrinterString = formatPrinterString & formatArray(k)&"@"&printerArray(0)&"*"
		    
		NEXT
		formatPrinterString = Left(formatPrinterString,Len(formatPrinterString)-1)
		Session("formatPrinterString") = formatPrinterString
		End If
	
  Else
	
	articlePcpies = Split(Session("GridIndexSelected"),",")
	
	kopbladNumber = 0
	vrijgaveNumber = 0
	stuklistNumber = 0
	printNumber = 0
	
	Session("TotalprintNumber") = 0
	
	printNumberSession = Split(Session("printNumberSession"),",") 
	stuklijstNumberSession = Split(Session("stuklijstNumberSession"),",") 
	
	IF Session("koblad_on") <> ""  Then
		kopbladNumber = Session("kopbladNumber")
	End If
	
	If(selectedCategories(0)="Vrijgave") Then
		vrijgaveNumber = UBound(articlePcpies)+1
	End If
	
	If(selectedCategories(2)="Stuklijst") Then ' Determine the stuklijst number 
		FOR k = 0 To Ubound(articlePcpies)
			appendixnumber =  Split(articlePcpies(k),"@@")
			
			If stuklijstSession(appendixnumber(0))="True" Then
				stuklistNumber = stuklistNumber + stuklijstNumberSession(appendixnumber(0))
			End If
		Next
		
	End If
	
	If(selectedCategories(1)="Bijlagen") Then ' Determine the Bijlagen number
		FOR k = 0 To Ubound(articlePcpies)
			appendixnumber =  Split(articlePcpies(k),"@@")
			printNumber = printNumber + printNumberSession(appendixnumber(0))
		Next
		Session("TotalprintNumber") = printNumber
	End If
	
  End If
  End If
  
  If Request("frombasket")="true" OR Request("frombasket")="false" Then
  
 
  xtmlString = "<?xml version='1.0' encoding='UTF-8' ?>"& vbcrlf &"<jobfile>"
  
  IF Session("koblad_on") <> ""  Then
	IF Session("formatPrinterString") <> "" Then
		formatPrinter = Split(Session("formatPrinterString"),"*")
		fp = Split(formatPrinter(UBound(formatPrinter)),"@")         
		 
		xtmlString = xtmlString & vbcrlf & "  <Job>"
		xtmlString = xtmlString & vbcrlf & "    <Type>Kopblad</Type>"
		xtmlString = xtmlString & vbcrlf & "    <JobType>PRINTING</JobType>"
		xtmlString = xtmlString & vbcrlf & "    <ProcessWorkingDirectory>"&PROSSESWORKINGDIRECTORY&"</ProcessWorkingDirectory>"
		xtmlString = xtmlString & vbcrlf & "    <WaitingTime>" &WAITINGTIME& "</WaitingTime>"
		xtmlString = xtmlString & vbcrlf & "    <File>" & Session("printingdir") & "\" & "kopblad.pdf</File>"
		xtmlString = xtmlString & vbcrlf & "    <printername>" & fp(1)& "</printername>"
		xtmlString = xtmlString & vbcrlf & "    <paperformat>" & Session("stuk_kop") & "</paperformat>"
		xtmlString = xtmlString & vbcrlf & "    <NumofPrintcopy>" & kopbladNumber & "</NumofPrintcopy>"
		xtmlString = xtmlString & vbcrlf & "  </Job>"
		xtmlString = xtmlString & vbcrlf
	End IF
  End If
  
  IF Session("GridIndexSelected") <> "" Then
	myStr = getIndexSetRowValues(Session("GridIndexSelected"))
    
	rows_ = Split(myStr,",")
	
	For k_=0 to UBound(rows_)
		article_version_ = Split(rows_(k_),"@@@@") 
		If(selectedCategories(2)="Stuklijst") Then
			selectedStuklijst = Split(articlePcpies(k_),"@@")
			printableNumber = selectedStuklijst(1)
			
			if(stuklijstSession(selectedStuklijst(0))="True") Then	
				
				formatPrinter = Split(Session("formatPrinterString"),"*")                  
				fp = Split(formatPrinter(UBound(formatPrinter)),"@") 
				
				 xtmlString = xtmlString & vbcrlf & " <Job>"
				 xtmlString = xtmlString & vbcrlf & "    <Type>"&"Stuklijst"&"</Type>"
				 xtmlString = xtmlString & vbcrlf & "    <JobType>PRINTING</JobType>"
				 xtmlString = xtmlString & vbcrlf & "    <ProcessWorkingDirectory>"&PROSSESWORKINGDIRECTORY&"</ProcessWorkingDirectory>"
				 xtmlString = xtmlString & vbcrlf & "    <WaitingTime>" &WAITINGTIME& "</WaitingTime>"
				 xtmlString = xtmlString & vbcrlf & "    <File>" & Session("printingdir") & "\" & article_version_(0)& article_version_(1)&"_stk.pdf</File>"
				 xtmlString = xtmlString & vbcrlf & "    <printername>" & fp(1) & "</printername>"
				 xtmlString = xtmlString & vbcrlf & "    <paperformat>" & Session("stuk_kop") & "</paperformat>" 
				 xtmlString = xtmlString & vbcrlf & "    <NumofPrintcopy>" & printableNumber & "</NumofPrintcopy>"
				 xtmlString = xtmlString & vbcrlf & " </Job>"
				 xtmlString = xtmlString & vbcrlf
			End IF
		End If
		
		If(selectedCategories(0)="Vrijgave") Then
		
			printableNumber = Split(articlePcpies(k_),"@@")(1)
		
			xtmlString = xtmlString & vbcrlf & "  <Job>"
			'article_version = Split(rows_(k_),"@@@@")
     
			xtmlString = xtmlString & vbcrlf & "    <Type>Normal</Type>"
			xtmlString = xtmlString & vbcrlf & "    <JobType>PRINTING</JobType>"
			xtmlString = xtmlString & vbcrlf & "    <ProcessWorkingDirectory>"&PROSSESWORKINGDIRECTORY&"</ProcessWorkingDirectory>"
			xtmlString = xtmlString & vbcrlf & "    <WaitingTime>" &WAITINGTIME& "</WaitingTime>"
            
            
            
			article_version_ = Split(rows_(k_),"@@@@")
			ch = checkFormatExist(article_version_(2))
			 IF article_version_(2) = "" or ch = 0 Then
			  myFormt = "unknown"
			 Else 
			  myFormt = article_version_(2)
			 End IF
			 getFormatPrinter = getPrinterForOneFormat(myFormt)			  
			
			 xtmlString = xtmlString & vbcrlf & "    <File>" & DocBasePath &  Replace(article_version_(3),"@","\") & article_version_(4) & "</File>"
			 xtmlString = xtmlString & vbcrlf & "    <printername>" & getFormatPrinter& "</printername>"
			 xtmlString = xtmlString & vbcrlf & "    <paperformat>" & myFormt& "</paperformat>"
			 xtmlString = xtmlString & vbcrlf & "    <NumofPrintcopy>" & printableNumber & "</NumofPrintcopy>"
			 
			 xtmlString = xtmlString & vbcrlf & "  </Job>"
		End If
		
		If(selectedCategories(1)="Bijlagen") Then
			printableNumber = Split(articlePcpies(k_),"@@")(1)
			'article_version_ = Split(rows_(k_),"@@@@") 
			appendicesinfo = GetAppendicesInfo(article_version_(0),article_version_(1)) ' Get the appendice for a provided article
			
			'Following line is commented by Naym
			'article_path = Split(article_version_(3),article_version_(0)) ' Getting path for appendices
			
			'Following line is commented by Naym
		    path = article_version_(3) 'Replace(article_path(0),"@","\")
			
			
			    
			If appendicesinfo <>"" Then
				appendices = Split(appendicesinfo,"@")
				
		    
				For i = 0 to UBound(appendices)
					appendix = Split(appendices(i),"*") ' Get an appendix
					
					printerArray =  getPrinters(appendix(1))
					
					xtmlString = xtmlString & vbcrlf & " <Job>"
					xtmlString = xtmlString & vbcrlf & "    <Type>"&"Bijlagen"&"</Type>"
					xtmlString = xtmlString & vbcrlf & "    <JobType>PRINTING</JobType>"
					xtmlString = xtmlString & vbcrlf & "    <ProcessWorkingDirectory>"&PROSSESWORKINGDIRECTORY&"</ProcessWorkingDirectory>"
					xtmlString = xtmlString & vbcrlf & "    <WaitingTime>" &WAITINGTIME& "</WaitingTime>"
					xtmlString = xtmlString & vbcrlf & "    <File>"  & DocBasePath   & path & appendix(0)&"</File>"
					xtmlString = xtmlString & vbcrlf & "    <printername>" & printerArray(0) & "</printername>"
					xtmlString = xtmlString & vbcrlf & "    <paperformat>" & appendix(1) & "</paperformat>" 
					xtmlString = xtmlString & vbcrlf & "    <NumofPrintcopy>" & printableNumber & "</NumofPrintcopy>"
					xtmlString = xtmlString & vbcrlf & " </Job>"
					xtmlString = xtmlString & vbcrlf
				NEXT
				
			End If
		End If
		
	Next
	
  End If
 
  xtmlString = xtmlString &vbcrlf & "</jobfile>"
  Session("printXML") = xtmlString
  
  End If

Function getPrinterForOneFormat(frmt)
  Dim printerForFormt,h,splitPF,retVal
  printerForFormt = Split(Session("formatPrinterString"),"*")
  For h=0 to UBound(printerForFormt)
   splitPF = split(printerForFormt(h),"@")
   IF Lcase(trim(frmt)) = Lcase(trim(splitPF(0))) Then
     retVal = splitPF(1)
     Exit For
   End IF
  Next
  getPrinterForOneFormat = retVal
End Function
   
Function checkFormatExist(frmt)
  Dim allmyFormats,t,retVal
  retVal = 0
  allmyFormats = getFormat()
  For t=0 to UBound(allmyFormats)
   IF frmt = allmyFormats(t) Then
     retVal = 1
     Exit For
   End IF 
  Next
  checkFormatExist = retVal
End Function
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>  
<head id="Head1" runat="server">
     <title>Print Wizard</title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
    <link href="../../styles/datagrid.css" rel="stylesheet" type="text/css" />

    <script src="../../Scripts/Common.js" type="text/javascript"></script>
    <script src="../Basket/script/basket.js" type="text/javascript"></script>
    <script src="../Attachment/script/common.js" type="text/javascript"></script>
    <script src="../Attachment/script/sarissa.js" type="text/javascript"></script>
    <script src="../Attachment/script/window.js" type="text/javascript"></script>

   

    <script>
		
		function Back()
		{
			var url = "Print_4_5.asp";
			location.href = url;
		} 
		
		function loadGeavanceerd(){
			//var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
			//openChild("Print_1_5.asp?fromadvance=true", "Printen", true, 500, 350, "no", "no");     
			//self.close();
		    window.location = "Print_1_5.asp?fromadvance=true";
		} 
	</script>
</head>
<body class="BodyStyle"> 

    <form name="ItemForm" action='Print_5_5.asp' enctype="application/x-www-form-urlencoded" method="POST">
     <div style="position:absolute; width: 479px; height: 316px;" id="DIV1">
       <table style = "width:100%;">
        <tr align='center'><td style="height: 57px">
           <b>
               Print Wizard - <%=Session(BasketName) %></b><br />
			   <%If Request("frombasket")<>"true" Then%>
				<b>5/5</b>
			   <%End If%>
        </td></tr>
        <tr  valign="top" style = "width:100%;"class="FontProperty">
			<td style="padding-left:20px;">
				Opties->Te Printen
			</td>
		</tr>
		<tr valign="top" class="FontProperty" >
			<td style="padding-left:20px;">
				Kopblad: <%=kopbladNumber%>
			</td>
		</tr>
		<tr valign="top" class="FontProperty">
			<td style="padding-left:20px;">
				Vrijgave: <%=vrijgaveNumber%>
			</td>
		</tr>
		<tr valign="top" class="FontProperty" >
			<td style="padding-left:20px;">
				Stuklijst : <%=stuklistNumber%>
			</td>
		</tr>
		<tr valign="top" style="height:120px;" class="FontProperty" >
			<td style="padding-left:20px;">
				Bijlagen : <%=printNumber%>
			</td>
		</tr>
        <tr>
		<td align='left' style="height: 22px;" >
		<%If Request("frombasket")<>"true" Then%>
			 <input id="Button2" style="width: 121px" type="button" value="Vorige" onclick="javascript:history.go(-1)" />
		<%Else%>
			<input id="Button2" style="width: 121px" type="button" value="Geavanceerd" onclick="loadGeavanceerd()" />
		<%End If%>
            
            <span style="width:200px;"></span><input id="Button1" style="width: 121px" type="button" value="Printen" onclick='SavePrintXML("Type a File Name")' /></td></tr>
       </table>
     </div>
    </form>
</body>

</html>