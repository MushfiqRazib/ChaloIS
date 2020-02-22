using System;
using System.Configuration;
using System.Data;
using System.Web;
using HIT.OB.STD.Wrapper.BLL;
using HIT.OB.STD.Wrapper.DAL;
using System.Web.SessionState;

public partial class Default : System.Web.UI.Page
{
    public string sharedPath;
    public string SIDValid = string.Empty;
    public string kitServerPath;
    public string printSeverLocation;
    public string repeater = string.Empty;
    public string authInformation = string.Empty;
    public string defaultconnectionkit = ConfigManager.GetDefaultConnectionKit();
    public string deepLinkReport = string.Empty;
    public string tab = string.Empty;
    public string whereClause = string.Empty;
    public string deepLinkStatus = string.Empty;
    public string SECURITY_KEY = string.Empty;
    public string BYPASSED_USER = "false";
    
    protected void Page_Load(object sender, EventArgs e)
    {
                 
        string queryString = Request.QueryString.ToString().ToLower();
        //When tried for deeplink url 
        if (queryString.IndexOf("report") > -1 && queryString.IndexOf("tab") > -1 && Session["SECURITY_KEY"] == null)
        {
            string roleInfo = GetClientBypassableCredentials();
            if (string.IsNullOrEmpty(roleInfo))
            {
                Response.Cookies["queryString"].Value = queryString;
                string defConKit = ConfigManager.GetDefaultConnectionKit();
                defaultconnectionkit = defConKit;
                //ProcessDeepLink();
                Response.Redirect(defConKit);
            }
            else
            {
                //Login bypass section starts here..
                SECURITY_KEY = GetBypassedSID(roleInfo);
                if (!string.IsNullOrEmpty(SECURITY_KEY))
                {
                    Response.Cookies["queryString"].Value = queryString;
                    SetLoginCheckInfo(SECURITY_KEY);
                }
            }
        }
        else  //Non deeplink url
        {
            SECURITY_KEY = Request["sid"];
            if (string.IsNullOrEmpty(SECURITY_KEY) || (queryString.IndexOf("report") > -1 && queryString.IndexOf("tab") > -1))
            {
                
                 SECURITY_KEY = Convert.ToString(Session["SECURITY_KEY"]);
                 
                 //Login bypass section starts here..
                 if (string.IsNullOrEmpty(SECURITY_KEY))
                 {
                     string roleInfo = GetClientBypassableCredentials();
                     SECURITY_KEY = GetBypassedSID(roleInfo);
                 }
                 else
                 {
                     BYPASSED_USER = IsBypassable();               
                 }
            }

            //*** Used in client side
            if (queryString.IndexOf("report") > -1 && queryString.IndexOf("tab") > -1)
            {
                Response.Cookies["queryString"].Value = queryString;
            }

            if (!string.IsNullOrEmpty(SECURITY_KEY))
            {
                SetLoginCheckInfo(SECURITY_KEY);
            }

            HttpSessionState ss = HttpContext.Current.Session;
            Response.Cookies["sessionid"].Value = ss.SessionID;
        }
    }

    private void SetLoginCheckInfo(string sid)
    {
        string url;
        bool userSessionValid = SecurityManager.GetKitServerURLWithValidityCheck(sid, out url, BYPASSED_USER);
        if (url.Length > 0)
        {
            kitServerPath = url.Substring(0, url.LastIndexOf("/"));
        }
        kitServerPath = Microsoft.JScript.GlobalObject.escape(kitServerPath);

        if (userSessionValid)
        {
            string[] securityInfos = SecurityManager.GetAuthenticationValues(sid);
            printSeverLocation = securityInfos[0];
            printSeverLocation = Microsoft.JScript.GlobalObject.escape(printSeverLocation);

            sharedPath = securityInfos[1];
            sharedPath = Microsoft.JScript.GlobalObject.escape(sharedPath);

            authInformation = securityInfos[2];
            authInformation = Microsoft.JScript.GlobalObject.escape(authInformation);

            repeater = ConfigurationManager.AppSettings["repeater"];
            SIDValid = "true";
            Session["SECURITY_KEY"] = sid;
        }
        else
        {
            SIDValid = "false";
        }

        if (Request.Cookies["queryString"] != null)
        {
            ProcessDeepLink();
        }
    }

    private void ProcessDeepLink()
    {
        //http://localhost/obrowser/default.aspx?report=ARCHIEF&tab=1&internalid=2
        //http://localhost/obrowser/default.aspx??report=tasks&tab=1&task_id='972'
        //http://localhost/obrowser/default.aspx??report=Archive (full)&tab=1&task_id='972'
        
        string queryString = Request.Cookies["queryString"].Value.ToLower();
        if (queryString == "")
        {
            queryString = Request.QueryString.ToString().ToLower();
        }
        
        if (queryString.IndexOf("report") > -1 && queryString.IndexOf("tab") > -1)
        {
            string[] queryParts = queryString.Split('&');
            for (int k = 0; k < queryParts.Length; k++)
            {
                if (k == 0 && !string.IsNullOrEmpty(queryParts[k]))
                {
                    deepLinkReport = queryParts[k].Split('=')[1];
                }
                else if (k == 1)
                {
                    tab = queryParts[k].Split('=')[1];
                }
                else
                {
                    string[] clauseParts = queryParts[k].Split('=');
                    whereClause += clauseParts[0] + "='" + clauseParts[1] + "'";
                    if (k < queryParts.Length - 1)
                    {
                        whereClause += " AND ";
                    }
                }
            }

            deepLinkStatus = WrappingManager.ValidateDeepLink(ref deepLinkReport, whereClause);
            //whereClause = Server.UrlEncode(whereClause);
            //whereClause = Server.UrlEncode(whereClause);
        }
        Response.Cookies["queryString"].Value = "";
    }


    string GetBypassedSID(string roleInfo)
    {
        string[] rolePass = roleInfo.Split(' ');
        if (rolePass.Length == 2)
        {
            EdmServicesForKit edmSFK = new EdmServicesForKit();
            string defConKit = ConfigManager.GetDefaultConnectionKit();
            string defaultdocSharedPathforkit = ConfigManager.GetDefaultDocSharedPathforkit();
            string clientIP = GetIpAddress();
            string sid = edmSFK.ValidateUserAndGetSecurityId(clientIP, rolePass[0], rolePass[1], "NL", defConKit, defaultdocSharedPathforkit);
            BYPASSED_USER = "true";
            return sid;
        }
        return string.Empty;
    }

    private string GetClientBypassableCredentials()
    {
        string line;
        try
        {
            string clientIP = GetIpAddress();            
            string filePath = Server.MapPath("./BypassList.txt");
            // Read the file and display it line by line.
            using (System.IO.StreamReader file = new System.IO.StreamReader(filePath))
            {
                line = file.ReadLine();
                while (line != null)
                {
                    if (line.StartsWith("["))
                    {
                        string roleInfo = line.Trim(new char[] {'[',']',' ' });
                        while ((line = file.ReadLine()) != null)
                        {                            
                            if (line.StartsWith("["))
                            {
                                break;
                            }
                            if (line.Trim().Equals(clientIP) || (clientIP.Trim().Equals("::1") && line.Trim().Equals("127.0.0.1"))) //<::1> for localhost
                            {
                               return roleInfo;
                            }
                        }                        
                    }
                }
            }
        }
        catch
        {            
        }
        return string.Empty;
    }

    private string IsBypassable()
    {
        string rolePassInfo = GetClientBypassableCredentials();
        if (rolePassInfo.Split(' ').Length == 2)
        {
            return "true";
        }else
        {
            return "false";
        }       
    }

    private string GetIpAddress()
    {
        string strIpAddress;
        strIpAddress = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
        if (strIpAddress == null)
        {
            strIpAddress = Request.ServerVariables["REMOTE_ADDR"];
        }
        return strIpAddress;
    }

   
    private bool CheckSecurityIDExist(string sid)
    {
        repeater = ConfigurationManager.AppSettings["repeater"];
        return SecurityManager.CheckSecurityIDExist(sid);

    }
}
