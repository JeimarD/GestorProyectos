using System;
using System.Web.Script.Services;
using System.Web.Services;
using Logic.Services;
using Objects.Entities;
using Presentation.Helpers;
using Presentation.Models;

namespace Presentation.Pages
{
    public partial class TaskDetails : BasePage
    {
        public override string ActiveNavigationKey { get { return "projects"; } }
        public int TaskId { get; private set; }
        public int ProjectId { get; private set; }
        public string ProjectName { get; private set; }
        public string TaskName { get; private set; }
        public string TaskStatus { get; private set; }
        public string TaskStatusClass { get; private set; }
        public string AssignedUserName { get; private set; }
        public string StartDateText { get; private set; }
        public string EstimatedEndDateText { get; private set; }
        public string Priority { get; private set; }
        public string EstimatedHoursText { get; private set; }
        public string TaskDescription { get; private set; }
        public int Progress { get; private set; }
        public int CommentCount { get; private set; }
        public int AttachmentCount { get; private set; }
        public bool IsTaskCompleted { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthenticatedUser currentUser = CurrentUser;
            int taskId;
            if (!int.TryParse(Request.QueryString["taskId"], out taskId) || taskId <= 0)
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
                return;
            }

            if (!AuthorizationHelper.CanAccessTask(currentUser, taskId))
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
                return;
            }

            TaskService taskService = new TaskService();
            TaskEntity task = taskService.GetTaskById(taskId);
            if (task == null)
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
                return;
            }

            TaskId = task.TaskId;
            ProjectId = task.ProjectId;
            ProjectName = task.ProjectName;
            TaskName = task.Name;
            TaskStatus = task.Status;
            TaskStatusClass = task.Status == "Completado" ? "is-teal" : task.Status == "Bloqueado" ? "is-error" : task.Status == "Planificado" ? "is-secondary" : "is-primary";
            AssignedUserName = task.AssignedUserName;
            StartDateText = task.StartDate.ToString("dd/MM/yyyy");
            EstimatedEndDateText = task.EstimatedEndDate.HasValue ? task.EstimatedEndDate.Value.ToString("dd/MM/yyyy") : "Pendiente";
            Priority = task.Priority;
            EstimatedHoursText = task.EstimatedHours.HasValue ? task.EstimatedHours.Value.ToString("0.##") + " horas" : "No definido";
            TaskDescription = string.IsNullOrWhiteSpace(task.Description) ? "Sin descripción adicional." : task.Description;
            Progress = task.Progress;
            CommentCount = task.CommentCount;
            AttachmentCount = task.AttachmentCount;
            IsTaskCompleted = task.Status == "Completado";
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetDetailData(int taskId)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanAccessTask(taskId);
                TaskService taskService = new TaskService();
                return new AjaxResponse { Success = true, Data = new { Comments = taskService.GetComments(taskId), Attachments = taskService.GetAttachments(taskId) } };
            }
            catch (Exception exception)
            {
                return new AjaxResponse { Success = false, Message = exception.Message, RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse SaveComment(TaskCommentEntity comment)
        {
            try
            {
                AuthenticatedUser currentUser = WebMethodSessionValidator.RequireUser();
                TaskService taskService = new TaskService();
                comment.UserId = currentUser.UserId;
                TaskEntity relatedTask = taskService.GetTaskById(comment.TaskId);
                if (relatedTask == null)
                {
                    return new AjaxResponse { Success = false, Message = "La tarea seleccionada no existe." };
                }

                AuthorizationHelper.EnsureCanAccessProject(currentUser, relatedTask.ProjectId);
                var result = taskService.SaveComment(comment);
                if (result.Success)
                {
                    ActivityLogWriter.LogTaskCommentSaved(currentUser, relatedTask, true);
                }
                return new AjaxResponse { Success = result.Success, Message = result.Message, Data = result };
            }
            catch (Exception exception)
            {
                return new AjaxResponse { Success = false, Message = exception.Message, RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse MarkTaskAsCompleted(int taskId)
        {
            try
            {
                AuthenticatedUser currentUser = WebMethodSessionValidator.RequireUserCanAccessTask(taskId);
                TaskService taskService = new TaskService();
                TaskEntity task = taskService.GetTaskById(taskId);

                if (task == null)
                {
                    return new AjaxResponse { Success = false, Message = "La tarea seleccionada no existe." };
                }

                if (task.Status == "Completado")
                {
                    return new AjaxResponse { Success = true, Message = "La tarea ya estaba completada." };
                }

                TaskEntity previousTask = new TaskEntity
                {
                    TaskId = task.TaskId,
                    ProjectId = task.ProjectId,
                    Name = task.Name,
                    Status = task.Status
                };

                task.Status = "Completado";
                task.Progress = 100;

                var result = taskService.SaveTask(task);

                if (result.Success)
                {
                    ActivityLogWriter.LogTaskSaved(currentUser, previousTask, task, true);
                }

                return new AjaxResponse
                {
                    Success = result.Success,
                    Message = result.Message,
                    Data = result
                };
            }
            catch (Exception exception)
            {
                return new AjaxResponse { Success = false, Message = exception.Message, RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse DeleteTask(int taskId)
        {
            try
            {
                AuthenticatedUser currentUser = WebMethodSessionValidator.RequireUserCanAccessTask(taskId);
                TaskService taskService = new TaskService();
                TaskEntity task = taskService.GetTaskById(taskId);

                if (task == null)
                {
                    return new AjaxResponse { Success = false, Message = "La tarea seleccionada no existe." };
                }

                var result = taskService.DeleteTask(taskId);

                if (result.Success)
                {
                    try
                    {
                        ActivityService activityService = new ActivityService();
                        activityService.SaveActivity(new ActivityLogEntity
                        {
                            EntityType = "Task",
                            ActivityType = "Delete",
                            Description = string.Format("Se eliminó la tarea \"{0}\".", task.Name),
                            RelatedProjectId = task.ProjectId,
                            RelatedTaskId = null,
                            PerformedByUserId = currentUser.UserId
                        });
                    }
                    catch
                    {
                    }
                }

                return new AjaxResponse
                {
                    Success = result.Success,
                    Message = result.Message,
                    Data = result
                };
            }
            catch (Exception exception)
            {
                return new AjaxResponse { Success = false, Message = exception.Message, RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null };
            }
        }
    }
}
