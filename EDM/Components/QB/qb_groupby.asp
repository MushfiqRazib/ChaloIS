<!-- #include file="../config.asp"     -->
<!-- #include file="./includes/common.asp"  -->
<!-- #include file="./includes/postgres.asp"  -->
<%

  '********************** Start Culture Validation section *******************************
  Dim capPageTitle, capFieldset, firstdrpcaption, seconddrpcaption,drpgroupby,thirddrpcaption,toevoegen,verwijderen,uitvoeren
  Dim firsttabimg, secondtabimg, thirdtabimg,emptyvaluemsg,numvaluemsg
  Dim cultureDoc
  cultureDoc = "./Cultures/Culture_" & CULTURECODE & ".xml"
  
  capPageTitle          = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/labels/pagetitle")  
  firstfieldsetcaption  = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/labels/firstfieldsetcaption")
  secondfieldsetcaption = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/labels/secondfieldsetcaption")
  firstdrpcaption       = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/labels/firstdrpcaption")
  seconddrpcaption      = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/labels/seconddrpcaption")   
  thirddrpcaption       = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/labels/thirddrpcaption")
  drpgroupby            = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/labels/drpgroupby")
  toevoegen             = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/toevoegen/caption")
  verwijderen           = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/verwijderen/caption")
  uitvoeren             = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/uitvoeren/caption")
  emptyvaluemsg         = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/toevoegen/successivemessages/emptyvaluemsg")
  numvaluemsg           = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/toevoegen/successivemessages/numvaluemsg")
  
  firsttabimg           = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/tabheaderinactive/caption")
  secondtabimg          = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/secondtab/controls/tabheaderinactive/caption")
  thirdtabimg           = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/tabheaderactive/caption")
  
  '********************** End Culture section *******************************************


    Dim rs, fld, fldType, qbFrom, qbGroupBy, qbGBSelect, optionList, i
	sessionId = RequestStr("SESSION_ID", "") 
	
	'*** On tab switch
    If (RequestStr("SrcSubmit", "") = "btnSelect") Then
      Call Response.Redirect("qb_select.asp?SESSION_ID=" & sessionId)
    ElseIf (RequestStr("SrcSubmit", "") = "btnWhere") Then
      Call Response.Redirect("qb_where.asp?SESSION_ID=" & sessionId)    
    End If

    '*** Get report parameters.   	
	sql = "select sql_from,sql_where,sql_gb_select, sql_group_by from qb_parameters where session_id='" & sessionId & "'"
	 If RSOpen(rs, gDBConn, sql, False) Then         
            qbFrom = rs("sql_from")
            qbWhere=rs("sql_where")
            qbGBSelect = rs("sql_gb_select") 
            qbGroupBy=rs("sql_group_by") 
      End if
      
	
	
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
        function UpdateOpenerGridInfo()
		{
			var sqlorderby = getElementAttrib("GroupBy", "value");
			var qbgbselectclause = getElementAttrib("GBSelectClause", "value");
			var sqlgroupby = getElementAttrib("GroupBy", "value");						
			if(sqlgroupby=="NONE" && qbgbselectclause!="")
			{
				alert("Please select field for grouping")
				return;
			}	
			
			if(sqlgroupby=="NONE")
			{
				sqlorderby = "";
			}			
			
			window.opener.QBSqlGroupByTab(sqlorderby, qbgbselectclause, sqlgroupby);               
        }
        
    </script>

</head>
<body onload="selectGroupingField(FieldAction);" onunload="CheckCloseEvent(<%=fromBrowser %>)">
    <table width="100%">
        <form name="QueryBuilder" action="qb_groupby.asp" method="POST" onsubmit="return checkGBSelectClause()">
        <!-- security controls -->
        <input name="SESSION_ID" type="hidden" value='<%=sessionId %>' />
        <input name="securityId" type="hidden" value='<%=securityId %>' />
        <input name="targetUrl" type="hidden" value='<%=targetUrl %>' />
        <input type="hidden" name="fromBrowser" value='<%=fromBrowser %>' />
        
        <input name="qbFrom" type="hidden" value="<%=qbFrom %>" />                               
        <input name="qbWhere" type="hidden" value="<%=qbWhere %>" />  
        <input name="sqlSelect" type="hidden" value="<%=sqlSelect %>" />                               
        <input name="sqlGroupBy" type="hidden" value="<%=sqlGroupBy %>" />     
        
        <!-- used in multilangual purposes -->
        <input type="hidden" name="emptyvaluemsg" value="<%=emptyvaluemsg %>" />
        <input type="hidden" name="numvaluemsg" value="<%=numvaluemsg %>" />
        
        <!-- Local variables we want to submit -->
        <input type="hidden" name="GroupBy" value="<%= qbGroupBy  %>">
        <input type="hidden" name="GroupingField" value="">
        <input type="hidden" name="GBSelectClause" value="<%= qbGBSelect %>">
        <input type="hidden" name="SrcSubmit" value="">
        <input type="hidden" name="Submitted" value="1">
        <tr>
            <td width="100%" class="qb_tabs">
                <img src="./images/fill_left.png"><input type="image" name="btnWhere" src="./images/<%=firsttabimg %>"
                    onclick='setElementAttrib("SrcSubmit", "value", "btnWhere");'><input type="image"
                        name="btnSelect" src="./images/<%=secondtabimg %>" onclick='setElementAttrib("SrcSubmit", "value", "btnSelect");'>
                        <img src="./images/<%=thirdtabimg %>">
            </td>
        </tr>
        </form>
        <tr>
            <td class="qb_content" style="height: 68px;">
                <fieldset style="height: 60px;">
                    <legend>
                        <%=firstfieldsetcaption %></legend>
                    <table style="margin: 4px 4px 4px 4px">
                        <tr>
                            <th width="110px">
                                <%=drpgroupby %>
                            </th>
                            <td>
                                <select onchange="setElementAttrib('GroupBy','value',this.value)">
                                    <option value=""></option>
                                    <%
    '*** Create fields array.
    optionList = TableFields(gDBConn, qbFrom)

    For i = LBound(optionList) To UBound(optionList)
                                    %>
                                    <option value="<%= optionList(i) %>" <%= EchoSelected(optionList(i) = qbGroupBy) %>>
                                        <%= optionList(i) %></option>
                                    <%
    Next
                                    %>
                                </select>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </td>
        </tr>
        <tr>
            <td class="qb_content" style="height: 264px;" valign="top">
                <fieldset style="height: 24px;">
                    <legend>
                        <%=secondfieldsetcaption %></legend>
                    <table style="margin: 4px 4px 4px 4px;">
                        <tr>
                            <th>
                                <%=firstdrpcaption %>
                            </th>
                            <th>
                                <%=seconddrpcaption %>
                            </th>
                            <th>
                                <%=thirddrpcaption %>
                            </th>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td align="left" class="clause">
                                <select id="GroupingType" style="width: 100px;">
                                    <option value="" selected></option>
                                </select>
                            </td>
                            <td align="left" class="clause">
                                <select name="FieldAction" id="FieldAction" onchange="selectGroupingField(FieldAction)"
                                    style="width: 120px;">
                                    <%
    If RSEmpty(rs, gDBConn, qbFrom) Then
      '*** Loop through fields and get their name and type.
      For Each fld In rs.Fields
        fldType = GetFieldType(fld.Type)
        
        '*** Only add field if supported data type.
        If (fldType <> adEmpty) Then
                                    %>
                                    <option value="<%= fldType & ";" & fld.Name %>">
                                        <%= fld.Name %></option>
                                    <%
        End If
      Next
      
      
    End If
                                    %>
                                </select>
                            </td>
                            <td align="left" class="clause_input">
                                <input type="text" id="GroupAs" style="width: 147px; height: 21px;" onkeypress="return isValidField(event);"
                                    onpaste="return false;">
                            </td>
                            <td align="left" class="clause">
                                <button style="width: 103px; height: 22px;" class="edit" onclick="addGrouping()"
                                    id="Button3">
                                    <%=toevoegen %></button>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <select name="GroupList" size="11" style="width: 377px">
                                    <%
    '*** Create fields array.
    optionList = Split(qbGBSelect, ",")

    For i = LBound(optionList) To UBound(optionList)
                                    %>
                                    <option value="<%= optionList(i) %>">
                                        <%= optionList(i) %></option>
                                    <%
    Next
                                    %>
                                </select>
                            </td>
                            <td valign="top">
                                <button style="width: 103px; height: 22px;" class="edit" onclick="removeGrouping()"
                                    id="Button2">
                                    <%=verwijderen %></button>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </td>
        </tr>
        <tr>
            <td align="right" class="qb_actions">
                <button style="width: 100px; height: 22px;" class="action" name="Execute" value="Uitvoeren"
                    onclick='checkGBSelectClause();UpdateOpenerGridInfo();'>
                    <%=uitvoeren %></button>
            </td>
        </tr>
    </table>
</body>
<%
   '*** Cleanup.
   Call RSClose(rs)
   Call DBDisconnect(gDBConn)
%>
</html>
