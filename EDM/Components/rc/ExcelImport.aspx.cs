using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using HIT.OB.STD.RC.Wrapper;
using System.Data;
using HIT.OB.STD.Wrapper.BLL;
using HIT.OB.STD.Wrapper.DAL;

public partial class Components_rc_ExcelImport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            TreeNode onjParent = new TreeNode("D:\\", "D:\\");
            onjParent.PopulateOnDemand = true;
            tvFolderList.Nodes.Add(onjParent);

            tvFolderList.CollapseAll();
        }
        lblError.Visible = false;
        tvFolderList.TreeNodeExpanded += new TreeNodeEventHandler(tvFolderList_TreeNodeExpanded);
        tvFolderList.SelectedNodeChanged += new EventHandler(tvFolderList_SelectedNodeChanged);
    }

    void tvFolderList_SelectedNodeChanged(object sender, EventArgs e)
    {
        txtBrowse.Text = tvFolderList.SelectedValue;
    }

    void tvFolderList_TreeNodeCollapsed(object sender, TreeNodeEventArgs e)
    {
        //throw new Exception("The method or operation is not implemented.");
    }

    void tvFolderList_TreeNodeExpanded(object sender, TreeNodeEventArgs e)
    {
        if (e.Node.Value.EndsWith("\\"))
        {
            AddNodes(e.Node.Value, e.Node);
        }


    }
    private TreeNode AddNodes(string path, TreeNode parentNode)
    {
        FileList objList = new FileList(path, "*.*");
        TreeNode node = new TreeNode(path, path);
        for (int index = 0; index < objList.Directories.Length; index++)
        {
            string directory = objList.Directories[index];
            TreeNode objChildNode = new TreeNode(directory, path + "\\" + directory + "\\");
            objChildNode.PopulateOnDemand = true;
            objChildNode.Target = "_blank";

            parentNode.ChildNodes.Add(objChildNode);
        }
        foreach (string file in objList.Files)
        {
            TreeNode objChildNode = new TreeNode(file, path + "\\" + file);
            parentNode.ChildNodes.Add(objChildNode);
        }
        return node;
    }


    protected void btnBrowse_Click(object sender, ImageClickEventArgs e)
    {
        tvFolderList.Nodes.Clear();
        if (UpdateBrowseTextBoxWithSlash())
        {

            TreeNode onjParent = new TreeNode(txtBrowse.Text, txtBrowse.Text);
            onjParent.PopulateOnDemand = true;
            tvFolderList.Nodes.Add(onjParent);

            tvFolderList.CollapseAll();
        }
        else
        {
            lblError.Visible = true;
            lblError.Text = "Please Enter valid path";
        }
    }

    private bool UpdateBrowseTextBoxWithSlash()
    {
        if (txtBrowse.Text.Length != 0)
        {
            if (
                    -1 == txtBrowse.Text.LastIndexOf(".") &&
                    !txtBrowse.Text.Substring(txtBrowse.Text.Length - 1, 1).Equals("/") &&
                    !txtBrowse.Text.Substring(txtBrowse.Text.Length - 1, 1).Equals("\\")
                )
            {
                if (txtBrowse.Text.Substring(0, 1).Equals("\\") || -1 != txtBrowse.Text.IndexOf(":\\"))
                    txtBrowse.Text += "\\";
                else
                    txtBrowse.Text += "/";
                return System.IO.Directory.Exists(txtBrowse.Text);
            }
            else if (txtBrowse.Text.LastIndexOf(".") > 0)
            {
                return System.IO.File.Exists(txtBrowse.Text);
            }
        }
        return true;
    }
    protected void btnImport_Click(object sender, EventArgs e)
    {
        if (!fuExcelItem.FileName.Equals(string.Empty))
        {
            string postedFile = this.fuExcelItem.PostedFile.FileName;
            string postedFileFullName = GetTempDir() + @"\" + postedFile;
            this.fuExcelItem.PostedFile.SaveAs(postedFileFullName);
            DataTable dtItems = HIT.OB.STD.RC.Wrapper.OLEDB.GetDataTableFromExcel(postedFileFullName, "Sheet1");
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
            try
            {
                iWrapFunctions.ImportExcelData(dtItems, "rc_item_hit");
            }
            catch(Exception ex)
            {
                lblError.Text = ex.Message;
                lblError.Visible = true;
            }
        }
        if (!fuExcelPartlist.FileName.Equals(string.Empty))
        {
            string postedFile = this.fuExcelPartlist.PostedFile.FileName;
            string postedFileFullName = GetTempDir() + @"\" + postedFile;
            this.fuExcelPartlist.PostedFile.SaveAs(postedFileFullName);
            DataTable dtItems = HIT.OB.STD.RC.Wrapper.OLEDB.GetDataTableFromExcel(postedFileFullName, "Sheet1");
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();
            try
            {
                iWrapFunctions.ImportExcelData(dtItems, "rc_c_bomeng");
            }
            catch (Exception ex)
            {
                lblError.Text = ex.Message;
                lblError.Visible = true;
            }
        }
    }
    private String GetTempDir()
    {
        return Environment.GetEnvironmentVariable("TEMP");
    }
}
