<!-- #include file="./functions.asp"      -->
<%

Dim iteminfo,artikelNr,versionNr,fileName,fileList,newAdd,reset,printFileName,ditributeFileName,upgrade,casecode,getXmlFiles
Dim setRelItem,BasketSize,getPrinter,formatPrinterString,deleteAll, art,sid,kitServerPath,printserverlocation
Dim FSO,myFile,outputDir
iteminfo = RequestStr("iteminfo", "")
iteminfo = Replace(iteminfo,"%%%","&") 
iteminfo = Replace(iteminfo,"**","\\") 
iteminfo = Replace(iteminfo,"*","\") 
sid       =  RequestStr("sid","")
printserverlocation = RequestStr("printserverlocation","")
kitServerPath = RequestStr("kitServerPath","")
 
artikelNr = RequestStr("artikelNr","")
artikelNr = Replace(artikelNr,"%%%","&") 
artikelNr = Replace(artikelNr,"**","\\") 
versionNr = RequestStr("versionNr","")

fileName  = RequestStr("fileName","")
fileList  = RequestStr("fileList","")

newAdd    =  RequestStr("newAdd","")
reset     =  RequestStr("reset","")
setRelItem = RequestStr("setRelItem","")

printFileName = RequestStr("printFileName","")
ditributeFileName = RequestStr("ditributeFileName","")

upgrade = RequestStr("upgrade","")

getPrinter = RequestStr("getPrinter","")
formatPrinterString = RequestStr("formatPrinterString","")
getXmlFiles = getPrinter = RequestStr("getXmlFiles","")



casecode = 0
If (reset<> "") Then 
    casecode = 1   '*** clear session when close basket window
ElseIf(newAdd<>"") Then
    casecode = 2   '*** when clicking on + sign to add a new item
ElseIf(fileList<>"") Then 
    casecode = 3 '*** Loading the basket
ElseIf(fileName<>"") Then
    casecode = 4 '*** Save the basket
ElseIf(printFileName<>"") Then
    casecode = 5 '*** Save printer xml
ElseIf(ditributeFileName<>"") Then
    'Response.Write(ditributeFileName)
    casecode = 6 '*** Save distribute xml
ElseIf(artikelNr<>"" AND setRelItem="" ) Then
    casecode = 7 '*** Delete a selected item
ElseIf(iteminfo<>"") Then
    casecode = 8 '*** New item add to basket session
ElseIf(upgrade<>"") Then
    casecode = 9 '*** upgrade session with changed rivision from database
ElseIf(setRelItem<>"") Then
    casecode = 10 '*** set related artikel info to basket
ElseIf(getPrinter<>"") Then
     casecode = 11 '*** get printer for the particular format 
ElseIf(formatPrinterString<>"") Then
     casecode = 12 '*** get a string sequence containing PrinterFormat with PrinterName(e.g.:A4@HpLager*A1@Cannon)    
ElseIf(getXmlFiles<>"") Then
     casecode = 13 '*** load the xml file name from the basket         
Else
    casecode = 14 '*** Default 
End If

 Select Case casecode
    Case 1 
           Session(BasketSession)= ""
           Session("relatedArtikels")=""
           Session("newAdd") = ""
           Session(BasketName) = "" 
           Call Quit("success")
    Case 2
           IF Session("newAdd") <> "" Then
              Call Quit("Added")
           Else  Call Quit("NullValue")
           End IF
    Case 3   
            Dim xml
	        Set xml = Server.CreateObject("Microsoft.XMLDOM")
	        xml.async = False	     
	        
	        xml.load (BASKET_OUTPUT & fileList)
            Dim total,heading,paragraph,testHTML,i,counter
	        counter = 0 
	        total = 0
	        total = xml.documentElement.childNodes.length
	        total = total \ 6 -1
            Session("loadString") = ""
            Session(BasketName) =  Split(fileList,".")(0)
            For i=0 to total
             Session("loadString")= Session("loadString") & xml.documentElement.childNodes(counter).text &"@@@@" & xml.documentElement.childNodes(counter+1).text &"@@@@" & xml.documentElement.childNodes(counter+2).text &"@@@@" & xml.documentElement.childNodes(counter+3).text & "@@@@" & xml.documentElement.childNodes(counter+4).text & "@@@@" & xml.documentElement.childNodes(counter+5).text & "****"
	         counter = counter + 6
            Next
            
            Session("loadString") = Left(Session("loadString"),Len(Session("loadString"))-4)
            Session(BasketSession)= Session("loadString")
            Set xml = Nothing
	        Call Quit("success")
    Case 4
           Dim arrArVr,a, BASKET_SAVE_DIR
           set FSO = Server.CreateObject("scripting.FileSystemObject")              
           BASKET_SAVE_DIR = BASKET_OUTPUT
           
           IF FSO.FileExists(BASKET_SAVE_DIR & fileName&".xml") Then
              FileDelete(BASKET_SAVE_DIR & fileName&".xml")
           End If
                      
           Session(BasketName) =  fileName
           set myFile = fso.CreateTextFile(BASKET_SAVE_DIR & fileName&".xml", true)
           arrArVr = Split(Session(BasketSession),"****")
           myFile.WriteLine("<Xml>") 
           For i=0 to UBound( arrArVr)             
              art = Split(arrArVr(i),"@@@@")              
              myFile.WriteLine("  <ArtikleNr>"&art(0)&"</ArtikleNr>") 
              myFile.WriteLine("  <Version>"&art(1)&"</Version>")  
              myFile.WriteLine("  <format>"&art(2)&"</format>")  
              myFile.WriteLine("  <filename>"& Replace(art(3),"@","\")&"</filename>")  
              myFile.WriteLine("  <filename1>"& art(4) &"</filename1>") 
              myFile.WriteLine("  <filename2>"& art(5) &"</filename2>") 
           Next
           myFile.WriteLine("</Xml>") 
           myFile.Close
           Session("newAdd") = ""
           Call Quit("success")
           '*** Else  Call Quit("duplicate")  
           '***End IF
    Case 5           
           outputDir = Session("printingdir")           
           If Not FolderExists(outputDir) Then
              CreateFolder(outputDir)
           End If
           
           set FSO = Server.CreateObject("scripting.FileSystemObject")
           set myFile = FSO.CreateTextFile(outputDir & "\" &"FullXML.xml", true)     
           
           myFile.WriteLine(Session("printXML"))               
           myFile.Close
           Call Quit("success")
           
    Case 6   
              
           outputDir = DISTRIBUTION_DIR & Session("DistOutputDirectory")  
           
           If Not FolderExists(outputDir) Then
               
              CreateFolder(outputDir)  
              
           End If
          
           '*** Delete the folder contents if already exists
           FileDelete(outputDir &"\*.*")
           
           '*** Copy the distribtue documents
           Dim distdocs,docpaths
           distdocs = Split(Session("distributedocs"),"****")           
           
           For i=0 to UBound( distdocs)
               docpaths = Split(distdocs(i),"*")
               If FileExists(docpaths(0)) Then
                   Call FileCopy(docpaths(0), docpaths(1))
               End If           
           Next
                  
           set FSO = Server.CreateObject("scripting.FileSystemObject")  
           
           set myFile = FSO.CreateTextFile(outputDir & "\" &"FullXML.xml", true)      
           
           myFile.WriteLine(Session("distributeXML"))               
           myFile.Close
           Call Quit("success")       
    Case 7 
            Dim arrArtVer,article
             IF Session(BasketSession) <> "" Then
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
                 IF Session(BasketSession) = "" Then
                   Session("newAdd") = ""
                 End IF
                 Call Quit("success")
              Else 
                 Call Quit("Session Time Out")
             End IF
    Case 8
       Dim stukLijst, artInfo,relTable,keyFields,relFilepath,fileSubPath,fullfileName
	   artInfo = Split(iteminfo,"@@@@")
	    'Response.Write("***********************artInfo/"&artInfo(1) &"/")
	   session("relfiletable") = artInfo(3)
	   session("keyfields") = artInfo(4)
	   Session("sid") = sid
	   Session("kitServerPath") = kitServerPath   
	   Session("printserverlocation") = printserverlocation  
	   relFilepath = GetRelFilePath(artInfo(0))
	   
	   
	   
	   fileSubPath = GetFileSubPathFromRelfilename(relFilepath)
	   
	   fullfileName = GetFileNameFromRelfilename(relFilepath)
	   
	   stukLijst = GetStuklijstNumber(artInfo(0))
	   brondocNum        = HasBornDoc(artInfo(0), Session(whichBasket), fileSubPath)
	   revInfo =  GetRevOrNonRevAppenNumber(artInfo(0), Session(whichBasket),artInfo(1),fileSubPath)
	   revInfo =  Split(revInfo,",")
	   NonRevAppendixNum = revInfo(1)
	   RevAppendixNum    = revInfo(0)
	   printNumber   = GetPrintNumber(artInfo(0), artInfo(1))	   
	   
	   
	   iteminfo = artInfo(0) & "@@@@"  & artInfo(1) & "@@@@"  & IIF(stukLijst>0,"Ja","Nee") & "@@@@"  & IIF(brondocNum = "True","Ja","Nee") & "@@@@"  &  NonRevAppendixNum &  "@@@@"  &  RevAppendixNum &  "@@@@"  &  printNumber 
	  
           IF Session(BasketSession) <> "" Then
             IF CheckForDuplicate(iteminfo) = true Then               
               Session(BasketSession) = Session(BasketSession) & "****" & iteminfo              
               BasketSize = Split(Session(BasketSession),"****")
               Session("newAdd") = "true"
               Call SortBasketSession()
               'Response.Write("***********************here")
              'Call Quit("success@@"&UBound(BasketSize)+1) 
               'Call Quit(UBound(BasketSize)+1) 
             Else 
               Call Quit("duplicate") 
             End IF
           Else 
             Session(BasketSession) = iteminfo
             Session("newAdd") = "true"
             Response.Write(Session(BasketSession))
             'Call Quit("success@@1")
             Call Quit("")
           End IF
    Case 9
          
          Dim artikleNr,rivision,fileFormat,sessionStr,str_artikle,arArtVer,my_article
          Dim rs, sql
          Response.Write("********************sql**********"& sql)
          IF Session(BasketSession) <> "" Then
           arArtVer = Split(Session(BasketSession),"****")
           For i=0 to UBound(arArtVer) 
            my_article = Split(arArtVer(i),"@@@@")
            str_artikle = str_artikle & "'" &my_article(0) & "'"& "," 
           Next
           str_artikle = Left(str_artikle,len(str_artikle)-1)
           sql = "SELECT item,revision,file_format,file_name FROM "& Session(whichBasket) & "_item_hit WHERE item in ("&str_artikle&")"
           Response.Write("********************sql**********"& sql)
           If RSOpen(rs, gDBConn, sql, True) Then
              While (Not rs.EOF)
                artikleNr = rs("item")     
                rivision = rs("revision")
                fileFormat = rs("file_format")
                filename = rs("file_name")
                sessionStr = sessionStr & artikleNr &"@@@@"&rivision&"@@@@"&fileFormat&"@@@@"&filename&"****"
              rs.MoveNext()
              Wend 
              sessionStr = Left(sessionStr,Len(sessionStr)-4)
              Session(BasketSession) = sessionStr
              Response.Write("********************sessionStr**********"& sessionStr)
			  Call SortBasketSession()
              Session("loadString") = ""
              Call Quit("success") 
           Else Call Quit("Error" & sql)      
           End IF
         End IF
    Case 10                      
           IF Session("relatedArtikels") <> "" Then
             IF Not InArray(Split(Session("relatedArtikels"),"****"),artikelNr) Then
               Session(BasketSession) = Session(BasketSession) & "****" & getRelatedArtikelInfo(gDBConn,"'" & artikelNr &"'", "'" & versionNr & "'")                                           
               Session("relatedArtikels") = Session("relatedArtikels") & "****" & artikelNr
			   Call SortBasketSession()
             Else 
               Call Quit("duplicate") 
             End IF             
           Else 
             Session(BasketSession)     = getRelatedArtikelInfo(gDBConn,"'" & artikelNr &"'", "'" & versionNr & "'") 
             Session("relatedArtikels") = artikelNr
			 Call SortBasketSession()
           End IF 
           
           '*** Set basket change status
           Session("newAdd") = "true"           
           
           BasketSize = Split(Session(BasketSession),"****")
           Call Quit("success@@"&UBound(BasketSize)+1) 
     Case 11
         Dim printers
         printers = Join(getPrinters(getPrinter),"*")
         Call Quit(printers) 
     Case 12
         Session("formatPrinterString") = formatPrinterString
         Call Quit("success")        
     Case 13
         Dim item1_,folder1_,fs1_,file1_
         file1_ = ""
         set fs1_ = CreateObject("Scripting.FileSystemObject")
         set folder1_ = fs1_.GetFolder(BASKET_OUTPUT)
         'get a list of files.
         For each item1_ in folder1_.Files
          file1_ = file1_ & IIf(file1_<>"","*","") & item1_.Name 
         Next
         Call Quit(file1_) 
     Case 14
          Call Quit("Error")     
    Case Else  Call Quit("Error")     
 End Select


 
Function CheckForDuplicate(item)
  Dim arrArtVer,arrItem,flag
  flag = true
  arrItem = Split(item,"@@@@")
  arrArtVer = Split(Session(BasketSession),"****")
  For i=0 to UBound(arrArtVer) 
   Dim article
   article = Split(arrArtVer(i),"@@@@")
   IF article(0) = arrItem(0) Then
    flag = false
    Exit For
   End IF 
  Next
  CheckForDuplicate = flag
End Function

Sub DeleteOtherItem(artikelNr,versionNr)  
   Dim newValues,items,newStr
   newValues = Split(Session(BasketSession),"****")
   For i=0 to UBound(newValues)
     items = Split(newValues(i),"@@@@")
     IF artikelNr <> items(0) Then
       newStr = newStr & items(0) & "@@@@" & items(1) & "@@@@" & items(2)& "@@@@" & items(3) & "@@@@" & items(4) & "@@@@" & items(5) & "@@@@" & items(6) & "****"  
     End IF
   Next
   newStr = Left(newStr,Len(newStr)-4)
   Session(BasketSession) = newStr
End Sub    
   
    
Sub DeleteFirstItem(artikelNr,versionNr)
   Session(BasketSession) = Replace(Session(BasketSession),artikelNr&"@@@@"&versionNr,"")
   Dim newValues,items,newStr
   newValues = Split(Session(BasketSession),"****")
   For i=1 to UBound(newValues)
     items = Split(newValues(i),"@@@@")
     newStr = newStr & items(0) & "@@@@" & items(1) & "@@@@" & items(2)& "@@@@" & items(3) & "@@@@" & items(4) & "@@@@" & items(5) & "@@@@" & items(6) & "****"  
   Next
   newStr = Left(newStr,Len(newStr)-4)
   Session(BasketSession) = newStr
End Sub


Sub SortBasketSession
	Dim Basket,i,j, temp
	Dim article1,article2
	Basket = Split(Session(BasketSession),"****")

	for i = UBound(Basket) - 1 To 0 Step -1
		for j= 0 to i
			article1 = Split(Basket(j),"@@@@")
			article2 = Split(Basket(j+1),"@@@@")
			
			'Article numbers can be non numeric so this sorting will not work
			if article1(0) > article2(0) then
				temp = Basket(j+1)
				Basket(j+1) = Basket(j)
				Basket(j) = temp
			end if
		next
	next
	temp = ""	
	For i=0 to UBound(Basket)
		temp = temp & Basket(i) & "****"
	Next
	temp = Left(temp,Len(temp)-4)
	Session(BasketSession) = temp
	Response.Write(temp)
End Sub

Sub Quit(retCode)
  '*** Cleanup.  
  If (retCode <> "") Then '   
    '*** Write error to document.
    Call Response.Write(retCode)
    Call Response.End()
  End If
End Sub


 %>