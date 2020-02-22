using System;
using HIT.OB.STD.Basket.Core.DAL;

/// <summary>
/// Summary description for DBManaFactory
/// </summary>
/// 
namespace HIT.OB.STD.Basket.Core.BLL
{
    public class DBManagerFactory
    {
        public IBasketFunctions GetDBManager(string reportCode)
        {
            string activeDatabase;
            HIT.OB.STD.Wrapper.BLL.DBManagerFactory dbManagerFactory = new HIT.OB.STD.Wrapper.BLL.DBManagerFactory();
            HIT.OB.STD.Wrapper.DAL.IWrapFunctions iWrapFunctions = dbManagerFactory.GetDBManager();

            string conString = iWrapFunctions.GetConnectionStringForReport(reportCode);
            if (conString.Equals(string.Empty))
            {
                activeDatabase = HIT.OB.STD.Core.DAL.ConfigManager.GetActiveDatabase();
                conString = HIT.OB.STD.Core.DAL.ConfigManager.GetConnectionString();
            }
            else
            {
                activeDatabase = HIT.OB.STD.Core.DAL.ConfigManager.GetActiveDatabase(conString);
            }
            
            switch (activeDatabase)
            {
                case "postgres":
                    return new PostgresDBManager(conString);
                    break;
                case "oracle":
                    //return new OracleDBManager(conString);
                    break;
                case "mysql":
                    //return new MySqlDBManager(conString);
                    break;
                case "mssql":
                    //return new MSSqlDBManager(conString);
                    break;
            }
        
            throw new Exception("No suitable Manager found !!");
        }

    }
}
