<!-- #include file="include/functions/general.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="include/copyright.inc" -->
<html>

<head>
  <title>Query Builder</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="style/obrowser.css">
</head>

<body>

<table align="center" border="0" height="100%">
  <tr>
    <td style="padding: 10px"><img src="image/icon_warning.gif"></td>
    <td height="100%" style="padding: 10px"><%= IIf(RequestStr("msg", "") <> "", RequestStr("msg", ""), "Onbekende fout.") %></td>
  </tr>
</table>

</body>

</html>