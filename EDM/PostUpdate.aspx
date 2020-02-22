<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PostUpdate.aspx.cs" Inherits="Scripts_Wrapper_PostUpdate" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script type="text/javascript">
    function SetValuesForServer() {
        var keyValues = opener.OBSettings.GetDelimittedKeyValuePair('$').split('$');               
        document.getElementById("KEYLIST").value = keyValues[0];
        document.getElementById("VALUELIST").value = keyValues[1];
        document.getElementById("SQLFROM").value = opener.OBSettings.SQL_FROM;
        document.getElementById("REPORTNAME").value = opener.OBSettings.REPORT_NAME;
        document.getElementById("SID").value = opener.SECURITY_KEY;
        return true;
    }
    
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <fieldset style="padding: 10px; padding-bottom: 25px;">
            <table>
                <tr>
                    <td valign="top">
                        Assign To:
                    </td>
                    <td>
                        <asp:DropDownList ID="lstUsers" runat="server" Style="width: 398px">
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        Task Summary:
                    </td>
                    <td>
                        <asp:TextBox ID="txtSummary" TextMode="MultiLine" Rows="2" Columns="47" runat="server"></asp:TextBox><asp:RequiredFieldValidator ID="rfvTxtSummery" runat="server" ErrorMessage="*" ControlToValidate="txtSummary"></asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        Task Description:
                    </td>
                    <td>
                        <asp:TextBox ID="txtDescription" TextMode="MultiLine" Rows="10" Columns="47" runat="server"></asp:TextBox><asp:RequiredFieldValidator ID="rfvTxtDesc" runat="server" ErrorMessage="*" ControlToValidate="txtDescription"></asp:RequiredFieldValidator>

                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        Select a document:
                    </td>
                    <td>
                    <asp:FileUpload ID="fileUpload" runat="server" Style="width: 398px"></asp:FileUpload>
                    </td>
                </tr>
                <tr>
                    <td>
                    </td>
                    <td style="text-align: right; padding-top: 20px;">
                        <asp:Button ID="btnSubmit" runat="server" Text="Post Update" 
                            onclick="btnSubmit_Click" OnClientClick="return SetValuesForServer();"></asp:Button>
                    </td>
                </tr>
            </table>
        </fieldset>
    </div>
    <asp:HiddenField ID="KEYLIST" runat="server"></asp:HiddenField>
    <asp:HiddenField ID="VALUELIST" runat="server"></asp:HiddenField>
    <asp:HiddenField ID="SQLFROM" runat="server"></asp:HiddenField>
    <asp:HiddenField ID="REPORTNAME" runat="server"></asp:HiddenField>
    <asp:HiddenField ID="SID" runat="server"></asp:HiddenField>
    
    </form>
</body>
</html>
