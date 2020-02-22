<%@ WebHandler Language="C#" Class="DocLoadHandler" %>

using System;
using System.IO;
using System.Web;
using System.Data;
using HIT.OB.STD.Core.DAL;
using System.Collections;
using System.Text;
using System.Web.SessionState;
using System.Diagnostics;
public class DocLoadHandler : IHttpHandler, IRequiresSessionState, IReadOnlySessionState
{

    public void ProcessRequest(HttpContext context)
    {
        string docPath = context.Request.QueryString["filepath"].ToString();
        docPath = docPath.Replace("@",@"\");                       
        string fileType = docPath.Substring(docPath.LastIndexOf(@".")+1);
        switch (fileType.ToLower())
        {
            case "dwf":
                context.Response.ContentType = "application/x-Autodesk-DWF";
                break;
            case "dwg":
                context.Response.ContentType = "application/x-Autodesk-DWF";
                break;
            case "tiff":
                context.Response.ContentType = "image/tiff";
                break;
            case "tif":
                context.Response.ContentType = "image/tiff";
                break;                
            case "pdf":
                context.Response.ContentType = "application/pdf";
                break;
			case "txt":
                context.Response.ContentType = "text/xml";
                break;	
            default:
                context.Response.ContentType = "application/octet-stream";
                break;
        }

        int startIndex = docPath.Replace('\\', '/').LastIndexOf('/') + 1;
        string fileName = docPath.Substring(startIndex, docPath.Length - startIndex);
        context.Response.AddHeader("Content-Disposition", "attachment;filename=" + fileName);

        FileStream file = new FileStream(docPath, FileMode.OpenOrCreate, FileAccess.Read);
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

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}