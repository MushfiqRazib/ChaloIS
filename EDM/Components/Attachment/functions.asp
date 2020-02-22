<!-- #include file="../config.asp"     -->
<!-- #include file="../qb/includes/common.asp"  -->
<!-- #include file="../qb/includes/postgres.asp"  -->
<%

'item.DateCreated = file creation date
'item.DateLastModified = file last modification date

sub ListFolderContents(path)
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


   '*** This method creates the select string for
   '*** dropdownlist version
   '*** version specific FileName = ArtikelNr + "_" + version + "_" + desc + "." + ext
   '*** general document FileName = ArtikelNr + "_" + "XX" + "_" + desc + "." + ext
Function LoadDropVersie(path,ArtikelNr,version)
   
     dim fs, folder, file, item, versie, selectString, versies,partsOfName
     
     'selectString = selectString &  "<option value=''>--Geen Selectie--</option>  " 
          
     If FolderExists(path) Then
     
         selectString = "<select id=""drpVersie"" name=""drpVersie"" class='Button' style=""width:140px;font-weight:normal"" onchange='reloadVersieGrid()'  >"
         set fs = CreateObject("Scripting.FileSystemObject")
         set folder = fs.GetFolder(path)
         
         'Get a list of files.         
	 for each item in folder.Files
		file = item.Name                         
		versie = mid(file,len(artikelnr)+2,2)
		If Len(versie) > 0 Then '*** version exists
		   'versie = partsOfName(0)   
		   '*** If not alread saved or not null or not general (XX)                                           
		   If Not InArray(Split(versies,"*"), versie) AND versie<>"" AND UCase(versie)<>"X" Then         
		       If version=versie Then
			   selectString = selectString &  "<option value=" & versie& " selected> "& versie &"</option>  "                                                                                                                                                  
		       Else
			   selectString = selectString &  "<option value=" & versie& ">"& versie &"</option>  "                                                                                                                                                  
		       End If
		       versies = versies & IIf(versies<>"","*","") & versie                         
		   End If 
		End If                  
	 next                     
         
         '*** Return select string                    
         selectString = selectString & "</select>"                       
     End If
     
     '*** Return select string for dropdown list 
     LoadDropVersie = selectString
End Function   

   
Function CreateDataGrid(path, gridId, ArtikelNr,version)     
    
     'Create grid header part
     Dim tableString, ColHeader, Columns, i, item,artPart,name,partsOfName
	 If Session("loggedIn")="TRUE" Then
		Columns = "Bestand, Datum, Afmeting,,,Printen"
	 Else
		Columns = "Bestand, Datum, Afmeting,,,Printen"
	 End If
     ColHeader = Split(Columns,",")
     tableString = "<TABLE id='FileInfo' cellspacing='0' cellpadding='0' class='Datagrid' >"    
     tableString = tableString & "<THEAD><TR>"
     '*** Create header of datagrid     
     For i = 0 To UBound(ColHeader)
        tableString = tableString & "<TH  class='Scroll"& gridId &"' nowrap>" & ColHeader(i) & "</TH>"                                 	                    
     Next
     tableString = tableString & "</TR></THEAD>"          
     tableString = tableString & "<TBODY>"
     
     If FolderExists(path) Then
         dim fs, folder, file,rowCounter,fileName,Ext
         fileInfo = ""
         set fs = CreateObject("Scripting.FileSystemObject")          
         set folder = fs.GetFolder(path)
         rowCounter = 0
         
         '*** Create grid body.  
         for each item in folder.Files
            file = item.Name
           
	    If (len(file) > len(artikelnr & "_" & version & ".X") OR UCase(trim(file)) = UCase(trim(artikelnr) & "_" & trim(version) & ".dwg")) AND Left(file,len(artikelnr)) = artikelnr Then
		versie = mid(file,len(artikelnr)+2,2)
		
	    If Len(versie) > 0 Then '*** version exists                 
                    
                    If versie<>"" AND UCase(versie)<>"X" AND versie = version  AND gridId = "GridSpecific" Then  
                        
                        Call addRowString(tableString,rowCounter,item,path)
                        rowCounter = rowCounter + 1    
                        
                    ElseIf UCase(versie)= "X" AND gridId = "GridGeneral"  Then 
                        Call addRowString(tableString,rowCounter,item,path)
                        rowCounter = rowCounter + 1                     
                    End If                    
                 End If                                                        
            End If
         next   
         
     End If      
     tableString = tableString & "</TBODY></TABLE>"      
     CreateDataGrid = tableString
      
   End Function
   
Function CreateBaseMaterialDataGrid(path, gridId, ArtikelNr)     
    
     'Create grid header part
     Dim tableString, ColHeader, Columns, i, item,artPart,name,partsOfName
	 Columns = "Bestand, Datum, Afmeting,,"
     ColHeader = Split(Columns,",")
     tableString = "<TABLE id='FileInfo' cellspacing='0' cellpadding='0' class='Datagrid' >"    
     tableString = tableString & "<THEAD><TR>"
     '*** Create header of datagrid     
     For i = 0 To UBound(ColHeader)
        tableString = tableString & "<TH  class='Scroll"& gridId &"' nowrap>" & ColHeader(i) & "</TH>"                                 	                    
     Next
     tableString = tableString & "</TR></THEAD>"          
     tableString = tableString & "<TBODY>"
    
     If FolderExists(path) Then
         dim fs, folder, file,rowCounter,fileName,Ext
         fileInfo = ""
         set fs = CreateObject("Scripting.FileSystemObject")          
         set folder = fs.GetFolder(path)
         rowCounter = 0
         
         '*** Create grid body.  
         for each item in folder.Files
            fileName = item.Name           
			'If InStrRev(fileName,ArtikelNr)=1 Then			
				Call addBaseRowString(tableString,rowCounter,item,path)
				rowCounter = rowCounter + 1                
            'End If
         next   
         
     End If      
     tableString = tableString & "</TBODY></TABLE>"      
     CreateBaseMaterialDataGrid = tableString
   End Function

Sub addBaseRowString(tableString,rowCounter,file,path )  
    Dim fileNExt,k,filePrintformat,value 
	
	fileNExt = Split(file.Name,".")
	'If UBound(fileNExt) >0 Then 
		tableString = tableString & "<TR id='rowId_" & rowCounter & "' >" 
		tableString = tableString & "<TD class='TDLeft' nowrap>" & file.Name & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & file.DateLastModified & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & file.Size & "</TD>"        
		
		fileName = Replace(path & file.Name,"\","@")
		'If user logged in , only then he can delete an appendix.
		'If Session("loggedIn")="TRUE" Then
			'tableString = tableString & "<TD class='TDCenter' nowrap>" & "<img class='Link' src='./image/delete.gif' alt='Verwijder de bijlage' onclick='deleteRow(this,"""& fileName &""")'></img>" & "</TD>" 	
		'End If

		tableString = tableString & "<TD class='TDCenter' nowrap>" & "<img class='Link' src='./image/view.gif' alt='Toon de bijlage' onclick='viewFile("""& fileName &""")'></img>" & "</TD>" 
		tableString = tableString & "<TD class='TDCenter' nowrap>" & "<img class='Link' src='./image/download.jpg' style='width:18px;height:18px;' alt='Toon de 	bijlage' onclick='Download("""& fileName &""")'></img>" & "</TD>" 		
		tableString = tableString & "</TR>"  
	'End If
End Sub
   
Sub addRowString(tableString,rowCounter,file,path )  
    Dim fileNExt,k,filePrintformat,value 
	Dim allFormats
	 
	'Get all print formats
	allFormats  = getFormat("Geen Printen")
	
	fileNExt = Split(file.Name,".")
	If UBound(fileNExt) >0 Then 
		tableString = tableString & "<TR id='rowId_" & rowCounter & "' >" 
		tableString = tableString & "<TD class='TDLeft' nowrap>" & file.Name & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & file.DateCreated & "</TD>"
		tableString = tableString & "<TD class='TDCenter' nowrap>" & file.Size & "</TD>"        
		
		fileName = Replace(path & file.Name,"\","@")
		'If user logged in , only then he can delete an appendix.
		If Session("loggedIn")="TRUE" Then
			tableString = tableString & "<TD class='TDCenter' nowrap>" & "<img class='Link' src='./image/delete.gif' alt='Verwijder de bijlage' onclick='deleteRow(this,"""& fileName &""")'></img>" & "</TD>" 	
		End If
        tableString = tableString & "<TD class='TDCenter' nowrap>" & "<img class='Link' src='./image/download.jpg' style='width:18px;height:18px;' alt='Toon de 	bijlage' onclick='Download("""& fileName &""")'></img>" & "</TD>" 		
		tableString = tableString & "<TD class='TDCenter' nowrap>" & "<img class='Link' src='./image/view.gif' alt='Toon de bijlage' onclick='viewFile("""& fileName &""")'></img>" & "</TD>" 

		filePrintformat = GetFilePrintFormat(file.Name)
		
		'Only 'DWF','TIF', OR 'PDF' files are printable
		IF UCase(fileNExt(1))="DWF" OR UCase(fileNExt(1))="TIF" OR UCase(fileNExt(1))="PDF" Then
			tableString = tableString & "<TD class='TDCenter' nowrap>"&"<select id=printen_" &rowCounter & " onchange='printableAttachment(this, """&file.Name&""")'>"
			
			For k=0 to UBound(allFormats)
				value = IIF(allFormats(k)="Geen Printen",0,allFormats(k))
				If allFormats(k)=filePrintformat Then
					tableString = tableString &  "<option value=" & value& " selected> "& allFormats(k) &"</option>"
				Else
					tableString = tableString &  "<option value=" & value& ">"& allFormats(k) &"</option>"
				End If
			Next
			tableString = tableString &"</select>"& "</TD>"
		Else
			tableString = tableString & "<TD  class='TDCenter' nowrap>"&"<select style='width:105px;' disabled='true'  ><option value= 'Geen Printen' selected></option></select>"&"</TD>"
		End If
		tableString = tableString & "</TR>"  
	End If
End Sub



Function GetFilePrintFormat(file)
	Dim printformat, rs, sql
	
	printformat = "Geen Printen"
	sql = "SELECT FORMAT FROM PRINTEN WHERE APPENDIXNAME = '" & file & "'"
	
	If RSOpen(rs, gDBConn, sql, True) Then
		printformat = rs("FORMAT")
	End If
	
	GetFilePrintFormat = printformat
End Function


Function GetFileRelativePath(mcodeField,revField, matcode, rev, sqlFrom)
	Dim rs, sql,filePath	
	sql = "SELECT relfilename FROM "& sqlFrom &" WHERE "& mcodeField &" = '" & matcode & "' and "& revField &"='" & rev & "'"	
	If RSOpen(rs, gDBConn, sql, True) Then
		filePath = rs("relfilename")
	End If
	
	GetFileRelativePath = filePath
End Function

Function GetFileRelativePathForBaseMaterial(mcodeField, matcode, sqlFrom)
	Dim rs, sql,filePath	
	sql = "SELECT relfilename FROM "& sqlFrom &" WHERE "& mcodeField &" = '" & matcode & "'"
	If RSOpen(rs, gDBConn, sql, True) Then
		filePath = rs("relfilename")
	End If
	
	GetFileRelativePathForBaseMaterial = filePath
End Function


Function getFormat(default_)
   Dim mydoc,xmlf,NodeList,printers,Node,format
   format = default_
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



   
   %>

   