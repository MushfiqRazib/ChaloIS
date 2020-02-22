using System;
using System.Data;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using System.Text;
using System.Net;

/// <summary>
/// Summary description for WebServiceCaller
/// </summary>
/// 
namespace HITKITServer
{
    public class WebServiceCaller
    {
        public WebServiceCaller()
        {
            //
            // TODO: Add constructor logic here
            //
        }

        public string _webServiceURI = string.Empty;
        public string _webMethodName = string.Empty;
        System.Collections.Hashtable _webServiceWebMethodRequestFormats = new System.Collections.Hashtable();
        string _requestFormat = string.Empty;

        public WebServiceCaller(string webServiceURI, string webMethodName)
            : base()
        {
            this._webServiceURI = webServiceURI;
            this._webMethodName = webMethodName;
            string hashTableKey = this._webServiceURI + "/" + this._webMethodName;
            if (_webServiceWebMethodRequestFormats.ContainsKey(hashTableKey))
            {
                this._requestFormat = (string)_webServiceWebMethodRequestFormats[hashTableKey];
            }
            else
            {
                this._requestFormat = this.GetRequestFormat();
                _webServiceWebMethodRequestFormats.Add(hashTableKey, this._requestFormat);
            }
        }

        private string GetRequestFormat()
        {
            const string XPATH_TO_WEB_METHOD_INFORMATION_NODE = "/types/schema/element[@name=\"{0}\"]/*";
            const string XPATH_TO_WEB_METHOD_PARAMETERS = "sequence/element";
            string xpathToWebMethodInformationNode = string.Format(
            XPATH_TO_WEB_METHOD_INFORMATION_NODE,
            this._webMethodName);
            string wsdl = this.GetWSDLForWebMethod();
            System.Xml.XmlDocument wsdlDocument = new System.Xml.XmlDocument();
            wsdlDocument.LoadXml(wsdl);
            System.Xml.XmlNode webMethodInformationNode = wsdlDocument.SelectSingleNode(xpathToWebMethodInformationNode);
            System.Xml.XmlNodeList parameterInformationNodes = webMethodInformationNode.SelectNodes(XPATH_TO_WEB_METHOD_PARAMETERS);
            return this.BuildRequestFormatFromNodeList(parameterInformationNodes);
        }

        private string BuildRequestFormatFromNodeList(System.Xml.XmlNodeList parameterInformationNodes)
        {
            const string PARAMETER_NAME_VALUE_PAIR_FORMAT = "{0}=[{1}]";
            System.Text.StringBuilder requestFormatToReturn = new System.Text.StringBuilder();
            for (int i = 0; i < parameterInformationNodes.Count; i++)
            {
                requestFormatToReturn.Append(
                string.Format(PARAMETER_NAME_VALUE_PAIR_FORMAT, parameterInformationNodes[i].Attributes["name"].Value,
                i) +
                ((i < parameterInformationNodes.Count - 1 &&
                parameterInformationNodes.Count > 1) ? "&" : string.Empty));
            }
            return requestFormatToReturn.ToString();
        }
        private string GetWSDLForWebMethod()
        {
            HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(this._webServiceURI + "?WSDL");
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            System.IO.Stream baseStream = response.GetResponseStream();
            System.IO.StreamReader responseStreamReader = new System.IO.StreamReader(baseStream);
            string wsdl = responseStreamReader.ReadToEnd();
            responseStreamReader.Close();
            return this.ExtractTypesXmlFragment(wsdl);
        }

        private string ExtractTypesXmlFragment(string wsdl)
        {
            const string CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_HTTP = "http:";
            const string CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_SOAP = "soap:";
            const string CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_SOAPENC = "soapenc:";
            const string CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_TM = "tm:";
            const string CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_S = "s:";
            const string CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_MIME = "mime:";
            const string CONST_XML_NAMESAPCE_REFERENCE_TO_REMOVE_WSDL = "wsdl:";
            const string CONST_TYPES_REGULAR_EXPRESSION = "<types>[\\s\\n\\r=\"<>a-zA-Z0-9.\\.:/\\w\\d%]+</types>";
            System.Collections.ArrayList namespaceDeclarationsToRemove = new System.Collections.ArrayList();
            namespaceDeclarationsToRemove.Add(CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_HTTP);
            namespaceDeclarationsToRemove.Add(CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_MIME);
            namespaceDeclarationsToRemove.Add(CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_S);
            namespaceDeclarationsToRemove.Add(CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_SOAP);
            namespaceDeclarationsToRemove.Add(CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_SOAPENC);
            namespaceDeclarationsToRemove.Add(CONST_XML_NAMESPACE_REFERENCE_TO_REMOVE_TM);
            namespaceDeclarationsToRemove.Add(CONST_XML_NAMESAPCE_REFERENCE_TO_REMOVE_WSDL);
            for (int i = 0; i < namespaceDeclarationsToRemove.Count; i++)
            {
                wsdl = wsdl.Replace((string)namespaceDeclarationsToRemove[i], string.Empty);
            }
            System.Text.RegularExpressions.Match match =
            System.Text.RegularExpressions.Regex.Match(wsdl, CONST_TYPES_REGULAR_EXPRESSION);
            return match.Groups[0].Value;
        }

        internal string CallWebMethod(params object[] parameters)
        {
            byte[] requestData = this.CreateHttpRequestData(parameters);
            string uri = this._webServiceURI + "/" + this._webMethodName;
            HttpWebRequest httpRequest = (HttpWebRequest)HttpWebRequest.Create(uri);
            httpRequest.Method = "POST";
            httpRequest.KeepAlive = false;
            httpRequest.ContentType = "application/x-www-form-urlencoded";
            httpRequest.ContentLength = requestData.Length;
            httpRequest.Timeout = 30000;
            HttpWebResponse httpResponse = null;
            string response = string.Empty;
            try
            {
                httpRequest.GetRequestStream().Write(requestData, 0, requestData.Length);
                httpResponse = (HttpWebResponse)httpRequest.GetResponse();
                System.IO.Stream baseStream = httpResponse.GetResponseStream();
                System.IO.StreamReader responseStreamReader = new System.IO.StreamReader(baseStream);
                response = responseStreamReader.ReadToEnd();
                responseStreamReader.Close();
            }
            catch (WebException e)
            {
                const string CONST_ERROR_FORMAT = "<?xml version=\"1.0\" encoding=\"utf-8\"?><Exception><{0}Error>{1}<InnerException>{2}</InnerException></{0}Error></Exception>";
                response = string.Format(CONST_ERROR_FORMAT, this._webMethodName, e.ToString(), (e.InnerException != null ? e.InnerException.ToString() : string.Empty));
            }
            return response;
        }

        private byte[] CreateHttpRequestData(object[] parameters)
        {
            StringBuilder requestStream = new StringBuilder();
            string p = this._requestFormat;
            int i = 0;

            foreach (object k in parameters) {
                p = p.Replace("["+i+"]",k.ToString());
                i++;
            }
            requestStream.Append(p);
            UTF8Encoding encoding = new UTF8Encoding();
            return encoding.GetBytes(requestStream.ToString());

        }

    }
}