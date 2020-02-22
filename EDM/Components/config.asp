<%
'Option Explicit
Dim  DOCUMENT_PATH

'*** Application constants
Const BasketSession       = "BasketObjects"
Const BasketName          = "VDLBasket"
Const DistributionName    = "distributionName"
Const whichBasket         = "whichBasket"

'*******************************************************************************
'*** Database connection string
'*******************************************************************************
Const DB_CONNSTRING = "Driver={PostgreSQL 64-Bit ODBC Drivers};Server=localhost;Port=5432;Database=vdl;Uid=postgres;Pwd=postgres"
'*** Supported document type for upload
Const SUPPORTED_DOC_TYPE = "TIFF;TIF;DWF;PDF"
'**** Multilangual culture code *****
Const CULTURECODE = "English-US"
'Const CULTURECODE = "Dutch-NL"


'*** Error messages ***
Const ERR_NODBCONNECT = "Ja nu heb je het voorelkaar; De database is stuk!"

'*******************************************************************************
'*** Data path (DWF and PDF files)
'*******************************************************************************
Const DocBasePath = "D:\Data\BASKET_OUTPUT\"
Const BaseMaterialBasePath = "D:\Data\BASKET_OUTPUT\"
Const BASKET_OUTPUT = "D:\Data\BASKET_OUTPUT\"
Const WAITINGTIME ="30"
Const PROSSESWORKINGDIRECTORY = "C:\HawarIT\HITPrintMonitor\Jobs\Higher\"
Const DISTRIBUTION_DIR = "D:\Data\BASKET_OUTPUT\"
Const PATH_RC = "D:\Data\RC\"


'*** Frequently used expressions.
Const vbQuote = """"

'*******************************************************************************
'*** SQL Queries
'*******************************************************************************

Const FUNCTIONS_PRINTEN_COUNT_SQL = "SELECT COUNT(*) AS TROW FROM PRINTEN WHERE SUBSTR(APPENDIXNAME,1,length('[matcode]')) = '[matcode]' AND UPPER(SUBSTR(APPENDIXNAME,length('[matcode]')+2, 2)) in ('[revision]','XX')"
Const FUNCTIONS_PRINTEN_SQL = "SELECT APPENDIXNAME,FORMAT FROM PRINTEN WHERE SUBSTR(APPENDIXNAME,1,length('[matcode]')) = '[matcode]' AND UPPER(SUBSTR(APPENDIXNAME,length('[matcode]')+2, 2)) in ('[revision]','XX')"

%>