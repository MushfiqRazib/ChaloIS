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

public partial class Scripts_Wrapper_PostUpdate : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            GetUsers();
        }
    }

    private void GetUsers()
    {
        DBManagerFactory dbManagerFactory = new DBManagerFactory();
        IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
        string projectCode = ConfigurationSettings.AppSettings["project_code"].ToString();
        string query = "select * from project_user where project_code='" + projectCode + "'";
        DataTable dt = iWrapFunctions.GetDataTable(query);
        lstUsers.DataTextField = "username";
        lstUsers.DataValueField = "username";
        lstUsers.DataSource = dt;
        lstUsers.DataBind();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        string summary = txtSummary.Text.Trim();
        string description = txtDescription.Text.Trim();
        string assignTo = lstUsers.SelectedItem.Text;
        try
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();            
            string openedBy = SecurityManager.GetUserName(SID.Value);            
            string sqlFrom = SQLFROM.Value;
            string reportName = REPORTNAME.Value;
            string keyList = KEYLIST.Value;
            string valueList = VALUELIST.Value;
            string[] keyItems = keyList.Split(';');
            string[] valueItems = valueList.Split(';');
            string whereClause = string.Empty;
            for (int k = 0; k < keyItems.Length; k++)
            {
                whereClause += keyItems[k] + " = '" + valueItems[k] + "' & ";
            }
            whereClause = whereClause.TrimEnd(new char[] { '&', ' ' }).Replace("&", "AND");
            string ref_info = sqlFrom + ";" +reportName + ";" + whereClause;

            if (reportName.ToUpper().Equals("TASKS")) {
                ref_info = string.Empty;
            }

            string taskId = iWrapFunctions.PostDocumentUpdate(summary, description, openedBy, assignTo, ref_info, fileUpload.FileName);

            if (fileUpload.PostedFile != null && fileUpload.PostedFile.FileName != "")
            {
                UploadSelectedDocument(sqlFrom, whereClause, taskId);
            }

            txtDescription.Text = "";
            txtSummary.Text = "";
            lstUsers.SelectedIndex = 0;
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "error", "<script>alert('" + ex.Message + "')</script>");
        }

        if(REPORTNAME.Value.ToUpper().Equals("TAKEN")){
            Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "refreshPage", "<script>opener.OBSettings.RefreshPage();</script>");
        }

        Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "error", "<script>self.close();</script>");

    }

    private void UploadSelectedDocument(string sqlFrom, string whereClause, string taskId)
    {
        DBManagerFactory dbManagerFactory = new DBManagerFactory();
        IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
        string relativePath = string.Empty;
              
        string basePath = HIT.OB.STD.Wrapper.CommonFunctions.GetDocBasePath("DocBasePath");

        string task_dir = "TASKS" + System.IO.Path.DirectorySeparatorChar + taskId;
        //if (sqlFrom.ToUpper().Equals("TASKS"))
        //{
        if (!System.IO.Directory.Exists(System.IO.Path.Combine(basePath, task_dir)))
        {
            System.IO.Directory.CreateDirectory(System.IO.Path.Combine(basePath, task_dir));
            }
        relativePath = task_dir + System.IO.Path.DirectorySeparatorChar + fileUpload.FileName;
        //}
        //else
        //{
        //    DataTable dtRelFile = iWrapFunctions.GetRelativeFileName(sqlFrom, whereClause);
        //    relativePath = dtRelFile.Rows[0]["relfilename"].ToString();
        //    relativePath = relativePath.Substring(0, relativePath.LastIndexOf('.')) + "_task_" + taskId + fileUpload.FileName.Substring(fileUpload.FileName.LastIndexOf('.'));
        //}

       
        string filePath = System.IO.Path.Combine(basePath, relativePath);                
        fileUpload.SaveAs(filePath);
       
    }

}
