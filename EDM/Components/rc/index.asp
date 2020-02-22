<!-- #include file="./common.asp"                   -->
<!-- #include file="./include/db.asp"               -->
<!-- #include file="./include/functions/select.asp" -->
<%
Dim rprt_name, rprt_groupby, rprt_result

'*** Get report parameters if specified, else default.
rprt_name               = RequestStr("Report", "")
rprt_groupby            = RequestStr("GroupBy", "NONE")
gReport.Item("MaxRows") = RequestInt("MaxRows", gReport.Item("MaxRows"))

If (gReport.Item("Name") = "" Or gReport.Item("Name") <> rprt_name) Then
  '*** First load?
  If (rprt_name = "") Then rprt_name = REPORT_DEFAULT
  
  '*** Start new report.
  Call Report_FromDatabase(rprt_name)
  
  '*** Set default grouping for this report.
  rprt_groupby = gReport.Item("SQL_GroupBy")
End If

'*** Grouping changed?
If (rprt_groupby <> gReport.Item("SQL_GroupBy")) Then Call Report_GroupBy(rprt_groupby)

'*** Get grid url.
rprt_result = "./template/" & IIf(gReport.Item("SQL_GroupBy") = "NONE", "grid_select.asp", "grid_grouped.asp")

'*** Write report to session.
Call Report_ToSession()
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="./include/copyright.inc" -->
<html>

<head>
  <title>VDL Jonckheere: Release Candidates</title>
  
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  
  <link rel="Stylesheet" type="text/css" href="./style/obrowser.css">
  <link rel="Stylesheet" type="text/css" href="./style/datagrid.css">
  
  <script type="text/javascript" src="./script/common.js"></script>
  <script type="text/javascript" src="./script/window.js"></script>
  <script type="text/javascript" src="./script/obrowser.js"></script>
  <script type="text/javascript" src="./script/sarissa.js"></script>
  <script type="text/javascript" src="./script/datagrid.js"></script>
  <script type="text/javascript" src="./script/custom.js"></script>
  <script type="text/javascript" src="../basket/script/basket.js"></script>  
  <script type="text/javascript">
  //*** Set window events.
  window.onresize = resizeElements;
  window.onunload = closeChilds;
  
  function init()
  {
    //*** Initialize tabstrip.
    tab_init();
    
    //*** Load navigation panel.
    loadNavigation("./template/nav_grid.asp");
    
    //*** Initialize grid.
    grid_load("TabPage_Grid", "<%= rprt_result %>", "PGrid", "", "", "", 1);
    
    resizeElements();
  }
   function OpenBasket(){
      var settings = 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=300,height=300,left=400,top=350';   
      openChild("../Basket/Basket.asp?rc=true", "Attachment", true, 665, 350, "no", "no");
      //openChild("../Basket/Basket.asp", "Attachment", true,800,850, "no", "no");     
    }  
 
    function ResetSession()
    { 
      if(event.clientY<0)
      {    
        var ttt = httpRequest("../basket/basketing.asp?reset="+true); 
      }
    }

  </script>
</head>

<body onload="init();" onunload="ResetSession()" onkeydown="return checkKey(event);">

<table class="Browser" cellspacing="0" cellpadding="0">
  <form name="Browser" action="./index.asp" method="POST">
    <input type="hidden" name="Report" value="<%= gReport.Item("Name") %>">
  <tr>
    <td>
      <!-- Toolbar -->
      <table width="100%">
        <tr>
          <td class="tabs" nowrap style="height: 31px"><img src="./image/fill_left.png"><img id="Tab1Img" class="Link" src="./image/overzicht_active.png" onclick='tab_set(1)'><img id="Tab2Img" class="Link" src="./image/detail.png" onclick='tab_set(2)'><img id="Tab3Img" class="Link" src="./image/graphics.png" onclick='tab_set(3)'></td>
          <td class="tabs" valign="middle" style="padding-left: 30px; height: 31px;" nowrap>Groeperen op:&nbsp;</td>
          <td class="tabs" valign="middle" style="height: 31px">
            <%= groupby_select(gReport.Item("SQL_Select"), rprt_groupby, 170, "submit()") %>
          </td>
          <td class="tabs" style="padding: 0px 0px 0px 15px; width: 100%; height: 31px;" nowrap>
            <!-- <button class="Toolbutton" alt="Selectiefilter..." title="Selectiefilter..." onclick="return openQueryBuilder();" onfocus="this.blur()"<%= EchoDisabled(rprt_name = "NONE") %>><img src="./image/filter.gif"></button> -->
            <button class="Toolbutton" alt="Snel zoeken..."    title="Snel zoeken..."    onclick="return openQuickSearch();"  onfocus="this.blur()"<%= EchoDisabled(rprt_name = "NONE") %>><img src="./image/search.gif"></button>
          </td>          
          <td class="tabs" valign="middle" style="padding-right: 5px; width: 134%; height: 31px;" nowrap align="right">
             <% Dim BasketSize             
             BasketSize = UBound(Split(Session("BasketObjects"),"****")) + 1 
             If BasketSize<1 Then BasketSize = 0 %>
              <button alt="Basket..." id="btnBasket"   title="Basket..." onclick="OpenBasket()" onfocus="this.blur()"<%= EchoDisabled(rprt_name = "NONE") %> style="width: 130px" >Basket Unnamed(<%=BasketSize %>)</button>
          </td>
          <td class="tabs" valign="middle" style="padding-right: 10px; height: 31px;" nowrap width="100%" align="right">
            <button style="width: 100px" onclick="return itemAdd();" onfocus="this.blur();"<%= EchoDisabled(rprt_name = "NONE") %>>Nieuw Artikel</button>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <!-- Body -->
  <tr>
    <td id="TabContainer" height="100%" valign="top">
      <!-- Datagrid -->
      <div class="Datagrid" id="TabPage_Grid"></div>
      <!-- Details -->
      <div class="Detail" id="TabPage_Detail"></div>
      <!-- Document Viewer -->
      <div class="Viewer" id="TabPage_Viewer">
      <!--
        <object id="DWFViewer" classid="CLSID:A662DA7E-CCB7-4743-B71A-D817F6D575DF" codebase="http://www.autodesk.com/global/dwfviewer/installer/DwfViewerSetup.cab#version=5,0,0,x" height="100%" width="100%"> 
          <param name="Src" value="">
        </object>
        
        <object id="PDFViewer" classid="CLSID:CA8A9780-280D-11CF-A24D-444553540000" height="100%" width="100%">
          <param name="Src" value="http://www.planetpdf.com/planetpdf/pdfs/gkent/example2.pdf">
          <embed src="example1.pdf" height="100%" width="100%">
            <noembed>Geen geschikte viewer gevonden voor het geselecteerde bestand.</noembed>
          </embed>
        </object>
        
        <embed src="" height="100%" width="100%"><noembed>Geen geschikte viewer gevonden voor het geselecteerde bestand.</noembed></embed>
      -->
      </div>
    </td>
  </tr>
  <!-- Navigation Bar -->
  <tr>
		<td>
			<table style="height: 33px;">
				<tr>
					<td id="NavigationPanel" class="navs" style="width: 100%; padding-left: 10px;"></td>
					<td class="navs" style="padding-left: 10px; text-align: right" width="100%" nowrap>Resultaten per pagina:&nbsp;</td>
					<td class="navs" style="padding-right: 10px;" nowrap>
						<input type="text" class="Text" name="MaxRows" style="text-align: right; width: 42px; height: 21px;" value="<%= gReport.Item("MaxRows") %>" onkeypress="return isNum(event)" onpaste="return false">&nbsp;
						<button title="Uitvoeren" onclick="submit()" onfocus="this.blur()"<%= EchoDisabled(rprt_name = "NONE") %>>Uitvoeren</button>
					</td>
				</tr>
			</table>
		</td>
  </tr>
  </form>
</table>

</body>
<%
'*** Cleanup.
Call DBDisconnect(gDBConn)
%>
</html>