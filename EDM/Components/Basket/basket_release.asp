<!-- #include file="../rc/include/functions/system.asp" -->
<!-- #include file="../rc/include/functions/custom.asp" -->
<!-- #include file="./functions.asp"      -->

<%
'*******************************************************************************
'***                                                                         ***
'*** File       : item_release.asp                                           ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 29-08-2006                                                 ***
'*** Copyright  : (C) 2006 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Release Candidate                                          ***
'***                                                                         ***
'*******************************************************************************

Dim rs, sqlParams(3)
Dim sql, itemCode, itemRev, itemRevStatus, allowOldRev,itemArr
Dim rcPath, rcFileName, vaPath, vaSubpath,cout,i, ErrorForArtikel, VrijgeveErrorStatus, secSubpath

IF (Session(BasketSession) = "") Then
  Call Quit("NO DATA") 
End IF

'Response.Write("ttttttttttttttttttttttttttttt" & Session(BasketSession))
'*****************************************************************************
'*** The following session holds the Processed item successfully completed ***
'*****************************************************************************
Session("ItemProcessingComplete") = ""
itemArr = Session(BasketSession)

itemArr = Split(Session(BasketSession),"****")
For i=0 to UBound(itemArr)
    
    Dim items
    items = Split(itemArr(i),"@@@@")
    itemCode = items(0)
    itemRev  = items(1)
    
    '*** Get parameters.
    allowOldRev  = (RequestInt("old", 0) = 1)
    sqlParams(0) = SQLEnc(itemCode)
    sqlParams(1) = SQLEnc(itemRev)
    sqlParams(2) = ""
    sqlParams(3) = SQLEnc(gUserName)
    ErrorForArtikel = ""
    
        '*******************************************************************************
        '*** Check presence of required parameters
        '*******************************************************************************
        'If (itemCode = "" Or itemRev = "") Then Call Quit("Ontbrekende parameters!")
        If (itemCode = "" Or itemRev = "") Then ErrorForArtikel = "Ontbrekende parameters!"
        
        
        If ErrorForArtikel = "" Then  '*** Error Check-1

            '*******************************************************************************
            '*** Check presence of item within 'Release Candidates'
            '*******************************************************************************
            sql = SPrintf("SELECT * FROM rc_item_hit WHERE item = {0} AND revision = {1}", sqlParams)

            If RSOpen(rs, gDBConn, sql, True) Then
              '*** Get file info.
              
              rcPath     = PATH_RC & rs("file_subpath")
              rcFileName = rs("file_name")
             
              
            Else
              '*** Item does not exist in RC.
              'Call Quit("Artikel " & itemCode & " Rev. " & itemRev & " niet gevonden in Release Candidates.")          
              ErrorForArtikel = "Artikel " & itemCode & " Rev. " & itemRev & " niet gevonden in Release Candidates."
              'Response.Write("ErrorForArtikel" & ErrorForArtikel)
            End If
                             
            If ErrorForArtikel = "" Then   '*** Error Check-2
            
                '*******************************************************************************
                '*** Check presence of item within 'Glovia'
                '*******************************************************************************
                'If Not itemInGlovia(itemCode) Then Call Quit("Artikelnummer " & itemCode & " niet gevonden in Glovia.")
                'If Not itemInGlovia(itemCode) Then ErrorForArtikel = "Artikelnummer " & itemCode & " niet gevonden in Glovia."
               
               If ErrorForArtikel = "" Then  '*** Error Check-3
               
                    '*******************************************************************************
                    '*** Check item revision within 'Vrijgegeven Archief'
                    '*******************************************************************************
                    itemRevStatus = getRevisionStatus(itemCode, itemRev)

                    If (itemRevStatus = 1) Then
                      '*** Revision already exist.
                      'Call Quit("Revisie " & itemRev & " bestaat al voor artikelnummer " & itemCode & ".")
                      ErrorForArtikel = "Revisie " & itemRev & " bestaat al voor artikelnummer " & itemCode & "."
					  Call DBExecute(gDBConn, "DELETE FROM rc_item_hit WHERE item = "& sqlParams(0), False)
					  'Response.Write "<script>alert("& sqlParams(0)& vbcrlf & sqlParams(1) &")</script>"
					  Call DeleteItemFromBasketSession(sqlParams(0),sqlParams(1))
                    ElseIf (itemRevStatus = -1 And Not allowOldRev) Then
                      '*** This an old revision, with no permission to release it.
                      'Call Quit("OLD_REVISION")
                      ErrorForArtikel = "OLD_REVISION"
					  Call DBExecute(gDBConn, "DELETE FROM rc_item_hit WHERE item = "& sqlParams(0), False)
					   'Response.Write "<script>alert("& sqlParams(0)& vbcrlf & sqlParams(1) &")</script>"
					  Call DeleteItemFromBasketSession(sqlParams(0),sqlParams(1))
                    End If

                    If ErrorForArtikel = "" Then  '*** Error Check-4
                    
                        '*******************************************************************************
                        '*** Create required directories
                        '*******************************************************************************
                        vaSubpath = Left(itemCode, 2) 
                        vaPath    = DocBasePath & vaSubpath

                        'If Not CreateFolder(vaPath) Then Call Quit("Directorie " & vaPath & " kan niet worden aangemaakt.")
                        If Not CreateFolder(vaPath) Then ErrorForArtikel = "Directorie " & vaPath & " kan niet worden aangemaakt."


                        If ErrorForArtikel = "" Then  '*** Error Check-5
                        
                            '*** Create second subdir.
			    secSubpath = Left(itemCode, 5)
                            vaSubpath = vaSubpath & "\" & Right(secSubpath,3) & "\"
                            vaPath    = DocBasePath & vaSubpath 

                            'If Not CreateFolder(vaPath) Then Call Quit("Directorie " & vaPath & " kan niet worden aangemaakt.")
                            If Not CreateFolder(vaPath) Then ErrorForArtikel = "Directorie " & vaPath & " kan niet worden aangemaakt."
                            
                            If ErrorForArtikel = "" Then      '*** Error Check-6

                                '*******************************************************************************
                                '*** Check file existence within 'Vrijgegeven Archief'
                                '*******************************************************************************
                                'If FileExists(vaPath & rcFileName) Then Call Quit("Bestand " & vaPath & rcFileName & " bestaat al.")
                                If FileExists(vaPath & rcFileName) Then ErrorForArtikel = "Bestand " & vaPath & rcFileName & " bestaat al."
                                
                                If ErrorForArtikel = "" Then      '*** Error Check-7

                                    '*******************************************************************************
                                    '*** Move files from 'Release Candidates' to 'Vrijgegeven Archief'
                                    '*******************************************************************************
                                    'Call MoveFiles(rcPath, itemCode & "_" & itemRev & ".*", vaPath)
                                    Call MoveFiles(rcPath, itemCode & "_*.*", vaPath)


                                    '*******************************************************************************
                                    '*** Move records from 'Release Candidates' to 'Vrijgegeven Archief'
                                    '*******************************************************************************
                                    If (itemRevStatus = 0) Then
                                      '*** Delete current revision from VA (if exist).
                                      Call DBExecute(gDBConn, "DELETE FROM va_item_hit WHERE item = "& sqlParams(0), False)
                                      
                                      '*** Copy record from RC to VA.
                                      sqlParams(2) = SQLEnc(vaSubpath)
                                      sql          = "INSERT INTO va_item_hit (item, revision, description, file_subpath, file_name, file_type, file_createdby, file_date, file_format, releasedby, validated) " & _
                                                     "SELECT item, revision, description, " & Replace(sqlParams(2),"\","\\") & ", file_name, file_type, file_createdby, file_date, file_format, " & sqlParams(3) & ", 1 "          & _
                                                     "FROM rc_item_hit WHERE item = " & sqlParams(0)
                                      'Response.Write(sql)
                                      Call DBExecute(gDBConn, sql, False)
                                      
                                      '*** Copy part list from RC to VA.
                                      Call DBExecute(gDBConn, "DELETE FROM va_c_bomeng WHERE item = " & sqlParams(0) & " AND draw_rev = " & sqlParams(1), False)
                                      Call DBExecute(gDBConn, "INSERT INTO va_c_bomeng SELECT * FROM rc_c_bomeng WHERE item = " & sqlParams(0), False)
                                      
                                      '*** Copy part list from RC to Glovia.
                                      Call DBExecute(gDBConn, "DELETE FROM c_bomeng WHERE item = " & sqlParams(0), False)
                                      Call DBExecute(gDBConn, "INSERT INTO c_bomeng SELECT * FROM rc_c_bomeng WHERE item = " & sqlParams(0), False)
                                    End If

                                    '*** Delete record(s) from RC.
                                    Call DBExecute(gDBConn, "DELETE FROM rc_item_hit WHERE item = " & sqlParams(0), False)
                                    Call DBExecute(gDBConn, "DELETE FROM rc_c_bomeng WHERE item = " & sqlParams(0), True)
                             
                                    Session("ItemProcessingComplete") = Session("ItemProcessingComplete") & itemCode & "@*@*@"
                                    
                                 End If     '*** Error Check-7   
                             End If         '*** Error Check-6 
                        End If              '*** Error Check-5 
                    End If                  '*** Error Check-4
                End If                      '*** Error Check-3
           End If                           '*** Error Check-2           
      End If                                '*** Error Check-1
      
      '*** Add Error for Artikel 
      If ErrorForArtikel <> "" Then VrijgeveErrorStatus =  VrijgeveErrorStatus & "Error for Artikel-" & itemCode & ErrorForArtikel 
      
        
 Next
 
 '*******************************************************************************
 '*** OK! Now exit/quit
 '*******************************************************************************
 If VrijgeveErrorStatus = "" Then
    Call Quit("Successfully transferred all artikels")
 Else
    Response.Write( VrijgeveErrorStatus)
    Call Quit("Could not transfer some Artikel")
 End If
 
        
'*******************************************************************************
'*** Private Functions
'*******************************************************************************
Sub Quit(errMsg)
  '*** Cleanup.
  Call RSClose(rs)
  Call DBDisconnect(gDBConn)
  IF (errMsg = "success") Then
    Session(BasketSession) = ""
    Session("newAdd") = ""
  Else 
    Call UnloadTransferedItems()  
  End IF
  Session("ItemProcessingComplete") = ""
  If (errMsg <> "") Then
    '*** Write error to document.
    Call Response.Write(errMsg)
    Call Response.End()
  End If
End Sub


'*** Update basket Session by removing the items which already 
'*** transferred to VA so that the basket can be reloaded with 
'*** right items
Sub UnloadTransferedItems() 
   Dim arrArt,articleN,i,complitedItem,completedCount,newArrayString
   
   IF Session("ItemProcessingComplete") <> "" Then
      Session("ItemProcessingComplete") = Left(Session("ItemProcessingComplete"),len(Session("ItemProcessingComplete"))-5)
      complitedItem = Split(Session("ItemProcessingComplete"),"@*@*@")
      
      For completedCount = 0 to UBound(complitedItem)
        arrArt = Split(Session(BasketSession),"****")
        newArrayString = ""
        For i=0 to UBound(arrArt)
           articleN = Split(arrArt(i),"@@@@")
           IF complitedItem(completedCount) <> articleN(0) Then 
              newArrayString = newArrayString & articleN(0) & "@@@@" & articleN(1) & "@@@@" & articleN(2) & "@@@@" & articleN(3) & "****" 
           End IF   
        Next 
        If newArrayString<>"" Then
            newArrayString = Left(newArrayString,len(newArrayString)-4)
        End If
        
        Session(BasketSession) = newArrayString        
      Next 
        
   End IF
End Sub
%>
