using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using DataAccess.Infrastructure;
using Objects.Entities;
using Objects.Filters;
using Objects.Responses;

namespace DataAccess.Repositories
{
    public class UserRepository
    {
        public IList<UserEntity> GetUsers(UserFilter filter)
        {
            IList<UserEntity> users = new List<UserEntity>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_User_List", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@FirstName", (object)filter.FirstName ?? DBNull.Value);
                    command.Parameters.AddWithValue("@LastName", (object)filter.LastName ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Identification", (object)filter.Identification ?? DBNull.Value);
                    command.Parameters.AddWithValue("@RoleId", (object)filter.RoleId ?? DBNull.Value);

                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            users.Add(new UserEntity
                            {
                                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                                RoleId = reader.GetInt32(reader.GetOrdinal("RoleId")),
                                RoleName = reader.GetSafeString("RoleName"),
                                GenderId = reader.GetInt32(reader.GetOrdinal("GenderId")),
                                GenderName = reader.GetSafeString("GenderName"),
                                MaritalStatusId = reader.GetInt32(reader.GetOrdinal("MaritalStatusId")),
                                MaritalStatusName = reader.GetSafeString("MaritalStatusName"),
                                FirstName = reader.GetSafeString("FirstName"),
                                LastName = reader.GetSafeString("LastName"),
                                Identification = reader.GetSafeString("Identification"),
                                BirthDate = reader.GetDateTime(reader.GetOrdinal("BirthDate")),
                                UserName = reader.GetSafeString("UserName"),
                                IsActive = reader.GetSafeBoolean("IsActive")
                            });
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading users.", exception);
            }

            return users;
        }

        public OperationResult SaveUser(UserEntity user)
        {
            string procedureName = user.UserId == 0 ? "dbo.usp_User_Create" : "dbo.usp_User_Update";

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand(procedureName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@RoleId", user.RoleId);
                    command.Parameters.AddWithValue("@GenderId", user.GenderId);
                    command.Parameters.AddWithValue("@MaritalStatusId", user.MaritalStatusId);
                    command.Parameters.AddWithValue("@FirstName", user.FirstName);
                    command.Parameters.AddWithValue("@LastName", user.LastName);
                    command.Parameters.AddWithValue("@Identification", user.Identification);
                    command.Parameters.AddWithValue("@BirthDate", user.BirthDate);
                    command.Parameters.AddWithValue("@UserName", user.UserName);

                    if (user.UserId == 0)
                    {
                        command.Parameters.AddWithValue("@PasswordHash", user.PasswordHash);
                    }
                    else
                    {
                        command.Parameters.AddWithValue("@UserId", user.UserId);
                        command.Parameters.AddWithValue("@PasswordHash", (object)user.PasswordHash ?? DBNull.Value);
                        command.Parameters.AddWithValue("@IsActive", user.IsActive);
                    }

                    connection.Open();

                    int? newId = null;
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        newId = Convert.ToInt32(result);
                    }

                    return new OperationResult
                    {
                        Success = true,
                        Message = user.UserId == 0 ? "Usuario creado correctamente." : "Usuario actualizado correctamente.",
                        NewId = newId
                    };
                }
            }
            catch (SqlException exception)
            {
                return new OperationResult
                {
                    Success = false,
                    Message = exception.Number == 2627 ? "El usuario o la cédula ya existen." : "No fue posible guardar el usuario."
                };
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error saving user.", exception);
            }
        }

        public OperationResult DeleteUser(int userId)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_User_Delete", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserId", userId);

                    connection.Open();
                    command.ExecuteNonQuery();
                }

                return new OperationResult
                {
                    Success = true,
                    Message = "Usuario desactivado correctamente."
                };
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error deleting user.", exception);
            }
        }
    }
}
