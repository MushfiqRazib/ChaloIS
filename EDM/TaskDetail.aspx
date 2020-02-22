<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TaskDetail.aspx.cs" Inherits="TaskDetail" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script type="text/javascript">
   window.onload = function(){
    
        if (opener.OBSettings.REPORT_CODE == "TASKS" && opener.OBSettings.HasPermission('DELETE')) {
            document.getElementById("btnDelete").style.display = 'block';
        } else {
           document.getElementById("btnDelete").style.display = 'none';
        } 
   }
    function SetValuesForServer()
    {              
        document.getElementById("SID").value = opener.SECURITY_KEY;
        return true;
    }

    function ReloadOpener() 
    {
        opener.OBSettings.RefreshPage();
        self.close();
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head >
    <title></title>
</head>
<body style="background-color:#D2DFF2">
    <form id="form1" runat="server" >
    <div>
        <fieldset style="padding: 10px; padding-bottom: 25px;">
            <table>
                <tr>
                    <td valign="top">
                        Assign To:
                    </td>
                    <td>
                        <asp:DropDownList ID="lstUsers" AutoPostBack="false" runat="server" Style="width: 398px">
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        Label:
                    </td>
                    <td>
                        <asp:TextBox ID="txtSummary" TextMode="MultiLine" Rows="2" Columns="47" runat="server"></asp:TextBox><asp:RequiredFieldValidator
                            ID="rfvTxtSummery" runat="server" ErrorMessage="*" ControlToValidate="txtSummary"></asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        Description:
                    </td>
                    <td>
                        <asp:TextBox ID="txtDescription" TextMode="MultiLine" Rows="7" Columns="47" 
                            runat="server" Height="159px"></asp:TextBox><asp:RequiredFieldValidator
                            ID="rfvTxtDesc" runat="server" ErrorMessage="*" ControlToValidate="txtDescription"></asp:RequiredFieldValidator>
                    </td>
                </tr>
               
                <tr>
                    <td valign="top">
                        Task Status:
                    </td>
                    <td>
                        <asp:DropDownList ID="lstTaskStatus" runat="server" Style="width: 398px">
                            <asp:ListItem Value="Open">Open</asp:ListItem>
                            <asp:ListItem Value="Close">Close</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr style="height:35px;">
                    <td colspan="2"></td>
                </tr>
                
            </table>
            
            <div  style="float:right">
            <div style="float:left">
                    <asp:Button ID="btnSubmit"  Width="120px" runat="server" Text="Save" OnClick="btnSubmit_Click"  OnClientClick="return SetValuesForServer();">
                        </asp:Button>
                        </div>
                        <div  style="float:left">
                     <asp:Button ID="btnDelete" Width="120px" runat="server" OnClientClick="return confirm('Weet u zeker dat u deze taak wilt verwijderen?');" Text="Delete" OnClick="btnDelete_Click">
                        </asp:Button>
                        </div>
                        <div  style="float:left">
                     <input id="btnCancel" style="width:120px" type="button" value="Cancel" onclick="javascript:self.close()" />
                    </div>                  
            </div>
        </fieldset>
    </div>
    <asp:HiddenField ID="SID" runat="server"></asp:HiddenField>
   
    </form>
</body>
</html>
