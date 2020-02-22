using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using PdfSharp.Drawing;

/// <summary>
/// Summary description for Kopblad
/// </summary>
public class Dist_Kopblad
{
    PageProperties pp = new PageProperties();
    public string path = "";
    private int docCount = 0;
    private int aantal = 0;
    private string stuklijst = "nee";
    private string header = "ja";
    private string description = "";
    private string basketName = "";
    private string baskPath = "";
    private string FirstPageOpmerking = "";
    private int jobCount;

    public Dist_Kopblad(int docCount, int aantal, bool stuk, bool header, string basName,
         string basketPath, string desc, string opmerking, int jobCount)
    {
        this.docCount = docCount;
        this.aantal = aantal;
        if (stuk) this.stuklijst = "ja";
        if (!header) this.header = "nee";
        description = desc;
        this.basketName = basName;
        this.baskPath = basketPath;
        this.jobCount = jobCount;
        FirstPageOpmerking = opmerking;
       
        pp.NewPage(PdfSharp.PageSize.A4, PdfSharp.PageOrientation.Portrait);
    }

    public void print()
    {
       
        PrintPageHeader();
        PrintDetails();
        pp.SaveFile(path);
    }

    
   
    public int pageCounter()
    {
        return pp._pageNumber;
    }

    private void PrintPageHeader()
    {
        pp.gfx.DrawString("Aantal documenten:", pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(0));
        pp.gfx.DrawString(docCount.ToString(), pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0) + 150, pp.GetVerticalPos(0));
        
        pp.gfx.DrawString("Aantal job’s:", pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap));
        jobCount += pp._pageNumber; 
        pp.gfx.DrawString(jobCount.ToString(), pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0) + 150, pp.GetVerticalPos(0));

        pp.gfx.DrawString("Basket naam:", pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap));
        pp.gfx.DrawString(basketName, pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0) + 150, pp.GetVerticalPos(0));

        pp.gfx.DrawString("Lokatie:", pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap));
        pp.gfx.DrawString(baskPath + basketName, pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0) + 150, pp.GetVerticalPos(0));

        pp.gfx.DrawString("Header:", pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap));
        pp.gfx.DrawString(header, pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0) + 150, pp.GetVerticalPos(0));

        pp.gfx.DrawString("Stuklijst:", pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap));
        pp.gfx.DrawString(stuklijst, pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0) + 150, pp.GetVerticalPos(0));

        if (FirstPageOpmerking.Length > 1)
        {
            FirstPageOpmerking = FirstPageOpmerking.Substring(0, FirstPageOpmerking.Length - 1);
            pp.gfx.DrawString("Opmerkingen:", pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap));
            int line_num = pp.PrintMultipleLine(FirstPageOpmerking, pp._normalFont, XBrushes.Black, 350, pp.GetHorizontalPos(0)+150, pp.GetVerticalPos(0), 15, false);
            pp.GetVerticalPos(line_num * pp._lineGap);
        }
        pp.gfx.DrawLine(XPens.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(7), pp.GetHorizontalPos(0)+500, pp.GetVerticalPos(0));
    }

    private void PrintDetails()
    {
        description = description.Replace("@@@@", "*");
        description = description.Replace("@@", "@");
        string[] rows = description.Split('*');
        
        string page = "page";
        if (pp._pageNumber > 1) page = "pages";
        pp.gfx.DrawString("Kopblad", pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap + 5));
        pp.gfx.DrawString(pp._pageNumber + " " + page, pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0) + 150, pp.GetVerticalPos(0));
        
        
        foreach (string myRow in rows)
        {
            string[] cols = myRow.Split('@');
             page = "page";
            if (Convert.ToInt16(cols[1]) > 1) page = "pages";
            pp.gfx.DrawString(cols[0], pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0), pp.GetVerticalPos(pp._lineGap + 5));
            pp.gfx.DrawString(cols[1] +" "+page, pp._normalFont, XBrushes.Black, pp.GetHorizontalPos(0) + 150, pp.GetVerticalPos(0));
           

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
           
        }

    }
}