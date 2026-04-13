using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using DataAccess.Infrastructure;
using Objects.Entities;

namespace DataAccess.Repositories
{
    public class ActivityRepository
    {
        public void SaveActivity(ActivityLogEntity activity)
        {
            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_ActivityLog_Create", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@EntityType", activity.EntityType);
                    command.Parameters.AddWithValue("@ActivityType", activity.ActivityType);
                    command.Parameters.AddWithValue("@Description", activity.Description);
                    command.Parameters.AddWithValue("@RelatedProjectId", (object)activity.RelatedProjectId ?? DBNull.Value);
                    command.Parameters.AddWithValue("@RelatedTaskId", (object)activity.RelatedTaskId ?? DBNull.Value);
                    command.Parameters.AddWithValue("@PerformedByUserId", (object)activity.PerformedByUserId ?? DBNull.Value);
                    connection.Open();
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error saving activity record.", exception);
            }
        }

        public IList<ActivityLogEntity> GetRecentActivities(int maxRows)
        {
            IList<ActivityLogEntity> activities = new List<ActivityLogEntity>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand("dbo.usp_ActivityLog_ListRecent", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@MaxRows", maxRows);
                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            activities.Add(new ActivityLogEntity
                            {
                                ActivityId = reader.GetInt32(reader.GetOrdinal("ActivityId")),
                                EntityType = reader.GetSafeString("EntityType"),
                                ActivityType = reader.GetSafeString("ActivityType"),
                                Description = reader.GetSafeString("Description"),
                                RelatedProjectId = reader.GetSafeInt32("RelatedProjectId"),
                                RelatedTaskId = reader.GetSafeInt32("RelatedTaskId"),
                                PerformedByUserId = reader.GetSafeInt32("PerformedByUserId"),
                                PerformedByName = reader.GetSafeString("PerformedByName"),
                                CreatedAt = reader.GetUtcDateTime("CreatedAt")
                            });
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading activity records.", exception);
            }

            return activities;
        }
    }
}
