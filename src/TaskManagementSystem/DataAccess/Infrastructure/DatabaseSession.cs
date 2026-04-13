using System;
using System.Configuration;
using System.Data.SqlClient;

namespace DataAccess.Infrastructure
{
    public static class DatabaseSession
    {
        public static SqlConnection CreateConnection()
        {
            ConnectionStringSettings connectionString = ConfigurationManager.ConnectionStrings["TaskManagementDb"];

            if (connectionString == null || string.IsNullOrWhiteSpace(connectionString.ConnectionString))
            {
                throw new InvalidOperationException("The TaskManagementDb connection string is not configured.");
            }

            return new SqlConnection(connectionString.ConnectionString);
        }
    }
}
