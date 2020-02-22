using System;
using System.Data;
using System.Data.OleDb; 
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using PdfSharp.Drawing;
using Npgsql;

/// <summary>
/// Summary description for Stuklijst
/// </summary>


    public class Stuklijst
    {
        string itemId, itemRev, description, constring, rcORva;
        public int detailsRowsCount = 0;
        public string path = "";
        public string table = "";
        public string keyFields = "";

        PageProperties pp = new PageProperties();

        public Stuklijst(string artikel, string revision,string tablename,string keyfields, string constring, string rcORva)
        {
            this.itemId = artikel;
            this.itemRev = revision;
            this.constring = constring;
            this.rcORva = rcORva;
            this.table = tablename;
            this.keyFields = keyfields;
            pp.NewPage(PdfSharp.PageSize.A4, PdfSharp.PageOrientation.Portrait);

        }

        private DataTable getDataTable(string query)
        {
            string conStr = constring;
            //string conStr = "Provider=OraOLEDB.Oracle;Persist Security Info=True;User ID=vdl;Data Source=iqbal;Password=vdl";
            NpgsqlConnection conn = new NpgsqlConnection(conStr);
            NpgsqlDataAdapter ad = new NpgsqlDataAdapter();
            ad.SelectCommand = new NpgsqlCommand(query,conn);
            DataTable Details = new DataTable();
            ad.Fill(Details);
            return Details;
        }

        public int pageCounter()
        {
            return pp._pageNumber;
        }

        public void Print()
        {

            DataTable Details = getDataTable("SELECT * FROM " + rcORva + "_bom where item='" + itemId + "' and revision ='" + itemRev + "'");
            detailsRowsCount = Details.Rows.Count;

            if (detailsRowsCount > 0) //Create pdf depending on the presence of stukjist
            {
                string[] tmpArr = new string[2];
                tmpArr[0] = keyFields.Split(new string[] { "@@" }, StringSplitOptions.None)[0];
                tmpArr[1] = keyFields.Split(new string[] { "@@" }, StringSplitOptions.None)[1];
                DataTable destn = getDataTable("SELECT * FROM " + table + " WHERE " + tmpArr[0] + "='" + itemId + "' and " + tmpArr[1] + " ='" + itemRev + "'");
                if (destn.Rows.Count > 0)
                    description = destn.Rows[0]["description"].ToString();
                else description = "";
                PrintPageHeader();
                PrintDetailsTableHeader();

                Print_Details(Details);
                pp.SaveFile(path);
            }

        }



        private void PrintPageHeader()
        {
            XFont _font = new XFont("Arial", 10);
            string type = "Eng";

            pp.gfx.DrawString("VDL Jonckheere ROESELARE", new XFont("Arial", 11), XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap));
            pp.gfx.DrawString(DateTime.Now.ToString("MM/dd/yyyy  hh:mm"), _font, XBrushes.Black, pp.GetHorizontalPos(0) + 450, pp.GetVerticalPos(0));

            pp.gfx.DrawString("Artikel: ", _font, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap * 2));
            pp.gfx.DrawString(itemId + "           Rev: " + itemRev + "   Type: " + type, _font, XBrushes.Black, pp.GetHorizontalPos(35), pp.GetVerticalPos(0));
            pp.gfx.DrawString(description, _font, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap * 2));

            //pp.gfx.DrawString("Rev:", _font, XBrushes.Black, pp.GetHorizontalPos(50) , pp.GetVerticalPos(0));
            //pp.gfx.DrawString("00", _font, XBrushes.Black, pp.GetHorizontalPos(25), pp.GetVerticalPos(0) );

            //pp.gfx.DrawString("Type:", _font, XBrushes.Black, pp.GetHorizontalPos(50), pp.GetVerticalPos(0));
            //pp.gfx.DrawString("Eng", _font, XBrushes.Black, pp.GetHorizontalPos(30) , pp.GetVerticalPos(0));


        }

        private void PrintDetailsTableHeader()
        {
            //CheckRequiredSpace(pp._lineGap * 2);
            pp.SetHorizontalPos(pp._leftMargin);

            float headerX = (float)pp.GetHorizontalPos(0);
            float headerY = (float)pp.GetVerticalPos(pp._lineGap * 2);
            float headerWidth = 550;
            float headerHeight = 15;
            XFont fnt = new XFont("Times New Roman", 10, XFontStyle.Bold);
            XRect myRect = new XRect(new System.Drawing.RectangleF(headerX - 3, headerY - 11, headerWidth, headerHeight));

            pp.gfx.DrawRectangle(XBrushes.LightGray, myRect);

            //XFont _normalBold = new XFont("Arial", 10, XFontStyle.Bold);
            pp.gfx.DrawString("Pos", fnt, XBrushes.Black, headerX, headerY);
            pp.gfx.DrawString("Component", fnt, XBrushes.Black, pp.GetHorizontalPos(21), pp.GetVerticalPos(0));
            pp.gfx.DrawString("Omschrijving", fnt, XBrushes.Black, pp.GetHorizontalPos(60), pp.GetVerticalPos(0));
            pp.gfx.DrawString("Verbruik", fnt, XBrushes.Black, pp.GetHorizontalPos(180), pp.GetVerticalPos(0));
            
            pp.gfx.DrawString("M", fnt, XBrushes.Black, pp.GetHorizontalPos(47), pp.GetVerticalPos(0));
            pp.gfx.DrawString("Ph", fnt, XBrushes.Black, pp.GetHorizontalPos(13), pp.GetVerticalPos(0));
            //pp.gfx.DrawString("Aantal", fnt, XBrushes.Black, pp.GetHorizontalPos(19), pp.GetVerticalPos(0));
            pp.gfx.DrawString("Lengte", fnt, XBrushes.Black, pp.GetHorizontalPos(37), pp.GetVerticalPos(0));
            pp.gfx.DrawString("Breedte", fnt, XBrushes.Black, pp.GetHorizontalPos(36), pp.GetVerticalPos(0));
            //pp.gfx.DrawString("Zaaghoeken", fnt, XBrushes.Black, pp.GetHorizontalPos(42), pp.GetVerticalPos(0));

        }

        private void Print_Details(DataTable Details)
        {
            XFont fnt = new XFont("Times New Roman", 8);

            //pp.GetVerticalPos(pp._lineGap*0.5);
            foreach (DataRow row in Details.Rows)
            {
                CheckRequiredSpace(pp._lineGap);

                pp.SetHorizontalPos(pp._leftMargin);
                pp.gfx.DrawString(row["pos_nr"].ToString(), fnt, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap));
                pp.gfx.DrawString(row["item"].ToString(), fnt, XBrushes.Black, pp.GetHorizontalPos(21), pp.GetVerticalPos(0));
                pp.gfx.DrawString(row["description"].ToString(), fnt, XBrushes.Black, pp.GetHorizontalPos(60), pp.GetVerticalPos(0));
                pp.DrawRightAlign(row["ref_qty"].ToString(), fnt, XBrushes.Black, pp.GetHorizontalPos(180) + 40, pp.GetVerticalPos(0));
                
                pp.gfx.DrawString("", fnt, XBrushes.Black, pp.GetHorizontalPos(47), pp.GetVerticalPos(0));
                pp.gfx.DrawString("", fnt, XBrushes.Black, pp.GetHorizontalPos(13), pp.GetVerticalPos(0));
                //pp.DrawRightAlign(row["ref_qty"].ToString(), fnt, XBrushes.Black, pp.GetHorizontalPos(19) + 28, pp.GetVerticalPos(0));
                pp.DrawRightAlign(row["length"].ToString(), fnt, XBrushes.Black, pp.GetHorizontalPos(37) + 30, pp.GetVerticalPos(0));
                pp.DrawRightAlign(row["width"].ToString(), fnt, XBrushes.Black, pp.GetHorizontalPos(36) + 32, pp.GetVerticalPos(0));

                //pp.gfx.DrawString(row["ref_description"].ToString(), fnt, XBrushes.Black, pp.GetHorizontalPos(42), pp.GetVerticalPos(0));

            }
        }


        private void CheckRequiredSpace(double value)
        {
            double availableHeight = pp.gfx.PageSize.Height - (pp.GetVerticalPos(0) + pp._bottomMargin + pp._lineGap * 1.5);

            if (value > availableHeight)
            {
                pp.NewPage(PdfSharp.PageSize.A4, PdfSharp.PageOrientation.Portrait);
                pp.GetVerticalPos(pp._lineGap);
                pp.GetHorizontalPos(pp._leftMargin);
                PrintPageHeader();
                PrintDetailsTableHeader();
            }

        }

        /*
                    private void CheckRequiredSpace_4total(double value)
                    {
                        double availableHeight = pp.gfx.PageSize.Height - (pp.GetVerticalPos(0) + pp._bottomMargin + pp._lineGap * 1.5);

                        if (value > availableHeight)
                        {
                            pp.NewTamplatePage();
                            pp.GetVerticalPos(-pp._topMargin);
                            pp.GetHorizontalPos(-pp._leftMargin - 5);
                            PrintPageHeader(currentId);
                            pp.GetVerticalPos(pp._lineGap * 2);

                        }

                    }
                   * */
    }

