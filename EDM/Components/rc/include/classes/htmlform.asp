<%
'*******************************************************************************
'***                                                                         ***
'*** File       : htmlform.asp                                               ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 15-08-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: HTMLForm Classes (for uploading etc.)                      ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'***                                                                         ***
'*** Uploader Class                                                          ***
'***                                                                         ***
'*******************************************************************************
Class HTMLForm
  Private CR            '*** ANSI Carriage Return
  Private LF            '*** ANSI Line Feed
  Private CRLF          '*** ANSI Carriage Return & Line Feed
  Private m_Fields()    '*** Array to hold field objects
  Private m_FieldCount  '*** Number of fields parsed
  
  
  '*****************************************************************************
  '*** Constructor / Destructor
  '*****************************************************************************
  Private Sub Class_Initialize()
    '*** Initialize.
    ReDim m_Fields(-1)
    
    m_FieldCount = 0
    
    '*** Compile ANSI equivilants of carriage returns and line feeds.
    CR   = ChrB(Asc(vbCr))
    LF   = ChrB(Asc(vbLf))
    CRLF = CR & LF
    
    '*** Parse the data.
    Call parseData()
	End Sub
  
  
  Private Sub Class_Terminate()
    '*** Destroy field array.
    'Call clear()
	End Sub
  
  
  '*****************************************************************************
  '*** Properties (public)
  '*****************************************************************************
  Public Property Get Count()
    '*** Return number of fields found.
    Count = m_FieldCount
  End Property
  
  
  Public Default Property Get Fields(index)
    Dim i
    
    If IsNumeric(index) Then
      '*** Numeric index.
      i = CLng(index)
      
      If (i >= 0 And i <= UBound(m_Fields)) Then
        '*** Return the field object for the index specified.
        Set Fields = m_Fields(i)
        
        Exit Property
      End If
    Else
      '*** Loop through fields to find specified key.
      For i = 0 To UBound(m_Fields)
        If (UCase(m_Fields(i).Name) = UCase(index)) Then
          '*** Return the field object for the key specified.
          Set Fields = m_Fields(i)
          
          Exit Property
        End If
      Next
    End If
    
    '*** If no match found, return an empty field.
		Set Fields = New FieldObject
  End Property
  
  
  Public Property Get Submitted()
    '*** Return number of fields found.
    Submitted = (m_FieldCount > 0)
  End Property
  
  
  '*****************************************************************************
  '*** Public Functions (Methods)
  '*****************************************************************************
  
  
  '*****************************************************************************
  '*** Private Functions
  '*****************************************************************************
  Private Sub addField(name, value, contentType, binaryData)
    Dim oField
    
    '*** Resize field array.
    ReDim Preserve m_Fields(m_FieldCount)
    
    '*** Create new field object.
    Set oField = New FieldObject
    
    '*** Set field properties.
    oField.Name        = name
    oField.ContentType = contentType
    
    If (LenB(binaryData) = 0) Then
      '*** String field.
      oField.BLOB  = ChrB(0)
      oField.Value = value
    Else
      '*** Binary field (file).
      oField.BLOB     = binaryData
      oField.FileName = value
    End If
    
    '*** Put field object into array.
    Set m_Fields(m_FieldCount) = oField
    
    '*** Increment field count.
    m_FieldCount = m_FieldCount + 1
  End Sub
  
  
  Private Function clear()
    Dim i
    
    '*** Loop through field array.
    For i = 0 To UBound(m_Fields)
      '*** Remove element.
      Set m_Fields(i) = Nothing
    Next
    
    '*** Redimension field array.
    ReDim m_Fields(-1)
    
    '*** Reset field count.
    m_FieldCount = 0
  End Function
  
  
  Private Function extractChunkHeader(chunk)
    Dim headerStart  '*** Start Position
    Dim headerLen    '*** Length
    
    '*** Find first occurance of a line starting with 'Content-Disposition:'.
    headerStart = InStrB(1, chunk, CRLF & ABStr("Content-Disposition:"), vbTextCompare)
    
    '*** Only proceed if start found.
    If (headerStart > 0) Then
      '*** Adjust start position to start after the text 'Content-Disposition:'.
      headerStart = headerStart + 22
      
      '*** Find header lenght.
      headerLen = (InStrB(headerStart, chunk, CRLF) - headerStart)
      
      '*** Return header as Unicode string (if exist).
      If (headerLen > 0) Then extractChunkHeader = BStr(MidB(chunk, headerStart, headerLen))
    End If
  End Function
  
  
  Private Function extractChunkName(header)
    Dim nameStart  '*** Start Position
    Dim nameLen    '*** Length
    
    '*** Find first occurance of text ' name='.
    nameStart = InStr(1, header, " name=", vbTextCompare)
    
    '*** Only proceed if start found.
    If (nameStart > 0) Then
      '*** Adjust start position to start after the text ' name="'.
      nameStart = nameStart + 7
      
      '*** Find name lenght.
      nameLen = (InStr(nameStart, header, """") - nameStart)
      
      '*** Return header as Unicode string (if exist).
      If (nameLen > 0) Then extractChunkName = Mid(header, nameStart, nameLen)
    End If
  End Function
  
  
  Private Function extractChunkType(chunk)
    Dim typeStart  '*** Start Position
    Dim typeLen    '*** Length
		
		'*** Find first occurance of a line starting with 'Content-Type:'.
		typeStart = InStrB(1, chunk, CRLF & ABStr("Content-Type:"), vbTextCompare)
		
		'*** Only proceed if start found.
    If (typeStart > 0) Then
      '*** Adjust start position to start after the text 'Content-Type:'.
      typeStart = typeStart + 15
      
      '*** Find type lenght.
      typeLen = (InStrB(typeStart, chunk, CR) - typeStart)
      
      '*** Return header as Unicode string (if exist).
      If (typeLen > 0) Then extractChunkType = Trim(BStr(MidB(chunk, typeStart, typeLen)))
    End If
  End Function
  
  
  Private Function extractFileName(header)
    Dim nameStart  '*** Start Position
    Dim nameLen    '*** Length
    
    '*** Find first occurance of text 'filename='.
    nameStart = InStr(1, header, "filename=", vbTextCompare)
    
    '*** Only proceed if start found.
    If (nameStart > 0) Then
      '*** Adjust start position to start after the text 'filename="'.
      nameStart = nameStart + 10
      
      '*** Find name lenght.
      nameLen = (InStr(nameStart, header, """") - nameStart)
      
      '*** Return header as Unicode string (if exist).
      If (nameLen > 0) Then extractFileName = Mid(header, nameStart, nameLen)
    End If
  End Function
  
  
  Private Sub parseChunk(chunk)
    Dim binaryData   '*** Binary data
    Dim chunkType    '*** Content type of binary data
    Dim chunkHeader  '*** Chunk header
    Dim chunkName    '*** Chunk name
    Dim fileName     '*** File name
    Dim dataStart    '*** Start position of binary data
    
    '*** Extract chunk properties.
    chunkHeader = extractChunkHeader(chunk)
    chunkType   = extractChunkType(chunk)
    chunkName   = extractChunkName(chunkHeader)
    fileName    = extractFileName(chunkHeader)
    
    '*** Find first occurence of a blank line.
    dataStart = InStrB(1, chunk, CRLF & CRLF)
    
    '*** Extract chunk data (if found).
    If (dataStart > 0) Then binaryData = MidB(chunk, dataStart + 4)
    
    If (chunkType = "") Then
      '*** If the content type is not defined, then assume the field is a normal form field.
      Call addField(chunkName, BStr(binaryData), chunkType, ABStr(""))
    Else
      '*** Field is a binary field (probably file).
      Call addField(chunkName, fileName, chunkType, binaryData)
    End If
  End Sub
  
  
  Private Sub parseData()
    Dim binaryData  '*** Submitted data (binary)
    Dim chunkDelim  '*** Chunk delimeter.
    Dim chunkStart  '*** Start position of chunk data
    Dim chunkLen    '*** Length of chunk
    Dim chunkEnd    '*** Last position of chunk data
    Dim chunkData   '*** Binary contents of chunk
    
    '*** Exit when no data submitted!
    If (Request.TotalBytes = 0) Then Exit Sub
    
    '*** Get data.
    binaryData = Request.BinaryRead(Request.TotalBytes)
    
    '*** Find start position.
    chunkStart = InStrB(1, binaryData, CRLF)
    
    '*** Get chunk delimeter.
    chunkDelim = MidB(binaryData, 1, chunkStart - 1)
    
    '*** Find start position after delimeter.
    chunkStart = InStrB(1, binaryData, chunkDelim & CRLF)
    
    While (chunkStart > 0)
      '*** Find the end position (after the start position).
      chunkEnd = InStrB(chunkStart + 1, binaryData, chunkDelim) - 2
      
      '*** Determine length of chunk.
      chunkLen = (chunkEnd - chunkStart)
      
      '*** Get chunk data.
      chunkData = MidB(binaryData, chunkStart, chunkLen)
			
			'*** Parse chunk data.
			Call parseChunk(chunkData)
			
			'*** Look for next chunk after the start position.
			chunkStart = InStrB(chunkStart + 1, binaryData, chunkDelim & CRLF)
    Wend
  End Sub
End Class



'*******************************************************************************
'***                                                                         ***
'*** FieldObject Class                                                       ***
'***                                                                         ***
'*******************************************************************************
Class FieldObject
  Public ContentType  '*** Content/Mime type of file.
  Public Name         '*** Name of the field defined in form
  
  Private m_BLOBData  '*** Binary data
  Private m_BLOBSize  '*** Byte size of binary data
  Private m_BLOBText  '*** Text buffer
  Private m_FileExt   '*** File extension
  Private m_FileName  '*** File name
  Private m_FilePath  '*** File path on client
  Private m_Value     '*** Unicode value of field
  
  
  '*****************************************************************************
  '*** Properties (public)
  '*****************************************************************************
  Public Property Get BLOB()
    '*** Return binary data.
    BLOB = m_BLOBData
  End Property
  
  Public Property Let BLOB(val)
    '*** Store binary data and it's lenght.
    m_BLOBData = val
    m_BLOBSize = LenB(m_BLOBData)
  End Property
  
  
  Public Property Get FileExt()
    '*** Return file extension.
    FileExt = m_FileExt
  End Property
  
  
  Public Property Get FileName()
    '*** Return file name.
    FileName = m_FileName
  End Property
  
  Public Property Let FileName(val)
    Dim pos
    
    '*** Default values.
    m_FilePath = ""
    m_FileName = val
    m_FileExt  = ""
    
    pos = InStrRev(m_FileName, "\")
    
    If (pos > 0) Then
      '*** Extract path + base name.
      m_FilePath = Mid(m_FileName, 1, pos - 1)
      m_FileName = Mid(m_FileName, pos + 1)
    End If
    
    pos = InStrRev(m_FileName, ".")
    
    '*** Extract extension.
    If (pos > 0) Then m_FileExt = Mid(m_FileName, pos + 1)
  End Property
  
  
  Public Property Get FilePath()
    '*** Return file path.
    FilePath = m_FilePath
  End Property
  
  
  Public Property Get FileSize()
    '*** Return file size.
    FileSize = m_BLOBSize
  End Property
  
  
  Public Default Property Get Value()
    '*** Return value.
    Value = m_Value
  End Property
  
  Public Property Let Value(val)
    '*** Set value.
    m_Value = val
  End Property
  
  
  '*****************************************************************************
  '*** Public Functions (Methods)
  '*****************************************************************************
  Public Function BLOBAsText()
    '*** Convert binary data (BLOB) to text?
		If (m_BLOBSize > 0 And Len(m_BLOBText) = 0) Then m_BLOBText = BStr(m_BLOBData)
		
		'*** Return Unicode Text.
		BLOBAsText = m_BLOBText
	End Function
  
  
  Public Function SaveAs(fullPath)
    Dim objStream
    
    '*** Don't save empty files.
    If (m_BLOBSize = 0 Or fullPath = "") Then Exit Function
    
    '*** Create Stream object.
    Set objStream = Server.CreateObject("ADODB.Stream")
    
    '*** Let stream know we are working with binary data (1 = adTypeBinary).
    objStream.Type = 1
    
    '*** Open stream.
    Call objStream.Open()
    
    '*** Write binary data to stream.
    Call objStream.Write(ASCIIToBytes(m_BLOBData))
    Response.Write("*****************fullPath"& fullPath)
    '*** Save the binary data to file system (2 = adSaveCreateOverWrite).
    Call objStream.SaveToFile(fullPath, 2)
    
    '*** Close the stream object
    Call objStream.Close()
    
    '*** Release objects.
    Set objStream = Nothing
    
    '*** Return succes/failure.
    SaveAs = FileSaved(fullPath)
	End Function
	
	
	Public Function ToInt()
	  If IsNumeric(m_Value) Then
	    '*** Return value as integer.
	    ToInt = CInt(m_Value)
	  Else
	    '*** Return default value.
	    ToInt = 0
	  End If
	End Function
	
	
	'*****************************************************************************
  '*** Private Functions
  '*****************************************************************************
  Private Function ASCIIToBytes(binaryData)
    Dim rs, dataLen
    
    '*** Get number of bytes.
    dataLen = LenB(binaryData)
    Set rs  = Server.CreateObject("ADODB.Recordset")
    
    '*** Create field in an empty recordset to hold binary data
    Call rs.Fields.Append("BinaryData", 205, dataLen)
    
    '*** Open recordset.
    Call rs.Open()
    
    '*** Add a new record to recordset.
    Call rs.AddNew()
    
    '*** Populate field with binary data.
    Call rs.Fields("BinaryData").AppendChunk(binaryData & ChrB(0))
    
    '*** Update / Convert Binary Data.
    Call rs.Update()
    
    '*** Request binary data and save to stream.
    ASCIIToBytes = rs.Fields("BinaryData").GetChunk(dataLen)
    
    '*** Close recordset.
    Call rs.Close()
    
    '*** Release recordset from memory.
    Set rs = Nothing
  End Function
  
  
  Private Function FileSaved(filename)
    Dim fso
    
    '*** Create FileSystem object.
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    
    '*** Check if files exist.
    FileSaved = fso.FileExists(filename)
    
    '*** Delete object.
    Set fso = Nothing
  End Function
End Class
%>