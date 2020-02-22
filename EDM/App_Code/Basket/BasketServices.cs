using System;
using System.Collections;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Linq;
using System.IO;
using System.Xml;
using System.Configuration;
using System.Security.AccessControl;
using System.Text;
using System.Collections.Generic;


/// <summary>
/// Summary description for BasketServices
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class BasketServices : System.Web.Services.WebService
{
	
    public  BasketServices()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }
	
    [WebMethod]
    public string SaveBasketToXML(string basketitems, string reportcode, string filename, string description, bool overwrite)
    {

        string[] items = basketitems.Split(new char[] { ';' });
        return SaveAsXml(items, reportcode, filename, description, overwrite);

    }

    [WebMethod]
    public string DeleteBasketFromXML(string reportcode,string filename)
    {

        
        return DeleteFromXML(reportcode,filename);

    }

    private string DeleteFromXML( string reportcode,string filename)
    {
        string basketFile = ConfigurationManager.AppSettings["BASKET_OUTPUT"] + reportcode + Path.DirectorySeparatorChar + filename + ".xml";
        if (File.Exists(basketFile))
        {
            File.Delete(basketFile);  
        }

        return "Deleted";
        
    }

    [WebMethod]
    public string RestoreBasket(string reportcode, string basketname)
    {
        string basketFile = ConfigurationManager.AppSettings["BASKET_OUTPUT"] + reportcode + Path.DirectorySeparatorChar + basketname + ".xml";
        return GetBasketData(reportcode, basketFile);
    }

    [WebMethod]
    public string GetSavedBasketList(string reportcode)
    {
        string basketFileDirectory = ConfigurationManager.AppSettings["BASKET_OUTPUT"] + reportcode;
        StringBuilder sb = new StringBuilder();
        
        if (Directory.Exists(basketFileDirectory))
        {
            sb.Append("[");
            string[] files = Directory.GetFiles(basketFileDirectory, "*.xml", SearchOption.TopDirectoryOnly);
            for (int i = 0; i < files.Length; i++)
            {
                if (i > 0)
                {
                    sb.Append(",");
                    sb.Append(ParseXML(files[i]));
                }
                else
                {
                    sb.Append(ParseXML(files[i]));
                }
            }

            sb.Append("]");
        }
        else
        {
            sb.Append("[");
            sb.Append("]");
        }

        return sb.ToString();
    }

    private string ParseXML(string file)
    {
        FileInfo curFile = new FileInfo(file);
        XDocument xDoc = XDocument.Load(file);
        IEnumerable<XElement> el = xDoc.Element("Basket").Elements("Description");
        string des = el.First().Value;
        string name = curFile.Name.Replace(".xml", string.Empty);
        return "['" + name + "','" + des + "']";
    }

    private string SaveAsXml(string[] basketitems, string reportcode, string filename, string description, bool overwrite)
    {
        string basketFileDirectory = ConfigurationManager.AppSettings["BASKET_OUTPUT"] + reportcode;
        bool hasDirectory = CreateReportDirectory(basketFileDirectory);
        string saveError = "Could not save in the directory";
        if (!hasDirectory)
        {
            return saveError;
        }

        string newFileUrl = basketFileDirectory + Path.DirectorySeparatorChar + filename + ".xml";
        if (!overwrite && File.Exists(newFileUrl))
        {
            return "exist";
        }

        try
        {
            XmlDocument xmlDoc = new XmlDocument();
            XmlElement root = xmlDoc.CreateElement("Basket");
            xmlDoc.AppendChild(root);
            XmlElement desc = xmlDoc.CreateElement("Description");
            desc.InnerText = description;
            root.AppendChild(desc);

            // Iterate by each record
            foreach (string itemRecord in basketitems)
            {
                string[] keyValues = itemRecord.Split(new char[] { ',' });
                XmlElement item = xmlDoc.CreateElement("Keyinfo");

                // Iterate by each key
                foreach (string keyValString in keyValues)
                {
                    string[] singleKeyValue = keyValString.Split(new char[] { ':' });
                    XmlElement key = xmlDoc.CreateElement(singleKeyValue[0].ToString().Replace(" ",""));
                    key.InnerText = singleKeyValue[1];
                    item.AppendChild(key);
                }


                root.AppendChild(item);
            }


            xmlDoc.Save(newFileUrl);
        }
        catch (Exception ex)
        {
            return saveError;
        }

        return "saved";
    }



    private bool CreateReportDirectory(string dirLocation)
    {

        try
        {
            if (Directory.Exists(dirLocation))
            {
                return true;
            }
            else
            {
                DirectoryInfo dirInfo = Directory.CreateDirectory(dirLocation);
                DirectorySecurity dirSecurity = dirInfo.GetAccessControl();
                dirSecurity.AddAccessRule(new FileSystemAccessRule("Everyone", FileSystemRights.FullControl, AccessControlType.Allow));
                dirInfo.SetAccessControl(dirSecurity);
            }
        }
        catch
        {
            return false;
        }

        return true;
    }

    private string GetBasketData(string reportcode, string basketFile)
    {
        string whereClause = "";
        List<bool> partExistList = null;
        int keyCounter = 0;
        int recordCounter = 0;
        //Hashtable itemRevs = new Hashtable();
        StringBuilder stringBuilder = new StringBuilder();
        StringBuilder sb = new StringBuilder();
        //stringBuilder.Append("[");

        if (File.Exists(basketFile))
        {
            XDocument xDoc = XDocument.Load(basketFile);
            IEnumerable<XElement> records = xDoc.Element("Basket").Elements("Keyinfo");
            List<XElement> els = records.ToList<XElement>();
            partExistList = new List<bool>(els.Count);


            foreach (XElement el in els)
            {
                /*keyCounter = 0;

                if (recordCounter > 0)
                {
                    whereClause += " OR ";
                }
                partExistList.Add(false);
                IEnumerable<XElement> keys = el.Descendants();


                string item = string.Empty;*/
                IEnumerable<XElement> keys = el.Descendants();
                //sb.Append("{");
                int counter = 0;
                foreach (XElement key in keys)
                {

                    //if (key.Name.ToString().Equals("item"))
                    //{
                    //    item = key.Value;
                    //}
                    //if (key.Name.ToString().Equals("revision"))
                    //{
                    //    itemRevs.Add(item,key.Value);
                    //    continue;
                    //}




                    string keyname = string.Empty;
                    if (key.Name.ToString().IndexOf('_') > 0)
                        keyname = key.Name.ToString().Replace("_", " ");
                    else
                        keyname = key.Name.ToString();

                    if (counter != 0)
                        //sb.AppendFormat(",'{0}':'{1}'", keyname, key.Value);
                        //sb.AppendFormat(",'{0}'", key.Value);
                        //sb.AppendFormat(",'[{0}]':'{1}'", counter.ToString(), key.Value);
                        sb.AppendFormat("#{0}", key.Value);
                    else
                        //sb.AppendFormat("'{0}':'{1}'", keyname, key.Value);
                        //sb.AppendFormat("'{0}'", key.Value);
                        //sb.AppendFormat("'[{0}]':'{1}'", counter.ToString(), key.Value);
                        sb.AppendFormat("{0}", key.Value);

                    counter++;

                    
                   
                }

                //sb.Append("},");
                sb.Append(",");
            }

            /*
            foreach (XElement key in keys)
            {
                if (key.Name.ToString().Equals("revision"))
                {
                    continue;
                }
                if (key.Name.ToString().Equals("parts"))
                {
                    partExistList[recordCounter]= true;
                    continue;
                }

                if (keyCounter == 0)
                {
                    whereClause += string.Format("({0}='{1}'", key.Name.LocalName, key.Value);
                }
                else
                {
                    whereClause += string.Format(" AND {0}='{1}'", key.Name.LocalName, key.Value);
                }

                keyCounter++;
            }

            whereClause += ")";

            recordCounter++;

        }
    }

    string sql_from = HIT.OB.STD.Basket.BLL.BasketManager.GetReportRelationName(reportcode);
    string jsonStringRecord = HIT.OB.STD.Basket.Core.BLL.BasketController.GetReportRecords(reportcode, sql_from, whereClause, partExistList,itemRevs);

    return jsonStringRecord;
             */

        }
        stringBuilder.Append(sb.ToString().TrimEnd(new char[] { ',' }));
        //stringBuilder.Append("]");
        
         return stringBuilder.ToString();
    }

}

