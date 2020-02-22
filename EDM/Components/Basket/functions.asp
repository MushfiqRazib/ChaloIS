<!-- #include file="../config.asp"     -->
<!-- #include file="../qb/includes/common.asp"  -->
<!-- #include file="../qb/includes/postgres.asp"  -->

<%

Sub ListFolderContents(path)
     dim fs, folder, file, item, url, fileInfo
     fileInfo = ""
     set fs = CreateObject("Scripting.FileSystemObject")
     set folder = fs.GetFolder(path)
     
     'get a list of files.  
     for each item in folder.Files
       url = MapURL(item.path)
       fileInfo = fileInfo & item.Name & item.Size & item.DateCreated        
     next
End Sub
   
   
'*** Return the documents name in formatted string according 
'*** to the document type for the provided Artikel
Function getDocuments(ArtikelNr, latestRevision, docType)
   Dim docPath,fs, folder,file,item,versie,attachments,Name,File_SubPath
   
   File_SubPath = GetFileSubPathFromMatCode(GetRelFilePath(ArtikelNr))
   docPath = DocBasePath & File_SubPath
                    
   If FolderExists(docPath) Then
      set fs = CreateObject("Scripting.FileSystemObject")
      set folder = fs.GetFolder(docPath)                  
            
     'Get a list of files.         
     for each item in folder.Files
         Name = item.Name                          
         file =  Split(Name,ArtikelNr)                          
         If UBound(file)>0 Then '*** Valid file check  
             partsOfName = file(UBound(file)) 
             partsOfName = Right(partsOfName, Len(partsOfName)-1)
             partsOfName = Replace(partsOfName,".","_")                                  
             partsOfName = Split(partsOfName,"_")
             versie      = partsOfName(0)
              
             Select Case docType
                '*** latest version match + not dwg + no description
                Case "main"  
                   If versie = latestRevision AND UBound(partsOfName)=1 AND UCase(partsOfName(1)) <> "DWG" Then                        
                       attachments = attachments & IIf(attachments="","","****") & docPath & Name & "*" & Name
                   End If     
                   
                '*** latest version match + dwg + no description   
                Case "source"
                   If UCase(partsOfName(1)) = "DWG" AND versie = latestRevision AND UBound(partsOfName)=1 Then
                       attachments = attachments & IIf(attachments="","","****") & docPath & Name & "*" & Name 
                   End If           
                
                '***less than latest version + NOT XX + NOT DWG + No desc
                Case "history" 
                    If  UBound(partsOfName)=1 AND  _                            
                        UCase(versie)<>"XX" AND  _
                        UCase(partsOfName(1)) <> "DWG" _
                        AND versie <> latestRevision  Then                             
                        attachments = attachments & IIf(attachments="","","****") & docPath & Name & "*" & Name                   
                    End If 
                '*** version XX + description must
                Case "general" 
                    If UBound(partsOfName) >1 AND _
                        UCase(versie)="XX" Then 
                        attachments = attachments & IIf(attachments="","","****") & docPath & Name & "*" & Name                    
                    End If                           
                
                '*** version XX + description must    
                Case "specific"                        
                    If UBound(partsOfName) >1 AND _                            
                        UCase(versie)<>"XX" AND _
                        versie = latestRevision  Then                             
                        attachments = attachments & IIf(attachments="","","****") & docPath & Name & "*" & Name                   
                    End If                                                 
                
             End Select                 
         End If                             
      next                       
   End If 
    
  '*** Return formatted string of related attachments          
  getDocuments = attachments

End Function 



'*** This function is obsolute here,bcoz we dont have any 
'*** File_SubPath field in Database. Instead we are using
'**** another function here named "GetFileSubPathFromMatCode"

'*** Get FileSubPath for the artikel
Function GetFileSubpath (ArtikelNr, RCorVA)
    Dim rs, sql, TableName,File_SubPath
    If RCorVA="rc" Then
        TableName = "RC_ITEM_HIT"
    Else
        TableName = "heyedm"
    End If
    
    '*** create sql for the query
    sql = "SELECT File_SubPath FROM " & TableName & " WHERE matcode = '" & ArtikelNr & "'"
    
    If RSOpen(rs, gDBConn, sql , True) Then      
         File_SubPath = rs("File_SubPath")      
    End If      
    
    '*** Return FileSubpath
    GetFileSubpath = File_SubPath  
    
End Function

  
   
Function LoadDropVersie(path,ArtikelNr)

     dim fs, folder, file, item, versie, selectString 
     selectString = "<select name=""drpVersie"" style=""width:80px"">"
     
     set fs = CreateObject("Scripting.FileSystemObject")
     set folder = fs.GetFolder(path)
         
     'get a list of files.
  
     for each item in folder.Files
         file = item.Name
         item = Split(file,".")(0)
         item =  Split(item,ArtikelNr)
         versie = item(UBound(item))
         selectString = selectString &  "<option value=""01"" selected>"& versie &"</option>  "       
     next
     
        selectString = selectString & "</select>"
        LoadDropVersie = selectString
End Function   
   

Function CreateListWithNameofXmlFile()
    
    dim fs, folder, file, item, versie, selectString 
    selectString = "<select id=""drpFilelist"" name=""drpFilelist"" style=""width:150px"">"     
    set fs = CreateObject("Scripting.FileSystemObject")
    
    set folder = fs.GetFolder(BASKET_OUTPUT)
    
    'get a list of files.
  
    for each item in folder.Files
        file = item.Name
        selectString = selectString &  "<option value=""01"" selected>"& file &"</option>  "       
    next
    
    selectString = selectString & "</select>"
    
    CreateListWithNameofXmlFile = selectString
End Function   
'***********Create Busket Grid ************
Function CreateBasketDataGrid(gridId)
    
     Dim tableData , article_version,rows,stuklistNumber, printNumber,tstuklistNumber, tprintNumber 
     Dim stuklijstSession,printNumberSession,stuklijstNumberSession
	 
     IF Session("loadString") <> "" Then
       tableData = Session("loadString")
       'Session("loadString")=""
     Else 
       tableData = Session(BasketSession)
     End IF
    
     rows = Split(tableData,"****")
     'Create grid header part
     Dim tableString, ColHeader, Columns, i
     Columns = "Artikelnr, Revisie,Stuklijst,Bron" & vbcrlf & "document,Algemene" & vbcrlf &"bijlagen,Revise"& vbcrlf &"bijlagen, Te printen"& vbcrlf &"bijlagen,"
     ColHeader = Split(Columns,",")
     tableString = "<TABLE id='FileInfo' cellspacing='0' cellpadding='0' class='Datagrid' >"    
     tableString = tableString & "<THEAD><TR>"
     '*** Create header of datagrid     
     For i = 0 To UBound(ColHeader)
        tableString = tableString & "<TH wrap>" & ColHeader(i) & "</TH>"                                 	                    
     Next
     tableString = tableString & "</TR></THEAD>"          
     tableString = tableString & "<TBODY>"
     
     dim fs, folder, file,rowCounter,fileName,bronRevorNonRevSession,brondocNum,RevAppendixNum,NonRevAppendixNum, subpath,revInfo
     fileInfo = ""
     'set fs = CreateObject("Scripting.FileSystemObject")
     'set folder = fs.GetFolder(path)
     
     '*** Create grid body. 
     For rowCounter=0 to UBound(rows)        
       article_version = Split(rows(rowCounter),"@@@@")
		
		
		'subpath = GetFileSubpath (article_version(0), Session(whichBasket)) ' Get subpath for the article
		'subpath =  GetFileSubPathFromMatCode(article_version(0))
		subpath =  article_version(3)
		
		stuklistNumber = article_version(5) 'GetStuklijstNumber(article_version(0))		
		brondocNum        = HasBornDoc(article_version(0), Session(whichBasket), subpath)
		revInfo =  GetRevOrNonRevAppenNumber(article_version(0), Session(whichBasket),article_version(1) ,subpath)
		revInfo =  Split(revInfo,",")
		NonRevAppendixNum = revInfo(1)
		RevAppendixNum    = revInfo(0)
		printNumber    = GetPrintNumber(article_version(0), article_version(1))
		
		
		
        tableString = tableString & "<TR id='rowId_" & rowCounter & "' >" 
        tableString = tableString & "<TD class='TDCenter' nowrap>" & article_version(0) & "</TD>"
        tableString = tableString & "<TD class='TDCenter' nowrap>" & article_version(1) & "</TD>"  
		tableString = tableString & "<TD class='TDCenter' nowrap>" & IIF(stuklistNumber>0,"Ja","Nee") & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & IIF(brondocNum = "True","Ja","Nee") & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & NonRevAppendixNum & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & RevAppendixNum & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & printNumber & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & "<img class='Link' id='img_"& rowCounter &"' src='./images/delete.png' alt='Verwijder uit basket' onclick='deleteRow(this)'></img></TD>" 
        tableString = tableString & "</TR>"
		
		tstuklistNumber =  CInt(tstuklistNumber) + CInt(stuklistNumber)
		tprintNumber    = tprintNumber    + printNumber
		
		stuklijstNumberSession = stuklijstNumberSession & stuklistNumber & ","
		
		stuklijstSession = stuklijstSession & IIF(stuklistNumber>0,"True","False") & ","
		printNumberSession = printNumberSession & printNumber & ","
		bronRevorNonRevSession = bronRevorNonRevSession & brondocNum & "," & RevAppendixNum & "," & NonRevAppendixNum &"@@"
     Next     
     
	 If stuklijstSession<>"" Then
		stuklijstSession = Left(stuklijstSession,Len(stuklijstSession)-1)
	 End If
	 If printNumberSession <> "" Then
		printNumberSession = Left(printNumberSession,Len(printNumberSession)-1)
	 End If
	 
	 If bronRevorNonRevSession <> "" Then
		bronRevorNonRevSession = Left(bronRevorNonRevSession,Len(bronRevorNonRevSession)-2)
	 End IF
	 
	 If stuklijstNumberSession<> "" Then
		stuklijstNumberSession = Left(stuklijstNumberSession,Len(stuklijstNumberSession)-1)
	 End IF
	 
	 Session("stuklijstSession") = stuklijstSession
	 
	 Session("printNumberSession") = printNumberSession
	 'Response.Write("bronRevorNonRevSession" & bronRevorNonRevSession)
	 Session("bronRevorNonRevSession") = bronRevorNonRevSession
	 Session("stuklijstNumberSession") = stuklijstNumberSession
	 
	 Session("stuklistPrintNumber") = tstuklistNumber & "@" & tprintNumber
     tableString = tableString & "</TBODY></TABLE>"               
      
     CreateBasketDataGrid = tableString
   End Function
'**************Determine whether stuklijst is presented for the provided article*******
Function GetStuklijstNumber(articleNr)
	Dim stuklijstCounter, rs, sql
	
	sql = "SELECT COUNT(*) AS TROW FROM va_bom WHERE item = '"&articleNr&"'"
	
	If RSOpen(rs, gDBConn, sql, True) Then
		stuklijstCounter = CInt(rs("TROW"))
	End If
	
	If stuklijstCounter > 0 Then
		GetStuklijstNumber = 1
	Else
		GetStuklijstNumber = 0
	End If
End Function
'*************Determinde whether Bon Document presents or not*****************
Function HasBornDoc(articleNr, RCorVA, subpath)
	Dim fs,folder,path,file,fileName,Ext,item, hasBorn,partsOfName
		
	hasBorn = False
	
	'Build total data path for the article
	IF RCorVA <> "rc" Then
		path = DocBasePath & subpath
	Else
		path = PATH_RC & subpath
	End IF
	
	If FolderExists(path) Then
		set fs = CreateObject("Scripting.FileSystemObject")
		set folder = fs.GetFolder(path)
		
		for each item in folder.Files
			file = item.Name    
            file =  Split(file,articleNr)
			If UBound(file) Then
			
				partsOfName = file(UBound(file)) 
                partsOfName = Right(partsOfName, Len(partsOfName)-1)
                partsOfName = Replace(partsOfName,".","_")                                  
                partsOfName = Split(partsOfName,"_")
				
				If  UCase(partsOfName(1))="DWG" Then
					hasBorn = True
					Exit For
				End If
			End If
		Next
	End If
	HasBornDoc = hasBorn
End Function
'**********Get the number of Revisioned/nonRevisioned appendices for provided article*******
Function GetRevOrNonRevAppenNumber(articleNr, RCorVA, revision,subpath)
	Dim fs,folder,path,file,fileName,Ext,item, revCounter,nonrevCounter, partsOfName	
	
	revCounter = 0
	nonrevCounter = 0
	
	'Build total data path for the article
	IF RCorVA <> "rc" Then
		path = DocBasePath & subpath
	Else
		path = PATH_RC & subpath
	End IF
	
	If FolderExists(path) Then
		set fs = CreateObject("Scripting.FileSystemObject")
		set folder = fs.GetFolder(path)
		
		for each item in folder.Files		
			file = item.Name    
			If (len(file) > len(articleNr & "_" & revision & ".XXX") OR UCase(trim(file)) = UCase(trim(articleNr) & "_" & trim(revision) & ".dwg")) AND Left(file,len(articleNr)) = articleNr Then
				versie = mid(file,len(articleNr)+2,2)
				If Len(versie) > 0 Then '*** version exists                 
					If versie<>"" AND UCase(versie)<>"XX" AND versie = revision  Then  
						revCounter = revCounter + 1
						'Call addRowString(tableString,rowCounter,item,path)
						'rowCounter = rowCounter + 1    
					ElseIf UCase(versie)= "XX" Then
						nonrevCounter = nonrevCounter + 1					
						'Call addRowString(tableString,rowCounter,item,path)
						'rowCounter = rowCounter + 1                     
					End If                    
				End If                                                        
			End If
		Next
	End If
	
	GetRevOrNonRevAppenNumber =  revCounter & "," & nonrevCounter
End Function
'**************Determine Print copies in Printen table for provided article*******
Function GetPrintNumber(articleNr, revision)
	Dim printcounter, rs, sql
	
	printcounter = 0
	sql = Replace(FUNCTIONS_PRINTEN_COUNT_SQL,"[matcode]",articleNr)
	
	sql = Replace(sql,"[revision]",revision)
	'sql = "SELECT COUNT(*) AS TROW FROM PRINTEN WHERE SUBSTR(APPENDIXNAME,1,length('"&articleNr&"')) = '"&articleNr&"' AND UPPER(SUBSTR(APPENDIXNAME,length('"&articleNr&"')+2, 2)) in ('"&revision&"','XX')"
	
	If RSOpen(rs, gDBConn, sql, True) Then
		printcounter = CInt(rs("TROW"))
	End If
	
	GetPrintNumber = printcounter
End Function
'************************* Get Printable Bijlagen for provided articleNumber**********
Function GetAppendicesInfo(articleNr, revision)
	Dim rs,sql,appendicesinfo
	
	appendicesinfo = ""
	'sql = "SELECT APPENDIXNAME,FORMAT FROM PRINTEN WHERE SUBSTR(APPENDIXNAME,1,length('"&articleNr&"')) = '"&articleNr&"' AND UPPER(SUBSTR(APPENDIXNAME,length('"&articleNr&"')+2, 2)) in ('"&revision&"','XX')"
	sql = Replace(FUNCTIONS_PRINTEN_SQL,"[matcode]",articleNr)
	sql = Replace(sql,"[revision]",revision)
	
	If RSOpen(rs, gDBConn, sql, True) Then
		While Not rs.EOF
			appendicesinfo = appendicesinfo & rs("APPENDIXNAME") & "*" & rs("FORMAT") & "@"
			rs.MoveNext
		Wend
		appendicesinfo = Left(appendicesinfo,Len(appendicesinfo)-1)
	End If
	
	GetAppendicesInfo = appendicesinfo
	
End Function

Function getRelatedArtikelInfo(conn,artikelNr, revision)

    Dim c_Bomengs, artikelInfo, relatedArtikels, cr
    c_Bomengs = artikelNr
    relatedArtikels = ""
    cr = 1
    Do Until c_Bomengs=""
        If c_Bomengs<>"" Then
            relatedArtikels = relatedArtikels & IIf(relatedArtikels<>"",",","") & c_Bomengs
        End If
	If cr>10 Then
		Exit Do
	End If
        c_Bomengs = getRelatedArtikels(c_Bomengs,conn,revision,cr) 
	cr = cr + 1
    Loop      
   
    artikelInfo = ""
    set rs=Server.CreateObject("ADODB.recordset")
    
    Dim segmentList,segId,counter,segSize,curSeg,totalitem,stukLijst
    segmentList = Split(relatedArtikels,",")
    totalitem = UBound(segmentList)
    'Call WriteToFile("C:\log.txt",totalitem,True)
    segSize = 999
    For segId=0 To totalitem
	curSeg = ""
	For counter=0 To (segSize-1)
		If segId<=totalitem Then
			curSeg = curSeg & IIf(curSeg="","",",")  & segmentList(segId)        
		Else
			Exit For                   
		End If
		segId = segId + 1
	Next 
	sql = "SELECT matcode, rev, file_subpath, file_name, file_format FROM heyedm where matcode in (" & curSeg & ")"
		
	rs.Open sql, conn    
	while Not rs.EOF           		
		stukLijst = GetStuklijstNumber(rs("matcode") )			       
		artikelInfo = artikelInfo & IIf(artikelInfo<>"","****","") & rs("matcode") & "@@@@" & rs("rev") & "@@@@" & rs("file_format") & "@@@@" & DocBasePath & rs("file_subpath") & rs("file_name") & "@@@@" & stukLijst
		rs.MoveNext
	Wend
	segId = segId - 1
	rs.close
   Next
  
  '*** return related artikel info

  getRelatedArtikelInfo = artikelInfo
    
End Function

Function getRelatedArtikels(c_Bomengs,conn, revision,cr)
    Dim artikels
    artikels = ""
    set rs=Server.CreateObject("ADODB.recordset")
    If cr=1 Then
	'sql = "SELECT comp_item FROM va_c_bomeng where item in (" & c_Bomengs & ") and DRAW_REV=" & revision & ""
	sql = "SELECT comp_item FROM stuklisjtInfo where item in (" & c_Bomengs & ") and revision=" & revision & ""
    Else
	'sql = "SELECT comp_item FROM va_c_bomeng where item in (" & c_Bomengs & ")"
	sql = "SELECT comp_item FROM stuklisjtInfo where item in (" & c_Bomengs & ")"
    End If
    
    '*** Open connection
    rs.Open sql, conn    
    while Not rs.EOF    
        artikels = artikels & IIf(artikels<>"",",","") & "'" & rs("comp_item") & "'"    
        rs.MoveNext    
    Wend
    rs.close
  '*** return related artikels
  getRelatedArtikels = artikels
    
End Function
 
'*** Returns current date as '/' separtor
Function getDate()
        Dim today_, dd, mm,yy
        
        '*** date evaluation part
        today_ = Split(Now," ")(0)
        '*** Some system gives - separated date  
        today_ = Replace(today_,"-","/")	
        today_ = Split(today_,"/") 
        dd = IIf( Len(today_(0))=1, "0"&today_(0), today_(0))
        mm = IIf( Len(today_(1))=1, "0"&today_(1), today_(1))
        yy = today_(2)
        
        '*** return todate
        getDate = mm & dd & yy
   End Function  
   
Function getRevDate()
        Dim today_, dd, mm,yy
        
        '*** date evaluation part
        today_ = Split(Now," ")(0)
        '*** Some system gives - separated date  
        today_ = Replace(today_,"-","/")	
        today_ = Split(today_,"/") 
        dd = IIf( Len(today_(0))=1, "0"&today_(0), today_(0))
        mm = IIf( Len(today_(1))=1, "0"&today_(1), today_(1))
        yy = today_(2)
        
        '*** return todate
        getRevDate = yy & mm & dd 
   End Function    

Function getTimeStamp()
        Dim time_,ss,mm,hh,date_
        
        date_ = getDate()
        
        '*** time evalutaion part
        time_ = Split(now," ")(1)
        time_ = Split(time_,":")
        
        hh = IIf( Len(time_(0))=1, "0"&time_(0), time_(0))
        mm = IIf( Len(time_(1))=1, "0"&time_(1), time_(1))
        ss = IIf( Len(time_(2))=1, "0"&time_(2), time_(2))
        
        '*** return todate
        getTimeStamp = date_ & hh & mm & ss
   End Function        
   
    
Function MapURL(path)
     dim rootPath, url
          
     'Convert a physical file path to a URL for hypertext links.
     rootPath = Server.MapPath("/")
     url = Right(path, Len(path) - Len(rootPath))
     MapURL = Replace(url, "\", "/")

   End Function
   
 Function getIndexSetRowValues(index)
    Dim value,arrRows,allRows,artNum
    arrRows =""
    value = Split(index,",")  
    allRows = Split(Session(BasketSession),"****")     
    
    If UBound(allRows) > 0 Then            
        For i=0 to UBound(value) 
	      artNum = Split(value(i),"@@")	 	  
          arrRows = arrRows & allRows(artNum(0)) & ","          
        Next
    End If
    
    IF arrRows <> "" Then 
      arrRows = Left(arrRows,Len(arrRows)-1)
    End IF
    getIndexSetRowValues = arrRows
    
End Function

'******************************************************************************   
'********************* Printen functions starts here **************************
'******************************************************************************

Function CreatePrintenDataGrid(gridId)
     Dim tableData , article_version,rows,stuklijstSession,printNumberSession 
     tableData = Session(BasketSession) ' "arPinaple*verEitch@arHello*verLook@arCool*verStatburg@arArticleData*verVersuibD@arPinaple*verEitch@arHello*verLook@arCool*verStatburg@arArticleData*verVersuibD"
     rows = Split(tableData,"****")     
     Session("GridRowNumber") = UBound(rows)
     'Create grid header part
     Dim tableString, ColHeader, Columns, i
     Columns = ",Artikelnr, Revisie,Stuklijst,Te printen"& vbcrlf &"bijlagen,Aantal"& vbcrlf &"Afdrukken" 
     ColHeader = Split(Columns,",")
     tableString = "<TABLE id='FileInfo' cellspacing='0' cellpadding='0' class='Datagrid' >"    
     tableString = tableString & "<THEAD><TR>"
     '*** Create header of datagrid     
     For i = 0 To UBound(ColHeader)
        tableString = tableString & "<TH  class='Scroll"& gridId &"' wrap>" & ColHeader(i) & "</TH>"                                 	                    
     Next
     tableString = tableString & "</TR></THEAD>"          
     tableString = tableString & "<TBODY>"
     
     dim fs, folder, file,rowCounter,fileName
     fileInfo = ""
     
	 stuklijstSession = Split(Session("stuklijstSession"),",") 
	 printNumberSession = Split(Session("printNumberSession"),",") 
	 
     '*** Create grid body. 
     For rowCounter=0 to UBound(rows)
        article_version = Split(rows(rowCounter),"@@@@")
        tableString = tableString & "<TR id='rowId_" & rowCounter & "' >" 
        tableString = tableString & "<TD class='TDCenter' nowrap><input  type='checkbox' name='chkBx_"& rowCounter &"' checked='checked'/></TD>"
        tableString = tableString & "<TD class='TDCenter' nowrap>" & article_version(0) & "</TD>"
        tableString = tableString & "<TD class='TDCenter' nowrap>" & article_version(1) & "</TD>" 
		tableString = tableString & "<TD class='TDCenter' nowrap>" & IIf(stuklijstSession(rowCounter) = "True","Ja","Nee")  & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & printNumberSession(rowCounter) & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap><input  type='textbox' name='txtBx_"& rowCounter &"' style='width:50px;text-align:center;' value='1' onkeypress='return isNum(event)'/></TD>"
        tableString = tableString & "</TR>"      
     Next     
     
           
     tableString = tableString & "</TBODY></TABLE>"               
      
     CreatePrintenDataGrid = tableString
   End Function


Function getSelectedIndex()
    Dim myString,rows,article_version,returnStr,test_art_ver,rowCounter,Counter
    myString = getIndexSetRowValues(Session("GridIndexSelected"))
    rows = Split(myString,",")
    returnStr = ""
    basketInfo = Session(BasketSession) 'basketInfo = "14050029@@@@00@@@@A0****14150733@@@@00@@@@A1****20350551@@@@00@@@@A0****20350552@@@@00@@@@A2"     
    itemArray = split(basketInfo,"****")
 
    For rowCounter=0 to UBound(rows)
      test_art_ver = Split(rows(rowCounter),"@@@@")
      For Counter=0 to UBound(itemArray)
        article_version = Split(itemArray(Counter),"@@@@")
        IF article_version(0) = test_art_ver(0) Then
           returnStr = returnStr & Counter & ","
        Exit For
        End IF
      Next
    Next
    IF returnStr <> "" Then 
       returnStr = Left(returnStr,len(returnStr)-1)
    End IF
 
  getSelectedIndex = returnStr
End Function


Function getDistinctFormat() 
    Dim basketInfo,distincFormat,itemArray,rowCounter,format,selectedIndexs
    distincFormat = ""
    basketInfo = Session(BasketSession) 'basketInfo = "14050029@@@@00@@@@A0****14150733@@@@00@@@@A1****20350551@@@@00@@@@A0****20350552@@@@00@@@@A2"     
    itemArray = split(basketInfo,"****")
 
    selectedIndexs = getSelectedIndex()
    row = split(selectedIndexs,",")
    For rowCounter=0 to UBound(row)
        
        format = Split(itemArray(row(rowCounter)),"@@@@")(2)
        format = IIf(format="","unknown",format)
        
        If Not InArray(Split(distincFormat,"*"),format) Then
            distincFormat = distincFormat + IIf(distincFormat<>"","*","") + format '*** format resides at index 2 of the array
        End If
    Next
    
    Session("selectedFormats") = distincFormat
    
    '*** return distinct format string
    getDistinctFormat = Split(distincFormat,"*")
End Function

Function getFormat4UnknownOrStuklijst(unknownOrStuk)
   Dim mydoc,xmlf,NodeList,printers,Node,format
   printers = ""
   Set mydoc=Server.CreateObject("Microsoft.XMLDOM")
   xmlf = "./../Printing_" & session("printserverlocation") & ".config"  
   mydoc.async=false 
   mydoc.load(Server.Mappath(xmlf))   
   IF mydoc.parseError.errorcode<>0 then
     Response.Write("XML Parse Error")
   Else   
     IF unknownOrStuk = "unknown" Then
     Set NodeList = mydoc.documentElement.selectNodes("defaultUnknownFormat/defaultformat")   
     Else
      Set NodeList = mydoc.documentElement.selectNodes("kopblad_stuklijst_Format/defaultformat")   
     End IF
     For Each Node In NodeList             
      format = format & "*" & Node.text       
     Next
   End IF  
   getFormat4UnknownOrStuklijst =  Split(format,"*")
End Function

Function getFormat()
   Dim mydoc,xmlf,NodeList,printers,Node
   printers = ""
   Set mydoc=Server.CreateObject("Microsoft.XMLDOM")
   xmlf = "./../Printing_" & session("printserverlocation") & ".config"  
   mydoc.async=false 
   mydoc.load(Server.Mappath(xmlf))   
   IF mydoc.parseError.errorcode<>0 then
     Response.Write("XML Parse Error")
   Else   
     Set NodeList = mydoc.documentElement.selectNodes("paperformats/paperformat")   
     For Each Node In NodeList             
      format = format & "*" & Node.text       
     Next
   End IF 
   getFormat =  Split(format,"*")
   
End Function




Function getPrinters(format)

   Dim mydoc,xmlf,NodeList,printers,Node
   printers = ""
   Set mydoc=Server.CreateObject("Microsoft.XMLDOM")
   xmlf = "../printing_" & session("printserverlocation") & ".config"  
   mydoc.async=false 
   getPrinters = Server.Mappath(xmlf)
   mydoc.load(Server.Mappath(xmlf))   
   
   
   If mydoc.parseError.errorcode<>0 then
     Response.Write("XML Parse Error")
   Else   
       '*** change the format for unknown format
       If format="unknown" Then 
          Set NodeList = mydoc.documentElement.selectNodes("defaultUnknownFormat/defaultformat")   
          For Each Node In NodeList             
            format = Node.text       
          Next
          Session("unknown") = format                             
       End If      
              
       '*** change the format for kopblad/stuklijst format
       If format="stuk_kop" Then 
          Set NodeList = mydoc.documentElement.selectNodes("kopblad_stuklijst_Format/defaultformat")   
          For Each Node In NodeList             
            format = Node.text       
          Next
          Session("stuk_kop") = format       
       End If
       
             
              
       '*** get default printer
       Set NodeList = mydoc.documentElement.selectNodes("printerlist/" &format& "/defaultprinter")       
       For Each Node In NodeList             
          printers = printers + IIf(printers<>"","*","") + Node.text       
       Next
       '*** get other printers
       Set NodeList = mydoc.documentElement.selectNodes("printerlist/" &format& "/printer")       
       For Each Node In NodeList             
          printers = printers + IIf(printers<>"","*","") + Node.text       
       Next
       
       '*** Return printer names  
       getPrinters = Split(printers,"*")
     
   End If

End Function 

Function InArray(arr, value)
  Dim i
  
  '*** Default value.
  InArray = False
  
  '*** Loop through array elements.
  For i = LBound(arr) To UBound(arr) 
    If (arr(i) = value) Then
      '*** Report back that array contains specified value.
      InArray = True
      
      Exit For
    End If
  Next
End Function

'******************************************************************************
'*** Distribute functions starts here  
'******************************************************************************
   
Function CreateDistributeDataGrid(gridId)
     Dim tableData , article_version,rows,bronRevorNonRevSession, stuklijstSession,bronRevorNonRevNum
     tableData = Session(BasketSession)     
     rows = Split(tableData,"****")
     Session("GridRowNumber") = UBound(rows)
     'Create grid header part
	 
	 stuklijstSession = Split(Session("stuklijstSession"),",") 
	 bronRevorNonRevSession = Split(Session("bronRevorNonRevSession"),"@@")
	 '
	 
     Dim tableString, ColHeader, Columns, i
     Columns = ",Artikelnr, Revisie,Stuklijst,Bron" & vbcrlf & "document,Algemene" & vbcrlf &"bijlagen,Revise"& vbcrlf &"bijlagen" 
     ColHeader = Split(Columns,",")
     tableString = "<TABLE id='FileInfo' cellspacing='0' cellpadding='0' class='Datagrid' >"    
     tableString = tableString & "<THEAD><TR>"
     '*** Create header of datagrid 
     
     For i = 0 To UBound(ColHeader)
        tableString = tableString & "<TH  wrap>" & ColHeader(i) & "</TH>"                                 	                    
     Next
     tableString = tableString & "</TR></THEAD>"          
     tableString = tableString & "<TBODY>"
     
     dim fs, folder, file,rowCounter,fileName
     fileInfo = ""
    
     '*** Create grid body. 
     For rowCounter=0 to UBound(rows)
        article_version = Split(rows(rowCounter),"@@@@")
       
		'bronRevorNonRevNum = Split(bronRevorNonRevSession(rowCounter),",")
		    
        tableString = tableString & "<TR id='rowId_" & rowCounter & "' >" 
        tableString = tableString & "<TD class='TDCenter' nowrap><input  type='checkbox' name='chkBx_"& rowCounter &"' checked='checked'/></TD>"
        tableString = tableString & "<TD class='TDCenter' nowrap>" & article_version(0) & "</TD>"
        tableString = tableString & "<TD class='TDCenter' nowrap>" & article_version(1) & "</TD>" 
		'tableString = tableString & "<TD class='TDCenter' nowrap>" & IIf(stuklijstSession(rowCounter) = "True","Ja","Nee") & "</TD>"  
		'tableString = tableString & "<TD class='TDCenter' nowrap>" & IIf(bronRevorNonRevNum(0) = "True","Ja","Nee") & "</TD>"  
		'tableString = tableString & "<TD class='TDCenter' nowrap>" & bronRevorNonRevNum(1) & "</TD>"  
		'tableString = tableString & "<TD class='TDCenter' nowrap>" & bronRevorNonRevNum(2)& "</TD>"  
        tableString = tableString & "</TR>"
      
     Next     
           
     tableString = tableString & "</TBODY></TABLE>"               
     
     CreateDistributeDataGrid = tableString
   End Function
  
  
  Function GetDir(outputDir)
    Dim id, Counter, Flag 
    id = Split(outputDir,Session(BasketName))(1)
    Counter = 1
    Flag = "True"

   While Flag = "True"     
     If Not FolderExists(outputDir&Counter) Then
        outputDir = outputDir & Counter        
        Flag = "False"
     End If        
     Counter = Counter + 1
    Wend
     
    '*** return string
    GetDir = outputDir

End Function 
'**************************************************************************
'***********Delete Item (not First) From Basket Session********************************
'**************************************************************************
Sub DeleteOtherItem(artikelNr,versionNr)  
   Dim newValues,items,newStr
   newValues = Split(Session(BasketSession),"****")
   For i=0 to UBound(newValues)
     items = Split(newValues(i),"@@@@")
     IF artikelNr <> items(0) Then
       newStr = newStr & items(0) & "@@@@" & items(1) & "@@@@" & items(2)& "@@@@" & items(3)& "****"  
     End IF
   Next
   newStr = Left(newStr,Len(newStr)-4)
   Session(BasketSession) = newStr
End Sub    
   
'**************************************************************************
'***********Delete Item (First) From Basket Session********************************
'**************************************************************************    
Sub DeleteFirstItem(artikelNr,versionNr)
   Session(BasketSession) = Replace(Session(BasketSession),artikelNr&"@@@@"&versionNr,"")
   Dim newValues,items,newStr
   newValues = Split(Session(BasketSession),"****")
   For i=1 to UBound(newValues)
     items = Split(newValues(i),"@@@@")
     newStr = newStr & items(0) & "@@@@" & items(1) & "@@@@" & items(2)& "@@@@" & items(3)& "****"  
   Next
   newStr = Left(newStr,Len(newStr)-4)
   Session(BasketSession) = newStr
End Sub                                                                             
'**************************************************************************
'***********Delete Item From Basket Session********************************
'**************************************************************************
Sub DeleteItemFromBasketSession(artikelNr,versionNr)
	Dim arrArtVer,article
	arrArtVer = Split(Session(BasketSession),"****")
    IF  UBound(arrArtVer) = 0 Then
        Session(BasketSession)= ""
    Else
        For i=0 to UBound(arrArtVer)
            article = Split(arrArtVer(i),"@@@@")
            IF article(0) = artikelNr Then 
                IF i = 0 Then
                    Call DeleteFirstItem(artikelNr,versionNr)
                Else
					Call DeleteOtherItem(artikelNr,versionNr) 
                End IF
            End IF  
        Next 
    End IF
End Sub

Function GetFileSubPathFromRelfilename(relFilename)
    Dim path
    
    IF relFilename <> "" then
        pathParts = Split(relFilename, "\")
        
        For i=0 to UBound(pathParts) -1 
            path = path & pathParts(i) & "\"          
        Next
    ELSE
        path = ""
    End If      
   
    
    GetFileSubPathFromRelfilename = path
End Function

Function GetFileNameFromRelfilename(relFilename)
    Dim path
    IF relFilename <> "" then
        pathParts = Split(relFilename, "\")
        GetFileNameFromRelfilename = pathParts(UBound(pathParts))
    ELSE
        GetFileNameFromRelfilename = ""  
    END IF      
End Function

Function GetRelFilePath(ArtikelNr)
    Dim sql,keyFields,File_SubPath
    keyFields = split(session("keyfields"),"@@")
    sql = "select relfilename from " & session("relfiletable")  & " WHERE " & keyFields(0) & "= '" & ArtikelNr & "'"
    If RSOpen(rs, gDBConn, sql , True) Then      
        File_SubPath = rs("relfilename")      
    End If  
    GetRelFilePath = File_SubPath
End Function

Function GetFileSubPathFromMatCode(matCode)
    Dim path
    IF Len(matCode) >= 4 then
        path = Left(matCode,4) & "\"        
    End IF
    GetFileSubPathFromMatCode = path
End Function

Function GetFileName(matCode,rev)
    Dim fileName
    fileName = matCode &  "_" & rev & ".dwf"        
    GetFileName = fileName
End Function
   
   %>

   