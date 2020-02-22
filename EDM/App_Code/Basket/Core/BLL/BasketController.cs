using System;
using System.Data;
using HIT.OB.STD.Basket.Core.DAL;
using System.Collections;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
//using

namespace HIT.OB.STD.Basket.Core.BLL
{
    public class BasketController
    {

        public static string GetReportRecords(string REPORT_CODE, string SQL_FROM, string SQL_WHERE,List<bool> partExistList)
        {
            string reportData = string.Empty;
            try
            {
                DBManagerFactory dbManagerFactory = new DBManagerFactory();
                IBasketFunctions iBkFunctions = dbManagerFactory.GetDBManager(REPORT_CODE);
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.Append("[");

                string jsonData = PrepareJsonForNormalGrid( iBkFunctions, SQL_FROM, SQL_WHERE,partExistList);
                stringBuilder.Append(jsonData);
                stringBuilder.Append("]");
                reportData = stringBuilder.ToString();
            }
            catch (Exception ex)
            {
                LogWriter.WriteLog(ex.Message);
                reportData = ex.StackTrace;
            }
            
            return reportData;
        }

        private static string PrepareJsonForNormalGrid(IBasketFunctions IBasket, string SQL_FROM, string SQL_WHERE, List<bool> partExistList)
        {
            try
            {
                DataTable dt = IBasket.GetReportData(SQL_FROM,SQL_WHERE);
                ArrayList fieldList = IBasket.GetFieldList(dt);
                StringBuilder sb = new StringBuilder();
                int rowCounter = 0;
                foreach (DataRow dr in dt.Rows)
                {
                    int counter = 0;
                    sb.Append("{");
                    foreach (string colName in fieldList)
                    {
                        if (counter != 0)
                        {
                            sb.AppendFormat(",{0}:'{1}'", colName, GetJSONFormat(dr[colName].ToString()));
                        }
                        else
                        {
                            sb.AppendFormat("{0}:'{1}'", colName, GetJSONFormat(dr[colName].ToString()));
                        }

                        counter++;
                        
                    }

                    if (partExistList[rowCounter])
                    {
                        sb.AppendFormat(",parts :'exists'");
                    }

                    rowCounter++;
                    sb.Append("},");
                }

                return sb.ToString().TrimEnd(new char[] { ',' }); 
                
            }
            catch (Exception ex)
            {
                LogWriter.WriteLog(ex.Message + "    " + ex.StackTrace);
                throw new Exception(ex.Message);
            }
            
            return string.Empty;
        }

        private static string GetJSONFormat(string value)
        {
            value = value.Replace("\"", "''");
            value = value.Replace("'", "\\'");
            value = value.Replace("\r\n", "<br/>");
            value = value.Replace("\\", "\\\\");
            value = value.Replace("\n", "<br/>");
            return value;
        }
    }
}

