using System;
using System.Data;
using System.Data.OleDb;

namespace HIT.OB.STD.RC.Wrapper
{
    /// <summary>
    /// Summary description for OLEDB
    /// </summary>
    public class OLEDB
    {
        public static DataTable GetDataTableFromExcel(string xlsFile, string sheetName)
        {
            string strConnectionString = string.Empty;
            strConnectionString = @"Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + xlsFile 
                + @";Extended Properties=""Excel 8.0;HDR=Yes;IMEX=1""";
            OleDbConnection cnCSV = new OleDbConnection(strConnectionString);
            DataTable dtCSV = new DataTable();
            try
            {
                cnCSV.Open();
                OleDbCommand cmdSelect = new OleDbCommand(@"SELECT * FROM [" + sheetName + "$]", cnCSV);
                OleDbDataAdapter daCSV = new OleDbDataAdapter();
                daCSV.SelectCommand = cmdSelect;

                daCSV.Fill(dtCSV);
                cnCSV.Close();
                daCSV = null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cnCSV.Close();
            }
            return dtCSV;
        }
    }
}