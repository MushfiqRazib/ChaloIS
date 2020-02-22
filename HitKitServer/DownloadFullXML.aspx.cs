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
using System.Threading;
using System.IO;
using System.Collections.Generic;

public partial class DownloadFullXML : System.Web.UI.Page
{
    System.Timers.Timer fileTransferInitiatorTimer = new System.Timers.Timer(10000);
    string filePath = string.Empty;
    string fileSubpath = string.Empty;
    string docSharePath = string.Empty;
    const int TimerLoop = 90;
    int currentLoopCounter = 0;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.Params["filePath"] != null)
        {
            DocUploader du = new DocUploader();
            du.GetFullXML(Request.Params["filePath"].ToString());
            Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "CloseWindow", "<script>self.close();</script>");
        }
        else if (Request.Params["redline"] != null)
        {
            filePath = Request.Params["redline"].ToString().Replace("@@@", "\\").Replace("/", "\\") + ".dwf";
            fileSubpath = Request.Params["relFileName"].ToString().ToLower().Replace(".dwf", "_Redline.dwf").Replace("@@@", "\\");
            docSharePath = ConfigurationManager.AppSettings["docSharedPath"];
            CheckIfRedLineFileSaved();
        }
        else if (Request.Params["downloadDocPath"] != null)
        {
            filePath = Request.Params["downloadDocPath"].ToString();
            fileSubpath = Request.Params["relFileName"].ToString();
            filePath = Microsoft.JScript.GlobalObject.unescape(filePath);
            fileSubpath = Microsoft.JScript.GlobalObject.unescape(fileSubpath);
            string docBasePath = ConfigurationManager.AppSettings["docBasePath"];
            DownloadTheNewlyUploadedDocument(filePath, fileSubpath, docBasePath);

        }
        else
        {
            Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "CloseWindow", "<script>self.close();</script>");
        }
    }

    void DownloadTheNewlyUploadedDocument(string srcPath, string fileSubpath, string docBasePath)
    {
        try
        {
            DocUploader uploaderService = new DocUploader();
            string tgtPath = Path.Combine(docBasePath, fileSubpath);
            uploaderService.DownloadTheNewlyUploadedDocument(srcPath, tgtPath);
        }
        catch (Exception exp)
        {
            LogWriter.WriteLog(exp.Message);
        }

    }

    void CheckIfRedLineFileSaved()
    {
        fileTransferInitiatorTimer.Elapsed += new System.Timers.ElapsedEventHandler(fileUploadTimer_Elapsed);
        fileTransferInitiatorTimer.Enabled = true;
    }


    void fileUploadTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
    {
        try
        {
            fileTransferInitiatorTimer.Enabled = false;
            DocUploader uploaderService = new DocUploader();
            if (uploaderService.CheckFileExist(filePath))
            {
                CleanShareDirectory();
                //*** Save in local connection kit repository for local users
                string docBasePath = ConfigurationManager.AppSettings["docBasePath"];
                string targetPath = Path.Combine(docBasePath, fileSubpath);
                
                string subdirectoryPath = targetPath.Substring(0, targetPath.LastIndexOf("\\"));
                if (!Directory.Exists(subdirectoryPath))
                {
                    Directory.CreateDirectory(subdirectoryPath);
                }
                FileInfo fi = new FileInfo(targetPath);
                if (fi.Exists)
                {
                    fi.Delete();
                }
                new FileInfo(filePath).CopyTo(targetPath);

                //*** Upload to remote server
                string msg = uploaderService.UploadDocument(filePath, fileSubpath);
                if (msg.Equals(string.Empty))
                {
                    Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "Success", "<script>alert('Redline Success Uploaded');</script>");
                }
                else
                {
                    Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "Error", "<script>alert('Fail to upload redline');</script>");
                }
                StopTimer();
            }
            else
            {
                if (currentLoopCounter >= TimerLoop)
                {
                    StopTimer();
                    Page.ClientScript.RegisterClientScriptBlock(typeof(Page), "Error", "<script>alert('Fail to upload redline after trying sevaral times.');</script>");

                }
                else fileTransferInitiatorTimer.Enabled = true;
            }

            currentLoopCounter++;
        }
        catch (Exception ex)
        {
            LogWriter.WriteLog("Redline upload and local save error: " + ex.Message);
        }

    }

    void CleanShareDirectory()
    {
        string[] files = Directory.GetFiles(docSharePath, "*.dwf", SearchOption.AllDirectories);
        TimeSpan time;
        foreach (string file in files)
        {
            time = File.GetLastWriteTime(file).Subtract(DateTime.Now);
            if (time.Days != 0 || Math.Abs(time.Hours) >= 12)
            {
                File.Delete(file);
            }
        }
    }

    void StopTimer()
    {
        fileTransferInitiatorTimer.Stop();
        fileTransferInitiatorTimer.Enabled = false;
    }
}
