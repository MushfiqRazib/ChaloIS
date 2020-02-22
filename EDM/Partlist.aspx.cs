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

public partial class Partlist : System.Web.UI.Page
{
    
    protected void Page_Load(object sender, EventArgs e)
    {
             
        if (Request.Params["sqlFrom"] != null)
        {
            sqlFrom.Value = Request.Params["sqlFrom"].ToString();
        }
        if (Request.Params["whereClause"] != null)
        {
            whereClause.Value = Request.Params["whereClause"].ToString();
        }
        if (Request.Params["repCode"] != null)
        {
            reportCode.Value = Request.Params["repCode"].ToString();
        }
    }
}
