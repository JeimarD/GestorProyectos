using System;
using System.Collections.Generic;
using System.Web.Script.Services;
using System.Web.Services;
using Logic.Services;
using Objects.Entities;
using Objects.Filters;
using Presentation.Helpers;
using Presentation.Models;

namespace Presentation.Pages
{
    public partial class CreateTask : BasePage
    {
        public override string ActiveNavigationKey { get { return "projects"; } }
        public int EditingTaskId { get; private set; }
        public bool IsEditMode { get; private set; }
        public int SelectedProjectId { get; private set; }
        public string SelectedProjectName { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthenticatedUser currentUser = CurrentUser;
            int taskId;
            if (int.TryParse(Request.QueryString["taskId"], out taskId) && taskId > 0)
            {
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

                EditingTaskId = task.TaskId;
                IsEditMode = true;
                SelectedProjectId = task.ProjectId;
                SelectedProjectName = string.IsNullOrWhiteSpace(task.ProjectName) ? "Proyecto" : task.ProjectName;
            }
            else
            {
                int projectId;
                if (int.TryParse(Request.QueryString["projectId"], out projectId) && projectId > 0)
                {
                    if (!AuthorizationHelper.CanAccessProject(currentUser, projectId))
                    {
                        Response.Redirect("~/Pages/Projects.aspx", true);
                        return;
                    }

                    SelectedProjectId = projectId;
                    ProjectService projectService = new ProjectService();
                    var project = projectService.GetProjectById(projectId);
                    SelectedProjectName = project == null ? "Proyecto" : project.Name;
                }
                else
                {
                    SelectedProjectId = 0;
                    SelectedProjectName = "Proyecto";
                }
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetInitialData(int projectId)
        {
            try
            {
                AuthenticatedUser currentUser = WebMethodSessionValidator.RequireUser();
                ProjectService projectService = new ProjectService();
                ProjectCollaboratorService collaboratorService = new ProjectCollaboratorService();
                IList<ProjectEntity> projects;
                IList<UserEntity> users;

                if (AuthorizationHelper.IsCollaborator(currentUser))
                {
                    IList<int> assignedProjectIds = collaboratorService.GetProjectIdsByUser(currentUser.UserId);
                    IList<ProjectEntity> allProjects = projectService.GetProjects(new ProjectFilter());
                    List<ProjectEntity> visibleProjects = new List<ProjectEntity>();

                    foreach (ProjectEntity project in allProjects)
                    {
                        if (assignedProjectIds.Contains(project.ProjectId))
                        {
                            visibleProjects.Add(project);
                        }
                    }

                    projects = visibleProjects;
                }
                else
                {
                    projects = projectService.GetProjects(new ProjectFilter());
                }

                if (projectId > 0)
                {
                    List<ProjectEntity> selectedProject = new List<ProjectEntity>();
                    foreach (ProjectEntity project in projects)
                    {
                        if (project.ProjectId == projectId)
                        {
                            selectedProject.Add(project);
                            break;
                        }
                    }

                    projects = selectedProject;
                }

                users = BuildResponsibleUsersForProject(projectId, projects, collaboratorService);

                return new AjaxResponse
                {
                    Success = true,
                    Data = new
                    {
                        Projects = projects,
                        Users = users
                    }
                };
            }
            catch (Exception exception)
            {
                return new AjaxResponse
                {
                    Success = false,
                    Message = exception.Message,
                    RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null
                };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse SaveTask(TaskEntity task)
        {
            try
            {
                AuthenticatedUser currentUser = WebMethodSessionValidator.RequireUser();
                AuthorizationHelper.EnsureCanAccessProject(currentUser, task.ProjectId);
                TaskService taskService = new TaskService();
                ProjectCollaboratorService collaboratorService = new ProjectCollaboratorService();
                TaskEntity previousTask = task.TaskId > 0 ? taskService.GetTaskById(task.TaskId) : null;

                if (previousTask != null)
                {
                    AuthorizationHelper.EnsureCanAccessProject(currentUser, previousTask.ProjectId);
                }

                if (task.TaskId == 0)
                {
                    task.CreatedByUserId = currentUser.UserId;
                }

                if (task.AssignedUserId.HasValue && !collaboratorService.IsUserCollaborator(task.ProjectId, task.AssignedUserId.Value))
                {
                    throw new ApplicationException("El responsable seleccionado no está asignado al proyecto.");
                }

                var result = taskService.SaveTask(task);

                if (result.Success)
                {
                    int taskId = task.TaskId > 0 ? task.TaskId : (result.NewId ?? 0);
                    if (task.TaskId == 0)
                    {
                        task.TaskId = taskId;
                    }

                    if (task.ProjectId <= 0 && previousTask != null)
                    {
                        task.ProjectId = previousTask.ProjectId;
                    }

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
                return new AjaxResponse
                {
                    Success = false,
                    Message = exception.Message,
                    RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null
                };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetTaskById(int taskId)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanAccessTask(taskId);
                TaskService taskService = new TaskService();
                TaskEntity task = taskService.GetTaskById(taskId);

                return new AjaxResponse
                {
                    Success = task != null,
                    Message = task == null ? "La tarea seleccionada no existe." : null,
                    Data = task
                };
            }
            catch (Exception exception)
            {
                return new AjaxResponse
                {
                    Success = false,
                    Message = exception.Message,
                    RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null
                };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetProjectResponsibleUsers(int projectId)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanAccessProject(projectId);
                ProjectCollaboratorService collaboratorService = new ProjectCollaboratorService();
                IList<UserEntity> users = BuildResponsibleUsersForProject(projectId, null, collaboratorService);

                return new AjaxResponse
                {
                    Success = true,
                    Data = users
                };
            }
            catch (Exception exception)
            {
                return new AjaxResponse
                {
                    Success = false,
                    Message = exception.Message,
                    RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null
                };
            }
        }

        private static IList<UserEntity> BuildResponsibleUsersForProject(int projectId, IList<ProjectEntity> visibleProjects, ProjectCollaboratorService collaboratorService)
        {
            List<UserEntity> users = new List<UserEntity>();
            if (projectId <= 0)
            {
                return users;
            }

            bool canUseProject = true;
            if (visibleProjects != null)
            {
                canUseProject = false;
                foreach (ProjectEntity project in visibleProjects)
                {
                    if (project.ProjectId == projectId)
                    {
                        canUseProject = true;
                        break;
                    }
                }
            }

            if (!canUseProject)
            {
                return users;
            }

            IList<ProjectCollaboratorEntity> collaborators = collaboratorService.GetCollaboratorsByProject(projectId);
            foreach (ProjectCollaboratorEntity collaborator in collaborators)
            {
                users.Add(new UserEntity
                {
                    UserId = collaborator.UserId,
                    UserName = collaborator.UserName,
                    FirstName = collaborator.FullName,
                    LastName = string.Empty,
                    RoleName = collaborator.RoleName,
                    IsActive = true
                });
            }

            return users;
        }
    }
}
