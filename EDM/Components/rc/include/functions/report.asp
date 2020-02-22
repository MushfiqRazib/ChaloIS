<%
'*******************************************************************************
'***                                                                         ***
'*** File       : report.asp                                                 ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 04-07-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Report Functions                                           ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** Global Variables
'*******************************************************************************
Dim gReport


'*******************************************************************************
'*** Local Variables
'*******************************************************************************
Dim mFieldDescrList


'*******************************************************************************
'*** Report Functions
'*******************************************************************************
Function Report_CheckGISSelect(sql_gisselect)
  '*** Return value.
  Report_CheckGISSelect = sql_gisselect
End Function


Function Report_CheckGroupBy(fieldname)
  Dim field_list, idx_first, idx_last, i
  
  '*** Get list of fieldnames.
  field_list = ColumnsAsArray(gDBConn, gReport.Item("SQL_From"))
  idx_first  = LBound(field_list)
  idx_last   = UBound(field_list)
  
  '*** Default return value.
  Report_CheckGroupBy = "NONE"
  
  For i = idx_first To idx_last
    '*** Does specified field exist?
    If (UCase(field_list(i)) = UCase(fieldname)) Then Report_CheckGroupBy = fieldname
  Next
End Function


Function Report_CheckOrderBy(fieldname)
  Dim field_list, idx_first, idx_last, i
  
  '*** Get list of fieldnames.
  field_list = ColumnsAsArray(gDBConn, gReport.Item("SQL_From"))
  idx_first  = LBound(field_list)
  idx_last   = UBound(field_list)
  
  '*** Default return value.
  Report_CheckOrderBy = field_list(idx_first)
  
  For i = idx_first To idx_last
    '*** Does specified field exist?
    If (UCase(field_list(i)) = UCase(fieldname)) Then Report_CheckOrderBy = fieldname
  Next
End Function


Function Report_CheckSelect(fieldNames)
  If (fieldNames = "" Or fieldNames = "*") Then
    '*** Get all fieldnames.
    Report_CheckSelect = TableColumns(gDBConn, gReport.Item("SQL_From"), ",")
  Else
    '*** Return defined field list.
    Report_CheckSelect = fieldNames
  End If
End Function


Sub Report_Clear()
  Dim key
  
  For Each key In Session.Contents
    '*** Delete session key if it belongs to this browser.
    If (Left(key, Len(BROWSER_PREFIX)) = BROWSER_PREFIX) Then Call Session.Contents.Remove(key)
  Next
End Sub


Sub Report_Create(report_name)
  '*** Create new Report object.
  Set gReport = Nothing
  Set gReport = Server.CreateObject("Scripting.Dictionary")
  
  '*** Add members.
  Call gReport.Add("Name",              report_name)
  Call gReport.Add("Description",       "")
  Call gReport.Add("Field_DWF",         "")
  Call gReport.Add("Field_Caps",        "")
  Call gReport.Add("MaxRows",           REPORT_MAXROWS)
  
  Call gReport.Add("SQL_Select",        "")
  Call gReport.Add("SQL_GISSelect",     "")
  Call gReport.Add("SQL_From",          "")
  Call gReport.Add("SQL_Where",         "")
  Call gReport.Add("SQL_GroupBy",       "NONE")
  Call gReport.Add("SQL_GroupBySelect", "COUNT(*) AS Aantal")
  Call gReport.Add("SQL_OrderBy",       "")
End Sub


Sub Report_FromDatabase(report_name)
  Dim rs
  
  '*** Clear report.
  Call Report_Clear()
  
  '*** Destroy current report and create new one.
  Call Report_Create(report_name)
  
  If RSOpen(rs, gDBConn, "SELECT * FROM " & REPORT_TABLE & " WHERE name = " & SQLEnc(report_name), True) Then
    '*** Report parameters.
    gReport.Item("Description")   = ToString(rs("description"))
    gReport.Item("Field_Caps")    = ToString(rs("fieldcaps"))
    
    '*** SQL related parameters.
    gReport.Item("SQL_From")      = ToString(rs("sql_from"))
    gReport.Item("SQL_Select")    = Report_CheckSelect(ToString(rs("sql_select")))
    gReport.Item("SQL_Where")     = ToString(rs("sql_where"))
    gReport.Item("SQL_GroupBy")   = Report_CheckGroupBy(ToString(rs("sql_groupby")))
    gReport.Item("SQL_OrderBy")   = Report_CheckOrderBy(ToString(rs("sql_orderby")))
    
    '*** GIS related parameters.
    gReport.Item("GIS_X")  = ToString(rs("gis_x"))
    gReport.Item("GIS_Y")  = ToString(rs("gis_y"))
    gReport.Item("GIS_Id") = ToString(rs("gis_id"))
    
    '*** Detail related parameters.
    gReport.Item("DetailURL") = ToString(rs("detail_url"))
    gReport.Item("DetailId")  = ToString(rs("detail_id"))
  End If
  
  '*** Cleanup.
  Call RSClose(rs)
  
  '*** Write Report to session.
  Call Report_ToSession()
End Sub


Sub Report_FromDatabase2(report_name)
  '*** Clear report.
  Call Report_Clear()
  
  '*** Destroy current report and create new one.
  Call Report_Create(report_name)
  
  '*** Report parameters.
  gReport.Item("Description") = "VDL Jonckheere"
  gReport.Item("Field_DWF")   = "file_name"
  gReport.Item("Field_Caps")  = "ITEM_CODE=Artikelnr.;ITEM_REV=Revisie;ITEM_DESCR=Omschrijving;FILE_PATH=Directorie;FILE_NAME=Bestandsnaam;FILE_TYPE=Bestandstype"
  
  '*** SQL related parameters.
  gReport.Item("SQL_Select")  = "ITEM_CODE, ITEM_REV, ITEM_DESCR, FILE_PATH, FILE_NAME, FILE_TYPE"
  gReport.Item("SQL_From")    = "OBJ_ITEMS"
  gReport.Item("SQL_OrderBy") = Report_CheckOrderBy("ITEM_CODE")
  
  '*** Write Report to session.
  Call Report_ToSession()
End Sub


Sub Report_FromSession()
  If IsObject(Session(BROWSER_PREFIX & "Report")) Then
    '*** Get existing Report.
    Set gReport = Session(BROWSER_PREFIX & "Report")
  Else
    '*** Create new Report object.
    Call Report_Create("")
    
    '*** Write Report to session.
    Call Report_ToSession()
  End If
End Sub


Sub Report_GroupBy(group_name)
  '*** Set group by.
  gReport.Item("SQL_GroupBy") = group_name
  
  '*** Other stuff
End Sub


Sub Report_ToSession()
  '*** Write Report object to session.
  Set Session(BROWSER_PREFIX & "Report") = gReport
End Sub


'*******************************************************************************
'*** Report Related Functions
'*******************************************************************************
Function GetFieldCaption(fieldName)
  '*** Create list (if not done before).
  If (Not IsObject(mFieldDescrList)) Then Call ExtractFieldCaptions()
  
  If mFieldDescrList.Exists(fieldName) Then
    '*** Description defined for specified field name.
    GetFieldCaption = mFieldDescrList.Item(fieldName)
  Else
    '*** No description found, so return field name.
    GetFieldCaption = fieldName
  End If
End Function


Sub ExtractFieldCaptions()
  Dim capList, kvPair, key, value, i
  
  '*** Create dictionary.
  Set mFieldDescrList = Nothing
  Set mFieldDescrList = Server.CreateObject("Scripting.Dictionary")
  
  '*** Create list of Key-Value strings.
  capList = Split(gReport.Item("Field_Caps"), ";")
  
  For i = 0 To UBound(capList)
    '*** Split Key-Value string.
    kvPair = Split(capList(i), "=")
        
    If (UBound(kvPair) => 1) Then
      '*** Add pair to dictionary.
      key   = UCase(Trim(kvPair(0)))
      value = Trim(kvPair(1))
      
      Call mFieldDescrList.Add(key, value)
    End If
  Next
End Sub
%>