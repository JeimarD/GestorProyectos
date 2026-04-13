using System;
using System.Data;
using System.Data.SqlClient;
using DataAccess.Infrastructure;
using Objects.Entities;

namespace DataAccess.Repositories
{
    public class AuthRepository
    {
        public AuthenticatedUser Login(string userName, string passwordHash)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_User_Login", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserName", userName);
                    command.Parameters.AddWithValue("@PasswordHash", passwordHash);

                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        return new AuthenticatedUser
                        {
                            UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                            RoleId = reader.GetInt32(reader.GetOrdinal("RoleId")),
                            RoleName = reader.GetSafeString("RoleName"),
                            FirstName = reader.GetSafeString("FirstName"),
                            LastName = reader.GetSafeString("LastName"),
                            UserName = reader.GetSafeString("UserName")
                        };
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error validating credentials.", exception);
            }
        }
    }
}
