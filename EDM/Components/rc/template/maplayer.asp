<!-- #include file="./common.asp" -->
<%
'*******************************************************************************
'***                                                                         ***
'*** File       : maplayer.asp                                               ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 13-03-2006                                                 ***
'*** Copyright  : (C) 2006 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Common interface for adding map layers                     ***
'***                                                                         ***
'*******************************************************************************

Dim mwfDoc, fso, mwxDir, mwxFileName, mwxFile, colorList

'*** Create File System Object.
Set fso = CreateObject("Scripting.FileSystemObject")

'*** Get temporary directory and filename.
mwxDir      = Request.ServerVariables("PATH_TRANSLATED")
mwxDir      = Left(mwxDir, InstrRev(mwxDir, "\"))
mwxFileName = mwxDir & fso.GetTempName()

If IsObject(Session("ColorList")) Then
  '*** Get existing color list.
  Set colorList = Session("ColorList")
Else
  '*** Create new color list.
  Set colorList = Server.CreateObject("Scripting.Dictionary")
End If

'*** Create temporary file.
Set mwxFile = fso.CreateTextFile(mwxFileName, True)

'*** Write data to temporary file.
Select Case UCase(Request("LT"))
  Case "POLYGON"
    Call CreatePolygonMWX(mwxFile, colorList)
  
  Case "POLYLINE"
    Call CreatePolylineMWX(mwxFile, colorList)
  
  Case Else
    '*** Unsupported layer types.
    '?
End Select

Call mwxFile.Close()

'*** Read XML file.
Set mwfDoc = Server.CreateObject("Autodesk.MapWindowFile")

mwfDoc.ValidateMwx = False
mwfDoc.CompressMwf = False

mwfDoc.ReadFromMwx(mwxFileName)

'*** Delete temporary MWX file.
If fso.FileExists(mwxFileName) Then Call fso.DeleteFile(mwxFileName)

'*** Clean up.
Set mwxFile = Nothing
Set fso     = Nothing

'*** Return the binary MLF information.
Response.Expires     = -1
Response.Buffer      = True
Response.ContentType = "application/x-mlf"

Response.BinaryWrite(mwfDoc.WriteToMlfStream("", MGLayer.Item("MapLayerName")))

Response.End
%>