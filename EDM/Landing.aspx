<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Landing.aspx.cs" Inherits="Landing" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Landing Page</title>
    <style type="text/css">
        #docContainer
        {
            height: 574px;
            width: 688px;
        }
    </style>
   
    <script>
        var docPath = "<%=docPath %>";
        window.onload = function LoadContent()
        {        
            docPath = docPath.replace(/@@@@/g,'\\');                 
            var docContainer = document.getElementById("docContainer");   
            if(docPath!="")
            {
                var url = "./Components/Attachment/Loader.ashx?filepath="+docPath;                
                docContainer.innerHTML = '<embed src="' + url + '" href="' + url + '" height="99%" width="100%">' +
                                          '  <noembed>Your browser does not support embedded files.</noembed>' +
                                          '</embed>'; 
                
           }else
           {
                var msgContent = "";
                msgContent += '<table height="100%" width="100%" >';
                msgContent += '  <tr>';
                msgContent += '    <td align="center" style="background-color:#eeffdd; color:#000000;">';
                msgContent += '      <b>Document not found</b>';
                msgContent += '    </td>';
                msgContent += '  </tr>';
                msgContent += '</table>';
                docContainer.innerHTML = msgContent; 
           }
           
           var height = document.documentElement.clientHeight;
           docContainer.style.height = height * 93/100 + "px";

           var detailInfo = document.getElementById("detailInfo");   
           detailInfo.style.height = height * 93/100-2 + "px";
                
        }
    </script>
</head>
<body style="background-color: #eeffdd;">
    <form id="form1" runat="server">  
    <div >
    <fieldset style="padding:5px;">
    <legend style="font-weight:bold">Document Info</legend>
    <div id="detailInfo" style="float:left;width:30%;height:99%; overflow:auto;border: 1px solid #000000;">
    <table>
    <%
        string caption;
        HIT.OB.STD.Core.BLL.DBManagerFactory dbManagerFactoryCore = new HIT.OB.STD.Core.BLL.DBManagerFactory();
                        HIT.OB.STD.Core.DAL.IOBFunctions iCoreFunctions = dbManagerFactoryCore.GetDBManager(reportCode);
                        DataTable dtDetailInfo = iCoreFunctions.GetSpecificRowDetailData(sqlFrom, selectedFields, keyList, valueList);
                        if (dtDetailInfo.Rows.Count > 0)
                        {
                            foreach (System.Data.DataColumn dcItem in dtDetailInfo.Columns)
                            {
                                caption = HIT.OB.STD.Wrapper.CommonFunctions.GetCaption(dcItem.ColumnName, capsList);
        
         %>
   <tr>
                        <td style="padding-left:10px;">
                            <%=caption%>
                        </td>
                        <td class="Detail" nowrap>
                            :&nbsp;&nbsp;
                            <%= dtDetailInfo.Rows[0][dcItem]%>
                        </td>
                    </tr>
                     <%                            
                        }
                        }                			
                    %>
         </table>
    </div>
    
    <div id="docContainer" style="padding-left:1%;float:left;width:68%; height:65%;border: 1px solid #000000;">
        
    </div>
     </fieldset>
      </div>
      <input type="hidden" name="report" value="<%= reportCode %>" />
      <input type="hidden" name="matcode" value="<%= matCode %>" />
      
    </form>
</body>
</html>
