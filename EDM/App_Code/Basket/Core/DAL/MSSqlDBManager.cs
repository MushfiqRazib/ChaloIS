using System;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Collections;
using System.Text.RegularExpressions;

/// <summary>
/// Summary description for PostgresDBHandler
/// </summary>

namespace HIT.OB.STD.Basket.Core.DAL
{
    public class MSSqlDBManager : IBasketFunctions
    {

        private string connectionString;

        public MSSqlDBManager(string conString)
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

        public ArrayList GetFieldList(DataTable dt)
        {
            ArrayList FieldList = new ArrayList();
            for (int k = 0; k < dt.Columns.Count; k++)
            {
                FieldList.Add(dt.Columns[k].ColumnName);
            }
            return FieldList;
        }
        
        public DataTable GetDataTable(string query)
        {
            DataTable dataTable = new DataTable();
            try
            {
                using (SqlConnection dbConnection = new SqlConnection(ConnectionString))
                {
                    SqlDataAdapter adapter = new SqlDataAdapter();
                    adapter.SelectCommand = new SqlCommand(query, dbConnection);
                    adapter.Fill(dataTable);
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dataTable;
        }


    }

}
