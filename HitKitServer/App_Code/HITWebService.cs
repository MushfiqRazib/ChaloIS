using System;
using System.Collections;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Linq;
using System.Xml;
using HITKITServer;
using System.Web.Script.Services;
using System.Collections.Generic;
using System.Configuration;

/// <summary>
/// Summary description for HITWebService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
 [System.Web.Script.Services.ScriptService]
public class HITWebService : System.Web.Services.WebService {

    public HITWebService () {
    }

    [WebMethod]
    [ScriptMethod(UseHttpGet = true)]
    public List<Application> GetAllApplication()
    {
        List<Application> allapplication = new List<Application>();
       
        try
        {
            XDocument appXML = XDocument.Load(Server.MapPath("./appInfo.xml"));

            var q = from c in appXML.Descendants("application")
                    select new
                    {
                        name = c.Element("name").Value,
                        baseurl = c.Element("baseurl").Value
                    };

            foreach (var obj in q)
            {
                Application application = new Application();
                application.name = obj.name;
                application.baseurl = obj.baseurl;

                allapplication.Add(application);
            }
        }
        catch (Exception ex)
        {
            //lblLoginMsg.Text = ex.Message;
        }

        return allapplication;
    }

    [WebMethod]
    [ScriptMethod]
    public string ValidateUser(string applicationName, string baseUrl, string userName, string password, string kitServerurl) {
        string roleName = string.Empty;
        string rolePass = string.Empty;

        return DoSecurityCheck(userName, password, applicationName, baseUrl, kitServerurl, ref roleName, ref rolePass);
    }

    private string DoSecurityCheck(string userId, string password, string appl, string baseUrl, string kitServerUrl, ref string roleName, ref string rolePass)
    {
        string returnUrl = string.Empty;

        IsValidLANUser(userId, password, appl, ref roleName, ref rolePass);
        if (!roleName.Equals(string.Empty) && !rolePass.Equals(string.Empty))
        {
            string print_server_location = ConfigurationManager.AppSettings["print_server_location"];
            string docSharePath = ConfigurationManager.AppSettings["docSharedPath"];
            ConfigurationManager.AppSettings["GINIX_EDMServices.EdmServicesForKit"] = baseUrl + "/EdmServicesForKit.asmx";

            GINIX_EDMServices.EdmServicesForKit cs = new GINIX_EDMServices.EdmServicesForKit();

            try
            {
                string securityId = cs.ValidateUserAndGetSecurityId(userId, roleName, rolePass, print_server_location, kitServerUrl, docSharePath);
                
                if (!securityId.Equals("-1"))
                {
                    returnUrl = baseUrl + "/Default.aspx?sid=" + securityId;
                }
                else
                {
                    returnUrl = "invalid";
                }
            }
            catch (Exception ex)
            {
                returnUrl = "invalid";
            }
        }
        else
        {
            returnUrl = "invalid";
        }

        return returnUrl;
    }

    public void IsValidLANUser(string userId, string password, string appl, ref string roleName, ref string rolePass)
    {
       
        try
        {
             XDocument appXML = XDocument.Load(Server.MapPath("./appInfo.xml"));

             var q = from k in
                         (from c in appXML.Descendants("application")
                          where c.Element("name").Value == appl
                          select c.Element("users")).Descendants("user")
                     select new { user = k.Value};
                                
            foreach (var obj in q)
            {
                if (obj.user.StartsWith(userId, StringComparison.OrdinalIgnoreCase))
                {
                    string[] creds = obj.user.Split(',');
                    if (!creds[1].Equals(password))
                    {
                        continue;
                    }
                    roleName = creds[2];
                    rolePass = creds[3];
                    break;
                }
            }
        }
        catch (Exception ex)
        {
            //lblLoginMsg.Text = ex.Message;
        }

    }
    
}

