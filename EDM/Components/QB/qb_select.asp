<!-- #include file="../config.asp"     -->
<!-- #include file="./includes/common.asp"  -->
<!-- #include file="./includes/postgres.asp"  -->
<%


  '********************** Start Culture Validation section *******************************
  Dim capPageTitle, capFieldset, leftlistheader, rightlistheader,thirddrpcaption,uitvoeren
  Dim firsttabimg, secondtabimg, thirdtabimg
  
  Dim cultureDoc
  cultureDoc = "./Cultures/Culture_" & CULTURECODE & ".xml"
  capPageTitle      = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/secondtab/controls/labels/pagetitle")  
  capFieldset       = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/secondtab/controls/labels/fieldsetcaption")
  leftlistheader    = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/secondtab/controls/labels/leftlistheader")
  rightlistheader   = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/secondtab/controls/labels/rightlistheader")
  uitvoeren         = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/uitvoeren/caption")
  movemsg           = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/secondtab/controls/moveitem/successivemessages/movemsg")
  
  
  firsttabimg    = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/tabheaderinactive/caption")
  secondtabimg   = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/secondtab/controls/tabheaderactive/caption")
  thirdtabimg    = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/tabheaderinactive/caption")
 
  '********************** End Culture section *******************************************


    Dim qbSelect, qbFrom, fldAvailable, fldSelected, i, tabinfo, sqlSelect, sqlGroupBy,sessionId
    sessionId = RequestStr("SESSION_ID", "") 
    
  
   '*** On tab switch
    If (RequestStr("SrcSubmit", "") = "btnGroupBy") Then
	    Call Response.Redirect("qb_groupby.asp?SESSION_ID=" & sessionId )
    ElseIf (RequestStr("SrcSubmit", "") = "btnWhere") Then
	    Call Response.Redirect("qb_where.asp?SESSION_ID=" & sessionId )    
    End If 
      
      sql = "select sql_from,sql_select from qb_parameters where session_id='" & sessionId & "'"
      If RSOpen(rs, gDBConn, sql, False) Then         
         qbFrom = rs("sql_from")
         qbSelect = rs("sql_select")                              
      End if


    '*** Create 'Available Fields' array.
    fldAvailable = TableFields(gDBConn, qbFrom)
              
    '*** Create 'Selected Fields' array.
    fldSelected = Split(ToString(qbSelect), ",")   
            

    '*** Hide hitSoundas clause from fieldlists    
    If UBound(Split(qbSelect,"hitSoundsas"))>0 Then
        ShowableFieldSize = UBound(fldSelected) - 2
        hitSoundAsClause = "," & fldSelected(ShowableFieldSize+1) & "," & fldSelected(ShowableFieldSize+2)
    Else
        ShowableFieldSize = UBound(fldSelected)
    End If					   						    						    						     
    
    '*** Hide tabinfo for ipoint report because this is mandatory field
    If UBound(Split(qbSelect,",tabinfo"))>0 Then        
        ShowableFieldSize = ShowableFieldSize - 1
        tabinfo  = ",tabinfo"
    Else
        tabinfo = ""    
    End If
        
    '*** Cleanup.
    
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- #include file="./includes/copyright.inc" -->
<html>
<head>
    <title>
        <%=capPageTitle %></title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
    <link rel="Stylesheet" type="text/css" href="./styles/qbuilder.css">
      
      <script type="text/javascript" src="./scripts/sarissa.js"></script>
      <script type="text/javascript" src="./scripts/common.js"></script>
      <script type="text/javascript" src="./scripts/qbuilder.js"></script>

    <script type="text/javascript">

        function SetSelectClauseInOpenner() {
              var sqlselect = getElementAttrib("SelectClause", "value");
              window.opener.QBSqlSelectTab(sqlselect);

//            var OpenerOBSettings = window.opener.OBSettings;
//            OpenerOBSettings.SQL_SELECT = getElementAttrib("SelectClause", "value");

//            if (OpenerOBSettings.SQL_GROUP_BY != "NONE") {
//                setTimeout('window.opener.CreateGroupByGrid()', 1);
//            } else {
//                setTimeout('window.opener.CreateNormalGrid()', 1);
//            }
            //this.close();
        }    
        
       
      
    </script>

</head>
<body >
    <table width="100%">
        <form name="QueryBuilder" action="qb_select.asp" method="POST" onsubmit="return checkSelectClause()"
        id="Form1">
        <!-- security controls -->
        <input name="securityId" type="hidden" value='<%=securityId %>' />
        <input name="targetUrl" type="hidden" value='<%=targetUrl %>' />
        <input name="fromBrowser" type="hidden" value='<%=fromBrowser %>' />
        <input name="movemsg" type="hidden" value='<%=movemsg %>' />
        <input name="qbFrom" type="hidden" value="<%=qbFrom %>" />
        <input name="qbSelect" type="hidden" value="<%=qbSelect %>" />   
        <input name="SESSION_ID" type="hidden" value='<%=sessionId %>' />
        <tr>
            <td width="100%" class="qb_tabs">
                <img src="./images/fill_left.png"><input type="image" src="./images/<%=firsttabimg %>"
                    onclick='setElementAttrib("SrcSubmit", "value", "btnWhere");'><img src="./images/<%=secondtabimg %>"><input
                        type="image" name="btnGroupBy" src="./images/<%=thirdtabimg %>" onclick='setElementAttrib("SrcSubmit", "value", "btnGroupBy");'
                        id="Image2">
            </td>
        </tr>
        <!-- Local variables we want to submit -->
        <input type="hidden" name="hitSoundAsClause" value="<%= hitSoundAsClause %>">
        <input type="hidden" name="tabinfo" value="<%= tabinfo %>">
        <input type="hidden" name="FieldName" value="">
        <input type="hidden" name="FieldType" value="">
        <input type="hidden" name="Submitted" value="1" id="Hidden3">
        <input type="hidden" name="SelectClause" value="<%= qbSelect %>" id="Hidden4">
        <input type="hidden" name="SrcSubmit" value="" id="Hidden5">
        </form>
        <tr>
            <td class="qb_content" style="height: 332px;">
                <fieldset style="height: 305px">
                    <legend>
                        <%=capFieldset %></legend>
                    <table align="center" style="margin: 8px 0px">
                        <tr>
                            <th>
                                <%=leftlistheader %>
                            </th>
                            <th>
                            </th>
                            <th>
                                <%=rightlistheader %>
                            </th>
                            <th>
                            </th>
                        </tr>
                        <tr>
                            <td>
                                <select name="Fields_A" size="15" id="Select1">
                                    <%
    For i = LBound(fldAvailable) To UBound(fldAvailable)
      '*** Only add field to Available Fields' if it's not selected.
      If Not InArray(fldSelected, fldAvailable(i)) Then
                                    %>
                                    <option value="<%= fldAvailable(i) %>">
                                        <%= fldAvailable(i) %></option>
                                    <%
      End If
    Next
                                    %>
                                </select>
                            </td>
                            <td style="padding: 0px 20px" valign="middle">
                                <button style="width: 22px; height: 22px;" class="edit" onclick="optionMove('Fields_A','Fields_V')">
                                    <img src="./images/right.gif"></button><br />
                                <br />
                                <!--<button style="width: 30px" onclick="optionMoveAll('Fields_A','Fields_V')">&gt;&gt;</button><br />
							    <button style="width: 30px" onclick="optionMoveAll('Fields_V','Fields_A')">&lt;&lt;</button><br />-->
                                <button style="width: 22px; height: 22px;" class="edit" onclick="optionMove('Fields_V','Fields_A')">
                                    <img src="./images/left.gif"></button>
                            </td>
                            <td>
                                <select name="Fields_V" size="15" id="Select2">
                                    <%	
							    '*** Create fields array.
							    'fldSelected = Left(ToString(qbSelect),Len(ToString(qbSelect))-1)
	                            'fldSelected = Replace(ToString(qbSelect), ";", ",")							 							    							    							    				    
	                            
							    For i = LBound(fldSelected) To ShowableFieldSize							    
                                    %>
                                    <option value="<%= fldSelected(i) %>">
                                        <%= fldSelected(i) %></option>
                                    <% Next %>
                                </select>
                            </td>
                            <td valign="middle" width="30" align="center">
                                <button style="width: 22px; height: 22px;" class="edit" onclick="optionSwap('Fields_V',-1)">
                                    <img src="./images/up.gif"></button><br />
                                <br />
                                <button style="width: 22px; height: 22px;" class="edit" onclick="optionSwap('Fields_V',1)">
                                    <img src="./images/down.gif"></button>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </td>
        </tr>
        <tr>
            <td align="right" class="qb_actions">
                <button style="width: 100px; height: 22px;" class="action" name="Execute" value="Uitvoeren"
                    onclick='checkSelectClause(); SetSelectClauseInOpenner();'>
                    <%=uitvoeren %></button>
            </td>
        </tr>
    </table>
</body>
</html>
<% 
'*** Cleanup.
Call RSClose(rs)
Call DBDisconnect(gDBConn)
%>