using System.Data;
using System.Collections;

/// <summary>
/// Summary description for IOBFunctions
/// </summary>
namespace HIT.OB.STD.Wrapper.DAL
{
    public interface IWrapFunctions
    {
        //*** The database connection has to be opened automatically
        //*** during instantiation of the database manager. So Database
        //*** connection will be active for the lifetime of the manager.
        //*** When the manager no longer used then it has to be closed.
        //*** There is no database open function to restrict frequent database
        //*** connection creation.
        
        DataTable GetReportList();
        DataTable GetReportArguments(string reportCode);
        DataTable GetReportFieldList(string tableName);
        DataTable GetReportFunctionsList(string reportCode);
        DataTable GetDataTable(string query);        
        DataRow GetReportConfigInfo(string reportCode);
        string GetConnectionStringForReport(string REPORT_CODE);
        bool UpdateUserDefinedReportSettings(string REPORT_CODE, string SQL_WHERE, string GROUP_BY, string ORDER_BY, string ORDER_BY_DIR, string field_caps, string report_settings);
        bool CreateNewReportWithSettings(string REPORT_CODE, string REPORT_NAME, string SQL_WHERE, string GROUP_BY, string ORDER_BY, string ORDER_BY_DIR, string field_caps, string report_settings, string sid, string reports, string obs);
        bool InsertGroupColor(string REPORT_CODE, string GROUP_BY, string GROUP_CODE, string COLOR_CODE);
        string PostDocumentUpdate(string taskSummary, string taskDescription, string openedBy, string assignTo, string refInfo, string original_fileName);
        DataTable GetReportExtensionInfo(string reportCode);
        DataTable GetRelativeFileName(string sqlFrom, string where_);
        DataTable GetPartlistInfo(string partlistQuery);
        string GetArticleCodeAndRevisionAndPartlistDataQuery(string sqlFrom, string whereClause, string rep_code);
        DataTable GetBaseMaterialDetail(string KeyNameValues, string rep_code);
        string DeleteTask(string taskId);
        string UpdateDetailTask(string taskId, string assignedTo,string editedBy, string label, string description, string taskSatus);
        string GetInfoForThisFile(string viewName, string fileName);
        string SaveFileInfo(string information, string viewName, string reference);
        string UpdateFileInfo(string information, string viewName, string relfilename);
        string ValidateDeepLink(ref string deepLinkReport, string whereClause);
        string GetBaseMaterialQuery(string whereClause, string rep_code);
        string DeleteReport(string rep_code);

        void ImportExcelData(DataTable dtItems, string dbTableName);
    }
}