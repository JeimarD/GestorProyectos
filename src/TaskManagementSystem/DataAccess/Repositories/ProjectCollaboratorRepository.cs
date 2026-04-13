using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using DataAccess.Infrastructure;
using Objects.Entities;

namespace DataAccess.Repositories
{
    public class ProjectCollaboratorRepository
    {
        public IList<int> GetProjectIdsByUser(int userId)
        {
            List<int> projectIds = new List<int>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("SELECT ProjectId FROM dbo.ProjectCollaborators WHERE UserId = @UserId;", connection))
                {
                    command.Parameters.AddWithValue("@UserId", userId);
                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            projectIds.Add(reader.GetInt32(0));
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading project collaborators.", exception);
            }

            return projectIds;
        }

        public bool IsUserCollaborator(int projectId, int userId)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("SELECT COUNT(1) FROM dbo.ProjectCollaborators WHERE ProjectId = @ProjectId AND UserId = @UserId;", connection))
                {
                    command.Parameters.AddWithValue("@ProjectId", projectId);
                    command.Parameters.AddWithValue("@UserId", userId);
                    connection.Open();
                    return Convert.ToInt32(command.ExecuteScalar()) > 0;
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error validating project collaborator.", exception);
            }
        }

        public IList<ProjectCollaboratorEntity> GetCollaboratorsByProject(int projectId)
        {
            List<ProjectCollaboratorEntity> collaborators = new List<ProjectCollaboratorEntity>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("SELECT pc.ProjectId, pc.UserId, u.UserName, (u.FirstName + ' ' + u.LastName) AS FullName, r.Name AS RoleName FROM dbo.ProjectCollaborators pc INNER JOIN dbo.Users u ON u.UserId = pc.UserId INNER JOIN dbo.Roles r ON r.RoleId = u.RoleId WHERE pc.ProjectId = @ProjectId AND u.IsActive = 1 ORDER BY u.FirstName, u.LastName;", connection))
                {
                    command.Parameters.AddWithValue("@ProjectId", projectId);
                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            collaborators.Add(new ProjectCollaboratorEntity
                            {
                                ProjectId = reader.GetInt32(reader.GetOrdinal("ProjectId")),
                                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                                UserName = reader.GetSafeString("UserName"),
                                FullName = reader.GetSafeString("FullName"),
                                RoleName = reader.GetSafeString("RoleName")
                            });
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading collaborators by project.", exception);
            }

            return collaborators;
        }

        public void SaveProjectCollaborators(int projectId, IList<int> userIds)
        {
            userIds = userIds ?? new List<int>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                {
                    connection.Open();

                    using (SqlTransaction transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            using (SqlCommand deleteCommand = new SqlCommand("DELETE FROM dbo.ProjectCollaborators WHERE ProjectId = @ProjectId;", connection, transaction))
                            {
                                deleteCommand.Parameters.AddWithValue("@ProjectId", projectId);
                                deleteCommand.ExecuteNonQuery();
                            }

                            foreach (int userId in userIds)
                            {
                                using (SqlCommand insertCommand = new SqlCommand("INSERT INTO dbo.ProjectCollaborators (ProjectId, UserId) VALUES (@ProjectId, @UserId);", connection, transaction))
                                {
                                    insertCommand.Parameters.AddWithValue("@ProjectId", projectId);
                                    insertCommand.Parameters.AddWithValue("@UserId", userId);
                                    insertCommand.ExecuteNonQuery();
                                }
                            }

                            transaction.Commit();
                        }
                        catch
                        {
                            transaction.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error saving project collaborators.", exception);
            }
        }
    }
}
