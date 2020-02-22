using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using HIT.OB.STD.Wrapper.BLL;
using HIT.OB.STD.Wrapper.DAL;
using System.Configuration;
using System.Data;

/// <summary>
/// Summary description for TaskService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
 [System.Web.Script.Services.ScriptService]
public class TaskService : System.Web.Services.WebService {

    public TaskService () {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    
    [WebMethod]
    [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
    public List<string> GetUsers()
    {
        DBManagerFactory dbManagerFactory = new DBManagerFactory();
        IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
        string projectCode = ConfigurationSettings.AppSettings["project_code"].ToString();
        string query = "select * from project_user where project_code='" + projectCode + "'";
        DataTable dt = iWrapFunctions.GetDataTable(query);
        List<string> userList = new List<string>();
        
        foreach (DataRow dr in dt.Rows)
        {
            userList.Add(dr["username"].ToString());
        }

        return userList;
    }

   
    
}

