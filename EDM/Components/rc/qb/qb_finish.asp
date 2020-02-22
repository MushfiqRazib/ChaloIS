<!-- #include file="../common.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="../include/copyright.inc" -->
<html>

<head>
  <title>Afsluiten</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="../style/qbuilder.css">

   
 
  <script type="text/javascript">
  var ob = window.opener;
  
  if (ob && !ob.closed)
  {
    //*** Set focus to main window and refresh it's content.
    ob.focus();
    //ob.refresh("<%= gReport.Item("SQL_GroupBy") %>");
    ob.OBSettings.RefreshPage();
  }
  
  //*** Close this window.*/
  window.close();

  </script>
</head>

<body></body>

</html>