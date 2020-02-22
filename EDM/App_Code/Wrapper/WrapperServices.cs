using System;
using System.Web.Services;
using System.Web.Script.Services;
using HIT.OB.STD.Wrapper.BLL;

/// <summary>
/// Summary description for OBWebServices
/// </summary>
namespace HIT.OB.STD.Wrapper.Services
{
    [WebService(Namespace = "http://hawarit.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class WrapperServices : System.Web.Services.WebService
    {

        public WrapperServices()
        {
            //Uncomment the following line if using designed components 
            //InitializeComponent(); 
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string GetReportArguments(string reportCode)
        {
            try
            {
                return WrappingManager.GetReportArguments(reportCode);
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }

        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string GetReportList(string dummyParam)
        {
            try
            {
                return WrappingManager.GetReportList();
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public bool SaveUserDefinedReportSettings(string REPORT_CODE, string REPORT_NAME, string SQL_WHERE, string GROUP_BY, string ORDER_BY, string ORDER_BY_DIR, string field_caps, string report_settings, string sid, string reports, string obs,string mode)
        {
            bool isProcessSuccess = false;
            try
            {
                //*** decode ecoded single quite(') to char
                REPORT_CODE = Microsoft.JScript.GlobalObject.unescape(REPORT_CODE);
                REPORT_NAME = Microsoft.JScript.GlobalObject.unescape(REPORT_NAME);
                SQL_WHERE = Microsoft.JScript.GlobalObject.unescape(SQL_WHERE);
                GROUP_BY = Microsoft.JScript.GlobalObject.unescape(GROUP_BY);
                ORDER_BY = Microsoft.JScript.GlobalObject.unescape(ORDER_BY);
                ORDER_BY_DIR = Microsoft.JScript.GlobalObject.unescape(ORDER_BY_DIR);
                field_caps = Microsoft.JScript.GlobalObject.unescape(field_caps);
                report_settings = Microsoft.JScript.GlobalObject.unescape(report_settings);
                sid = Microsoft.JScript.GlobalObject.unescape(sid);
                reports = Microsoft.JScript.GlobalObject.unescape(reports);
                obs = Microsoft.JScript.GlobalObject.unescape(obs);
                if (mode == "new")
                {
                    isProcessSuccess = WrappingManager.CreateNewReportWithSettings(REPORT_CODE, REPORT_NAME, SQL_WHERE, GROUP_BY, ORDER_BY, ORDER_BY_DIR, field_caps, report_settings, sid, reports, obs);
                }
                else
                {
                    isProcessSuccess = WrappingManager.UpdateUserDefinedReportSettings(REPORT_CODE, SQL_WHERE, GROUP_BY, ORDER_BY, ORDER_BY_DIR, field_caps, report_settings);
                }
            }
            catch (Exception ex)
            {
                return isProcessSuccess;
            }
            return isProcessSuccess;
        }

        [WebMethod(true)]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string InsertGroupColor(string REPORT_CODE, string GROUP_BY, string GROUP_CODE, string COLOR_CODE)
        {

            try
            {
                //*** decode ecoded single quite(') to char
                //SQL_WHERE = Microsoft.JScript.GlobalObject.unescape(SQL_WHERE);
                bool result = WrappingManager.InsertGroupColor(REPORT_CODE, GROUP_BY, GROUP_CODE, COLOR_CODE);
                string value = string.Empty;
                if (result)
                {
                    value = "{\"result\":\"true\"}";
                }
                else
                {
                    value = "{\"result\":\"false\"}";
                }
                return value;
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
                //return false;
            }
        }


        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string GetReportConfigInfo(string rep_code)
        {
            try
            {
                return WrappingManager.GetReportConfigInfo(rep_code);
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }

        }


        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string GetPartListQueryAndKeys(string sqlFrom, string whereClause, string rep_code)
        {
            try
            {
                return WrappingManager.GetPartlistQueryAndKeys(sqlFrom, whereClause, rep_code);
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string GetPartListInfo(string sqlFrom, string whereClause, string rep_code)
        {
            try
            {
                return WrappingManager.GetPartlistInfo(sqlFrom, whereClause, rep_code);
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string GetAvailableListQueryPair(string sqlFrom, string whereClause, string rep_code)
        {
            try
            {
                return WrappingManager.GetAvailableListQueryPair(sqlFrom, whereClause, rep_code);
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string GetListItemInfo(string sqlFrom, string whereClause, string rep_code, string listName,string selectedFields)
        {
            try
            {
                return WrappingManager.GetListItemInfo(sqlFrom, whereClause, rep_code, listName, selectedFields);
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string GetItemInfoByItemNo(string sqlFrom, string whereClause, string selectedFields)
        {
            try
            {
                return WrappingManager.GetItemInfoByItemNo(sqlFrom, whereClause, selectedFields);
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string UpdateBusket(string sqlFrom)
        {
            try
            {
                return WrappingManager.UpdateBusket(sqlFrom);
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }
        }


        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public string GetBaseMaterialDetail(string keyNameValues, string rep_code)
        {
            try
            {
                keyNameValues = Microsoft.JScript.GlobalObject.unescape(keyNameValues);
                return WrappingManager.GetBaseMaterialDetail(keyNameValues, rep_code);
            }
            catch (Exception ex)
            {
                return ex.StackTrace;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public bool CheckForReportCodeAvailability(string rep_code)
        {
            return WrappingManager.CheckForReportCodeAvailability(rep_code);
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
        public bool DeleteReport(string rep_code)
        {
            return WrappingManager.DeleteReport(rep_code);
        }

    }
}
