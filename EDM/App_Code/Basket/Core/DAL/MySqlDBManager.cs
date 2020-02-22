using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.Collections;

/// <summary>
/// Summary description for PostgresDBHandler
/// </summary>

namespace HIT.OB.STD.Basket.Core.DAL
{
    public class MySqlDBManager : IBasketFunctions
    {

        private string connectionString;

        public MySqlDBManager(string conString)
        {
            this.connectionString = conString;
        }

        private string ConnectionString
        {
            get { return connectionString; }
            set { connectionString = value; }
        }

        public DataTable GetReportData(string sql_from, string whereClause)
        {
            string query = "SELECT * FROM " + sql_from + " WHERE " + whereClause;
            DataTable dt = GetDataTable(query);
            return dt;
        }
        
        public DataTable GetDataTable(string query)
        {
            DataTable dataTable = new DataTable();
            try
            {
                using (MySqlConnection dbConnection = new MySqlConnection(ConnectionString))
                {
                    MySqlDataAdapter adapter = new MySqlDataAdapter();
                    adapter.SelectCommand = new MySqlCommand(query, dbConnection);
                    adapter.Fill(dataTable);
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dataTable;
        }

        public ArrayList GetFieldList(DataTable dt)
        {
            ArrayList FieldList = new ArrayList();
            for (int k = 0; k < dt.Columns.Count; k++)
            {
                FieldList.Add(dt.Columns[k].ColumnName);
            }
            return FieldList;
        }

    }

}
