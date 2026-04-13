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
    public class TaskRepository
    {
        public TaskEntity GetTaskById(int taskId)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_Task_GetById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TaskId", taskId);
                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        return new TaskEntity
                        {
                            TaskId = reader.GetInt32(reader.GetOrdinal("TaskId")),
                            ProjectId = reader.GetInt32(reader.GetOrdinal("ProjectId")),
                            ProjectName = reader.GetSafeString("ProjectName"),
                            AssignedUserId = reader.GetSafeInt32("AssignedUserId"),
                            AssignedUserName = reader.GetSafeString("AssignedUserName"),
                            CreatedByUserId = reader.GetSafeInt32("CreatedByUserId"),
                            Name = reader.GetSafeString("Name"),
                            Description = reader.GetSafeString("Description"),
                            Status = reader.GetSafeString("Status"),
                            Priority = reader.GetSafeString("Priority"),
                            StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                            Progress = reader.GetInt32(reader.GetOrdinal("Progress")),
                            EstimatedHours = reader.IsDBNull(reader.GetOrdinal("EstimatedHours")) ? (decimal?)null : reader.GetDecimal(reader.GetOrdinal("EstimatedHours")),
                            EstimatedEndDate = reader.GetSafeDateTime("EstimatedEndDate"),
                            CommentCount = reader.GetInt32(reader.GetOrdinal("CommentCount")),
                            AttachmentCount = reader.GetInt32(reader.GetOrdinal("AttachmentCount")),
                            CreatedAt = reader.GetUtcDateTime("CreatedAt")
                        };
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading task detail.", exception);
            }
        }

        public IList<TaskEntity> GetTasks(TaskFilter filter)
        {
            IList<TaskEntity> tasks = new List<TaskEntity>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_Task_List", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Name", (object)filter.Name ?? DBNull.Value);
                    command.Parameters.AddWithValue("@ProjectId", (object)filter.ProjectId ?? DBNull.Value);
                    command.Parameters.AddWithValue("@AssignedUserId", (object)filter.AssignedUserId ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Status", (object)filter.Status ?? DBNull.Value);

                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            tasks.Add(new TaskEntity
                            {
                                TaskId = reader.GetInt32(reader.GetOrdinal("TaskId")),
                                ProjectId = reader.GetInt32(reader.GetOrdinal("ProjectId")),
                                ProjectName = reader.GetSafeString("ProjectName"),
                                AssignedUserId = reader.GetSafeInt32("AssignedUserId"),
                                AssignedUserName = reader.GetSafeString("AssignedUserName"),
                                CreatedByUserId = reader.GetSafeInt32("CreatedByUserId"),
                                Name = reader.GetSafeString("Name"),
                                Description = reader.GetSafeString("Description"),
                                Status = reader.GetSafeString("Status"),
                                Priority = reader.GetSafeString("Priority"),
                                StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                Progress = reader.GetInt32(reader.GetOrdinal("Progress")),
                                EstimatedHours = reader.IsDBNull(reader.GetOrdinal("EstimatedHours")) ? (decimal?)null : reader.GetDecimal(reader.GetOrdinal("EstimatedHours")),
                                EstimatedEndDate = reader.GetSafeDateTime("EstimatedEndDate"),
                                CommentCount = reader.GetInt32(reader.GetOrdinal("CommentCount")),
                                AttachmentCount = reader.GetInt32(reader.GetOrdinal("AttachmentCount")),
                                CreatedAt = reader.GetUtcDateTime("CreatedAt")
                            });
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading tasks.", exception);
            }

            return tasks;
        }

        public OperationResult SaveTask(TaskEntity task)
        {
            string procedureName = task.TaskId == 0 ? "dbo.usp_Task_Create" : "dbo.usp_Task_Update";

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand(procedureName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    if (task.TaskId != 0)
                    {
                        command.Parameters.AddWithValue("@TaskId", task.TaskId);
                    }

                    command.Parameters.AddWithValue("@ProjectId", task.ProjectId);
                    command.Parameters.AddWithValue("@AssignedUserId", (object)task.AssignedUserId ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Name", task.Name);
                    command.Parameters.AddWithValue("@Description", (object)task.Description ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Status", task.Status);
                    command.Parameters.AddWithValue("@Priority", task.Priority);
                    command.Parameters.AddWithValue("@StartDate", task.StartDate);
                    command.Parameters.AddWithValue("@Progress", task.Progress);
                    command.Parameters.AddWithValue("@EstimatedHours", (object)task.EstimatedHours ?? DBNull.Value);
                    command.Parameters.AddWithValue("@EstimatedEndDate", (object)task.EstimatedEndDate ?? DBNull.Value);

                    if (task.TaskId == 0)
                    {
                        command.Parameters.AddWithValue("@CreatedByUserId", (object)task.CreatedByUserId ?? DBNull.Value);
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
                        Message = task.TaskId == 0 ? "Tarea creada correctamente." : "Tarea actualizada correctamente.",
                        NewId = newId
                    };
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error saving task.", exception);
            }
        }

        public OperationResult DeleteTask(int taskId)
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
                            using (SqlCommand command = new SqlCommand("IF OBJECT_ID('dbo.ActivityLog', 'U') IS NOT NULL DELETE FROM dbo.ActivityLog WHERE RelatedTaskId = @TaskId; DELETE FROM dbo.TaskAttachments WHERE TaskId = @TaskId; DELETE FROM dbo.TaskComments WHERE TaskId = @TaskId; DELETE FROM dbo.Tasks WHERE TaskId = @TaskId;", connection, transaction))
                            {
                                command.Parameters.AddWithValue("@TaskId", taskId);
                                command.ExecuteNonQuery();
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

                return new OperationResult
                {
                    Success = true,
                    Message = "Tarea eliminada correctamente."
                };
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error deleting task.", exception);
            }
        }

        public IList<TaskCommentEntity> GetComments(int taskId)
        {
            IList<TaskCommentEntity> comments = new List<TaskCommentEntity>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_TaskComment_List", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TaskId", taskId);

                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            comments.Add(new TaskCommentEntity
                            {
                                CommentId = reader.GetInt32(reader.GetOrdinal("CommentId")),
                                TaskId = reader.GetInt32(reader.GetOrdinal("TaskId")),
                                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                                UserName = reader.GetSafeString("UserName"),
                                CommentText = reader.GetSafeString("CommentText"),
                                CreatedAt = reader.GetUtcDateTime("CreatedAt")
                            });
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading comments.", exception);
            }

            return comments;
        }

        public OperationResult SaveComment(TaskCommentEntity comment)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_TaskComment_Create", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TaskId", comment.TaskId);
                    command.Parameters.AddWithValue("@UserId", comment.UserId);
                    command.Parameters.AddWithValue("@CommentText", comment.CommentText);

                    connection.Open();
                    int newId = Convert.ToInt32(command.ExecuteScalar());

                    return new OperationResult
                    {
                        Success = true,
                        Message = "Comentario registrado correctamente.",
                        NewId = newId
                    };
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error saving comment.", exception);
            }
        }

        public TaskAttachmentEntity GetAttachmentById(int attachmentId)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_TaskAttachment_GetById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@AttachmentId", attachmentId);
                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        return new TaskAttachmentEntity
                        {
                            AttachmentId = reader.GetInt32(reader.GetOrdinal("AttachmentId")),
                            TaskId = reader.GetInt32(reader.GetOrdinal("TaskId")),
                            FileName = reader.GetSafeString("FileName"),
                            FilePath = reader.GetSafeString("FilePath"),
                            UploadedByUserId = reader.GetSafeInt32("UploadedByUserId"),
                            UploadedAt = reader.GetUtcDateTime("UploadedAt")
                        };
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading attachment detail.", exception);
            }
        }

        public OperationResult SaveAttachment(TaskAttachmentEntity attachment)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_TaskAttachment_Create", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TaskId", attachment.TaskId);
                    command.Parameters.AddWithValue("@FileName", attachment.FileName);
                    command.Parameters.AddWithValue("@FilePath", attachment.FilePath);
                    command.Parameters.AddWithValue("@UploadedByUserId", (object)attachment.UploadedByUserId ?? DBNull.Value);

                    connection.Open();
                    int newId = Convert.ToInt32(command.ExecuteScalar());

                    return new OperationResult
                    {
                        Success = true,
                        Message = "Adjunto cargado correctamente.",
                        NewId = newId
                    };
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error saving attachment.", exception);
            }
        }

        public IList<TaskAttachmentEntity> GetAttachments(int taskId)
        {
            IList<TaskAttachmentEntity> attachments = new List<TaskAttachmentEntity>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_TaskAttachment_List", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TaskId", taskId);
                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            attachments.Add(new TaskAttachmentEntity
                            {
                                AttachmentId = reader.GetInt32(reader.GetOrdinal("AttachmentId")),
                                TaskId = reader.GetInt32(reader.GetOrdinal("TaskId")),
                                FileName = reader.GetSafeString("FileName"),
                                FilePath = reader.GetSafeString("FilePath"),
                                UploadedByUserId = reader.GetSafeInt32("UploadedByUserId"),
                                UploadedAt = reader.GetUtcDateTime("UploadedAt")
                            });
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading attachments.", exception);
            }

            return attachments;
        }
    }
}
