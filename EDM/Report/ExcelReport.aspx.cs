using System;
using System.Collections;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.IO;
using System.Web.UI.WebControls;
using HIT.OB.STD.Wrapper.BLL;



public partial class Report_ExcelReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string selectSql = string.Empty;
        string docName = string.Empty;
        string reportcode = Request.QueryString["reportcode"];
        string reportExtension = Request.QueryString["repExtension"].ToLower();
        string artCode = string.Empty;
        string revision = string.Empty;
        if (Request.QueryString["listName"] != null)
        {
            artCode = Request.QueryString["artCode"];
            string listName = Request.QueryString["listName"];
            artCode = artCode.Split(':')[1].Trim();
            docName = artCode + "_" + listName;
            string sqlFrom = Request.QueryString["sqlFrom"];
            string whereClause = Request.QueryString["whereClause"].Replace("-","%");
            selectSql = WrappingManager.GetListQueryByListName(sqlFrom, whereClause, reportcode, listName);
        }
        else
        {
            string table = Request.QueryString["table"].Replace("@@@", "\"");
            string fields = Request.QueryString["fields"];
            string whereclause = Request.QueryString["whereclause"].Replace("-", "%");
            string groupby = Request.QueryString["groupby"];
            string orderby = Request.QueryString["orderby"];
            docName = reportcode;

            if (table != "" && fields != "")
            {
                selectSql = " select " + fields + " from " + table;

                if (whereclause != "")
                {
                    selectSql = selectSql + " where " + whereclause + " ";
                }


                if (groupby.ToUpper() != "NONE" && groupby != "")
                {
                    selectSql = selectSql + " order by " + groupby;
                }


                if (orderby != "")
                {
                    if (selectSql.ToLower().Contains("order by"))
                    {
                        selectSql = selectSql + " , " + orderby;
                    }
                    else
                    {
                        selectSql = selectSql + " order by " + orderby;
                    }

                }

            }
        }

        HIT.OB.STD.Core.BLL.DBManagerFactory Factory = new HIT.OB.STD.Core.BLL.DBManagerFactory();
        HIT.OB.STD.Core.DAL.IOBFunctions obFunctions = Factory.GetDBManager(reportcode);

        DataTable dt = obFunctions.GetDataTable(selectSql);

        if (reportExtension.Equals("xls"))
        {
            ExportExcel(dt, docName);
        }
        else if (reportExtension.Equals("csv"))
        {
            ExportCSV(dt, docName);
        }



    }

    private void ExportExcel(DataTable dt, string fileName)
    {
        GridView gv = new GridView();
        gv.DataSource = dt;
        gv.DataBind();
        StringWriter stw = new StringWriter();
        HtmlTextWriter htextw = new HtmlTextWriter(stw);
        gv.RenderControl(htextw);

        Response.Clear();
        Response.Buffer = true;
        Response.ContentType = "application/vnd.ms-excel";
        Response.AddHeader("Content-Disposition", "attachment;filename=" + fileName + ".xls");
        Response.Write(stw.ToString());
        Response.Flush();
        Response.End();
    }

    public void ExportCSV(DataTable data, string fileName)
    {

        HttpContext context = HttpContext.Current;

        context.Response.Clear();
        context.Response.ContentType = "text/csv";
        context.Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName + ".csv");

        //Write column header names
        for (int i = 0; i < data.Columns.Count; i++)
        {
            if (i > 0)
            {
                context.Response.Write(",");
            }
            context.Response.Write(data.Columns[i].ColumnName);
        }
        context.Response.Write(Environment.NewLine);

        //Write data
        foreach (DataRow row in data.Rows)
        {

            for (int i = 0; i < data.Columns.Count; i++)
            {
                if (i > 0)
                {
                    context.Response.Write(",");
                }
                context.Response.Write(row[i]);
            }
            context.Response.Write(Environment.NewLine);
        }
        context.Response.End();

    }


}
