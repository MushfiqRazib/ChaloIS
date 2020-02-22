<%@ WebHandler Language="C#" Class="DocLoadHandler" %>

using System;
using System.IO;
using System.Web;
using System.Data;
using HIT.OB.STD.Core.DAL;
using System.Collections;
using System.Text;

public class DocLoadHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        string docStatusRequest = context.Request.QueryString["GETSTATUS"];
        if (!string.IsNullOrEmpty(docStatusRequest))
        {
            try
            {
                //string whereClause = string.Empty;
                string sqlFrom = string.Empty;
                string relFilename = string.Empty;
                
                string reportCode = context.Request.QueryString["REPORT_CODE"];

                HIT.OB.STD.Wrapper.BLL.DBManagerFactory dbManagerFactory = new HIT.OB.STD.Wrapper.BLL.DBManagerFactory();
                HIT.OB.STD.Wrapper.DAL.IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
                                
                sqlFrom = context.Request.QueryString["SQL_FROM"];
                //whereClause = context.Request.QueryString["whereClause"].ToString().Replace("$", " AND ");
                string keyList = context.Request.QueryString["KEYLIST"].ToString();
                string valueList = context.Request.QueryString["VALUELIST"].ToString();
                string redline = context.Request.QueryString["Redline"]; 
                                
                //*** Check document validation.
                string fileType = context.Request.QueryString["TYPE"];
                
                HIT.OB.STD.Core.BLL.DBManagerFactory dbManagerFactoryCore = new HIT.OB.STD.Core.BLL.DBManagerFactory();
                HIT.OB.STD.Core.DAL.IOBFunctions iCoreFunc = dbManagerFactoryCore.GetDBManager(reportCode);

                relFilename = iCoreFunc.GetRelativeFileName(sqlFrom, keyList, valueList);

                if (relFilename.Equals(""))
                {
                    string original_FileName = iCoreFunc.GetTasksOriginalFileName(valueList).Split(new char[]{'.'})[0];
                    LogWriter.WriteLog("Original_Path: " + original_FileName);
                    relFilename = @"TASKS\" + valueList + @"\" + original_FileName + "." + fileType;
                    
                }
                
                
                string basePath = HIT.OB.STD.Wrapper.CommonFunctions.GetDocBasePath("DocBasePath");
                string filePath = Path.Combine(basePath, relFilename);
                string newExt = "." + fileType;
                string baseExt = ".dwf";
                if (!fileType.ToLower().Equals("dwf"))
                {
                    filePath = filePath.ToLower().Replace(baseExt, newExt);
                    relFilename = relFilename.ToLower().Replace(baseExt, newExt);
                }

                
                bool redlineExists = false;
                if (!string.IsNullOrEmpty(redline))
                {
                    filePath = filePath.Replace(baseExt, "_Redline" + baseExt);
                    relFilename = relFilename.Replace(baseExt, "_Redline" + baseExt);
                }
                else
                {
                    string redlineFilePath = filePath.Replace(baseExt, "_Redline" + baseExt);                    
                    redlineExists = File.Exists(redlineFilePath);
                }

                string current_directory = AppDomain.CurrentDomain.BaseDirectory;

                if (fileType.ToLower().Equals("doc") || fileType.ToLower().Equals("odt"))
                {
                    //*** Cleanup directory
                    if (Directory.Exists(current_directory + "Docs"))
                    {
                        DeletePreviousFiles(current_directory);
                        
                        //Directory.Delete(current_directory + "Docs", true);
                    }
                    else
                    {
                        Directory.CreateDirectory(current_directory + "Docs");
                    }
                    relFilename =  filePath.Substring(filePath.LastIndexOf("\\") + 1);
                    
                    if (File.Exists(current_directory + "Docs/" + relFilename)) {
                        File.Delete(current_directory + "Docs/" + relFilename);
                    }
                    
                    File.Copy(filePath, current_directory+"Docs/" + relFilename);
                    relFilename = "Docs/"+relFilename;
                }     
                
                if (File.Exists(filePath))
                {
                    context.Response.ContentType = "application/xml";
                    context.Response.Write(relFilename + "$$$" + redlineExists.ToString().ToLower());
                    //context.Response.End();
                    HttpContext.Current.ApplicationInstance.CompleteRequest();
                }
                else
                {
                    //*** When all validation failed
                    context.Response.Write("$$$$$:Document not found");
                }
            }
            catch (Exception exp)
            {
                if (exp.Message.ToLower().IndexOf("relfilename") > -1)
                {
                    context.Response.Write("$$$$$: Documents relative filename not defined.");
                }
                else
                {
                    context.Response.Write("$$$$$: Document viewer not allowed for the report.");
                }
            }
        }
        else
        {
            string basePath = HIT.OB.STD.Wrapper.CommonFunctions.GetDocBasePath("DocBasePath");
            string filePath = basePath + context.Request.QueryString["RELFILEPATH"];
            string fileType = context.Request.QueryString["TYPE"];

            switch (fileType.ToLower())
            {
                case "dwf":
                    context.Response.ContentType = "application/x-Autodesk-DWF";

                    break;
                case "pdf":
                    context.Response.ContentType = "application/pdf";
                    break;
                case "doc":
                    context.Response.ContentType = "application/msword";
                    break;
                 //case "odt":
                 //   context.Response.ContentType = "mimetypeapplication/vnd.oasis.opendocument.text";
                 //   break;
                
                default:
                    context.Response.ContentType = "application/octet-stream";
                    break;
            }
          
            FileStream file = new FileStream(filePath, FileMode.OpenOrCreate, FileAccess.Read);
            StreamReader sr = new StreamReader(file);
            Stream stream = sr.BaseStream;

            const int buffersize = 1024 * 16;
            byte[] buffer = new byte[buffersize];
            int count = stream.Read(buffer, 0, buffersize);
            while (count > 0)
            {
                context.Response.OutputStream.Write(buffer, 0, count);
                count = stream.Read(buffer, 0, buffersize);
            }
            file.Dispose();
            stream.Dispose();
            stream.Close();

        }
    }

    private  void DeletePreviousFiles(string directory_Path)
    {

        string[] files = Directory.GetFiles(directory_Path + "Docs");

        foreach (string file in files)
        {
            FileInfo fileInfo = new FileInfo(file);
            if ((DateTime.Today.DayOfYear-fileInfo.CreationTime.DayOfYear) >= 1)
            {
                fileInfo.Delete();
            }
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}