using System;
using System.Data;
using System.Data.Odbc;
using System.Configuration;
using System.Web;
using System.IO;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.OleDb;
using Npgsql;

public partial class StuklijstWriter : System.Web.UI.Page
{
    int documentCount = 0;
    int aantal = 0;
    bool stuklijst = false;
    bool header = false;
    string kobladPDFstring = "";
    string[] formatPrinterArr;
    string printingdir, normalDoc;
    int jobCount = 0;
    string rcORva = "";
    string appendicesCount = string.Empty;
    int appendicesNumber = 0;

    protected void Page_Load(object sender, EventArgs e)
    {

        rcORva = Request.Params["rcORva"].ToString();
        if (Request.Params["printpagereport"] != null)
        {
            WorkForPrintWizard();
        }
        else if (Request.Params["distributepagereport"] != null)
        {
            WorkForDistributeWizard();
        }


    }

    private void WorkForDistributeWizard()
    {
        string basketName = Request.Params["basketName"].ToString();
        string basketPath = Request.Params["basketPath"].ToString();
        string tablename = Request.Params["tablename"].ToString();
        string keyFields = Request.Params["keyfields"].ToString();

        string constring = Request.Params["constring"].ToString();
        printingdir = Request.Params["printingdir"].ToString();
        normalDoc = Request.Params["normalDoc"].ToString();

        string sid = Request.Params["sid"].ToString();

        if (Request.Params["tprintnumber"] != null)
        {
            appendicesCount = Request.Params["tprintnumber"].ToString();
        }
        else
        {
            appendicesCount = "0";
        }

        string row = Request.Params["rows"].ToString().Trim().Replace("|", @"\");

        if (!(row.Length == 1 && row.Contains("/")))
        {
            string opm = Request.Params["opmerking"].ToString();
            if (opm.Length > 1)
                opm = opm.Replace("@**@", " ");

            row = row.Replace("*", " ");
            row = row.Replace("@@@@", "*");
            string[] rows = row.Split(',');
            //string[] ai = rows[3].Split('*');

            string str = Request.Params["FirstPage"].ToString();
            if (str.ToLower().Contains("true"))
            {
                aantal++;
                stuklijst = true;
            }

            if (stuklijst)
            {
                foreach (string ar_ver in rows)
                {
                    string[] article_version = ar_ver.Split('*');
                    PrintDistributeReport(article_version[0], article_version[1],tablename,keyFields ,constring);
                }
            }

            if (normalDoc == "True")
            {
                jobCount += rows.Length;
            }

            if (!appendicesCount.Equals(""))
            {
                Int32.TryParse(appendicesCount, out appendicesNumber);
                jobCount += appendicesNumber;
            }


            string[] arrS = Request.Params["secondPage"].ToString().Split(',');
            documentCount = arrS.Length;
            aantal += documentCount;
            if (Request.Params["thirdPage"].ToString() != "")
            {
                aantal++;
                header = true;
            }

            if (kobladPDFstring.Length > 0)
            {
                kobladPDFstring = kobladPDFstring.Substring(0, kobladPDFstring.Length - 4);
            }

            if (Request.Params["koblad"].ToString() != "")
            {
                PrintDistributeKoblad(documentCount, aantal, basketName, basketPath, kobladPDFstring, opm, jobCount);
            }
        }

        //Response.Write("<script>CallKitServerToGetFullXml('" + kitServerIp + "','" + printingdir + "');self.close();</script>");
        //Response.End();
    }

    private void WorkForPrintWizard()
    {
        string basketName = Request.Params["basketName"].ToString();
        string basketPath = Request.Params["basketPath"].ToString();
        string formatPrinter = Request.Params["formatPrinter"].ToString();
        string constring = Request.Params["constring"].ToString();
        printingdir = Request.Params["printingdir"].ToString();
        normalDoc = Request.Params["normalDoc"].ToString();
        appendicesCount = Request.Params["tprintnumber"].ToString();
        string sid = Request.Params["sid"].ToString();
        string kitServerPath = Request.Params["kitServerPath"].ToString();
        string tablename = Request.Params["tablename"].ToString();
        string keyFields = Request.Params["keyfields"].ToString();
        formatPrinterArr = formatPrinter.Split('*');
        string row = Request.Params["rows"].ToString().Trim();

        if (!(row.Length == 1 && row.Contains("/")))
        {
            string opm = Request.Params["opmerking"].ToString();
            if (opm.Length > 1)
                opm = opm.Replace("@**@", " ");

            row = row.Replace("*", " ");
            row = row.Replace("@@@@", "*");
            string[] rows = row.Split(',');

            string str = Request.Params["FirstPage"].ToString();
            if (str.ToLower().Contains("stuklijst"))
            {
                aantal++;
                stuklijst = true;
            }

            if (stuklijst)
            {
                foreach (string ar_ver in rows)
                {

                    string[] article_version = ar_ver.Split('*');
                    PrintReport(article_version[0], article_version[1], article_version[2],tablename,keyFields, constring);
                }
            }
            if (normalDoc == "True")
            {
                jobCount += rows.Length;
            }

            if (!appendicesCount.Equals(""))
            {
                Int32.TryParse(appendicesCount, out appendicesNumber);
                jobCount += appendicesNumber;
            }

            string[] arrS = Request.Params["secondPage"].ToString().Split(',');
            documentCount = arrS.Length;
            aantal += documentCount;
            if (Request.Params["thirdPage"].ToString() != "")
            {
                aantal++;
                header = true;
            }


            if (kobladPDFstring.Length > 0)
            {
                kobladPDFstring = kobladPDFstring.Substring(0, kobladPDFstring.Length - 4);
            }

            if (Request.Params["koblad"].ToString() != "")
            {
                string[] kop_printer_format = formatPrinterArr[formatPrinterArr.Length - 1].Split('@');
                PrintKoblad(documentCount, aantal, basketName, basketPath, kobladPDFstring, opm, kop_printer_format, jobCount);
            }
        }


        string FullXmlFilePath = printingdir.Replace(@"\", "|") + "|FullXML.xml";
        ClientScript.RegisterClientScriptBlock(typeof(Page), "NotifyKitServer", "<script>CallKitServerToGetFullXml('" + kitServerPath + "','" + FullXmlFilePath + "');</script>");

    }

    private void PrintKoblad(int docCount, int aantal, string baskName, string basketPath, string descStr, string opmerking, string[] arrForPrint, int jobCount)
    {
        Kopblad report = new Kopblad(docCount, aantal, stuklijst, header, baskName, basketPath, descStr, opmerking, arrForPrint, jobCount);
        //string path = Path.GetTempFileName();
        string path = printingdir + System.IO.Path.DirectorySeparatorChar + "Kopblad.pdf";
        //path = path.Replace(".tmp", ".pdf");
        report.path = path;
        report.print();
        //Response.Write("Success : " + path);
        //Response.Redirect(path);
        //Page.RegisterStartupScript("x", "<script>alert('Operation failed');</script>");
    }

    private void PrintDistributeKoblad(int docCount, int aantal, string baskName, string basketPath, string descStr, string opmerking, int jobCount)
    {
        Dist_Kopblad report = new Dist_Kopblad(docCount, aantal, stuklijst, header, baskName, basketPath, descStr, opmerking, jobCount);

        string path = printingdir + System.IO.Path.DirectorySeparatorChar + "Kopblad.pdf";

        report.path = path;
        report.print();
    }

    protected void PrintDistributeReport(string arNr, string verNr, string tablename, string keyfields, string constring)
    {
        Stuklijst report = new Stuklijst(arNr, verNr, tablename, keyfields,constring, rcORva);
        string path = printingdir + System.IO.Path.DirectorySeparatorChar + arNr + verNr + "_stk.pdf";

        report.path = path;
        report.Print();
        string printerName = "";

        kobladPDFstring = kobladPDFstring + arNr + "_stk.pdf" + "@@" + report.pageCounter() + "@@@@";
        jobCount += report.pageCounter();
    }


    protected void PrintReport(string arNr, string verNr, string format,string tablename,string keyfields, string constring)
    {
        Stuklijst report = new Stuklijst(arNr, verNr,tablename,keyfields, constring, rcORva);
        string path = printingdir + System.IO.Path.DirectorySeparatorChar + arNr + verNr + "_stk.pdf";

        //string path = Path.GetTempFileName();
        //path = path.Replace(".tmp",".pdf");
        report.path = path;
        report.Print();

        if (report.detailsRowsCount > 0)
        {
            string printerName = "";
            if (format.Trim() == "") format = "unknown";
            foreach (string str in formatPrinterArr)
            {
                string[] col = str.Split('@');
                if (col[0].Trim().ToLower() == format.Trim().ToLower())
                    printerName = col[1];

            }
            kobladPDFstring = kobladPDFstring + arNr + "_stk.pdf" + "@@" + report.pageCounter() + "@@" + format + "@@" + printerName + "@@@@";

            jobCount += report.pageCounter();
        }

        //Response.Redirect(path);

    }
}


