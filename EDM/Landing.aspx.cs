using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using HIT.OB.STD.Wrapper.BLL;
using HIT.OB.STD.Wrapper.DAL;
using System.IO;

public partial class Landing : System.Web.UI.Page
{
    public string reportCode, sqlFrom, selectedFields, keyList, valueList, docPath, matCode, keyField;
    public string[] capsList;
    DataRow drReportConfig;
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            reportCode = Request.QueryString["report"].ToString();            
            string basePath = HIT.OB.STD.Wrapper.CommonFunctions.GetDocBasePath("DocBasePath");
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunc = dbManagerFactory.GetDBManager();
            drReportConfig = iWrapFunc.GetReportConfigInfo(reportCode);
            keyField = drReportConfig["sql_keyfields"].ToString();
            matCode = Request.QueryString[keyField].ToString();            
            keyList = keyField;
            valueList = matCode;

            sqlFrom = drReportConfig["sql_from"].ToString();
            selectedFields = drReportConfig["detail_fieldsets"].ToString().Trim(new char[] { ';' }).Replace(';', ',');
            string fieldCaps = drReportConfig["field_caps"].ToString();
            capsList = fieldCaps.Split(';');

            string whereClause = " matcode='" + matCode + "'";
            DataTable dtRelFile = iWrapFunc.GetRelativeFileName(sqlFrom, whereClause);
            string relativePath = dtRelFile.Rows[0]["relfilename"].ToString();
            docPath = Path.Combine(basePath, relativePath);
            if (!File.Exists(docPath))
            {
                docPath = "";
            }
            else
            {
                docPath = docPath.Replace("\\", "@@@@");
            }
        }
        catch (Exception ex)
        {

        }
    }

    

    void Page_Error(Object sender, EventArgs args)
    {
        Response.Write("Sorry, An internal error occured.");
        Exception e = Server.GetLastError();
        Response.Write("<br/>Message : "+ e.Message);
        //Response.Write("Source:"+ e.Source);
        //Response.Write("Stack Trace:"+ e.StackTrace);        
        Context.ClearError();
    }

}
