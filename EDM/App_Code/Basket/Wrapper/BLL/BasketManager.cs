using System.Data;
using System.Text;
using HIT.OB.STD.Basket.DAL;
using System;
using HIT.OB.STD.Core.DAL;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
/// <summary>
/// Summary description for DBManaFactory
/// </summary>
/// 
namespace HIT.OB.STD.Basket.BLL
{
    public class BasketManager
    {

        public BasketManager(string activeDb)
        {

        }
        public static string GetReportRelationName(string reportCode)
        {
            DBManagerFactory dbManagerFactory = new DBManagerFactory();
            IBasketFunctions ibasketFunctions = dbManagerFactory.GetDBManager();
            DataTable dtReportInfo = ibasketFunctions.GetReportRelationName(reportCode);
            string sqlFrom = string.Empty;
            if (dtReportInfo.Rows.Count > 0)
            {
                DataRow reportInfoRow = dtReportInfo.Rows[0];                
                sqlFrom = reportInfoRow["sql_from"].ToString();
            }
            
            dtReportInfo.Dispose();

            return sqlFrom;
        }


    }

}

