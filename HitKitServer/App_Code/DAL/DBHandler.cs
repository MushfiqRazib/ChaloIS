using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Npgsql;

/// <summary>
/// Summary description for DBHandler
/// </summary>
/// 
namespace HITKITServer
{
    public class DBHandler
    {
        public DBHandler()
        {
            //
            // TODO: Add constructor logic here
            //
        }

        public static void InsertCurrentSecurityKey(string userName,string securityId,string timeout)
        {
            string sql = string.Empty;
            string loginStatus = string.Empty;
            DataTable activeMapExtent = new DataTable("securityinfo");
            try
            {
                using (NpgsqlConnection connection = new NpgsqlConnection(ConfigManager.ConnectionString))
                {
                    connection.Open();
                    sql = @"insert into securityinfo(username, securityid,timeout,last_access_time) values(@username, @securityid,@timeout,@now)";
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sql, connection))
                    {
                        cmd.Parameters.Add("username", userName);
                        cmd.Parameters.Add("securityid", securityId);
                        cmd.Parameters.Add("timeout", timeout);
                        cmd.Parameters.Add("now", DateTime.Now);
                        cmd.ExecuteNonQuery();
                    }
                }

            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

        public static bool IsValidCredentials(string userName, string password)
        {
            string sql = string.Empty;
            string loginStatus = string.Empty;
            try
            {
                using (NpgsqlConnection connection = new NpgsqlConnection(ConfigManager.ConnectionString))
                {
                    connection.Open();
                    sql = @"select count(*) from hitcon_users where lower(username) = @username and password=@password;";

                    using (NpgsqlCommand cmd = new NpgsqlCommand(sql, connection))
                    {
                        cmd.Parameters.Add("username", userName.ToLower());
                        cmd.Parameters.Add("password", password);
                        loginStatus = cmd.ExecuteScalar().ToString();
                    }
                }

                return int.Parse(loginStatus) > 0;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

        public static string GetUserRelatedInfo(string userName)
        {
            string sql = string.Empty;
            string timeout;
            try
            {
                using (NpgsqlConnection connection = new NpgsqlConnection(ConfigManager.ConnectionString))
                {
                    connection.Open();
                    sql = @"select  timeout from hitcon_users where lower(username) = @username";

                    using (NpgsqlCommand cmd = new NpgsqlCommand(sql, connection))
                    {
                        cmd.Parameters.Add("username", userName.ToLower());
                        DataTable dt = new DataTable();
                        NpgsqlDataAdapter adapt = new NpgsqlDataAdapter(cmd);
                        adapt.Fill(dt);
                        timeout = dt.Rows[0][0].ToString();
                    }
                }

                return timeout;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

        public static DataTable GetUserSessionInfo(string securityKey)
        {
            string sql = string.Empty;
            DataTable dt = new DataTable();
            try
            {
                using (NpgsqlConnection connection = new NpgsqlConnection(ConfigManager.ConnectionString))
                {
                    connection.Open();
                    sql = @"select timeout,last_access_time from securityinfo where securityid = @securityKey";

                    using (NpgsqlCommand cmd = new NpgsqlCommand(sql, connection))
                    {
                        cmd.Parameters.Add("securityKey", securityKey);
                        NpgsqlDataAdapter adapt = new NpgsqlDataAdapter(cmd);
                        adapt.Fill(dt);
                    }
                }

                return dt;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

        public static void UpdateLastAccessTime(string securityKey)
        {
            try
            {
                using (NpgsqlConnection connection = new NpgsqlConnection(ConfigManager.ConnectionString))
                {
                    connection.Open();
                    string sql = @"update securityinfo set last_access_time = now() where securityid = @securityKey";

                    using (NpgsqlCommand cmd = new NpgsqlCommand(sql, connection))
                    {
                        cmd.Parameters.Add("securityKey", securityKey);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

        internal static void DeleteSecurityKeyInfo(string securityKey)
        {
            string sql = string.Empty;
            DataTable activeMapExtent = new DataTable("securityinfo");
            try
            {
                using (NpgsqlConnection connection = new NpgsqlConnection(ConfigManager.ConnectionString))
                {
                    connection.Open();
                    sql = @"delete from securityinfo where securityid = @securityKey;";
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sql, connection))
                    {
                        cmd.Parameters.Add("securityKey", securityKey);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

        internal static DataTable GetAuthentionData(string username)
        {
            string sql = string.Empty;
            DataTable dt = new DataTable();
            try
            {
                using (NpgsqlConnection connection = new NpgsqlConnection(ConfigManager.ConnectionString))
                {
                    connection.Open();
                    sql = @"select  distinct ug.usergroup,aut.authtype,aut.authvalue
                            from hitcon_usergroups ug,hitcon_definition aut
                            where ug.usergroup = aut.usergroup and lower(ug.username) = lower(@username)";

                    using (NpgsqlCommand cmd = new NpgsqlCommand(sql, connection))
                    {
                        cmd.Parameters.Add("username", username);
                        NpgsqlDataAdapter adapt = new NpgsqlDataAdapter(cmd);
                        adapt.Fill(dt);
                    }
                }

                return dt;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }
    }
}
