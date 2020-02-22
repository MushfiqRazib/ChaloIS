<!-- #include file="./common.asp"                   -->
<!-- #include file="./include/functions/system.asp" -->
<%
Dim docPath,oStream,docId, docType
docPath =  Request("docpath")
docPath =  Replace(docPath,"$$$$","\")
docType =  Request("ext")
docId   =  Request("name")

If FileExists(docPath) Then
  '*** Create a stream object.
  Set oStream = Server.CreateObject("ADODB.Stream")
  
  '*** Open specified file...
  oStream.Type = 1
  oStream.Open
  oStream.LoadFromFile docPath      
  docType = UCase(docType)
  
  '*** Determine MIME type.
  Select Case docType
    Case "DWF"
      Response.ContentType = "drawing/x-dwf"   
    Case "DWG"
      Response.ContentType = "drawing/x-dwf"        
    Case "PDF"
      Response.ContentType = "application/pdf"          
    Case "TIFF"
      Response.ContentType = "Image/tiff"          
    Case "TIF"
      Response.ContentType = "Image/tiff"            
    Case Else
      '*** Default MIME type.
      Response.ContentType = "application/octet-stream"      
  End Select   
  
  '*** Output the contents of the stream object.
  Response.AddHeader "Content-Disposition", "inline; filename=" & docId & "." & docType
  
  Response.BinaryWrite oStream.Read    
     
  '*** Close stream.
  Call oStream.Close()
  
  '*** Clean up...
  Set oStream = Nothing
End If


 %>