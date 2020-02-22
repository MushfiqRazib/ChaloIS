<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="HIT.OB.STD.Wrapper.DAL" %>
<%@ Import Namespace="HIT.OB.STD.Wrapper.BLL" %>
<%@ Import Namespace="System.IO" %>
<head>
    <style type="text/css">
        .style1
        {
            height: 26px;
            width: 131px;
        }
    </style>
</head>
<table align="center" cellspacing="20" style="width: 252px">
    <tr>
        <td style="height: 123px" colspan="4">
            <fieldset>
                <legend>Document Gegevens</legend>
                <table align="center" cellspacing="4" style="margin: 8px 0px">
                    <%             
                                          
                        string keyList = Request.QueryString["KEYLIST"].ToString();
                        string valueList = Request.QueryString["VALUELIST"].ToString();
                        string reportCode = Request.QueryString["REPORT_CODE"];

                        DataTable dtDetailInfo;
                        DBManagerFactory dbManagerFactory = new DBManagerFactory();
                        IWrapFunctions iWrapFunc = dbManagerFactory.GetDBManager();
                        DataRow drRepportConfigInfo = iWrapFunc.GetReportConfigInfo(reportCode);
                        DataTable dtReportExtInfo = iWrapFunc.GetReportExtensionInfo(reportCode);

                        string fieldCaps = drRepportConfigInfo["field_caps"].ToString();
                        string sqlFrom = drRepportConfigInfo["SQL_FROM"].ToString();
                        string[] capsList = fieldCaps.Split(';');
                        string matcode = string.Empty;
                        string caption;
                        string fileSubpath = string.Empty;
                        string selectedFields = drRepportConfigInfo["detail_fieldsets"].ToString().Trim(new char[] { ';' }).Replace(';', ',');

                        HIT.OB.STD.Core.BLL.DBManagerFactory dbManagerFactoryCore = new HIT.OB.STD.Core.BLL.DBManagerFactory();
                        HIT.OB.STD.Core.DAL.IOBFunctions iCoreFunctions = dbManagerFactoryCore.GetDBManager(reportCode);
                        dtDetailInfo = iCoreFunctions.GetSpecificRowDetailData(sqlFrom, selectedFields, keyList, valueList);

                        string value = string.Empty;

                        if (dtDetailInfo.Rows.Count > 0)
                        {
                            foreach (System.Data.DataColumn dcItem in dtDetailInfo.Columns)
                            {
                                caption = HIT.OB.STD.Wrapper.CommonFunctions.GetCaption(dcItem.ColumnName, capsList);
                                if (!dcItem.ColumnName.Equals("detailed_desc")) // For task report
                                {
                                    value = dtDetailInfo.Rows[0][dcItem].ToString();                                   
                    %>
                    <tr>
                        <td class="Detail" nowrap>
                            <%=caption%>
                        </td>
                        <td class="Detail" nowrap>
                            :&nbsp;&nbsp;
                            <%= value%>
                        </td>
                    </tr>
                    <%
                        }

                            }
                        }
                    %>
                    <tr id="deepLinkRow">
                        <td class="Detail" nowrap>
                            Deeplink
                        </td>
                        <td class="Detail" nowrap>
                            :&nbsp;&nbsp;
                            <input readonly type="text" style="width: 450px;" id="deeplink" />
                        </td>
                    </tr>
                </table>
            </fieldset>
        </td>
    </tr>
    <tr>
        <%      
            
            string artikelNr = string.Empty;
            string revision = string.Empty;
            string url = string.Empty;
            bool mainDocFound = false;
            
            string[] keyItems = keyList.Split(';');
            string[] valueItems = valueList.Split(';');
            string whereClause = string.Empty;
            for (int k = 0; k < keyItems.Length; k++)
            {
                whereClause += keyItems[k] + " = '" + valueItems[k] + "' & ";
                //whereClause += "lower(trim(cast(" + keyItems[k] + " AS VARCHAR))) = trim(lower('" + valueItems[k] + "')) & ";
            }
            whereClause = whereClause.TrimEnd(new char[] { '&', ' ' }).Replace("&", "AND");



            if (reportCode.Equals("TASKS"))
            {
                url = "Attachment/TasksAttachment.asp?rc=true&matcodeField=task_id&revField= &artikelnr=" + dtDetailInfo.Rows[0]["task_id"].ToString() + "&version=" + revision + "&sqlfrom=";
                    
                %>
                <td style="height: 26px;">
                    <input type="button" onfocus="this.blur();" onclick="OpenAttachment('<%= url %>')"
                        style="width: 114px" value="Bijlagen" />
                </td>
                <%
            }
            else {
                string basePath = HIT.OB.STD.Wrapper.CommonFunctions.GetDocBasePath("DocBasePath");
                DataTable dtRelFile = iWrapFunc.GetRelativeFileName(sqlFrom, whereClause);
                string relativePath = dtRelFile.Rows[0]["relfilename"].ToString();
                string filePath = Path.Combine(basePath, relativePath);
               
                if (File.Exists(filePath))
                {
                    mainDocFound = true;
                }
            }
            
            if (reportCode.Equals("BASEMAT"))
            { 
                %>
                <td style="height: 26px;">
                    <input type="button" onfocus="this.blur();" onclick="OpenWhereUsed()" style="width: 144px"
                        value="Gebruikt in..." />
                </td>
                <%
                 
                if (mainDocFound)
                {
                    string attachmentQuery = "SELECT matcode FROM  heybasematerial";
                    string sqlQuery = attachmentQuery + " WHERE " + whereClause;

                    DataTable dt = iWrapFunc.GetDataTable(sqlQuery);
                    string matCodeFieldName = dt.Columns[0].ColumnName;
                    string revFieldName = string.Empty;
                    artikelNr = dt.Rows[0][0].ToString();
                    
                    url = "Attachment/BaseAttachment.asp?matcodeField=" + matCodeFieldName + "&revField=" + revFieldName + "&artikelnr=" + artikelNr + "&version=" + revision + "&sqlfrom=" + sqlFrom;
                    url = url.Replace(@"\", "/");
                    
                    %>
                        <td style="height: 26px;">
                            <input type="button" onfocus="this.blur();" onclick="OpenAttachment('<%= url %>')"
                                style="width: 114px" value="Bijlagen" />
                        </td>
                    <%
                }
            }
            
            if (dtReportExtInfo.Rows.Count > 0)
            {
                

                //*** Partlist Button
                if (dtReportExtInfo.Rows[0]["list_partlistsql"].ToString() != "" && dtReportExtInfo.Rows[0]["list_partlistsql"].ToString() != "no")
                {
               
                    %>
                    <td style="height: 26px;">
                        <%--<input type="button" onfocus="this.blur();" onclick="OpenPartlijst('<%= sqlFrom %>','<%=whereClause.Replace("'","|") %>','<%=reportCode %>')"
                            style="width: 144px" value="Onderdelenlijst" />--%>
                            <input type="button" onfocus="this.blur();" onclick="javascript:Ext.getCmp('obTabs').setActiveTab(4);"
                            style="width: 144px" value="Onderdelenlijst" />
                    </td>
                    <%
                }

                //*** History Button
                if (Convert.ToBoolean(dtReportExtInfo.Rows[0]["history"].ToString()))
                {                    
                            
                %>
                    <td>
                        <input type="button" onclick="OpenHistory('<%= sqlFrom %>','<%=whereClause.Replace("'","|")  %>')"
                             style="width: 114px"  onfocus="this.blur();" value="Historie" />
                    </td>
                <%
                }
               

                //*** Attachment Button
                if (dtReportExtInfo.Rows[0]["attachmentsql"] != null && dtReportExtInfo.Rows[0]["attachmentsql"].ToString() != "")
                {
                    try
                    {
                        string attachmentQuery = dtReportExtInfo.Rows[0]["attachmentsql"].ToString();
                        string sqlQuery = attachmentQuery + " WHERE " + whereClause;
                        DataTable dt = iWrapFunc.GetDataTable(sqlQuery);
                        string matCodeFieldName = dt.Columns[0].ColumnName;
                        string revFieldName = dt.Columns[1].ColumnName;
                        artikelNr = dt.Rows[0][0].ToString();
                        revision = dt.Rows[0][1].ToString();

                        if (mainDocFound)
                        { 
                           url = "Attachment/Attachment.asp?rc=true&matcodeField=" + matCodeFieldName + "&revField=" + revFieldName + "&artikelnr=" + artikelNr + "&version=" + revision + "&sqlfrom=" + sqlFrom;
                           url = url.Replace(@"\", "/");
                        }
                        else
                        {
                            url = "Geen document gevonden om bijlagen aan toe te voegen.";
                        }
                    }
                    catch (Exception ex)
                    {
                        url = "Relative file name is not defined";
                    }
                    
                    
                      
                                
        %>
        <td style="height: 26px;">
            <input type="button" onfocus="this.blur();" onclick="OpenAttachment('<%= url %>')"
                style="width: 114px" value="Bijlagen" />
        </td>
        <%
            }
            }
            
            
        %>
    </tr>
</table>
