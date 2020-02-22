using System;
using System.Data;
using Npgsql;
using System.Configuration;
using HIT.OB.STD.Core;
using System.Text;
using System.Text.RegularExpressions;

/// <summary>
/// Summary description for PostgresDBHandler
/// </summary>

namespace HIT.OB.STD.Wrapper.DAL
{
    public class PostgresDBManager : IWrapFunctions
    {
        private static string ConnectionString
        {
            get { return ConfigManager.GetConnectionString(); }
        }

        public DataTable GetReportList()
        {
            string query = "select report_code, report_name from " + ConfigManager.GetReportTableName() + " order by report_order;";
            DataTable dtReportList = GetDataTable(query);
            return dtReportList;
        }

        public DataTable GetReportArguments(string reportCode)
        {
            try
            {
                string query = "select * from " + ConfigManager.GetReportTableName() + " where upper(report_code) ='" + reportCode.ToUpper() + "'";
                LogWriter.WriteLog(query);
                DataTable dtReportArgs = GetDataTable(query);
                return dtReportArgs;
            }
            catch (Exception)
            {
                throw;
            }
        }

        public DataTable GetReportFieldList(string tableName)
        {
            try
            {
                string query = "SELECT * FROM " + tableName + " WHERE 1 = 0";
                DataTable dtFieldList = GetDataTable(query);
                return dtFieldList;
            }
            catch (Exception)
            {
                throw;
            }
        }

        public DataTable GetReportFunctionsList(string reportCode)
        {
            try
            {
                string query = "select * from " + ConfigurationManager.AppSettings["reportfunctionstable"] + " where upper(report_code) ='" + reportCode.ToUpper() + "' order by order_position";
                LogWriter.WriteLog(query);
                DataTable dtFunReportArgs = GetDataTable(query);
                return dtFunReportArgs;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        public DataTable GetDataTable(string query)
        {
            DataTable dataTable = new DataTable();
            try
            {
                using (NpgsqlConnection dbConnection = new NpgsqlConnection(ConnectionString))
                {
                    NpgsqlDataAdapter adapter = new NpgsqlDataAdapter();
                    adapter.SelectCommand = new NpgsqlCommand(query, dbConnection);
                    adapter.Fill(dataTable);
                }
            }
            catch (Exception ex)
            {
                throw new Exception("From GetDataTable method:" + ex.Message);
            }
            return dataTable;
        }



        public bool UpdateUserDefinedReportSettings(string REPORT_CODE, string SQL_WHERE, string GROUP_BY, string ORDER_BY, string ORDER_BY_DIR, string field_caps, string report_settings)
        {
            string updateQuery = @"update dfn_repdetail set 
                                   report_settings=:report_settings,
                                   field_caps=:field_caps,
                                   sql_where=:sql_where,sql_groupby=:sql_groupby,
                                   sql_orderby=:sql_orderby,sql_orderdir=:sql_orderdir Where REPORT_CODE=:REPORT_CODE";
            using (NpgsqlConnection con = new NpgsqlConnection(ConnectionString))
            {
                using (NpgsqlCommand updateCmd = new NpgsqlCommand(updateQuery, con))
                {
                    updateCmd.Parameters.Add("report_settings", report_settings);
                    updateCmd.Parameters.Add("sql_where", SQL_WHERE);
                    updateCmd.Parameters.Add("sql_groupby", GROUP_BY);
                    updateCmd.Parameters.Add("sql_orderby", ORDER_BY);
                    updateCmd.Parameters.Add("sql_orderdir", ORDER_BY_DIR);
                    updateCmd.Parameters.Add("REPORT_CODE", REPORT_CODE);
                    updateCmd.Parameters.Add("field_caps", field_caps);
                    updateCmd.Connection.Open();
                    updateCmd.ExecuteNonQuery();
                    updateCmd.Connection.Close();
                }
            }

            return true;
        }

        public bool CreateNewReportWithSettings(string REPORT_CODE, string REPORT_NAME, string SQL_WHERE, string GROUP_BY, string ORDER_BY, string ORDER_BY_DIR, string field_caps, string report_settings, string sid, string reports, string obs)
        {

            //select the report from dfn_repdetail table to make a copy
            string query = "SELECT * FROM  dfn_repdetail WHERE REPORT_CODE = '" + REPORT_CODE + "'";
            DataTable reportTable = GetDataTable(query);

            //insert a new row in the dfn_repdetail by copying the values from current report
            query = @"INSERT INTO dfn_repdetail values (:report_code,:report_name,:report_order,:field_caps,:sql_gisselect,:sql_from,:sql_where,:sql_groupby,:sql_orderby,:connection_string,:sql_orderdir,:sql_keyfields,:report_settings,:gis_theme_layer,:multiselect,:detail_fieldsets,:deeplink)";

            NpgsqlCommand sqlCmp = new NpgsqlCommand(query);
            sqlCmp.Parameters.Add("report_settings", report_settings);
            sqlCmp.Parameters.Add("sql_where", SQL_WHERE);
            sqlCmp.Parameters.Add("sql_groupby", GROUP_BY);
            sqlCmp.Parameters.Add("sql_orderby", ORDER_BY);
            sqlCmp.Parameters.Add("sql_orderdir", ORDER_BY_DIR);
            sqlCmp.Parameters.Add("report_code", REPORT_NAME);
            sqlCmp.Parameters.Add("field_caps", field_caps);
            sqlCmp.Parameters.Add("report_name", REPORT_NAME);
            sqlCmp.Parameters.Add("report_order", Convert.ToInt16(reportTable.Rows[0]["report_order"].ToString()));
            sqlCmp.Parameters.Add("sql_gisselect", reportTable.Rows[0]["sql_gisselect"].ToString());
            sqlCmp.Parameters.Add("sql_from", reportTable.Rows[0]["sql_from"].ToString());
            sqlCmp.Parameters.Add("connection_string", reportTable.Rows[0]["connection_string"].ToString());
            sqlCmp.Parameters.Add("sql_keyfields", reportTable.Rows[0]["sql_keyfields"].ToString());
            if (reportTable.Rows[0]["gis_theme_layer"].ToString().Equals(String.Empty))
            {
                sqlCmp.Parameters.Add("gis_theme_layer", null);
            }
            else
            {
                sqlCmp.Parameters.Add("gis_theme_layer", Convert.ToBoolean(reportTable.Rows[0]["gis_theme_layer"].ToString()));
            }
            if (reportTable.Rows[0]["multiselect"].ToString().Equals(String.Empty))
            {
                sqlCmp.Parameters.Add("multiselect", null);
            }
            else
            {
                sqlCmp.Parameters.Add("multiselect", Convert.ToBoolean(reportTable.Rows[0]["multiselect"]));
            }
            if (reportTable.Rows[0]["deeplink"].ToString().Equals(String.Empty))
            {
                sqlCmp.Parameters.Add("deeplink", null);
            }
            else
            {
                sqlCmp.Parameters.Add("deeplink", Convert.ToBoolean(reportTable.Rows[0]["deeplink"]));
            }

            sqlCmp.Parameters.Add("detail_fieldsets", reportTable.Rows[0]["detail_fieldsets"].ToString());



            query = "SELECT * FROM  edm_repdetail WHERE REPORT_CODE = '" + REPORT_CODE + "'";
            DataTable edmTable = GetDataTable(query);

            //insert a new row in the dfn_repdetail by copying the values from current report
            query = @"INSERT INTO edm_repdetail values
            (:report_code,:list_partlistsql,:description_list_partlistsql,:list_whereusedsql,:description_list_whereusedsql,:attachmentsql,:history)";

            NpgsqlCommand edmCmd = new NpgsqlCommand(query);
            edmCmd.Parameters.Add("report_code", REPORT_NAME);
            edmCmd.Parameters.Add("list_partlistsql", edmTable.Rows[0]["list_partlistsql"]);
            edmCmd.Parameters.Add("description_list_partlistsql", edmTable.Rows[0]["description_list_partlistsql"]);
            edmCmd.Parameters.Add("list_whereusedsql", edmTable.Rows[0]["list_whereusedsql"]);
            edmCmd.Parameters.Add("description_list_whereusedsql", edmTable.Rows[0]["description_list_whereusedsql"]);
            edmCmd.Parameters.Add("attachmentsql", edmTable.Rows[0]["attachmentsql"]);
            edmCmd.Parameters.Add("history", edmTable.Rows[0]["history"]);


            query = "SELECT * FROM  hitcon_auth_def WHERE AUTHSECTION = 'REPORT' AND FUNCTIONNAME = '" + REPORT_CODE + "'";
            DataTable authTable = GetDataTable(query);

            //insert a new row in the dfn_repdetail by copying the values from current report
            query = @"INSERT INTO hitcon_auth_def values
            (:rolename,:authsection,:functionname,:description)";

            NpgsqlCommand authCmd = new NpgsqlCommand(query);
            authCmd.Parameters.Add("rolename", authTable.Rows[0]["rolename"]);
            authCmd.Parameters.Add("authsection", authTable.Rows[0]["authsection"]);
            authCmd.Parameters.Add("functionname", REPORT_NAME);
            authCmd.Parameters.Add("description", authTable.Rows[0]["description"]);

            // select the functions from report_functions table to make copy for the new report
            query = "SELECT * FROM  report_functions WHERE REPORT_CODE = '" + REPORT_CODE + "'";
            DataTable functionTable = GetDataTable(query);

            NpgsqlCommand functionCommand = new NpgsqlCommand(query);
            reports = reports.Replace(",", "\",\"");
            reports = "\"" + reports + "\"";
            obs = obs.Replace(",", "\",\"");
            obs = "\"" + obs + "\"";
            query = "update securityinfo set authentication_values = '{\"REPORT\":[" + reports + "],\"OB\":[" + obs + "]}' where securityid = '"+sid+"'";
            NpgsqlCommand securityCommand = new NpgsqlCommand(query);
            NpgsqlCommand[] commands = new NpgsqlCommand[functionTable.Rows.Count + 5];
            commands[0] = sqlCmp;
            commands[1] = edmCmd;
            commands[2] = authCmd;
            commands[3] = functionCommand;
            commands[4] = securityCommand;


            //insert new rows in the report_functions table for the new report
            for (int i = 0; i < functionTable.Rows.Count; i++)
            {
                query = @"insert into report_functions values(:report_code,:function_name,:order_position,:parameters,:iscustom)";
                commands[5 + i] = new NpgsqlCommand(query);
                commands[5 + i].Parameters.Add("report_code", REPORT_NAME);
                commands[5 + i].Parameters.Add("function_name", functionTable.Rows[i]["function_name"].ToString());
                commands[5 + i].Parameters.Add("order_position", Convert.ToInt16(functionTable.Rows[i]["order_position"].ToString()));
                commands[5 + i].Parameters.Add("parameters", functionTable.Rows[i]["parameters"].ToString());

                if (functionTable.Rows[i]["iscustom"].ToString().Equals(String.Empty))
                {
                    commands[5 + i].Parameters.Add("iscustom", null);
                }
                else
                {
                    commands[5 + i].Parameters.Add("iscustom", Convert.ToBoolean(functionTable.Rows[i]["iscustom"]));
                }
            }

            NpgsqlTransaction transaction = null;
            NpgsqlConnection conn;
            conn = new NpgsqlConnection(PostgresDBManager.ConnectionString);

            try
            {
                conn.Open();
                transaction = conn.BeginTransaction();
                foreach (NpgsqlCommand command in commands)
                {
                    command.Connection = conn;
                    command.Transaction = transaction;
                    command.ExecuteNonQuery();
                }
                transaction.Commit();
            }
            catch (NpgsqlException ex)
            {
                transaction.Rollback();
                //throw new Exception("ERROR: " + ex.Code + "<br>" + "ERROR Message: " + ex.Message);
                return false;
            }
            finally
            {
                conn.Close();
            }

            return true;
        }

        public DataRow GetReportConfigInfo(string reportCode)
        {
            DataTable dataTable = new DataTable();
            try
            {
                string query = "select field_caps, sql_from,detail_fieldsets,sql_keyfields from " + ConfigManager.GetReportTableName() + " where upper(report_code) ='" + reportCode.ToUpper() + "'";
                using (NpgsqlConnection dbConnection = new NpgsqlConnection(ConnectionString))
                {
                    using (NpgsqlDataAdapter adapter = new NpgsqlDataAdapter())
                    {
                        adapter.SelectCommand = new NpgsqlCommand(query, dbConnection);
                        adapter.Fill(dataTable);
                        return dataTable.Rows[0];
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("From GetDataTable method:" + ex.Message);
            }
            return null;
        }


        public static void ExecuteTransaction(NpgsqlCommand[] commands)
        {
            NpgsqlTransaction transaction = null;
            NpgsqlConnection conn;
            conn = new NpgsqlConnection(PostgresDBManager.ConnectionString);

            try
            {
                conn.Open();
                transaction = conn.BeginTransaction();
                foreach (NpgsqlCommand command in commands)
                {
                    command.Connection = conn;
                    command.Transaction = transaction;
                    command.ExecuteNonQuery();
                }
                transaction.Commit();
            }
            catch (NpgsqlException ex)
            {
                transaction.Rollback();
                throw new Exception("ERROR: " + ex.Code + "<br>" + "ERROR Message: " + ex.Message);
            }
            finally
            {
                conn.Close();
            }
        }
        public static void ExecuteTransaction(System.Collections.ArrayList commands)
        {
            NpgsqlTransaction transaction = null;
            NpgsqlConnection conn;
            conn = new NpgsqlConnection(PostgresDBManager.ConnectionString);

            try
            {
                conn.Open();
                transaction = conn.BeginTransaction();
                foreach (NpgsqlCommand command in commands)
                {
                    command.Connection = conn;
                    command.Transaction = transaction;
                    command.ExecuteNonQuery();
                }
                transaction.Commit();
            }
            catch (NpgsqlException ex)
            {
                transaction.Rollback();
                throw new Exception("ERROR: " + ex.Code + "<br>" + "ERROR Message: " + ex.Message);
            }
            finally
            {
                conn.Close();
            }
        }
        public string GetConnectionStringForReport(string REPORT_CODE)
        {
            string query = "select connection_string from " + ConfigManager.GetReportTableName() + " Where report_code='" + REPORT_CODE + "'";
            DataTable dtConSring = GetDataTable(query);
            if (dtConSring.Rows.Count > 0 && !dtConSring.Rows[0][0].ToString().Trim().Equals(string.Empty))
            {
                return dtConSring.Rows[0][0].ToString();
            }
            else
            {
                return string.Empty;
            }
        }

        public bool InsertGroupColor(string REPORT_CODE, string GROUP_BY, string GROUP_CODE, string COLOR_CODE)
        {
            bool IsInserted = false;
            string TableName = ConfigurationManager.AppSettings["groupcolortable"];
            GROUP_CODE = GROUP_CODE.Trim(',');
            COLOR_CODE = COLOR_CODE.Trim(',');
            string[] groupList = GROUP_CODE.Split(',');
            string[] colorList = COLOR_CODE.Split(',');
            NpgsqlCommand commands = new NpgsqlCommand();
            string deleteQueryValues = "(";
            for (int i = 0; i < groupList.Length; i++)
            {
                deleteQueryValues += "'" + REPORT_CODE + "'||'" + GROUP_BY +
                                    "'||'" + groupList[i] + "',";
            }
            deleteQueryValues = deleteQueryValues.Remove(deleteQueryValues.LastIndexOf(','), 1);
            deleteQueryValues += ")";
            NpgsqlConnection conn = new NpgsqlConnection(ConnectionString);

            try
            {
                conn.Open();
                string deleteSQL = "delete from " + TableName + " where reportcode || groupby || groupcode in " +
                                        deleteQueryValues;

                commands = new NpgsqlCommand(deleteSQL, conn);
                commands.ExecuteNonQuery();

                for (int i = 0; i < groupList.Length; i++)
                {

                    string insertSQL = " insert into " + TableName +
                                        " (reportcode,groupby,groupcode,colorcode) " +
                                        " values(:reportcode,:groupby,:groupcode,:colorcode) ";

                    commands = new NpgsqlCommand(insertSQL, conn);
                    commands.Parameters.Add("reportcode", REPORT_CODE);
                    commands.Parameters.Add("groupby", GROUP_BY);
                    commands.Parameters.Add("groupcode", groupList[i]);
                    commands.Parameters.Add("colorcode", colorList[i]);
                    commands.ExecuteNonQuery();
                }
                IsInserted = true;
            }
            catch (Exception ex)
            {
                IsInserted = false;
                throw new Exception("From GetDataTable method:" + ex.Message);
            }
            finally
            {
                conn.Close();
            }
            return IsInserted;
        }

        public string GetNextTaskID()
        {
            string sql = "select task_id from tasks";
            string task_id = "TK" + DateTime.Today.ToString("yyMMdd");
            long SN;

            DataTable dt = GetDataTable(sql);
            DataTable dtSN = new DataTable();
            dtSN.Columns.Add("SN", typeof(long));


            DataRow myRow;
            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    SN = Convert.ToInt64(dt.Rows[i][0].ToString().Split(new char[] { '-' })[1]);

                    myRow = dtSN.NewRow();
                    myRow["SN"] = SN;
                    dtSN.Rows.Add(myRow);
                }
                DataView dtView = new DataView(dtSN);
                dtView.Sort = "SN ASC";

                DataTable dtR = dtView.ToTable();

                string nSN = (Convert.ToInt64(dtR.Rows[dtR.Rows.Count - 1][0].ToString()) + 1).ToString();
                task_id = task_id + "-" + (nSN.Length > 1 ? nSN : "0" + nSN);
            }
            else
            {
                task_id = task_id + "-01";
            }

            return task_id;
        }

        public string PostDocumentUpdate(string taskSummary, string taskDesc, string openedBy, string assignTo, string refInfo, string original_fileName)
        {
            string maxId = string.Empty;
            string sql = "insert into tasks(task_id, project_id,opened_by,item_summary,detailed_desc,item_status,last_edited_by,assign_to, original_filename) values(:task_id, :project_id,:opened_by,:item_summary,:detailed_desc,:item_status,:last_edited_by,:assign_to,:original_filename)";
            try
            {
                taskSummary = taskSummary.Replace("@@", "\'");
                taskSummary = taskSummary.Replace("$$", "\"");
                taskDesc = taskDesc.Replace("@@", "\'");
                taskDesc = taskDesc.Replace("$$", "\"");

                using (NpgsqlConnection dbConnection = new NpgsqlConnection(ConnectionString))
                {
                    dbConnection.Open();
                    maxId = GetNextTaskID();
                    using (NpgsqlCommand command = new NpgsqlCommand(sql))
                    {
                        command.Parameters.Add("task_id", maxId);
                        command.Parameters.Add("project_id", "EDM");
                        command.Parameters.Add("opened_by", openedBy);
                        command.Parameters.Add("item_summary", taskSummary);
                        command.Parameters.Add("detailed_desc", taskDesc);
                        command.Parameters.Add("item_status", "Open");
                        command.Parameters.Add("last_edited_by", "");
                        command.Parameters.Add("assign_to", assignTo);
                        command.Parameters.Add("original_filename", original_fileName);
                        command.Connection = dbConnection;
                        int a = command.ExecuteNonQuery();
                    }

                    dbConnection.Close();

                }
            }
            catch (Exception ex)
            {
                return "-1";
            }


            return maxId;
        }

        public DataTable GetReportExtensionInfo(string reportCode)
        {
            string query = "select * from edm_repdetail where report_code='" + reportCode + "'";
            DataTable dtReportList = GetDataTable(query);
            return dtReportList;
        }

        public DataTable GetRelativeFileName(string sqlFrom, string where_)
        {
            string query = "select relfilename from " + sqlFrom + " where " + where_;
            DataTable dtRelFileName = GetDataTable(query);
            return dtRelFileName;
        }

        public DataTable GetPartlistInfo(string partlistQuery)
        {
            DataTable dtReportList = new DataTable();
            dtReportList = GetDataTable(partlistQuery);
            return dtReportList;
        }

        public string GetArticleCodeAndRevisionAndPartlistDataQuery(string sqlFrom, string whereClause, string rep_code)
        {
            string queryEDMdetail = "select list_partlistsql,description_list_partlistsql from edm_repdetail where lower(report_code) = '" + rep_code.ToLower() + "'";
            DataTable dt = GetDataTable(queryEDMdetail);
            string partlistQuery = dt.Rows[0][0].ToString();

            string[] fields = HIT.OB.STD.CommonUtil.ExtractFieldNameFromQuery(partlistQuery).Split(',');
            string sqlQuery = "select " + string.Join(",", fields) + " FROM " + sqlFrom + " WHERE " + whereClause;
            DataTable dtData = this.GetDataTable(sqlQuery);
            string artikelNr = dtData.Rows[0][0].ToString();
            string revision = dtData.Rows[0][1].ToString();

            partlistQuery = partlistQuery.Replace("%" + fields[0] + "%", "'" + artikelNr + "'").Replace("%" + fields[1] + "%", "'" + revision + "'");

            return fields[0].ToUpperFirstChar() + " : " + artikelNr + "@@@@" + fields[1].ToUpperFirstChar() + " : " + revision + "@@@@" + partlistQuery;
        }

        public DataTable GetBaseMaterialDetail(string KeyNameValues, string rep_code)
        {
            string[] fieldTypes = GetFieldNameType("heypartlist").Split('|');
            string[] nameValueList = KeyNameValues.Split('$');
            string type = GetFieldType(fieldTypes, nameValueList[0]);
            string whereClause = nameValueList[0] + "='" + nameValueList[1] + "'";
            if (type.Equals("STRING", StringComparison.OrdinalIgnoreCase))
            {
                whereClause = "trim(" + nameValueList[0] + ")=trim('" + nameValueList[1] + "')";
            }
            //string queryBaseMaterial = "select  parentmatcode,partdescr,parentrev,count(*) as \"Uses Count\" from heypartlist where " + whereClause + " group by partdescr,parentmatcode,parentrev";
            string queryBaseMaterial = GetBaseMaterialQuery(whereClause, rep_code);
            LogWriter.WriteLog(queryBaseMaterial);
            DataTable dtBaseMat = GetDataTable(queryBaseMaterial);
            return dtBaseMat;
        }


        public string GetBaseMaterialQuery(string whereClause, string rep_code)
        {
            string queryEDMdetail = "select list_whereusedsql, description_list_whereusedsql from edm_repdetail where lower(report_code) = '" + rep_code.ToLower() + "'";
            DataTable dt = GetDataTable(queryEDMdetail);
            string whereUsedQuery = dt.Rows[0][0].ToString();
            int start = whereUsedQuery.IndexOf("WHERE") + 6;
            int lengthOfWhereClause = whereUsedQuery.LastIndexOf("%") - start + 1;
            string existingWhereClauseSubstring = whereUsedQuery.Substring(start, lengthOfWhereClause);
            whereUsedQuery = whereUsedQuery.Replace(existingWhereClauseSubstring, whereClause);

            return whereUsedQuery;
        }


        private string GetCaseInsensitiveWhere(string sqlWhere, string tableName)
        {
            string[] fieldTypes = GetFieldNameType(tableName).Split('|');
            string outerPattern = @"( AND )|( OR )";
            string newTgtString;
            StringBuilder newWhere = new StringBuilder();
            string[] conditions = Regex.Split(sqlWhere, outerPattern, RegexOptions.None);
            foreach (string condString in conditions)
            {
                newTgtString = condString.Trim();
                string innerPattern = @"(<>)|(=)|(<=)|(>=)|(<)|(>)|(\sLIKE\s)";
                string[] condItems = Regex.Split(newTgtString, innerPattern, System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                if (condItems.Length == 3)
                {
                    string type = GetFieldType(fieldTypes, condItems[0]);
                    if (type.Equals("STRING", StringComparison.OrdinalIgnoreCase))
                    {
                        newWhere.Append("UPPER(").Append(condItems[0]).Append(") ");
                        newWhere.Append(condItems[1]);
                        newWhere.Append(" UPPER(").Append(condItems[2]).Append(")");
                    }
                    else
                    {
                        newWhere.Append(condItems[0]).Append(" ");
                        newWhere.Append(condItems[1]);
                        newWhere.Append(" ").Append(condItems[2]).Append(" ");
                    }
                }
                else
                {
                    newWhere.Append(" ").Append(newTgtString).Append(" ");
                }
            }
            return newWhere.ToString().Trim();
        }

        public int GetNormalGridRowCount(string tableName, string sqlWhere)
        {
            sqlWhere = GetCaseInsensitiveWhere(sqlWhere, tableName);
            string query = "SELECT count(*) FROM " + tableName;
            if (!sqlWhere.Equals(string.Empty))
            {
                query += " WHERE " + sqlWhere;
            }
            LogWriter.WriteLog("GetNormalRowCount: " + query);
            int totalRows = 0;
            using (NpgsqlConnection con = new NpgsqlConnection(ConnectionString))
            {
                NpgsqlCommand com = new NpgsqlCommand(query, con);
                con.Open();
                totalRows = Convert.ToInt32(com.ExecuteScalar());
                con.Close();
                com.Dispose();
            }
            return totalRows;
        }

        public DataTable GetNormalGridData(string tableName, string sqlSelect, string sqlWhere, string START_ROW, string PAGE_SIZE, string SQL_ORDER_BY, string SQL_ORDER_DIR)
        {
            sqlWhere = GetCaseInsensitiveWhere(sqlWhere, tableName);
            string query = "SELECT " + sqlSelect + " FROM " + tableName;
            if (!sqlWhere.Equals(string.Empty))
            {
                query += " WHERE " + sqlWhere;
            }

            if (SQL_ORDER_BY != null && SQL_ORDER_BY != "" && SQL_ORDER_BY != "undefined" && SQL_ORDER_BY != "ADD" && SQL_ORDER_BY != "EDIT" && SQL_ORDER_BY != "DELETE")
            {
                query += String.Format(" ORDER BY {0} {1}", SQL_ORDER_BY, SQL_ORDER_DIR);
            }

            query += " limit " + PAGE_SIZE + " offset " + START_ROW;

            LogWriter.WriteLog("GetNormalResultsetForGrid: " + query);

            DataTable dt = GetDataTable(query);
            //dt.Columns.Add(new DataColumn("id-no"));

            return dt;
        }

        private string GetFieldType(string[] fieldTypes, string fieldName)
        {
            foreach (string str in fieldTypes)
            {
                string[] typeName = str.Split(';');
                if (typeName[1].Equals(fieldName, StringComparison.OrdinalIgnoreCase))
                {
                    return typeName[0];
                }
            }
            return "NUEMRIC";
        }

        public DataTable GetGroupByGridData(string sqlSelectFields, string columnName, string tableName, string sqlWhere, string startRow, string pageSize, string SQL_ORDER_BY, string SQL_ORDER_DIR, string QB_GB_SELECT_CLAUSE, string GIS_THEME_LAYER)
        {
            sqlWhere = GetCaseInsensitiveWhere(sqlWhere, tableName);
            string order_by = string.Empty;
            string countBlock = string.Format("COUNT(*) AS Nr");
            if (!string.IsNullOrEmpty(sqlWhere))
            {
                sqlWhere = " WHERE " + sqlWhere;
            }

            if (!string.IsNullOrEmpty(SQL_ORDER_BY) && SQL_ORDER_BY.IndexOf(" AS ") == -1)
            {
                order_by = String.Format(" ORDER BY {0} {1} ", columnName, SQL_ORDER_DIR);
            }
            else if (SQL_ORDER_BY.IndexOf(" AS ") > -1)
            {
                order_by = SQL_ORDER_BY.Split(new string[] { " AS " }, StringSplitOptions.RemoveEmptyEntries)[0];
                order_by = String.Format(" ORDER BY {0} {1} ", order_by, SQL_ORDER_DIR);
            }

            //string query = string.Format("SELECT {0}, {5} FROM {1} {6} GROUP BY {0} {4} LIMIT {2} OFFSET {3} ", columnName, tableName, pageSize, startRow, order_by, countBlock, sqlWhere);
            string query = string.Format("SELECT {0},{1} FROM {2} {3} GROUP BY {4} {5} LIMIT {6} OFFSET {7} ", sqlSelectFields, countBlock, tableName, sqlWhere, columnName, order_by, pageSize, startRow);

            LogWriter.WriteLog("GetGroupByResultsetForGrid: " + query);
            return GetDataTable(query);
        }

        public string GetFieldNameType(string SQL_FROM)
        {
            SQL_FROM = SQL_FROM.Trim('"');
            string query = "select column_name,data_type as type from information_schema.columns where table_name='" + SQL_FROM + "'";

            DataTable dt = GetDataTable(query);
            string typeAndNames = string.Empty;
            string dataType = string.Empty;
            foreach (DataRow dr in dt.Rows)
            {
                if (dr["type"].ToString().StartsWith("boolean") || dr["type"].ToString().StartsWith("bigint") || dr["type"].ToString().StartsWith("double") || dr["type"].ToString().StartsWith("numeric") || dr["type"].ToString().StartsWith("integer"))
                {
                    typeAndNames += "NUMERIC";
                }
                else if (dr["type"].ToString().StartsWith("date"))
                {
                    typeAndNames += "DATE";
                }
                else if (dr["type"].ToString().StartsWith("timestamp"))
                {
                    typeAndNames += "TIMESTAMP";
                }
                else
                {
                    typeAndNames += "STRING";
                }
                typeAndNames += ";" + dr["column_name"].ToString() + "|";
            }

            return typeAndNames.TrimEnd('|');
        }

        public string DeleteTask(string taskId)
        {
            string sql = "delete from tasks where task_id=@task_id";
            try
            {
                using (NpgsqlConnection dbConnection = new NpgsqlConnection(ConnectionString))
                {
                    dbConnection.Open();
                    using (NpgsqlCommand command = new NpgsqlCommand(sql))
                    {
                        command.Parameters.Add("task_id", taskId);
                        command.Connection = dbConnection;
                        command.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
            return "success";
        }

        public string UpdateDetailTask(string taskId, string assignedTo, string editedBy, string label, string description, string taskSatus)
        {
            string sql = "update tasks set item_summary=:item_summary, detailed_desc=:detailed_desc,item_status=:item_status,last_edited_by=:last_edited_by,assign_to=:assign_to,last_edited_time=:last_edited_time where task_id=:task_id";
            try
            {
                using (NpgsqlConnection dbConnection = new NpgsqlConnection(ConnectionString))
                {
                    dbConnection.Open();
                    using (NpgsqlCommand command = new NpgsqlCommand(sql))
                    {
                        command.Parameters.Add("item_summary", label);
                        command.Parameters.Add("detailed_desc", description);
                        command.Parameters.Add("item_status", taskSatus);
                        command.Parameters.Add("last_edited_by", editedBy);
                        command.Parameters.Add("assign_to", assignedTo);
                        command.Parameters.Add("last_edited_time", DateTime.Now);
                        command.Parameters.Add("task_id", taskId);
                        command.Connection = dbConnection;
                        int a = command.ExecuteNonQuery();
                    }
                    dbConnection.Close();
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return "success";
        }

        public string GetInfoForThisFile(string viewName, string fileName)
        {
            DataTable dataTable = new DataTable();
            string _sql = string.Empty;

            try
            {
                _sql = "SELECT rev, description, relfilename FROM " + viewName + "  WHERE LOWER(relfilename) LIKE '%" + fileName.ToLower() + "'";

                dataTable = GetDataTable(_sql);
                if (dataTable.Rows.Count > 0)
                {
                    return "revision::" + dataTable.Rows[0]["rev"].ToString() + "##description::" + dataTable.Rows[0]["description"].ToString() + "##relfilename::" + dataTable.Rows[0]["relfilename"].ToString();
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }

            return "";
        }

        public string UpdateFileInfo(string information, string viewName, string relfilename)
        {
            DataTable dataTable = new DataTable();
            string _sql = "SELECT sql_keyfields FROM dfn_repdetail WHERE sql_from = :viewName";
            string primarykey = string.Empty;
            string[] primaryKeys = null;

            try
            {
                using (NpgsqlConnection dbConnection = new NpgsqlConnection(ConnectionString))
                {
                    dbConnection.Open();
                    using (NpgsqlCommand command = new NpgsqlCommand(_sql))
                    {
                        command.Parameters.Add("viewName", viewName);
                        command.Connection = dbConnection;

                        primarykey = command.ExecuteScalar().ToString();

                    }

                    primaryKeys = primarykey.Split(new char[] { ',', ';' });

                    _sql = "SELECT ";

                    foreach (string pKey in primaryKeys)
                    {
                        _sql = _sql + pKey + ", ";
                    }

                    _sql = _sql.Trim().TrimEnd(new char[] { ',' });
                    _sql = _sql + " FROM " + viewName;
                    _sql = _sql + " WHERE LOWER(relfilename) LIKE '%" + relfilename.ToLower() + "'";

                    NpgsqlDataAdapter adapter = new NpgsqlDataAdapter();
                    adapter.SelectCommand = new NpgsqlCommand(_sql, dbConnection);
                    adapter.Fill(dataTable);

                    string[] info = Regex.Split(information, "##");
                    if (dataTable.Rows.Count > 0)
                    {
                        _sql = "UPDATE " + viewName.Replace("_v", "") + " SET rev = '" + info[0] + "', description='" + info[1] + "' WHERE ";

                        foreach (string pKey in primaryKeys)
                        {
                            _sql = _sql + pKey + " = " + dataTable.Rows[0][pKey] + ", ";
                        }

                        _sql = _sql.Trim().TrimEnd(new char[] { ',' });

                        using (NpgsqlCommand command = new NpgsqlCommand(_sql))
                        {
                            command.Connection = dbConnection;
                            int a = command.ExecuteNonQuery();
                        }
                    }

                    dbConnection.Close();
                }

            }
            catch (Exception ex)
            {
                return "error";
            }

            return "success";
        }

        public string SaveFileInfo(string information, string viewName, string reference)
        {
            DataTable dataTable = new DataTable();
            string primarykey = string.Empty;
            string[] primaryKeys = null;

            string _sql = "SELECT sql_keyfields FROM dfn_repdetail WHERE sql_from = :viewName";

            try
            {
                using (NpgsqlConnection dbConnection = new NpgsqlConnection(ConnectionString))
                {
                    dbConnection.Open();
                    using (NpgsqlCommand command = new NpgsqlCommand(_sql))
                    {
                        command.Parameters.Add("viewName", viewName);
                        command.Connection = dbConnection;

                        primarykey = command.ExecuteScalar().ToString();

                    }

                    primaryKeys = primarykey.Split(new char[] { ',', ';' });
                    string[] info = Regex.Split(information, "##");
                    _sql = "INSERT INTO " + viewName.Replace("_v", "") + "(" + primaryKeys[0] + ", rev, description) VALUES (:reference ,'" + info[0] + "','" + info[1] + "')";
                    //_sql = "INSERT INTO :tableName (:pKey, rev, description) VALUES (:reference, :rev, :description)";

                    using (NpgsqlCommand command = new NpgsqlCommand(_sql))
                    {
                        //command.Parameters.Add("tableName", viewName.Replace("_v", ""));
                        //command.Parameters.Add("pKey", primaryKeys[0]);
                        command.Parameters.Add("reference", reference);
                        //command.Parameters.Add("rev", info[0]);
                        //command.Parameters.Add("description", info[1]);
                        command.Connection = dbConnection;
                        int a = command.ExecuteNonQuery();
                    }

                    _sql = "SELECT relfilename FROM " + viewName + " WHERE " + primaryKeys[0] + " = :reference";

                    using (NpgsqlCommand command = new NpgsqlCommand(_sql))
                    {
                        command.Parameters.Add("reference", reference);
                        //command.Parameters.Add("rev", info[0]);
                        //command.Parameters.Add("description", info[1]);
                        command.Connection = dbConnection;
                        NpgsqlDataAdapter adapter = new NpgsqlDataAdapter();
                        adapter.SelectCommand = command;
                        adapter.Fill(dataTable);

                    }
                    dbConnection.Close();

                    if (dataTable.Rows.Count > 0)
                    {
                        return dataTable.Rows[0]["relfilename"].ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

            return "";
        }

        public string ValidateDeepLink(ref string deepLinkReport, string whereClause)
        {
            string deepLinkStatus = string.Empty;

            try
            {
                string query = "select * from dfn_repdetail where upper(report_code) like upper('%" + deepLinkReport + "%')";
                DataTable dt = GetDataTable(query);
                if (dt.Rows.Count > 0)
                {
                    deepLinkReport = dt.Rows[0]["report_code"].ToString();
                    query = "select count(*) from " + dt.Rows[0]["sql_from"].ToString() + " where " + whereClause;
                    GetDataTable(query);

                    deepLinkStatus = "";

                }
                else
                {
                    deepLinkStatus = "invalid";
                }
            }
            catch (Exception ex)
            {
                deepLinkStatus = "invalid";
            }
            return deepLinkStatus;
        }

        public string DeleteReport(string rep_code)
        {            
            NpgsqlCommand[] commands = new NpgsqlCommand[4];

            commands[0] = new NpgsqlCommand("delete from dfn_repdetail where report_code ='"+rep_code+"'");
            commands[1] = new NpgsqlCommand("delete from edm_repdetail where report_code ='" + rep_code + "'");
            commands[2] = new NpgsqlCommand("delete from hitcon_auth_def where authsection='REPORT' and functionname ='" + rep_code + "'");
            commands[3] = new NpgsqlCommand("delete from report_functions where report_code ='" + rep_code + "'");

            NpgsqlTransaction transaction = null;
            NpgsqlConnection conn;
            conn = new NpgsqlConnection(PostgresDBManager.ConnectionString);

            try
            {
                conn.Open();
                transaction = conn.BeginTransaction();
                foreach (NpgsqlCommand command in commands)
                {
                    command.Connection = conn;
                    command.Transaction = transaction;
                    command.ExecuteNonQuery();
                }
                transaction.Commit();
            }
            catch (NpgsqlException ex)
            {
                transaction.Rollback();
                //throw new Exception("ERROR: " + ex.Code + "<br>" + "ERROR Message: " + ex.Message);
                return "fail";
            }
            finally
            {
                conn.Close();
            }
            return "success";
        }
        public void ImportExcelData(DataTable table, string dbTableName)
        {
            System.Collections.ArrayList commands = GetInsertCommands(table,dbTableName);
            ExecuteTransaction(commands);
        }

        public System.Collections.ArrayList GetInsertCommands(DataTable table, string dbTableName)
        {
            System.Collections.ArrayList commands = new System.Collections.ArrayList();
            string sqlColCount = @"select count(*) from information_schema.columns where table_name='rc_item_hit'";
            int count = int.Parse(GetDataTable(sqlColCount).Rows[0][0].ToString());
            foreach (DataRow row in table.Rows)
            {
                string insertQuery = "Insert into " + dbTableName + " values (";
                foreach (DataColumn col in table.Columns)
                {
                    if (Regex.IsMatch(col.ColumnName, @"F\d+")) continue;
                    if (row[col].ToString().Contains(@"\"))
                    {
                        insertQuery += "E'" + row[col].ToString().Replace(@"\",@"\\") + "',";
                    }
                    else
                    {
                        insertQuery += "'" + row[col].ToString() + "',";
                    }
                }
                commands.Add(new NpgsqlCommand(insertQuery.TrimEnd(',') + ")"));
            }
            return commands;
        }

    }
}
