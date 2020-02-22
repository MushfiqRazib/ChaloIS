<%
'*******************************************************************************
'***                                                                         ***
'*** File       : security.asp                                               ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 26-09-2006                                                 ***
'*** Copyright  : (C) 2004 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: Security Functions                                         ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** Global Variables
'*******************************************************************************
Dim gUserName, gUserRights, gLoggedIn


'*******************************************************************************
'*** Public Functions
'*******************************************************************************
Sub Security_Check()
  '*** Read security parameters from session (if exist).
  gUserName   = Session("Username")
  gUserRights = Session("UserRights")
  gLoggedIn   = (gUserName <> "")
End Sub


Function Security_Login(username, password)
  Dim conn, rs, sql
  
  '*** Connect to database.
  If DBConnect(conn, DB_BERKHOF, adModeRead) Then
    '*** Try to get username/password combination.
    sql = "SELECT * FROM hit_user WHERE (user_name = " & SQLEnc(username) & ") AND (user_pwd = " & SQLEnc(password) & ")"
    
    '*** User exist?
    If RSOpen(rs, conn, sql, True) Then
      '*** Set session timeout.
      Session.Timeout = 120
      
      '*** Set user info (rights etc.)
      Session("Username")   = rs("user_name")
      Session("UserRights") = rs("user_rights")
    End If
    
    '*** Close recordset.
    Call RSClose(rs)
  End If
  
  '*** Close database connection.
  Call DBDisconnect(conn)
  
  '*** Recheck, so global variables will be reset.
  Call Security_Check()
  
  '*** Return success/failure.
  Security_Login = gLoggedIn
End Function


Function Security_Logout()
  '*** Remove security session parameters.
  Call Session.Contents.Remove("Username")
  Call Session.Contents.Remove("UserRights")
  
  '*** Recheck, so global variables will be reset.
  Call Security_Check()
End Function
%>