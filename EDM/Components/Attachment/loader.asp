<!-- #include file="./functions.asp" -->
<%
Dim docPath,oStream,docType
   
   '*** Set the view file 
  If(Request("setpath")<>"") Then
       docPath = Request("setpath")
       docPath = Replace(docPath,"@","\")
       Session("viewfile") = docPath    
       Response.End()
    
  Elseif(Request("loaddoc")<>"") Then
      '*** Retrieve the viewfile from session
      docPath =  Session("viewfile")         
          
      '*** Load the file to view in the viewer   
      If FileExists(docPath) Then
      '*** Create a stream object.
      Set oStream = Server.CreateObject("ADODB.Stream")
      
      '*** Open specified file...
      oStream.Type = 1
      oStream.Open
      oStream.LoadFromFile docPath      
      
      '*** Determine doctype.
      If UCase(Right(docPath,3))="DWF" Then 
        docType = "DWF"
      ElseIf UCase(Right(docPath,3))="DWG" Then   
        docType = "DWG"   
      ElseIf UCase(Right(docPath,3))="PDF" Then   
        docType = "PDF"  
      ElseIf UCase(Right(docPath,3))="TIF" Then   
        docType = "TIFF" 
      ElseIf UCase(Right(docPath,4))="TIFF" Then   
        docType = "TIFF"    
      Else  
        docType = "text/plain; charset=us-ascii"  
      End If        
      
      '*** Determine MIME type.
      Select Case UCase(docType)
        Case "DWF"
          Response.ContentType = "drawing/x-dwf"    
        Case "DWG"
          Response.ContentType = "drawing/x-dwf"   
        Case "PDF"
          Response.ContentType = "application/pdf"    
        Case "TIFF"
          Response.ContentType = "image/tiff"                                      
        Case Else
          '*** Default MIME type.
          Response.ContentType = "application/octet-stream"
      End Select 
        
      '*** Output the contents of the stream object.
      Response.AddHeader "Content-Disposition", "inline; filename=file.dwf"
      
      '*** Read from server write to client
      Response.BinaryWrite oStream.Read  
       
      '*** Close stream.
      Call oStream.Close()
      
      '*** Clean up...
      Set oStream = Nothing
    End If
    
  End If
  
  

 %>