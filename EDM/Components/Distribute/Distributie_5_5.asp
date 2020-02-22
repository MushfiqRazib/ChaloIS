<!-- #include file="./../basket/functions.asp" -->

<%
   Dim textBoxValue,myString,rows,article_version,chkDist1Stat,xtmlString,formatArray    
   Dim arrArtVer,article,printer,i,j,k,attachCounter,formats,temptextBoxValue
   Dim flag,temxtmlString, fileName, srcFile,tgtFile, relAttachments, DistDir  
   Dim vrijgaveNumber,stuklistNumber,bronDocNumber,anawBijNumber,algbijNumber,basketInfo,bronRevorNonRevNum  
   Dim bronRevorNonRevSession, articlePcpies, stuklijstNumberSession,appendixnumber
   
   If Request("distributename") <> "" Then
       Session(DistributionName) = Request("distributename")
   End If
	
   'Response.Write session("distibute_1_5")
	
   If Request("frombasket")="true" Then
     If Session(BasketSession) <> "" Then
		Session("distibute_1_5") = "Vrijgave True,Stuklijst True,Gekoppeid True,Gekoppelde True,Algemene True"
		vrijgaveNumber = 0
		basketInfo 	   = Split(Session(BasketSession),"****")
		vrijgaveNumber = UBound(basketInfo)+1
		stuklistNumber = 0
		
		If Session("stuklistPrintNumber") <>"" Then
			stuklistNumber = Split(Session("stuklistPrintNumber"),"@")(0)
		End If
		
		bronDocNumber  = 0 
		anawBijNumber  = 0
		algbijNumber   = 0
		
		Session("koblad_on") = "on"
		
		bronRevorNonRevSession = Split(Session("bronRevorNonRevSession"),"@@")
		
		For i=0 to UBound(bronRevorNonRevSession)
			bronRevorNonRevNum = Split(bronRevorNonRevSession(i),",")
			
			If bronRevorNonRevNum(0)="True" Then
				bronDocNumber = bronDocNumber+1 
			End If
			
			anawBijNumber = anawBijNumber + bronRevorNonRevNum(1) + bronRevorNonRevNum(2)
			algbijNumber = algbijNumber + bronRevorNonRevNum(1)
		Next
	 End IF
   Else
        CreateBasketDataGrid("myGrid")
		stuklijstNumberSession = Split(Session("stuklijstNumberSession"),",")
		stuklijstSession = Split(Session("stuklijstSession"),",") 
		vrijgaveNumber = 0
		stuklistNumber = 0
		bronDocNumber  = 0 
		anawBijNumber  = 0
		algbijNumber   = 0
		
		'Response.Write session("distibute_1_5")
		articlePcpies = Split(Session("GridIndexSelected"),",")
		chkDist1Stat = Split(session("distibute_1_5"),",")
		
		If chkDist1Stat(0)="Vrijgave True" Then
			vrijgaveNumber = UBound(articlePcpies)+1
		End If
		
		If chkDist1Stat(1)="Stuklijst True" Then
			FOR k = 0 To Ubound(articlePcpies)
				appendixnumber =  Split(articlePcpies(k),"@@")
				
				If stuklijstSession(appendixnumber(0))="True" Then
					stuklistNumber = stuklistNumber + stuklijstNumberSession(appendixnumber(0))
				End If
			Next
		End If
		
		bronRevorNonRevSession = Split(Session("bronRevorNonRevSession"),"@@")
		
		
		If chkDist1Stat(2)="Gekoppeid True" Then    
			FOR k = 0 To Ubound(articlePcpies)
				appendixnumber =  Split(articlePcpies(k),"@@")
				bronRevorNonRevNum = Split(bronRevorNonRevSession(appendixnumber(0)),",")
				
				If bronRevorNonRevNum(0)="True" Then
					bronDocNumber = bronDocNumber+1 
				End If
			Next
		End If
		
		If chkDist1Stat(3)="Gekoppelde True" Then    
			FOR k = 0 To Ubound(articlePcpies)
				appendixnumber =  Split(articlePcpies(k),"@@")
				bronRevorNonRevNum = Split(bronRevorNonRevSession(appendixnumber(0)),",")
				
				anawBijNumber = anawBijNumber + bronRevorNonRevNum(1) + bronRevorNonRevNum(2)
			Next
		End If
		
		If chkDist1Stat(4)="Algemene True" Then    
			FOR k = 0 To Ubound(articlePcpies)
				appendixnumber =  Split(articlePcpies(k),"@@")
				bronRevorNonRevNum = Split(bronRevorNonRevSession(appendixnumber(0)),",")
				
				algbijNumber = algbijNumber + bronRevorNonRevNum(1)
			Next
		End If
		
   End If
	
   If Request("frombasket")="true" OR Request("frombasket")="false" Then
   distribute_xml = "<?xml version='1.0' encoding='UTF-8' ?>"+ vbcrlf +"<jobfile>"
      
   chkDist1Stat = Split(session("distibute_1_5"),",")          
   
   'textBoxValue = ">Opties : " & vbcrlf & "    "& chkDist1Stat(0) & vbcrlf &"    "&chkDist1Stat(1)&vbcrlf &"    "&chkDist1Stat(2)&vbcrlf &"    "& chkDist1Stat(3) &vbcrlf &"    "& chkDist1Stat(4) 
   
   '*** Kopblad section
   IF Session("koblad_on")<>""  Then        
         'textBoxValue = textBoxValue & vbcrlf& ">Kopblad :"&vbcrlf & "    "& Session("opmarking") &vbcrlf          
         tgtFile = DISTRIBUTION_DIR &  Session("DistOutputDirectory")& "\" & "kopblad.pdf"
         '*** Create xml for new job
         Call CreateNewJob("Kopblad", tgtFile) 
    End IF    
    distribute_xml = distribute_xml & temxtmlString
   
   IF Session("GridIndexSelected")<> "" Then    
    myString = getIndexSetRowValues(Session("GridIndexSelected"))
    rows = Split(myString,",")   
    'textBoxValue = textBoxValue &vbcrlf&  vbcrlf& ">Overzicht te distribueren documenten :" &vbcrlf   
    Session("distributedocs") = ""
    DistDir = DISTRIBUTION_DIR &  Session("DistOutputDirectory")
    
    For j=0 to UBound(rows)
     article_version = Split(rows(j),"@@@@")
     'textBoxValue =  textBoxValue & "    " & article_version(0) & " - " & article_version(1) &vbcrlf 
      IF Session(BasketSession) <> ""  Then         
         arrArtVer = Split(Session(BasketSession),"****")
          For i=0 to UBound(arrArtVer)
          article = Split(arrArtVer(i),"@@@@")
          srcFile = Replace(article(3),"@","\")          
          fileName = Split(srcFile,"\")(UBound(Split(srcFile,"\")))
          tgtFile = DistDir & "\" & fileName          
                              
          IF  article_version(0)=article(0) and  article_version(1)=article(1) Then 
          
               If chkDist1Stat(0)="Vrijgave True" Then
                   '*** Add the artikel itself/main document for distribution               
                   Session("distributedocs") = Session("distributedocs") & IIf(Session("distributedocs")<>"","****","") & srcFile &"*"& tgtFile                                           
                   '*** Create xml for new job
                   Call CreateNewJob("Normal",tgtFile)
               End If
                                                
               If chkDist1Stat(1)="Stuklijst True" Then                   
                   '*** Add the stuklijst/partlist document of the artikel for distribution                                            
                   tgtFile = DistDir & "\" & article_version(0) & article_version(1) &"_stk.pdf"
                   Call CreateNewJob("Stuklijst",tgtFile)  
               End If                                                               
                                             
               '*** Add the dwg source document/Gekoppeld attachments of the artikel for distribution               
               If chkDist1Stat(2)="Gekoppeid True" Then                    
                    '*** files are separated by '**' 
                    relAttachments = getDocuments(article(0),article(1), "source")
                    relAttachments = Split(relAttachments, "****")                
                    For attachCounter=0 To UBound(relAttachments)   
                        srcFile = Split(relAttachments(attachCounter),"*")(0)
                        tgtFile = DistDir & "\" & Split(relAttachments(attachCounter),"*")(1)                        
                        Session("distributedocs") = Session("distributedocs") & IIf(Session("distributedocs")<>"","****","") & srcFile &"*"& tgtFile                                           
                        '*** Create xml for new job
                        Call CreateNewJob("Source",tgtFile)                                                  
                    Next                    
               End If               
               
               '*** Add all the version specific/Gekoppelde attachments of the artikel for distribution                              
               If chkDist1Stat(3)="Gekoppelde True" Then                    
                    '*** files are separated by '**'                     
                    relAttachments = getDocuments(article(0),article(1), "specific")
                    relAttachments = Split(relAttachments, "****")
                    
                    For attachCounter=0 To UBound(relAttachments)   
                        srcFile = Split(relAttachments(attachCounter),"*")(0)
                        tgtFile = DistDir & "\" & Split(relAttachments(attachCounter),"*")(1)                        
                        Session("distributedocs") = Session("distributedocs") & IIf(Session("distributedocs")<>"","****","") & srcFile &"*"& tgtFile                                           
                        '*** Create xml for new job
                        Call CreateNewJob("Versie",tgtFile)                                                  
                    Next                    
               End If
                              
               '*** Add all general/common/Algemene attachments of the artikel for distribution                              
               If chkDist1Stat(4)="Algemene True" Then                   
                    '*** files are separated by '**'                                                            
                    relAttachments = getDocuments(article(0),article(1), "general")
                    relAttachments = Split(relAttachments, "****")
                                        
                    For attachCounter=0 To UBound(relAttachments)   
                       srcFile = Split(relAttachments(attachCounter),"*")(0)
                       tgtFile = DistDir & "\" & Split(relAttachments(attachCounter),"*")(1)                        
                       Session("distributedocs") = Session("distributedocs") & IIf(Session("distributedocs")<>"","****","") & srcFile &"*"& tgtFile                                           
                       '*** Create xml for new job
                       Call CreateNewJob("Common",tgtFile)                                                  
                    Next                    
               End If
            End IF           
          Next         
      End IF    
   Next
  
  End IF
       
  'textBoxValue = textBoxValue &vbcrlf& ">Output directory :"&vbcrlf & "    "& Session("DistOutputDirectory") 
  distribute_xml = distribute_xml &vbcrlf & "</jobfile>"  
  Session("distributeXML") = distribute_xml    
  End If
  
'*** Create a new job in xml for  a document
Sub CreateNewJob(TagType, tgtFile)
   distribute_xml = distribute_xml & vbcrlf & "  <Job>"
   distribute_xml = distribute_xml & vbcrlf & "    <Type>"& TagType &"</Type>"
   distribute_xml = distribute_xml & vbcrlf & "    <JobType>PRINTING</JobType>"
   distribute_xml = distribute_xml & vbcrlf & "    <ProcessWorkingDirectory>"&PROSSESWORKINGDIRECTORY&"</ProcessWorkingDirectory>"
   distribute_xml = distribute_xml & vbcrlf & "    <WaitingTime>" &WAITINGTIME& "</WaitingTime>"
   distribute_xml = distribute_xml & vbcrlf & "    <File>" & tgtFile & "</File>"
   distribute_xml = distribute_xml & vbcrlf & "    <OutputDirectory>"& Session("DistOutputDirectory") &"</OutputDirectory>"
   distribute_xml = distribute_xml & vbcrlf & "  </Job>"
End Sub  
  
  
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>  
<head id="Head1" runat="server">
     <title>Distributie Wizard</title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
    <script type="text/javascript" src="../Attachment/script/AddAttachment.js"></script>
    <script type="text/javascript" src="../rc/script/common.js"></script>
    <script type="text/javascript" src="../rc/script/sarissa.js"></script>
    <script type="text/javascript" src="../rc/script/window.js"></script>
    <script type="text/javascript" src="../basket/script/basket.js"></script>
	<script>
	  function Back()
       {
        var url = "Distributie_4_5.asp";        
        location.href = url; 
       }
		
		function loadGeavanceerd()
		{
			self.close();
			var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
			openChild("Distributie_1_5.asp", "Distribute", true, 535, 350, "no", "no");     
		} 
	</script>
  
   <link href="../Attachment/styles/datagrid.css" type="text/css" rel="stylesheet" />
 
   
</head>
<body class="BodyStyle">
    <form name="ItemForm" action='Distributie_5_5.asp' enctype="application/x-www-form-urlencoded" method="POST">
     <div style="position:absolute; width: 520px; height: 316px; background-color:#E6E6E6;  font-family:Arial;" id="DIV1" >
       <table >
        <tr align='center'><td style="height: 57px">
           <b>Distributie Wizard - <%=Session(BasketName) %></b><br />
		   <%If Request("frombasket")<>"true" Then%>
				Distributie(5/5)
		   <%End If%>

        </td></tr>
        <tr  valign="top" style = "width:100%;"class="FontProperty">
			<td style="padding-left:20px;">
				Opties->Te distribueren
			</td>
		</tr>
		<tr valign="top" class="FontProperty" >
			<td style="padding-left:20px;">
				Kopblad&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; :
			</td>
		</tr>
		<tr valign="top" class="FontProperty">
			<td style="padding-left:20px;">
				Vrijgave&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <%=vrijgaveNumber%>
			</td>
		</tr>
		<tr valign="top" class="FontProperty" >
			<td style="padding-left:20px;">
				Stuklijst&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <%=stuklistNumber%>
			</td>
		</tr>
		<tr valign="top" style="height:20px;" class="FontProperty" >
			<td style="padding-left:20px;">
				Aanwezig bron document : &nbsp;<%=bronDocNumber%>
			</td>
		</tr>
		<tr valign="top" style="height:20px;" class="FontProperty" >
			<td style="padding-left:20px;">
				Aanwezig bijlage&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <%=anawBijNumber%>
			</td>
		</tr>
		<tr valign="top" style="height:80px;" class="FontProperty" >
			<td style="padding-left:20px;">
				Algemene bijlage &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <%=algbijNumber%>
			</td>
		</tr>
        <tr><td align='left' style="height: 22px">
			<%If Request("frombasket")<>"true" Then%>
				<input id="Button2" style="background-color: #E6E6E6;width: 121px" type="button" value="Vorige" onclick="javascript:history.go(-1)" />
			<%Else%>
				<input id="Button2" style="background-color: #E6E6E6;width: 121px" type="button" value="Geavanceerd" onclick="loadGeavanceerd()" />
		    <%End If%>
            
            <span style="width:225px"></span>
			<input id="Button1" style="background-color: #E6E6E6;width: 121px" type="button" value="Distributie" onclick='SaveDistributeXML()' /></td></tr>
       </table>
     </div>
    </form>
</body>
<%
Sub Quit(retCode)
  '*** Cleanup.  
  If (retCode <> "") Then    
    '*** Write error to document.
    Call Response.Write(retCode)
    Call Response.End()
  End If
End Sub

 %>
</html>