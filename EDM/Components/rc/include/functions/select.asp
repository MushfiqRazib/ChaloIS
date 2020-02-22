<%
'*******************************************************************************
'***                                                                         ***
'*** File       : select.asp                                                 ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 29-06-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Functions for creating <SELECT> boxes                      ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** Pick a 'Group By' field, any field...
'*******************************************************************************
Function groupby_select(fieldNames, default, selectWidth, selectEvent)
  Dim select_str, def_exist, i, optionList, optionValue, optionDescr, optionSelected
  
  '*** Create option list.
  optionList = Split(fieldNames, ",")
  
  '*** Check if default value exist.
  For i = 0 To UBound(optionList)
    If (UCase(optionList(i)) = UCase(default)) Then def_exist = True
  Next
  
  '*** (Re)set default value, if it does not exist.
  default = IIf(def_exist, default, "NONE")
  
  '*** Default option.
  optionValue    = "NONE"
  optionDescr    = "-------- Geen selectie --------"
  optionSelected = IIf(optionValue = default, " selected", "")
  
  '*** Open tag.
  select_str = "<select name=""GroupBy"" style=""width: " & selectWidth & "px"" onchange=" & AddQuotes(selectEvent) & ">"
  
  '*** Add default option.
  select_str = select_str & "<option value=" & AddQuotes(optionValue) & optionSelected & ">" & optionDescr & "</option>"
  
  For i = 0 To UBound(optionList)
    '*** Add get option parameters.
    optionValue    = Trim(optionList(i))
    optionDescr    = GetFieldCaption(optionValue)
    optionSelected = IIf(optionValue = default, " selected", "")
    
    '*** Add default option.
    select_str = select_str & "<option value=" & AddQuotes(optionValue) & optionSelected & ">" & optionDescr & "</option>"
  Next
  
  '*** Close tag.
  select_str = select_str & "</select>"
  
  '*** Return string.
  groupby_select = select_str
End Function


'*******************************************************************************
'*** Pick a report, any report...
'*******************************************************************************
Function report_select(tableName, default, selectWidth, selectEvent)
  Dim rs, sql
  Dim select_str, optionValue, optionDescr, optionSelected
  
  '*** Initialize parameters.
  sql            = "SELECT name FROM " & tableName & " ORDER BY name"
  optionValue    = "NONE"
  optionDescr    = "-------- Geen selectie --------"
  optionSelected = IIf(optionValue = default, " selected", "")
  
  '*** Open tag.
  select_str = "<select name=""Report"" style=""width: " & selectWidth & "px"" onchange=" & AddQuotes(selectEvent) & ">"
  
  '*** Add default option.
  select_str = select_str & "<option value=" & AddQuotes(optionValue) & optionSelected & ">" & optionDescr & "</option>"
  
  If RSOpen(rs, gDBConn, sql, True) Then
    '*** Loop through records.
    While (Not rs.EOF)
      '*** Add get option parameters.
      optionValue    = rs("name")
      optionDescr    = optionValue
      optionSelected = IIf(optionValue = default, " selected", "")
      
      '*** Add default option.
      select_str = select_str & "<option value=" & AddQuotes(optionValue) & optionSelected & ">" & optionDescr & "</option>"
      
      rs.MoveNext()
    Wend
  End If
  
  '*** Cleanup.
  Call RSClose(rs)
  
  '*** Close tag.
  select_str = select_str & "</select>"
  
  '*** Return string.
  report_select = select_str
End Function

   
%>