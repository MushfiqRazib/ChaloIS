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


public partial class TaskDetail : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string task_id = Request.QueryString["taskId"].ToString();
            GetTaskDetails(task_id);
        }
    }

    void GetTaskDetails(string task_id)
    {
        DBManagerFactory dbManagerFactory = new DBManagerFactory();
        IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
        string sql = "select * from tasks where task_id = '"+ task_id + "'";
        DataTable dt = iWrapFunctions.GetDataTable(sql);
        string assingedTo = dt.Rows[0]["assign_to"].ToString();
        string taskStatus = dt.Rows[0]["item_status"].ToString();
        GetUsers(assingedTo);
        txtSummary.Text = dt.Rows[0]["item_summary"].ToString();
        txtDescription.Text = dt.Rows[0]["detailed_desc"].ToString();        
        lstTaskStatus.SelectedValue = taskStatus;           
    }

    private void GetUsers(string assingedTo)
    {
        DBManagerFactory dbManagerFactory = new DBManagerFactory();
        IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
        string projectCode = ConfigurationSettings.AppSettings["project_code"].ToString();
        string query = "select * from project_user where project_code='" + projectCode + "' order by username desc";
        DataTable dt = iWrapFunctions.GetDataTable(query);
        lstUsers.DataTextField = "username";
        lstUsers.DataValueField = "username";
        lstUsers.DataSource = dt;
        try
        {
            lstUsers.DataBind();
            lstUsers.SelectedItem.Text = assingedTo;
        }
        catch (Exception ex)
        {

        }
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        DBManagerFactory dbManagerFactory = new DBManagerFactory();
        IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
        string taskId = Request.QueryString["taskId"].ToString();
        string xx = iWrapFunctions.DeleteTask(taskId);

        string basePath = HIT.OB.STD.Wrapper.CommonFunctions.GetDocBasePath("DocBasePath");

        string task_dir = "TASKS" + System.IO.Path.DirectorySeparatorChar + taskId;
        //if (sqlFrom.ToUpper().Equals("TASKS"))
        //{
        if (System.IO.Directory.Exists(System.IO.Path.Combine(basePath, task_dir)))
        {
            System.IO.Directory.Delete(System.IO.Path.Combine(basePath, task_dir),true);
        }

        Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "Close", "<script>ReloadOpener();</script>");
        
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        string editedBy = SecurityManager.GetUserName(SID.Value);         
        string label = txtSummary.Text.Trim();
        string description = txtDescription.Text.Trim();
        string assignedTo = lstUsers.SelectedItem.Text;
        string taskSatus = lstTaskStatus.SelectedValue;
        string taskId = Request.QueryString["taskId"].ToString();
      
        try
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
            string xx = iWrapFunctions.UpdateDetailTask(taskId, assignedTo, editedBy, label, description, taskSatus);
            Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "Close", "<script>ReloadOpener()</script>");
            //Response.Write("<script type='text/javascript'>ReloadOpener();</script>");
        }
        catch (Exception ex)
        {
            Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "error", "<script>alert('" + ex.Message + "')</script>");
        }
    }



}
