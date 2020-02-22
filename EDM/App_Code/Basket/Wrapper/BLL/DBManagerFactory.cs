using System;
using HIT.OB.STD.Basket.DAL;

/// <summary>
/// Summary description for DBManaFactory
/// </summary>
/// 
namespace HIT.OB.STD.Basket.BLL
{
    public class DBManagerFactory
    {

        public IBasketFunctions GetDBManager()
        {
            string activeDatabase = HIT.OB.STD.Wrapper.DAL.ConfigManager.GetActiveDatabase();
            switch (activeDatabase)
            {
                case "postgres":
                    return new PostgresDBManager();
                    break;
                case "oracle":
                    return new OracleDBManager();
                    break;
                case "mysql":
                    return new MySqlDBManager();
                    break;
                case "mssql":
                    return new MSSqlDBManager();
                    break;
            }
        
            throw new Exception("No suitable Manager found !!");
        }

    }
}
