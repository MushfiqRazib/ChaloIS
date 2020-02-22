<!-- #include file="../config.asp"     -->
<!-- #include file="./includes/common.asp"  -->
<!-- #include file="./includes/postgres.asp"  -->

<% 
  
  '********************** Start Culture Validation section *******************************
  Dim capPageTitle,capFieldset, firstdrpcaption, seconddrpcaption,thirddrpcaption,toevoegen,verwijderen,uitvoeren
  Dim firsttabimg, secondtabimg, thirdtabimg
  Dim cultureDoc
  cultureDoc = "./Cultures/Culture_" & CULTURECODE & ".xml"
  
  capPageTitle      = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/labels/pagetitle")  
  capFieldset       = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/labels/fieldsetcaption")
  firstdrpcaption   = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/labels/firstdrpcaption")
  seconddrpcaption  = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/labels/seconddrpcaption")
  thirddrpcaption   = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/labels/thirddrpcaption")
  toevoegen         = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/toevoegen/caption")
  edit              = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/edit/caption")
  verwijderen       = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/verwijderen/caption")
  
  capokedit         = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/okedit/caption")
  capcanceledit     = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/canceledit/caption")
  
  uitvoeren         = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/uitvoeren/caption")
  
  firsttabimg       = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/firsttab/controls/tabheaderactive/caption")
  secondtabimg      = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/secondtab/controls/tabheaderinactive/caption")
  thirdtabimg       = GetCultureValue(cultureDoc,"pagenames/querybuilderpage/thirdtab/controls/tabheaderinactive/caption")
  
  '********************** End Culture section *******************************************

  


    Dim rs, fld, fldType, qbFrom, qbWhere, optionList, optionValue, i,sessionId
	
    sessionId = RequestStr("SESSION_ID", "") 
	
	
    '*** On tab switch
    If (RequestStr("SrcSubmit", "") = "btnSelect") Then
      Call Response.Redirect("qb_select.asp?SESSION_ID=" & sessionId )
    ElseIf (RequestStr("SrcSubmit", "") = "btnGroupBy") Then
      Call Response.Redirect("qb_groupby.asp?SESSION_ID=" & sessionId )    
    End If
	
    
	sql = "select sql_from,sql_where from qb_parameters where session_id='" & sessionId & "'"
      If RSOpen(rs, gDBConn, sql, False) Then         
         qbFrom = rs("sql_from")
         qbWhere = rs("sql_where")       
      End if
	     
         
    %>
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <!-- #include file="./includes/copyright.inc" -->
    <html>

    <head>
      <title><%=capPageTitle %></title>
      
      <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
      
      <link rel="Stylesheet" type="text/css" href="./styles/qbuilder.css">
      
      <script type="text/javascript" src="./scripts/sarissa.js"></script>
      <script type="text/javascript" src="./scripts/common.js"></script>
      <script type="text/javascript" src="./scripts/qbuilder.js"></script>
           
      <script type="text/javascript">
      function init()
      {
		 HideElement("EditDiv");
         //*** Simulate 'onChange' event so 'ValueList' will be filled on load.
         selectField(getElementAttrib("FieldDef", "value"));        
         
      }

      function SetWhereCloseInOpenner() {
            var sqlwhere = getElementAttrib("WhereClause", "value");
            window.opener.QBSqlWhereTab(sqlwhere);
            
      }
      
      function selectField(value)
      {
      
        var fieldProps = value.split(";");
        
        //*** Set field name.
        setElementAttrib("FieldName", "value", fieldProps[0]);
        
        //*** Set field type.
        setElementAttrib("FieldType", "value", fieldProps[1]);
        
        //*** Get a list of distinct values for selected field.
        getDistinctValues("<%= qbFrom %>", fieldProps[0], 1000, "ValueList");
                      
        //*** Set default value.
        setElementAttrib("FieldValue", "value", "");
                
      }
      
      
      function selectEditField()
      {
        ShowElement('EditDiv', "<%= qbFrom %>");
                      
      }
            
            
      </script>
    </head>

    <body onload="init();" >

    <table width="100%" >
	    <form name="QueryBuilder" action="qb_where.asp" method="POST" onsubmit="return checkWhereClause()" ID="Form1">
	    <!-- security controls -->
        <input name="securityId" type="hidden" value='<%=securityId %>' />
        <input name="targetUrl" type="hidden" value='<%=targetUrl %>' />
        <input name="fromBrowser" type="hidden" value='<%=fromBrowser %>' />  
        <input name="SESSION_ID" type="hidden" value='<%=sessionId %>' />  
        <input name="qbFrom" type="hidden" value="<%=qbFrom %>" />                               
        <input name="qbWhere" type="hidden" value="<%=qbWhere %>" /> 
        <input name="sqlSelect" type="hidden" value="<%=sqlSelect %>" />                           
        <input name="qbGBSelectClause" type="hidden" value="<%=qbGBSelectClause %>" />  
                                      
	    <tr>
		    <td width="100%" class="qb_tabs">
		    <img src="./images/fill_left.png">
		    <img src="./images/<%=firsttabimg %>">
		    <input type="image" name="btnSelect" src="./images/<%=secondtabimg %>" onClick='setElementAttrib("SrcSubmit", "value", "btnSelect");' ID="Image1">
		    <input type="image" name="btnGroupBy" src="./images/<%=thirdtabimg %>" onClick='setElementAttrib("SrcSubmit", "value", "btnGroupBy");' ID="Image2">
		    </td>
	    </tr>
		    <!-- Local variables we want to submit -->
		    <input type="hidden" name="FieldName"   value="">
		    <input type="hidden" name="FieldType"   value="">
		    <input type="hidden" name="Submitted"   value="1">
		    <input type="hidden" name="WhereClause" value="<%= qbWhere %>">
		    <input type="hidden" name="SrcSubmit"   value="">
	    </form>
	    <tr>
		    <td class="qb_content" style="height: 332px;">

			    <fieldset style="height: 305px">
				    <legend><%=capFieldset %></legend>
    				  
				    <table style="margin: 4px 4px 4px 4px;">
					    <tr>
						    <th style="height: 17px"><%=firstdrpcaption %></th>
						    <th style="height: 17px"><%=seconddrpcaption %></th>
						    <th width="250px" style="height: 17px"><%=thirddrpcaption %></th>
						    <td width="108px" style="height: 17px"></td>
					    </tr>
					    <tr>
						    <td align="left" class="clause" style="height: 25px">
						    <select name="FieldDef" onchange="selectField(this.value)" style="width: 146px">
	    <%
	    If RSEmpty(rs, gDBConn, qbFrom) Then
	    '*** Loop through fields and get their name and type.
	    For Each fld In rs.Fields
		    fldType = GetFieldType(fld.Type)
    	    
		    '*** Only add field if supported data type.
		    If (fldType <> adEmpty) Then
	    %>						<option value="<%= fld.Name & ";" & fldType %>"><%= fld.Name %></option>
	    <%
		    End If
	    Next
    	  
	    
	    End If
	    %>					</select>
					    </td>
					    <td align="left" class="clause" style="height: 25px">
						    <select name="FieldComp" style="width: 60px;">
							    <option value="=" selected>=</option>
							    <option value="&lt;&gt;">&lt;&gt;</option>
							    <option value="&lt;">&lt;</option>
							    <option value="&gt;">&gt;</option>
							    <option value="&lt;=">&lt;=</option>
							    <option value="&gt;=">&gt;=</option>
							    <!--<option value="IN">IN</option>-->
							    <option value="LIKE">LIKE</option>
						    </select>
					    </td>
					    <td valign="top" style="padding-top: 1px; width: 194px; height: 25px;">
						    <input type="text" class="Combobox" name="FieldValue" onkeypress="return isValidWhere(event);" onpaste="return false" >
						    <select class="Combobox" id="ValueList" onchange="setElementAttrib('FieldValue', 'value', this.value)">
							    <option value="" selected></option>							    
						    </select>
					    </td>
					    <td align="left" class="clause" style="height: 25px">
						    <button style="width: 100px; height: 22px;" class="edit" onclick="addWhereClause()" ID="Button2"><%=toevoegen %></button>
					    </td>
				    </tr>
				    <tr>
					    <td colspan="3" style="height: 156px">
						    <select name="WhereList" size="10" style="width: 377px;">
	    <%
	    '*** Create fields array.
	    optionList = Split(ToString(qbWhere), "AND")

	    For i = LBound(optionList) To UBound(optionList)
	    '*** Chunk of unneccessary characters.
	    optionValue = Trim(optionList(i))
    	  
	    If (Left(optionValue, 1) = "(") And (Right(optionValue, 1) = ")") Then
		    '*** Remove brackets.
		    optionValue = Mid(optionValue, 2, Len(optionValue) - 2)		    
	    End If
	    %>						<option value="<%= optionValue %>"><%= unescape(optionValue) %></option>
	    <%
	    Next
	    %>					</select>
					    </td>
					    <td valign="top" style="height: 156px">
					      <table>
					      <tr><td>
					      <button style="width: 100px; height: 22px;" class="edit"  onClick="selectEditField()"><%=edit %></button>
					      </td></tr>
					      <tr><td style="padding-top:5px; height: 27px;">
					      <button style="width: 100px; height: 22px;" class="edit" onclick="removeWhereClause()"><%=verwijderen %></button>
					        
					      </td></tr>					      
					      </table>	
					      						  
					    </td>					    
				      </tr>
				     <tr>
				    </tr>
			    </table>
		    </fieldset>
	    </tr>
	    <tr>
		    <td align="right" class="qb_actions">			    
			    <button style="width: 100px; height: 22px;" class="action" name="Execute" value="Uitvoeren" onclick='checkWhereClause(); SetWhereCloseInOpenner();'><%=uitvoeren %></button>
		    </td>
	    </tr>
    </table>
    
    <div id="EditDiv" style="position:absolute;top:281px;left:16px;width:373px;height:60px; background-color:#FFFFCC;color:Black;visibility:visible; border: 1px solid #000000;">
        <table style="width: 375px">      
        <tr style="height:5px;width:100%"><td colspan=3></td></tr>  
        <tr>
        <td style="padding-left:7px; width: 133px; height: 29px;"><input type=text id="edtFieldName" style="width: 130px" readonly /></td>
        <td style="width: 55px; height: 29px;"><select name="edtFieldComp" style="width: 51px;">
							    <option value="=" selected>=</option>
							    <option value="&lt;&gt;">&lt;&gt;</option>
							    <option value="&lt;">&lt;</option>
							    <option value="&gt;">&gt;</option>
							    <option value="&gt;=">&gt;=</option>
            <option value=""></option>
                <option value="<= " ">&lt;=</option>
							    <option value="LIKE">LIKE</option>
		</select></td>
        <td style="width: 154px; height: 25px;">
        <input type="text" class="Combobox" id="edtFieldValue" name="FieldEditValue" style="top: 9px; height: 21px" >
		<select class="Combobox" id="ValueEditList" name="FieldEditValue" onchange="setElementAttrib('FieldEditValue', 'value', this.value)" style="top: 9px">							    						    
						    </select>
        </td>        
        </tr>
        <tr>
					      <td colspan="2" style="height: 22px"></td>
					      <td align="right" style="width: 154px;padding-right:9px; height: 22px;"><button style="width: 70px; height: 22px;" class="edit" onclick="EditWhereClause('EditDiv')"><%=capokedit %></button>
					      <button style="width: 70px; height: 22px;" class="edit" onclick="HideElement('EditDiv')"><%=capcanceledit %></button></td>
					      </tr>
        </table>
    </div>
    

    </body>
    <%
   '*** Cleanup.
   Call RSClose(rs)
   Call DBDisconnect(gDBConn)
    %>
    </html>
    

