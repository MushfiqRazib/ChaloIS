using System.Data;
using System.Text;
using HIT.OB.STD.Wrapper.DAL;
using System;
using HIT.OB.STD.Core.DAL;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
/// <summary>
/// Summary description for DBManaFactory
/// </summary>
/// 
namespace HIT.OB.STD.Wrapper.BLL
{
    public class WrappingManager
    {

        public WrappingManager(string activeDb)
        {
        }
        public static string GetReportArguments(string reportCode)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            DataTable dtReportInfo = iWrapFunctions.GetReportArguments(reportCode);
            StringBuilder settingsBuilder = new StringBuilder();
            string sqlSelect = string.Empty;
            string FieldList = "";
            StringBuilder sqlkeyfields = new StringBuilder();
            StringBuilder detailSqlFields = new StringBuilder();
            string fieldTypesJson = "";

            string keyfields = string.Empty;
            string detailSqlFieldSets = string.Empty;

            if (dtReportInfo.Rows.Count > 0)
            {
                DataRow reportInfoRow = dtReportInfo.Rows[0];
                string sqlFrom = reportInfoRow["sql_from"].ToString();
                string reportSettings = reportInfoRow["report_settings"].ToString();
                string orderBy = reportInfoRow["sql_orderby"].ToString();
                string groupBy = reportInfoRow["sql_groupby"].ToString();
                if (string.IsNullOrEmpty(groupBy))
                {
                    groupBy = "NONE";
                }
                string fieldNameAndType = GetFieldAndTypeList(reportInfoRow["sql_from"].ToString(), reportCode);
                string sqlWhere = reportInfoRow["sql_where"].ToString();
                if (!string.IsNullOrEmpty(sqlWhere))
                {
                    string isWhereValid = HIT.OB.STD.Core.BLL.OBController.ValidateWhereClause(reportCode, sqlFrom, sqlWhere);
                    if (isWhereValid != "true")
                    {
                        sqlWhere = "INVALID_WHERE";
                    }
                }
                string fieldCaps = reportInfoRow["field_caps"].ToString().Replace(',', ';').Trim(new char[] { ';' });
                FieldList = fieldNameAndType.Split(new string[] { "$$$$" }, StringSplitOptions.None)[0];
                fieldTypesJson = fieldNameAndType.Split(new string[] { "$$$$" }, StringSplitOptions.None)[1];

                settingsBuilder.AppendFormat("report_code: \"{0}\"", GetJSONFormat(reportCode));
                settingsBuilder.AppendFormat(",report_name: \"{0}\"", GetJSONFormat(reportInfoRow["report_name"].ToString()));
                settingsBuilder.AppendFormat(",field_caps: \"{0}\"", GetJSONFormat(fieldCaps));

                string selectedFields = FieldList.Replace("'", "").Replace(',', ';').Trim(';');
                settingsBuilder.AppendFormat(",sql_select: \"{0}\"", GetJSONFormat(selectedFields));

                settingsBuilder.AppendFormat(",sql_from: \"{0}\"", GetJSONFormat(sqlFrom));
                settingsBuilder.AppendFormat(",sql_where: \"{0}\"", GetJSONFormat(sqlWhere));
                settingsBuilder.AppendFormat(",sql_groupby: \"{0}\"", GetJSONFormat(groupBy));
                settingsBuilder.AppendFormat(",gis_theme_layer: \"{0}\"", reportInfoRow["gis_theme_layer"].ToString().ToLower());

                settingsBuilder.AppendFormat(",sql_orderby: \"{0}\"", GetJSONFormat(orderBy));
                settingsBuilder.AppendFormat(",sql_orderdir: \"{0}\"", GetJSONFormat(reportInfoRow["sql_orderdir"].ToString()));
                settingsBuilder.AppendFormat(",report_settings: \"{0}\"", GetJSONFormat(reportSettings));
                string multiSelect = reportInfoRow["multiselect"].ToString().ToLower();
                settingsBuilder.AppendFormat(",multiselect: \"{0}\"", multiSelect);
                settingsBuilder.AppendFormat(",deeplink: \"{0}\"", reportInfoRow["deeplink"].ToString().ToLower());

                // sqlSelect = reportInfoRow["sql_select"].ToString();
                detailSqlFieldSets = reportInfoRow["detail_fieldsets"].ToString().Replace(",", ";").Trim(';');
                detailSqlFields.AppendFormat("detailsqlfields: \"{0}\"", GetJSONFormat(detailSqlFieldSets));

                keyfields = reportInfoRow["sql_keyfields"].ToString().Replace(',', ';').Trim(';');
                sqlkeyfields.AppendFormat("sqlkeyfields: {0}", GetJSONFormat(SQLKeyFieldsJSON(keyfields)));


            }
            dtReportInfo.Dispose();

            //***Report function processing            
            DataTable dtFunctionReportInfo = iWrapFunctions.GetReportFunctionsList(reportCode);
            StringBuilder functionList = new StringBuilder();
            StringBuilder sqlMandatory = new StringBuilder();
            string parameters = string.Empty;
            string sqlFunList = string.Empty;
            string imageUrls = string.Empty;
            string orderPos = string.Empty;
            string temp = string.Empty;
            string commonParams = string.Empty;
            string iscustom = string.Empty;

            if (dtFunctionReportInfo.Rows.Count > 0)
            {
                foreach (DataRow dr in dtFunctionReportInfo.Rows)
                {
                    sqlFunList = dr["function_name"].ToString();
                    orderPos = dr["order_position"].ToString();
                    parameters = dr["parameters"].ToString().Replace(',', ';').Trim(new char[] { ';' });
                    iscustom = dr["iscustom"].ToString().ToLower();

                    // getting sqlparameters as semicolon separated.
                    parameters = parameters.Trim(';');
                    StringBuilder param = new StringBuilder();
                    param.Append("'").Append(parameters.Replace(";", "','")).Append("'");

                    // checking common parameters.
                    commonParams = CommonParameters(parameters, commonParams);
                    functionList.AppendFormat("['{0}','{1}','{2}',[{3}]]", sqlFunList.ToUpper(), orderPos, iscustom, param.ToString());
                    functionList.Append(",");
                } // END of foreach

                commonParams = CompareSqlManSqlKey(commonParams, keyfields);
                functionList.Remove(functionList.ToString().LastIndexOf(','), 1);
                sqlMandatory.Append("'").Append(commonParams).Append("'");
            }
            else
            {
                sqlMandatory.Append("");
                functionList.Append("");
            }
            dtFunctionReportInfo.Dispose();

            return "{settings:{" + settingsBuilder.ToString() +
                    "},fieldTypes:{" + fieldTypesJson + "},fieldList:[" + FieldList + "]" +
                    ",sqlmandatory:[" + sqlMandatory.ToString() +
                    "],functionlist:[" + functionList.ToString() +
                    "]," + sqlkeyfields.ToString() + "," + detailSqlFields.ToString() + "}";
        }

        public static string SQLKeyFieldsJSON(string keyFields)
        {
            string sqlKeyJson = string.Empty;
            if (!keyFields.Equals(string.Empty))
            {
                string[] sqlParams = keyFields.Split(';');
                sqlKeyJson = "{";
                for (int i = 0; i < sqlParams.Length; i++)
                {
                    sqlKeyJson += sqlParams[i].ToString() + ": '', ";
                }
                sqlKeyJson = sqlKeyJson.Remove(sqlKeyJson.LastIndexOf(','), 1);
                sqlKeyJson += "}";
            }
            else
            {
                sqlKeyJson = "''";
            }
            return sqlKeyJson;

        }

        public static string CompareSqlManSqlKey(string sqlMand, string sqlKey)
        {
            if (!sqlKey.Equals(string.Empty))
            {
                string[] sqlParameters = sqlKey.Split(';');
                List<string> mandFieldList = sqlMand.Split(';').ToList<string>();
                for (var x = 0; x < sqlParameters.Length; x++)
                {
                    if (!mandFieldList.Contains(sqlParameters[x]))
                    {
                        sqlMand += ";" + sqlParameters[x].ToLower();
                    }
                }
            }
            return sqlMand;
        }


        // checking common parameters.
        public static string CommonParameters(string parameters, string commonParams)
        {
            string[] sqlParameters = parameters.Split(';');
            if (commonParams.Equals(string.Empty))
            {
                commonParams += parameters;
            }
            else
            {
                List<string> commonParamList = commonParams.ToLower().Split(';').ToList<string>();
                for (int x = 0; x < sqlParameters.Length; x++)
                {
                    if (!commonParamList.Contains(sqlParameters[x].ToLower()))
                    {
                        commonParams += ";" + sqlParameters[x].ToString();
                    }
                }
            }
            return commonParams;
        }

        static string GetFieldAndTypeList(string tableName, string reportCode)
        {
            StringBuilder delimittedFields = new StringBuilder();
            try
            {
                HIT.OB.STD.Core.BLL.DBManagerFactory dbManagerFactory = new HIT.OB.STD.Core.BLL.DBManagerFactory();
                HIT.OB.STD.Core.DAL.IOBFunctions iCoreFunctions = dbManagerFactory.GetDBManager(reportCode);
                //ArrayList fieldList = iCoreFunctions.GetFieldList(tableName);
                string[] fieldTypes = iCoreFunctions.GetFieldNameType(tableName).Split(new char[] { '|' });
                StringBuilder types = new StringBuilder();
                string[] nameTypeArr = new string[2];
                for (int i = 0; i < fieldTypes.Length; i++)
                {
                    nameTypeArr = fieldTypes[i].Split(';');
                    delimittedFields.Append("'").Append(nameTypeArr[1].ToString()).Append("'").Append(",");
                    types.Append("'").Append(nameTypeArr[1]).Append("':'").Append(nameTypeArr[0]).Append("',");
                }

                string fields = delimittedFields.ToString().Trim(',');
                return fields + "$$$$" + types.ToString().Trim(',');
            }
            catch (Exception ex)
            {
                return "";
            }
        }

        public static string GetReportList()
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            DataTable dtReportInfo = iWrapFunctions.GetReportList();
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.Append("reportList:[");
            for (int r = 0; r < dtReportInfo.Rows.Count; r++)
            {
                DataRow reportInfoRow = dtReportInfo.Rows[r];
                stringBuilder.Append("{");
                stringBuilder.AppendFormat("report_code: '{0}'", reportInfoRow["report_code"].ToString());
                stringBuilder.AppendFormat(",report_name: '{0}'", reportInfoRow["report_name"].ToString());
                stringBuilder.Append("}");
                if (r < dtReportInfo.Rows.Count - 1)
                {
                    stringBuilder.Append(",");
                }
            }
            dtReportInfo.Dispose();
            stringBuilder.Append("]");
            return "{" + stringBuilder + "}";
        }

        private static string GetJSONFormat(string value)
        {
            //value = value.Trim();
            value = value.Replace("\"", "@@@");
            value = value.Replace("\r\n", "<br/>");
            //value = value.Replace("[", "");
            //value = value.Replace("]", "");
            //value = value.Replace("{", "");
            //value = value.Replace("}", "");
            value = value.Replace(@"\", "\\\\");
            value = value.Replace("\n", "<br/>");
            //value = System.Web.HttpUtility.HtmlEncode(value);                              

            return value;
        }


        internal static bool UpdateUserDefinedReportSettings(string REPORT_CODE, string SQL_WHERE, string GROUP_BY, string ORDER_BY, string ORDER_BY_DIR, string field_caps, string report_settings)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iOBFunctions = dbManagerFactory.GetDBManager();
            iOBFunctions.UpdateUserDefinedReportSettings(REPORT_CODE, SQL_WHERE, GROUP_BY, ORDER_BY, ORDER_BY_DIR, field_caps, report_settings);
            return true;
        }

        internal static bool CreateNewReportWithSettings(string REPORT_CODE, string REPORT_NAME, string SQL_WHERE, string GROUP_BY, string ORDER_BY, string ORDER_BY_DIR, string field_caps, string report_settings, string sid, string reports, string obs)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iOBFunctions = dbManagerFactory.GetDBManager();
            iOBFunctions.CreateNewReportWithSettings(REPORT_CODE, REPORT_NAME, SQL_WHERE, GROUP_BY, ORDER_BY, ORDER_BY_DIR, field_caps, report_settings, sid, reports, obs);
            return true;
        }

        public static bool InsertGroupColor(string REPORT_CODE, string GROUP_BY, string GROUP_CODE, string COLOR_CODE)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iOBFunctions = dbManagerFactory.GetDBManager();
            bool result = iOBFunctions.InsertGroupColor(REPORT_CODE, GROUP_BY, GROUP_CODE, COLOR_CODE);
            return result;
        }

        public static string GetReportConfigInfo(string rep_code)
        {

            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
            DataRow drRepportConfigInfo = iWrapFunctions.GetReportConfigInfo(rep_code);
            return drRepportConfigInfo["SQL_FROM"].ToString();
        }

        public static string GetPartlistQueryAndKeys(string sqlFrom, string whereClause, string rep_code)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            string artCodeRevisonAndQuery = iWrapFunctions.GetArticleCodeAndRevisionAndPartlistDataQuery(sqlFrom, whereClause.Replace("|", "'"), rep_code);
            string[] partlistInfoArray = artCodeRevisonAndQuery.Split(new string[] { "@@@@" }, StringSplitOptions.None);

            string artRevInfo = "Keys:['" + partlistInfoArray[0] + "','" + partlistInfoArray[1] + "'],";

            return "{" + artRevInfo + "Query:[\"" + partlistInfoArray[2] + "\"]}";
        }

        public static string GetPartlistInfo(string sqlFrom, string whereClause, string rep_code)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            string artCodeRevisonAndQuery = iWrapFunctions.GetArticleCodeAndRevisionAndPartlistDataQuery(sqlFrom, whereClause.Replace("|", "'"), rep_code);
            string[] partlistInfoArray = artCodeRevisonAndQuery.Split(new string[] { "@@@@" }, StringSplitOptions.None);
            DataTable dtPartlistInfo = iWrapFunctions.GetPartlistInfo(partlistInfoArray[2]);
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder = GetColumnInfoGridInfoFromDataTable(dtPartlistInfo, stringBuilder);

            string artRevInfo = "Keys:['" + partlistInfoArray[0] + "','" + partlistInfoArray[1] + "'],";
            return "{" + artRevInfo + stringBuilder + "}";
        }

        public static string GetRevision(string whereClause, String sqlFrom, IWrapFunctions iWrapFunctions)
        {
            DataTable dt = iWrapFunctions.GetDataTable("SELECT * FROM " + sqlFrom);
            StringBuilder revisions = new StringBuilder();
            revisions.Append("revisions:[");
            string revisionColumnName = string.Empty;

            foreach (DataColumn column in dt.Columns)
            {
                if (column.ColumnName.Contains("rev"))
                {
                    revisionColumnName = column.ColumnName;
                }
            }

            if (!revisionColumnName.Equals(string.Empty))
            {
                whereClause = whereClause.Substring(0, whereClause.IndexOf("AND"));

                DataTable dtRevisions = iWrapFunctions.GetDataTable("SELECT distinct(" + revisionColumnName + ") FROM " + sqlFrom + " WHERE " + whereClause);

                int revNo = Convert.ToInt32(dtRevisions.Rows[0][0].ToString());
                //int revNo = Convert.ToInt32(whereClause.Split('=')[2].ToString().Replace("'", "").Trim());

                for (int i = 0; i <= revNo; i++)
                {
                    if (i < 10)

                        revisions.AppendFormat("'0{0}'", i);
                    else
                        revisions.AppendFormat("'{0}'", i);

                    if (i < revNo)
                    {
                        revisions.Append(",");
                    }
                }

                //for (int i = 0; i < dtRevisions.Rows.Count; i++)
                //{
                //    revisions.AppendFormat("'{0}'", GetJSONFormat(dtRevisions.Rows[i][0].ToString()));
                //    if (i < dtRevisions.Rows.Count - 1)
                //    {
                //        revisions.Append(",");
                //    }
                //}
            }

            revisions.Append("],");
            return revisions.ToString();
        }

        public static string GetAvailableListQueryPair(string sqlFrom, string whereClause, string rep_code)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            DataTable listInfoTable = iWrapFunctions.GetReportExtensionInfo(rep_code);

            List<string> columnsNamelist = new List<string>();

            foreach (DataColumn column in listInfoTable.Columns)
            {
                if (column.ColumnName.StartsWith("list"))
                {
                    columnsNamelist.Add(column.ColumnName);
                }
            }

            StringBuilder listNameQueryPair = new StringBuilder();
            listNameQueryPair.Append("{listNameQueryPair:[");

            if (listInfoTable.Rows.Count > 0)
            {
                int i = 0;
                string queryValue = string.Empty;
                foreach (string column in columnsNamelist)
                {
                    if (!listInfoTable.Rows[0][column].ToString().Equals(string.Empty))
                    {
                        //queryDescription.AppendFormat("['{0}','{1}']", listInfoTable.Rows[0][column], listInfoTable.Rows[0]["description_" + column]);
                        queryValue = listInfoTable.Rows[0][column].ToString();
                        if (queryValue.Contains("AS"))
                        {
                            queryValue.Replace("\"", ";double;Quote;");
                        }

                        listNameQueryPair.AppendFormat("['{0}','{1}']", column.Replace("sql", string.Empty).Replace("list_", string.Empty).ToUpperFirstChar(), queryValue);
                        if (i < columnsNamelist.Count - 1)
                        {
                            listNameQueryPair.Append(",");
                        }
                    }
                    i++;
                }
            }

            listNameQueryPair.Append("]}");

            return listNameQueryPair.ToString();
        }

        public static string GetListQueryByListName(string sqlFrom, string whereClause, string rep_code, string listName)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            string[] listQueryAndDescription = GetListQueryAndDescriptionByName(listName, rep_code).Split(new string[] { "@@@@" }, StringSplitOptions.None);
            string listQuery = listQueryAndDescription[0];
            string[] fields = HIT.OB.STD.CommonUtil.ExtractFieldNameFromQuery(listQuery).Split(',');
            List<string> columnField = new List<string>();

            DataTable dtData = iWrapFunctions.GetDataTable("SELECT * FROM " + sqlFrom);

            listQuery = RemoveFieldsFromWhereClauseWhichValuesAreNotAvailable(listQuery, fields, columnField, dtData);


            string sqlQuery = "select " + string.Join(",", columnField.ToArray()) + " FROM " + sqlFrom + " WHERE " + whereClause;
            dtData = iWrapFunctions.GetDataTable(sqlQuery);
            foreach (string field in columnField)
            {
                listQuery = listQuery.Replace("%" + field + "%", "'" + dtData.Rows[0][field].ToString().Trim() + "'");
            }

            return listQuery;
        }

        public static string GetListQueryAndDescriptionByName(string listName, string rep_code)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            DataTable listInfoTable = iWrapFunctions.GetReportExtensionInfo(rep_code);

            return listInfoTable.Rows[0]["list_" + listName + "sql"].ToString() + "@@@@" + listInfoTable.Rows[0]["description_list_" + listName + "sql"].ToString();
        }

        public static string GetListItemInfo(string sqlFrom, string whereClause, string rep_code, string listName, string selectedFields)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            string[] listQueryAndDescription = GetListQueryAndDescriptionByName(listName, rep_code).Split(new string[] { "@@@@" }, StringSplitOptions.None);
            string listQuery = listQueryAndDescription[0];
            string[] fields = HIT.OB.STD.CommonUtil.ExtractFieldNameFromQuery(listQuery).Split(',');
            List<string> columnField = new List<string>();

            DataTable dtData = iWrapFunctions.GetDataTable("SELECT * FROM " + sqlFrom);

            listQuery = RemoveFieldsFromWhereClauseWhichValuesAreNotAvailable(listQuery, fields, columnField, dtData);

            string[] requiredField = selectedFields.Split(';');

            string currentRevision = string.Empty;

            string sqlQuery = "select " + string.Join(",", columnField.ToArray()) + (selectedFields.Length > 0 ? ("," + selectedFields.Replace(';', ',')) : "") + " FROM " + sqlFrom + " WHERE " + whereClause.Substring(0, whereClause.IndexOf("AND"));
            dtData = iWrapFunctions.GetDataTable(sqlQuery);



            foreach (string field in columnField)
            {
                if (field.Contains("revision"))
                {
                    listQuery = listQuery.Replace("%revision%", whereClause.Split('=')[2].ToString().Trim());

                }
                else
                    listQuery = listQuery.Replace("%" + field + "%", "'" + dtData.Rows[0][field].ToString().Trim() + "'");

                if (field.Contains("rev"))
                {
                    //currentRevision = dtData.Rows[0]["revision"].ToString();
                    currentRevision = whereClause.Split('=')[2].ToString().Replace("'", "").Trim();

                }


            }

            DataTable dtPartlistInfo = iWrapFunctions.GetPartlistInfo(listQuery);


            DataTable dtMainPartList = dtPartlistInfo.Clone();
            foreach (DataRow row in dtPartlistInfo.Rows)
            {
                DataRow newMainRow = dtMainPartList.NewRow();
                newMainRow[0] = row[0];
                newMainRow[1] = row[1];
                newMainRow[2] = row[2];
                newMainRow[3] = row[3];
                newMainRow[4] = row[4];
                newMainRow[5] = row[5];
                newMainRow[6] = row[6];
                newMainRow[7] = row[7];
                newMainRow[8] = row[8];
                newMainRow[9] = row[9];
                dtMainPartList.Rows.Add(newMainRow);
                string childComp_itemNo = row["comp_item"].ToString();
                string childItemNo = row["item"].ToString();

                string childRevNo = row["revision"].ToString();
                //childQuery = "SELECT * FROM rc_bom WHERE item='" + childItemNo + "'  AND revision='" + childRevNo + "'  ORDER BY pos_nr";
                if (!childComp_itemNo.Equals(childItemNo))
                {
                    string childQuery = listQueryAndDescription[0];

                    childQuery = childQuery.Replace("%item%", "'" + childComp_itemNo + "'");
                    childQuery = childQuery.Replace("%revision%", "'" + childRevNo + "'");

                    DataTable dtChildPartList = iWrapFunctions.GetPartlistInfo(childQuery);

                    foreach (DataRow childRow in dtChildPartList.Rows)
                    {
                        //dtMainPartList.ImportRow(childRow);
                        DataRow newrow = dtMainPartList.NewRow();
                        newrow[0] = childRow[0];
                        newrow[1] = childRow[1];
                        newrow[2] = childRow[2];
                        newrow[3] = childRow[3];
                        newrow[4] = childRow[4];
                        newrow[5] = childRow[5];
                        newrow[6] = childRow[6];
                        newrow[7] = childRow[7];
                        newrow[8] = childRow[8];
                        newrow[9] = childRow[9];
                        //newrow = childRow;
                        //newrow[ = childRow;
                        dtMainPartList.Rows.Add(newrow);
                    }
                }



            }

            StringBuilder stringBuilder = new StringBuilder();
            //stringBuilder = GetColumnInfoGridInfoFromDataTable(dtPartlistInfo, stringBuilder);
            stringBuilder = GetColumnInfoGridInfoFromDataTable(dtMainPartList, stringBuilder);



            string firstLabel = columnField[0].ToUpperFirstChar() + " : " + dtData.Rows[0][0].ToString();

            string secondLabel = string.Empty;
            if (dtData.Rows[0][requiredField[0]].ToString() != string.Empty && (!columnField.Contains(requiredField[0])))
            {
                secondLabel = requiredField[0].ToUpperFirstChar() + " : " + dtData.Rows[0][requiredField[0]].ToString();
            }

            string thirdLabel = string.Empty;
            if (dtData.Rows[0][requiredField[1]].ToString() != string.Empty && (!columnField.Contains(requiredField[1])))
            {
                thirdLabel = requiredField[1].ToUpperFirstChar() + " : " + dtData.Rows[0][requiredField[1]].ToString();
            }

            string artRevInfo = "Keys:['" + firstLabel + "','" + secondLabel + "','" + thirdLabel + "','" + listQueryAndDescription[1] + "','" + currentRevision + "'],";
            string revision = GetRevision(whereClause, sqlFrom, iWrapFunctions);

            return "{" + artRevInfo + revision + stringBuilder + "}";
        }

        private static StringBuilder GetColumnInfoGridInfoFromDataTable(DataTable dtPartlistInfo, StringBuilder stringBuilder)
        {
            stringBuilder.Append("columnInfo:[");
            string columns = string.Empty;
            columns += "\" # \",";
            foreach (DataColumn column in dtPartlistInfo.Columns)
            {
                columns += "\"" + column.ColumnName + "\",";
            }
            stringBuilder.Append(columns);
            stringBuilder = stringBuilder.Remove(stringBuilder.ToString().LastIndexOf(','), 1);
            stringBuilder.Append("],");


            stringBuilder.Append("gridInfo:[");
            //int rowNum = 1;

            for (int i = 0; i < dtPartlistInfo.Rows.Count; i++)
            {
                DataRow currentRow = dtPartlistInfo.Rows[i];
                stringBuilder.Append("[\"" + (i + 1).ToString() + "\",");

                foreach (DataColumn column in dtPartlistInfo.Columns)
                {
                    stringBuilder.AppendFormat("\"{0}\",", GetJSONFormat(currentRow[column.ColumnName].ToString()));
                }

                stringBuilder = stringBuilder.Remove(stringBuilder.ToString().LastIndexOf(','), 1);
                stringBuilder.Append("]");
                if (i < dtPartlistInfo.Rows.Count - 1)
                {
                    stringBuilder.Append(",");
                }
            }

            stringBuilder.Append("]");
            return stringBuilder;
        }

        private static string RemoveFieldsFromWhereClauseWhichValuesAreNotAvailable(string listQuery, string[] fields, List<string> columnField, DataTable dtData)
        {
            /* Removing the column which is not available in the sqlform,
             * as its value is not available, we cant match its value inside listQuery.
             * So removing it from listQuery.
             */
            int index = 0;
            string substr;
            foreach (string field in fields)
            {
                if (!(dtData.Columns.Contains(field)))
                {
                    index = listQuery.IndexOf("%" + field + "%");
                    substr = listQuery.Substring(0, index + fields.Length + 3);
                    substr = substr.Substring(substr.ToUpperFirstChar().LastIndexOf(" AND "));
                    listQuery = listQuery.Replace(substr, "");
                }
                else
                {
                    columnField.Add(field);
                }
            }
            return listQuery;
        }

        public static string GetBaseMaterialDetail(string keyNameValues, string rep_code)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
            DataTable dtBaseMaterial = iWrapFunctions.GetBaseMaterialDetail(keyNameValues, rep_code);
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.Append("\"columnInfo\":[");
            string columns = string.Empty;
            foreach (DataColumn column in dtBaseMaterial.Columns)
            {
                columns += "\"" + column.ColumnName + "\",";
            }
            stringBuilder.Append(columns);
            stringBuilder = stringBuilder.Remove(stringBuilder.ToString().LastIndexOf(','), 1);
            stringBuilder.Append("],");

            stringBuilder.Append("gridInfo:[");
            //int rowNum = 1;

            for (int i = 0; i < dtBaseMaterial.Rows.Count; i++)
            {
                DataRow currentRow = dtBaseMaterial.Rows[i];
                //stringBuilder.Append("[\"" + rowNum + "\",");
                stringBuilder.Append("[");

                foreach (DataColumn column in dtBaseMaterial.Columns)
                {
                    stringBuilder.AppendFormat("\"{0}\",", GetJSONFormat(currentRow[column.ColumnName].ToString()));
                }

                stringBuilder = stringBuilder.Remove(stringBuilder.ToString().LastIndexOf(','), 1);
                stringBuilder.Append("]");
                if (i < dtBaseMaterial.Rows.Count - 1)
                {
                    stringBuilder.Append(",");
                }
            }
            stringBuilder.Append("]");
            return "{" + stringBuilder + "}";
        }

        public static DataTable GetReportCodeList()
        {

            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            return iWrapFunctions.GetReportList();
        }

        public static string GetInfoForThisFile(string viewName, string fileName)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            return iWrapFunctions.GetInfoForThisFile(viewName, fileName);
        }

        public static string UpdateFileInfo(string information, string viewName, string relfilename)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            return iWrapFunctions.UpdateFileInfo(information, viewName, relfilename);
        }

        public static string SaveFileInfo(string information, string viewName, string reference)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            return iWrapFunctions.SaveFileInfo(information, viewName, reference);

        }

        public static string ValidateDeepLink(ref string deepLinkReport, string whereClause)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            return iWrapFunctions.ValidateDeepLink(ref deepLinkReport, whereClause);
        }

        public static bool CheckForReportCodeAvailability(string rep_code)
        {
            bool isAvailable = true;

            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
            DataTable dt = iWrapFunctions.GetDataTable("select * from dfn_repdetail where upper(report_code) = '" + rep_code.ToUpper() + "'");
            if (dt.Rows.Count > 0)
            {
                isAvailable = false;
            }
            return isAvailable;
        }


        public static string GetItemInfoByItemNo(string sqlFrom, string whereClause, string selectedFields)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
            //string strSql = "Select " + string.Join(",", selectedFields.Split(';')) + " from " + sqlFrom + " where " + whereClause;
            string strSql = "Select distinct " + selectedFields + " from " + sqlFrom + " where " + whereClause;
            DataTable dtPartlistInfo = iWrapFunctions.GetDataTable(strSql);

            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.Append("ItemInfo:[");
            //int rowNum = 1;

            for (int i = 0; i < dtPartlistInfo.Rows.Count; i++)
            {
                DataRow currentRow = dtPartlistInfo.Rows[i];
                // stringBuilder.Append("[\"" + (i + 1).ToString() + "\",");
                stringBuilder.Append("[");
                foreach (DataColumn column in dtPartlistInfo.Columns)
                {
                    stringBuilder.AppendFormat("\"{0}\",", GetJSONFormat(currentRow[column.ColumnName].ToString()));
                }

                stringBuilder = stringBuilder.Remove(stringBuilder.ToString().LastIndexOf(','), 1);
                stringBuilder.Append("]");
                if (i < dtPartlistInfo.Rows.Count - 1)
                {
                    stringBuilder.Append(",");
                }
            }

            stringBuilder.Append("]");
            return "{" + stringBuilder + "}";

        }

        public static string UpdateBusket(string sqlFrom)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
            DataTable dtPartlistInfo = iWrapFunctions.GetDataTable(sqlFrom);

            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.Append("ItemInfo:[");
            //int rowNum = 1;

            for (int i = 0; i < dtPartlistInfo.Rows.Count; i++)
            {
                DataRow currentRow = dtPartlistInfo.Rows[i];
                // stringBuilder.Append("[\"" + (i + 1).ToString() + "\",");
                stringBuilder.Append("[");
                foreach (DataColumn column in dtPartlistInfo.Columns)
                {
                    stringBuilder.AppendFormat("\"{0}\",", GetJSONFormat(currentRow[column.ColumnName].ToString()));
                }

                stringBuilder = stringBuilder.Remove(stringBuilder.ToString().LastIndexOf(','), 1);
                stringBuilder.Append("]");
                if (i < dtPartlistInfo.Rows.Count - 1)
                {
                    stringBuilder.Append(",");
                }
            }

            stringBuilder.Append("]");
            return "{" + stringBuilder + "}";
        }

        public static bool DeleteReport(string rep_code)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
            string result = iWrapFunctions.DeleteReport(rep_code);
            return result == "success" ? true : false;
        }
    }

}

