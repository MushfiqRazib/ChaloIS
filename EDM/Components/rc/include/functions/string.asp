<%
'*******************************************************************************
'***                                                                         ***
'*** File       : string.asp                                                 ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 15-08-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: String Manipulation Functions                              ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** String Conversion Constants
'*******************************************************************************
Const vbUpperCase   = 1    '*** Converts the string to uppercase characters.
Const vbLowerCase   = 2    '*** Converts the string to lowercase characters.
Const vbProperCase  = 3    '*** Converts the first letter of every word in string to uppercase.
Const vbWide        = 4    '*** Converts narrow (single-byte) characters in string to wide (double-byte) characters.
Const vbNarrow      = 8    '*** Converts wide (double-byte) characters in string to narrow (single-byte) characters.
Const vbKatakana    = 16   '*** Converts Hiragana characters in string to Katakana characters.
Const vbHiragana    = 32   '*** Converts Katakana characters in string to Hiragana characters.
Const vbToUnicode   = 64   '*** Converts the string from ANSI (byte array) to Unicode.
Const vbFromUnicode = 128  '*** Converts the string from Unicode to ANSI (byte array).


'*******************************************************************************
'*** Conversion Functions
'*******************************************************************************
Function BStr(string)
  '*** Converts an ANSI string to Unicode.
  Dim outStr, i
  
  For i = 1 to LenB(string)
    '*** Convert ANSI char to Unicode char.
    outStr = outStr & Chr(AscB(MidB(string, i, 1)))
  Next
  
  '*** Return Unicode string/array.
  BStr = outStr
End Function


Function ABStr(string)
  '*** Converts a Unicode string to ANSI.
  Dim outStr, i
  
  For i = 1 to Len(string)
    '*** Convert Unicode char to ANSI char.
    outStr = outStr & ChrB(Asc(Mid(string, i, 1)))
  Next
  
  '*** Return ANSI string/array.
  ABStr = outStr
End Function


Function PCase(string)
  Dim cstring, sentences, s, words, w
  
  If IsNull(string) Then
    '*** Return NULL.
    cstring = Null
  Else
    '*** Convert variant to lowercase C string.
    cstring = LCase(CStr(string))
    
    '*** Split text into sentences.
    sentences = Split(cstring, vbCrLf)
    
    For Each s In sentences
      '*** Split sentence into words.
      words = Split(s, " ")
      
      For Each w In words
        '*** Convert first character into uppercase.
        w = UCase(Left(w, 1)) & Mid(w, 2)
      Next
      
      '*** Combine words into sentence.
      s = Join(words, " ")
    Next
    
    '*** Combine sentences into text.
    cstring = Join(sentences, vbCrLf)
  End If
  
	'*** Return string.
	PCase = cstring
End Function


Function StrConv(string, conversion)
  Select Case conversion
    Case vbUpperCase
      '*** Convert to uppercase.
      StrConv = UCase(string)
    
    Case vbLowerCase
      '*** Convert to lowercase.
      StrConv = LCase(string)
    
    Case vbProperCase
      '*** Convert to propercase.
      StrConv = PCase(string)
    
    Case vbToUnicode
      '*** Convert ANSI (byte array) to Unicode.
      StrConv = BStr(string)
    
    Case vbFromUnicode
      '*** Convert Unicode to ANSI (byte array).
      StrConv = ABStr(string)
    
    Case Else
      '*** Unknown conversion type.
      StrConv = string
  End Select
End Function


Function ToString(expr)
  If IsNull(expr) then
    '*** Return empty string.
    ToString = ""
  Else
    '*** Return expression as string.
    ToString = CStr(expr)
  End If
End Function


Function URLEncode(expr)
  '*** Return expression as string.
  URLEncode = Server.URLEncode(ToString(expr))
End Function

'*** OLD!!! ***
'Function URLEncode(expr)
'  If IsNull(expr) then
'    '*** Return NULL.
'    URLEncode = expr
'  Else
'    '*** Return expression as string.
'    URLEncode = Server.URLEncode(expr)
'  End If
'End Function


'*******************************************************************************
'*** Miscellaneous Functions
'*******************************************************************************
Function AddQuotes(str)
  '*** Add (double) quotes to begin and end of string.
  AddQuotes = """" & str & """"
End Function
%>