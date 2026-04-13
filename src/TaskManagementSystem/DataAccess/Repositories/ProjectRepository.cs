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
    public class ProjectRepository
    {
        public ProjectEntity GetProjectById(int projectId)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_Project_GetById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@ProjectId", projectId);
                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        return new ProjectEntity
                        {
                            ProjectId = reader.GetInt32(reader.GetOrdinal("ProjectId")),
                            Name = reader.GetSafeString("Name"),
                            ClientName = reader.GetSafeString("ClientName"),
                            Description = reader.GetSafeString("Description"),
                            StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                            EndDate = reader.GetSafeDateTime("EndDate"),
                            Status = reader.GetSafeString("Status"),
                            Priority = reader.GetSafeString("Priority"),
                            Progress = reader.GetInt32(reader.GetOrdinal("Progress")),
                            CreatedByUserId = reader.GetSafeInt32("CreatedByUserId"),
                            CreatedByName = reader.GetSafeString("CreatedByName")
                        };
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading project detail.", exception);
            }
        }

        public IList<ProjectEntity> GetProjects(ProjectFilter filter)
        {
            IList<ProjectEntity> projects = new List<ProjectEntity>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_Project_List", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Name", (object)filter.Name ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Status", (object)filter.Status ?? DBNull.Value);

                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            projects.Add(new ProjectEntity
                            {
                                ProjectId = reader.GetInt32(reader.GetOrdinal("ProjectId")),
                                Name = reader.GetSafeString("Name"),
                                ClientName = reader.GetSafeString("ClientName"),
                                Description = reader.GetSafeString("Description"),
                                StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                EndDate = reader.GetSafeDateTime("EndDate"),
                                Status = reader.GetSafeString("Status"),
                                Priority = reader.GetSafeString("Priority"),
                                Progress = reader.GetInt32(reader.GetOrdinal("Progress")),
                                CreatedByUserId = reader.GetSafeInt32("CreatedByUserId"),
                                CreatedByName = reader.GetSafeString("CreatedByName")
                            });
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading projects.", exception);
            }

            return projects;
        }

        public OperationResult SaveProject(ProjectEntity project)
        {
            string procedureName = project.ProjectId == 0 ? "dbo.usp_Project_Create" : "dbo.usp_Project_Update";

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand(procedureName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    if (project.ProjectId != 0)
                    {
                        command.Parameters.AddWithValue("@ProjectId", project.ProjectId);
                    }

                    command.Parameters.AddWithValue("@Name", project.Name);
                    command.Parameters.AddWithValue("@ClientName", project.ClientName);
                    command.Parameters.AddWithValue("@Description", (object)project.Description ?? DBNull.Value);
                    command.Parameters.AddWithValue("@StartDate", project.StartDate);
                    command.Parameters.AddWithValue("@EndDate", (object)project.EndDate ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Status", project.Status);
                    command.Parameters.AddWithValue("@Priority", project.Priority);

                    if (project.ProjectId == 0)
                    {
                        command.Parameters.AddWithValue("@CreatedByUserId", (object)project.CreatedByUserId ?? DBNull.Value);
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
                        Message = project.ProjectId == 0 ? "Proyecto creado correctamente." : "Proyecto actualizado correctamente.",
                        NewId = newId
                    };
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error saving project.", exception);
            }
        }

        public OperationResult DeleteProject(int projectId)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                {
                    connection.Open();
                    using (SqlTransaction transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            int relatedTaskCount;
                            using (SqlCommand validateCommand = new SqlCommand("SELECT COUNT(1) FROM dbo.Tasks WHERE ProjectId = @ProjectId;", connection, transaction))
                            {
                                validateCommand.Parameters.AddWithValue("@ProjectId", projectId);
                                relatedTaskCount = Convert.ToInt32(validateCommand.ExecuteScalar());
                            }

                            if (relatedTaskCount > 0)
                            {
                                transaction.Commit();
                                return new OperationResult
                                {
                                    Success = false,
                                    Message = "No se puede eliminar un proyecto con tareas asociadas."
                                };
                            }

                            using (SqlCommand cleanupActivityCommand = new SqlCommand("IF OBJECT_ID('dbo.ActivityLog', 'U') IS NOT NULL DELETE FROM dbo.ActivityLog WHERE RelatedProjectId = @ProjectId; IF OBJECT_ID('dbo.ProjectCollaborators', 'U') IS NOT NULL DELETE FROM dbo.ProjectCollaborators WHERE ProjectId = @ProjectId;", connection, transaction))
                            {
                                cleanupActivityCommand.Parameters.AddWithValue("@ProjectId", projectId);
                                cleanupActivityCommand.ExecuteNonQuery();
                            }

                            int affectedRows;
                            using (SqlCommand deleteCommand = new SqlCommand("DELETE FROM dbo.Projects WHERE ProjectId = @ProjectId;", connection, transaction))
                            {
                                deleteCommand.Parameters.AddWithValue("@ProjectId", projectId);
                                affectedRows = deleteCommand.ExecuteNonQuery();
                            }

                            transaction.Commit();

                            return new OperationResult
                            {
                                Success = affectedRows > 0,
                                Message = affectedRows > 0
                                    ? "Proyecto eliminado correctamente."
                                    : "No se encontró el proyecto a eliminar."
                            };
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
                throw new ApplicationException("Error deleting project.", exception);
            }
        }
    }
}
