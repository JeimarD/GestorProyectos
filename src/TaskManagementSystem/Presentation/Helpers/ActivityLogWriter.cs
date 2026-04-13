using System;
using Logic.Services;
using Objects.Entities;

namespace Presentation.Helpers
{
    public static class ActivityLogWriter
    {
        public static void LogProjectSaved(AuthenticatedUser actor, ProjectEntity previousProject, ProjectEntity currentProject, bool saveSucceeded)
        {
            if (!saveSucceeded || currentProject == null)
            {
                return;
            }

            string description;
            string activityType;

            if (previousProject == null)
            {
                activityType = "Create";
                description = string.Format("Se creó el proyecto \"{0}\".", currentProject.Name);
            }
            else if (!string.Equals(previousProject.Status, currentProject.Status, StringComparison.OrdinalIgnoreCase))
            {
                activityType = "StatusChange";
                description = string.Format("Se cambió el estado del proyecto \"{0}\" de \"{1}\" a \"{2}\".", currentProject.Name, previousProject.Status, currentProject.Status);
            }
            else
            {
                activityType = "Update";
                description = string.Format("Se actualizó el proyecto \"{0}\".", currentProject.Name);
            }

            SaveActivity(actor, "Project", activityType, description, currentProject.ProjectId, null);
        }

        public static void LogTaskSaved(AuthenticatedUser actor, TaskEntity previousTask, TaskEntity currentTask, bool saveSucceeded)
        {
            if (!saveSucceeded || currentTask == null)
            {
                return;
            }

            string description;
            string activityType;

            if (previousTask == null)
            {
                activityType = "Create";
                description = string.Format("Se creó la tarea \"{0}\".", currentTask.Name);
            }
            else if (!string.Equals(previousTask.Status, currentTask.Status, StringComparison.OrdinalIgnoreCase))
            {
                activityType = "StatusChange";
                description = string.Format("La tarea \"{0}\" cambió de estado de \"{1}\" a \"{2}\".", currentTask.Name, previousTask.Status, currentTask.Status);
            }
            else
            {
                activityType = "Update";
                description = string.Format("Se actualizó la tarea \"{0}\".", currentTask.Name);
            }

            SaveActivity(actor, "Task", activityType, description, currentTask.ProjectId, currentTask.TaskId);
        }

        public static void LogTaskCommentSaved(AuthenticatedUser actor, TaskEntity task, bool saveSucceeded)
        {
            if (!saveSucceeded || task == null)
            {
                return;
            }

            string description = string.Format("Se agregó un comentario en la tarea \"{0}\".", task.Name);
            SaveActivity(actor, "TaskComment", "Create", description, task.ProjectId, task.TaskId);
        }

        private static void SaveActivity(AuthenticatedUser actor, string entityType, string activityType, string description, int? relatedProjectId, int? relatedTaskId)
        {
            try
            {
                ActivityService activityService = new ActivityService();
                activityService.SaveActivity(new ActivityLogEntity
                {
                    EntityType = entityType,
                    ActivityType = activityType,
                    Description = description,
                    RelatedProjectId = relatedProjectId,
                    RelatedTaskId = relatedTaskId,
                    PerformedByUserId = actor == null ? (int?)null : actor.UserId
                });
            }
            catch
            {
            }
        }
    }
}
