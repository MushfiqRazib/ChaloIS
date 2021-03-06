﻿using System;
using System.Collections;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Linq;
using System.Web.Script.Services;
using System.IO;
using System.Xml;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using HITKITServer;

/// <summary>
/// Summary description for DocUploader
/// </summary>
[WebService(Namespace = "http://hawarit.nl.bd.connectionKit/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class DocUploader : System.Web.Services.WebService
{
    string baseUrl = string.Empty;
    public DocUploader()
    {
        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    [ScriptMethod]
    public bool CheckFileExist(string filePath)
    {
        filePath = filePath.Replace("@@", "\\").Replace("/", "\\");

        return File.Exists(filePath);
        
    }

    //[WebMethod]
    //[ScriptMethod]
    //public string GetSharePathName()
    //{
    //    return System.Configuration.ConfigurationSettings.AppSettings["docSharedPath"].ToString().Trim();
    //}

    [WebMethod]
    [ScriptMethod]
    //[ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json, XmlSerializeString = false)]
    public string UploadDocument(string filePath, string appServerSubPath)
    {
        GINIX_EDMServices.EdmServicesForKit uploader = new GINIX_EDMServices.EdmServicesForKit();
        //EdmServices.EdmServicesForKit uploader = new EdmServices.EdmServicesForKit();
        filePath = filePath.Replace("@@", "\\").Replace("/", "\\");
        appServerSubPath = appServerSubPath.Replace("@@", "\\").Replace("/", "\\");
        
        string fileName = filePath.Substring(filePath.LastIndexOf("\\") + 1);
        LogWriter.WriteLog(filePath + "@@@@@@@@@" + appServerSubPath);

        System.IO.FileStream fileStream = new FileStream(filePath, FileMode.Open);

        string message = string.Empty;
        string fb = string.Empty;

        byte[] fileBuffer = null;
        for (int counter = 0; ; counter++)
        {
            try
            {
                fileBuffer = GiveFileChunk(counter, ref fileStream);

                if (fileBuffer == null)
                    break;

                if (counter == 0)
                {
                    string xx = uploader.SaveDocument(fileBuffer, counter, true, appServerSubPath);
                   
                    continue;
                }
                string xxg = uploader.SaveDocument(fileBuffer, counter, false, appServerSubPath);
              
            }
            catch (Exception ex)
            {
                message = "error";
                break;
            }
        }        

        fileStream.Close();
        System.IO.File.Delete(filePath);
        return message;
    }


    private Byte[] GiveFileChunk(int chunkNo, ref FileStream objFileStream)
    {
        int customCount = 64000;
        int readDataSuccessfull = 0;
        long customPosition = chunkNo * customCount;

        Byte[] fileInfo = new Byte[customCount];
        /*
         * As count or file chunk count starts from 0.
         * So position will be set from 0 first time.
         *Setting the stream position
         */
        objFileStream.Seek(customPosition, SeekOrigin.Begin);

        if (customPosition < objFileStream.Length)
        {
            long remainingLength = objFileStream.Length - customPosition;
            if (remainingLength < customCount)
            {
                fileInfo = new Byte[remainingLength];
                customCount = (int)remainingLength;
            }
        }

        if (customPosition <= objFileStream.Length)
        {
            try
            {
                readDataSuccessfull = objFileStream.Read(fileInfo, 0, customCount);
            }
            catch (FieldAccessException objFileAccessEx)
            {
                throw objFileAccessEx;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        if (readDataSuccessfull == 0)
        {
            return null;
        }
        else
        {
            return fileInfo;
        }
    }


    [WebMethod]
    [ScriptMethod]
    public void GetFullXML(string filePath)
    {
        this.baseUrl = baseUrl;

        string[] dirArr = filePath.Split('|');
        string fullXmlTmpDirectoryName = dirArr[dirArr.Length - 2];
        filePath = filePath.Replace('|', Path.DirectorySeparatorChar);
        GINIX_EDMServices.EdmServicesForKit uploader = new GINIX_EDMServices.EdmServicesForKit();
        

        string xmlString = uploader.GetFullXML(filePath);
        XElement xElmt = XElement.Parse(xmlString);

        var jobs = from file in xElmt.Descendants("Job")
                   select file;

        List<string> stuklists = new List<string>();
        List<string> otherFiles = new List<string>();
        string fileType = "";
        foreach (var job in jobs)
        {
            fileType = job.Descendants("Type").Single().Value.ToUpper();
            if (fileType.Equals("STUKLIJST") || fileType.Equals("KOPBLAD"))
            {
                stuklists.Add(job.Descendants("File").Single().Value);
            }
            else
            {
                otherFiles.Add(job.Descendants("File").Single().Value);
            }
        }

        DownLoadFiles(stuklists, false, null);
        DownloadFilesIfNotExists(otherFiles);

        string fullXmlPath = ConfigurationManager.AppSettings["fullXml_path"].ToString() + fullXmlTmpDirectoryName;
        Directory.CreateDirectory(fullXmlPath);
        XmlDocument xDoc = new XmlDocument();
        xDoc.InnerXml = xmlString;
        xDoc.Save(fullXmlPath + Path.DirectorySeparatorChar + "FullXml.xml");

    }
    /// <summary>
    /// Download files from app. server for printing.
    /// </summary>
    /// <param name="files"></param>
    /// <param name="findLatest">true:If file exists in both kitserver and app server then get the latest one. false: directly download file from app server.</param>
    private void DownLoadFiles(List<string> files, bool findLatest, DateTime? lastModifiedDTime)
    {
        GINIX_EDMServices.EdmServicesForKit uploader = new GINIX_EDMServices.EdmServicesForKit();
        //EdmServices.EdmServicesForKit uploader = new EdmServices.EdmServicesForKit();
        string locationCode = ConfigurationManager.AppSettings["print_server_location"];
        foreach (string file in files)
        {
            DownloadSingleFile(file, findLatest, lastModifiedDTime, locationCode, ref uploader);
            //string msg = uploader.UploadDocument(file, findLatest, lastModifiedDTime, locationCode);
        }
    }

    public void DownloadTheNewlyUploadedDocument(string srcPath, string tgtPath)
    {
        int chunkCounter = 0;
        Byte[] fileData = new Byte[64000];
        GINIX_EDMServices.EdmServicesForKit uploader = new GINIX_EDMServices.EdmServicesForKit();
        do
        {
            try
            {
                string locationCode = ConfigurationManager.AppSettings["print_server_location"];
                fileData = uploader.FetchFileChunk(srcPath, false, null, locationCode, chunkCounter);
                if (fileData != null)
                {
                    SaveDocument(fileData, chunkCounter, tgtPath);
                    chunkCounter++;
                }
                else
                {
                    LogWriter.WriteLog("counter:" + chunkCounter++);
                    break;
                }
            }
            catch (Exception exp)
            {
                break;
            }

        }
        while (true);
    }

    void DownloadSingleFile(string file, bool findLatest, DateTime? lastModifiedDTime, string locationCode, ref  GINIX_EDMServices.EdmServicesForKit uploader)
    {
        int chunkCounter = 0;
        Byte[] fileData = new Byte[64000];
        do
        {
            try
            {
                fileData = uploader.FetchFileChunk(file, findLatest, lastModifiedDTime, locationCode, chunkCounter);
                if (fileData != null)
                {
                    SaveDocument(fileData, chunkCounter, file);
                    chunkCounter++;
                }
                else break;
            }
            catch (Exception exp)
            {
                break;
            }

        }
        while (true);
    }

    private void DownloadFilesIfNotExists(List<string> files)
    {
        List<string> argFile = new List<string>();
        foreach (string file in files)
        {
            argFile.Clear();
            argFile.Add(file);
            if (!File.Exists(file))
            {
                DownLoadFiles(argFile, false, null);
            }
            else
            {
                DownLoadFiles(argFile, true, File.GetLastWriteTime(file));
            }
        }
    }

    private string SaveDocument(Byte[] fileChunk, int chunkNo, string filePath)
    {
        string message = string.Empty;
        long customPosition = chunkNo * 64000;
        FileStream objFileStream;
        string subdirectoryPath = filePath.Substring(0, filePath.LastIndexOf("\\"));
        try
        {
            if (!Directory.Exists(subdirectoryPath))
            {
                Directory.CreateDirectory(subdirectoryPath);
            }


            if (chunkNo == 0)
            {
                if (File.Exists(filePath))
                {
                    File.Delete(filePath);
                }

                objFileStream = new FileStream(filePath, FileMode.Create);
            }
            else
            {
                objFileStream = new FileStream(filePath, FileMode.Open);
            }

            objFileStream.Seek(customPosition, SeekOrigin.Begin);
            objFileStream.Write(fileChunk, 0, (int)fileChunk.Length);
            objFileStream.Close();
        }
        catch (Exception ex)
        {
            message = "error";
        }

        return filePath;
    }

    //[WebMethod]
    //public DataSet  GetReportCodes() {
    //    DataSet ds = new DataSet();
    //    GINIX_EDMServices.EdmServicesForKit uploader = new GINIX_EDMServices.EdmServicesForKit();
    //    return uploader.GetReportCodes();
    //}

    //[WebMethod]
    //public string GetInfoForThisFile(string viewName, string fileName)
    //{
    //    GINIX_EDMServices.EdmServicesForKit uploader = new GINIX_EDMServices.EdmServicesForKit();
    //    return uploader.GetInfoForThisFile(viewName, fileName);
    //}

    //[WebMethod]
    //public string GetFileProperties(string relativeFilePath) { 
    //    GINIX_EDMServices.EdmServicesForKit uploader = new GINIX_EDMServices.EdmServicesForKit();
    //    return uploader.GetFileProperties(relativeFilePath);
    //}

    //[WebMethod]
    //public string UpdateFileInfo(string information, string viewName, string relfilename)
    //{
    //    GINIX_EDMServices.EdmServicesForKit uploader = new GINIX_EDMServices.EdmServicesForKit();
    //    return uploader.UpdateFileInfo(information, viewName, relfilename);
    //}

    //[WebMethod]
    //public string SaveFileInfo(string information, string viewName, string reference){
    //    GINIX_EDMServices.EdmServicesForKit uploader = new GINIX_EDMServices.EdmServicesForKit();
    //    return uploader.SaveFileInfo(information, viewName, reference);
    //}
}

public struct FileChunk
{
    public Byte[] ChunkData;
    public Boolean NextChunkExist;
}

