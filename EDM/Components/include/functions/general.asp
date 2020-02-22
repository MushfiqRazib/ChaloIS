<%
'*******************************************************************************
'***                                                                         ***
'*** File       : general.asp                                                ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 22-02-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Common Functions                                           ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** Browser Detection
'*******************************************************************************
Dim gIExplorer

gIExplorer = (InStr(1, UCase(Request.ServerVariables("HTTP_USER_AGENT")), "MSIE") > 0)



'*******************************************************************************
'*** Print/Echo Functions
'*******************************************************************************
Function EchoChecked(expr)
  '*** Return CHECKED attribute (or not!).
  EchoChecked = IIf(expr, " checked", "")
End Function


Function EchoDateTime(value, includeTime)
  Dim dateTimeStr
  
  '*** Default output.
  dateTimeStr = "00-00-0000" & IIf(includeTime, " 00:00", "")
  
  '*** Date specified?
  If Not IsNull(value) Then
    Dim realDate, dayVal, monthVal, yearVal, hourVal, minuteVal
    
    '*** Create real date.
    realDate = CDate(value)
    
    '*** Extract day, month and year.
    dayVal    = IIf(Day(realDate) < 10, "0", "") & Day(realDate)
    monthVal  = IIf(Month(realDate) < 10, "0", "") & Month(realDate)
    yearVal   = Year(realDate)
    hourVal   = IIf(Hour(realDate) < 10, "0", "") & Hour(realDate)
    minuteVal = IIf(Minute(realDate) < 10, "0", "") & Minute(realDate)
    
    '*** Create date string.
    dateTimeStr = dayVal & "-" & monthVal & "-" & yearVal
    
    '*** Add time?
    If includeTime Then dateTimeStr = dateTimeStr & " " & hourVal & ":" & minuteVal
  End If
  
  '*** Return date string.
  EchoDateTime = dateTimeStr
End Function


Function EchoDisabled(expr)
  '*** Return CHECKED attribute (or not!).
  EchoDisabled = IIf(expr, " disabled", "")
End Function


Function EchoNumber(expr, decimals, decimalSeparator)
  Dim num
  
  '*** Format number.
  num = FormatNumber(expr, decimals, -1, 0, 0)
  num = Replace(num, ".", decimalSeparator)
  num = Replace(num, ",", decimalSeparator)
  
  '*** Return formatted number
  EchoNumber = num
End Function


Function EchoXHTML(expr, default)
  '*** Return XHTML formatted value.
  If (expr <> "") Then
    EchoXHTML = Server.HTMLEncode(expr)
  Else
    EchoXHTML = default
  End If
End Function


Function EchoReadonly(expr)
  '*** Return READONLY attribute (or not!).
  EchoReadonly = IIf(expr, " readonly", "")
End Function


Function EchoSelected(expr)
  '*** Return SELECTED attribute (or not!).
  EchoSelected = IIf(expr, " selected", "")
End Function



'*******************************************************************************
'*** Misc Functions
'*******************************************************************************
Function ButtonPressed(key)
  '*** Return indicator form button is pressed.
  ButtonPressed = CBool(Request(key) <> "")
End Function


Sub ErrorMessage(message)
  '*** Redirect to error page with specified parameters.
  Response.Redirect("error.asp?msg=" & Server.URLEncode(message))
End Sub


Function IIf(expr, truepart, falsepart)
  If expr then
    '*** Return 'TRUE' part.
    IIf = truepart
  Else
    '*** Return 'FALSE' part.
    IIf = falsepart
  End If
End Function


Function InArray(arr, value)
  Dim i
  
  '*** Default value.
  InArray = False
  
  '*** Loop through array elements.
  For i = LBound(arr) To UBound(arr)
    If (arr(i) = value) Then
      '*** Report back that array contains specified value.
      InArray = True
      
      Exit For
    End If
  Next
End Function


Function RequestBool(key)
  Dim value
  
  '*** Get parameter value.
  value = UCase(Request(key))
  
  '*** Return boolean.
  RequestBool = CBool(value = "TRUE" Or value = "1")
End Function


Function RequestInt(key, default)
  Dim value
  
  value = Request(key)
  
  If (value <> "" And IsNumeric(value)) Then
    '*** Return integer value of string.
    RequestInt = CLng(value)
  Else
    '*** Return default value.
    RequestInt = default
  End If
End Function


Function RequestSng(key, default)
  Dim value
  
  value = Request(key)
  
  If (value <> "" And IsNumeric(value)) Then
    '*** Return value as single.
    RequestSng = CSng(value)
  Else
    '*** Return default value.
    RequestSng = default
  End If
End Function


Function RequestStr(key, default)
  Dim value
  
  '*** Get parameter value.
  value = Request(key)
  
  '*** Return as string even if parameter doesn't exist.
  RequestStr = IIf(value = "", default, CStr(value))
End Function
%>