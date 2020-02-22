<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ExcelImport.aspx.cs" Inherits="Components_rc_ExcelImport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../styles/datagrid.css" rel="stylesheet" type="text/css" />
    <style>
        .errorMsg
        {
            color: red;
        }
        .hilite
        {
            background-color: #dfe5ff;
        }
        .nohilite
        {
            background-color: #ffffff;
        }
        .tableOutlineWt
        {
            border-right: #cccccc 1px solid;
            border-top: #666666 1px solid;
            margin-top: 0px;
            overflow: auto;
            border-left: #333333 1px solid;
            padding-top: 0px;
            border-bottom: #cccccc 1px solid;
        }
    </style>

    <script type="text/javascript">
        function checkFileExtension(elem) {
            var filePath = elem.value;

            if (filePath.indexOf('.') == -1)
                return false;

            var validExtensions = new Array();
            var ext = filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();
            //Add valid extentions in this array
            validExtensions[0] = 'xls';
            validExtensions[1] = 'xlsx';
            //validExtensions[1] = 'pdf';

            for (var i = 0; i < validExtensions.length; i++) {
                if (ext == validExtensions[i])
                    return true;
            }

            alert('The file extension ' + ext.toUpperCase() + ' is not allowed!');
            elem.value = "";
            return false;
        }</script>

</head>
<body>
    <form id="form1" runat="server">
    <div>
        <fieldset>
            <table  border="0" cellspacing="0">
                <tr>
                    <td>
                        Select Item (.xls):
                    </td>
                    <td>
                        <asp:FileUpload runat="server" ID="fuExcelItem" onchange="checkFileExtension(this);" />
                    </td>
                </tr>
                <tr>
                    <td>
                        Select Partlist (.xls):
                    </td>
                    <td>
                        <asp:FileUpload runat="server" ID="fuExcelPartlist" onchange="checkFileExtension(this);" />
                    </td>
                </tr>
                <tr><td colspan="2"><hr /></td></tr>
                <tr>
                    <td colspan="2">
                        <table width="100%" border="0" cellspacing="0">
                            <tr>
                                <td>
                                    <asp:Label ID="lblError" runat="server" CssClass="errorMsg"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <b>Select DWF Directory (example: c:\ ):</b>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:TextBox ID="txtBrowse" runat="server" Width="344px" Text="d:\"/><asp:ImageButton
                                        ID="btnBrowse" ImageUrl="~/Components/rc/image/Go.gif" runat="server" OnClick="btnBrowse_Click" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div class="tableOutlineWt" 
                                        style="width: 364px; height: 200px; background-color: white">
                                        <table cellspacing="0" cellpadding="4" width="100%" bgcolor="#ffffff" border="0">
                                            <tr>
                                                <td>
                                                    <asp:TreeView ID="tvFolderList" runat="server" Height="200px" ImageSet="XPFileExplorer"
                                                        NodeIndent="15" Width="335px">
                                                        <ParentNodeStyle Font-Bold="False" />
                                                        <HoverNodeStyle Font-Underline="True" ForeColor="#6666AA" />
                                                        <SelectedNodeStyle BackColor="#B5B5B5" Font-Underline="False" HorizontalPadding="0px"
                                                            VerticalPadding="0px" />
                                                        <NodeStyle Font-Names="Tahoma" Font-Size="8pt" ForeColor="Black" HorizontalPadding="2px"
                                                            NodeSpacing="0px" VerticalPadding="2px" />
                                                        <LeafNodeStyle ImageUrl="~/Components/rc/image/folder.gif" />
                                                    </asp:TreeView>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                            <%--<tr>
                                <td align="left">
                                    <asp:ImageButton ID="_selectButton" ImageUrl="~/Components/rc/image/ok.jpg" OnClientClick="SelectAndClose();"
                                        runat="server" />
                                </td>
                            </tr>--%>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Button ID="btnClose" runat="server" Text="Annuleren" OnClientClick="window.close()" />
                        <asp:Button ID="btnImport" runat="server" Text="OK" OnClick="btnImport_Click" />
                    </td>
                </tr>
            </table>
        </fieldset>
    </div>
    </form>
</body>
</html>
