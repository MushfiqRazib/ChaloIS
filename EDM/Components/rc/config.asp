<%
'Dim DB_CONNSTRING

'*******************************************************************************
'*** Database connection string
'*******************************************************************************
'DB_CONNSTRING = DB_BERKHOF
'set DB_CONNSTRING = "Driver={PostgreSQL 64-Bit ODBC Drivers};Server=localhost;Port=5432;Database=vdl;Uid=postgres;Pwd=postgres"

'*******************************************************************************
'*** Report parameters
'*******************************************************************************
Const REPORT_DEFAULT = "Release Candidates"
Const REPORT_MAXROWS = 25
Const REPORT_TABLE   = "ob_report"

'*******************************************************************************
'*** Browser Prefix
'***
'*** This value is used to prevent browsers overwriting each others session
'*** variables when more then one browser is used within a single site.
'*******************************************************************************
Const BROWSER_PREFIX = "RC_"

'*******************************************************************************
'*** String used for indicating NULL value
'*******************************************************************************
Const NULLSTRING = "{null}"
%>