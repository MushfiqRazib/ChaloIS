using System;
using System.Data;
using Npgsql;
using System.Configuration;
using HIT.OB.STD.Core;
using System.Text;
using System.Text.RegularExpressions;

/// <summary>
/// Summary description for PostgresDBHandler
/// </summary>

namespace HIT.OB.STD.Basket.DAL
{
    public class PostgresDBManager : IBasketFunctions
    {
        private static string ConnectionString
        {
            get { return HIT.OB.STD.Wrapper.DAL.ConfigManager.GetConnectionString(); }
        }

        public DataTable GetReportRelationName(string reportCode)
        {
            try
            {
                string query = "select sql_from from " + HIT.OB.STD.Wrapper.DAL.ConfigManager.GetReportTableName() + " where upper(report_code) ='" + reportCode.ToUpper() + "'";
                LogWriter.WriteLog(query);
                DataTable dtReportArgs = GetDataTable(query);
                return dtReportArgs;
            }
            catch (Exception)
            {
                throw;
            }
        }


        public DataTable GetDataTable(string query)
        {
            DataTable dataTable = new DataTable();
            try
            {
                using (NpgsqlConnection dbConnection = new NpgsqlConnection(ConnectionString))
                {
                    NpgsqlDataAdapter adapter = new NpgsqlDataAdapter();
                    adapter.SelectCommand = new NpgsqlCommand(query, dbConnection);
                    adapter.Fill(dataTable);
                }
            }
            catch (Exception ex)
            {
                throw new Exception("From GetDataTable method:" + ex.Message);
            }
            return dataTable;
        }




    }
}
