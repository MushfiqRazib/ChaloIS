<!-- #include file="./functions.asp" -->
<%

 Dim ArtikelNr, docPath,version,File_Subpath, RCorVA, DOC_DIR,gridId, AppendixName, Format
 Dim reload, itemcheck,casecode,task
 
 reload = Request("reload")
 itemcheck = Request("itemcheck")
 AppendixName = Request("appendixname")
 task = Request("task")
 Format = Request("format")
  
 Sub WriteLog(msg)
    Dim fs,fname
    set fs=Server.CreateObject("Scripting.FileSystemObject")
    set fname=fs.CreateTextFile("E:\Projects\PSOM\OBrowser\log.txt",true)
    fname.WriteLine(vbcrlf  & msg )
    fname.Close
    set fname=nothing
    set fs=nothing
End Sub


If (reload = "true") Then 
    casecode = 1 '*** reload version specific datagrid
ElseIf(itemcheck="true") Then
    casecode = 2 '*** check item 
ElseIf(AppendixName<>"") Then
	casecode = 3 '*** add\update Printen table for printing
ElseIf(task="true") Then
    casecode = 4
Else
    casecode = 5 '*** default and do nothing
End If

Select Case casecode
    Case 1   
           
           ArtikelNr = Request("artikelnr")
           version   = Request("version")
           If version<>"X" Then
              Session("version") = version
           End If
           RCorVA    = Request("rc")
           File_Subpath = Request("File_Subpath")
           File_Subpath = Replace(File_Subpath,"@","\") 
           gridId = Request("gridId")
   
          '*** Check if duplicate item selected by artikelno and revision                    
          
          
          docPath    = DocBasePath & File_Subpath      
          Dim tableString
          
          tableString = CreateDataGrid(docPath,gridId,ArtikelNr,version)
          Response.Write tableString
          Response.End()           
    Case 2
          docPath = Request("docPath")
          docPath = Replace(docPath,"@","\")
         
          If FileExists(docPath) Then
            Response.Write "duplicate"
          Else
            Response.Write "uploadable"
          End If  
    Case 3
		  Dim rs, sql		  
		  
		  sql = "SELECT APPENDIXNAME FROM PRINTEN WHERE APPENDIXNAME = '" & AppendixName & "'"
		  If RSOpen(rs, gDBConn, sql , True) Then 
				IF Format<>"0" Then
					Call DBExecute(gDBConn, "UPDATE PRINTEN SET FORMAT='"&Format&"' WHERE APPENDIXNAME = '"&AppendixName&"'", False)
				Else
					Call DBExecute(gDBConn, "DELETE FROM PRINTEN WHERE APPENDIXNAME = '"&AppendixName&"'", False)
					
				End IF
		  Else
				Call DBExecute(gDBConn, "INSERT INTO PRINTEN VALUES('"&AppendixName&"', '"&Format&"')", False)
		  End If
       Case 4   
           
           ArtikelNr = Request("artikelnr")
           version   = Request("version")
           If version<>"X" Then
              Session("version") = version
           End If
           RCorVA    = Request("rc")
           File_Subpath = Request("File_Subpath")
           File_Subpath = Replace(File_Subpath,"@","\") 
           gridId = Request("gridId")
   
          '*** Check if duplicate item selected by artikelno and revision                    
          
          
          docPath    = DocBasePath & File_Subpath      
          Dim taskTableString
          
          taskTableString = CreateBaseMaterialDataGrid(docPath,gridId,ArtikelNr)
          Response.Write taskTableString
          Response.End()           
     Case Else  Call Quit("Error")     
End Select

Sub Quit(retCode)
  '*** Cleanup.  
  If (retCode <> "") Then    
    '*** Write error to document.
    Call Response.Write(retCode)
    Call Response.End()
  End If
End Sub
 
 
 








%>