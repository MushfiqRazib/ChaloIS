using System;
using System.Collections;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Services;
using HITKITServer;
using System.Data;

/// <summary>
/// Summary description for UserSession
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class UserSession : System.Web.Services.WebService
{

    public UserSession()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    [ScriptMethod]
    public bool UpdateLastAccessTime(string securityKey)
    {
        DataTable dt = DBHandler.GetUserSessionInfo(securityKey);
        if (dt.Rows.Count > 0)
        {
            DateTime dTime = Convert.ToDateTime(dt.Rows[0]["last_access_time"]);
            Double timeout = Convert.ToDouble(dt.Rows[0]["timeout"]);
            TimeSpan idleTimeSpan = DateTime.Now.Subtract(dTime);
            Double idleTimeInSecond = idleTimeSpan.TotalSeconds;
            if (timeout >= idleTimeInSecond)
            {
                DBHandler.UpdateLastAccessTime(securityKey);
                return true;
            }
            else
            {
                DBHandler.DeleteSecurityKeyInfo(securityKey);
            }
        }
        return false;
    }

}

