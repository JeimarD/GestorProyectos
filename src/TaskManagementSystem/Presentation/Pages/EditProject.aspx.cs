using System;
using System.Collections.Generic;
using System.Web.Script.Services;
using System.Web.Services;
using Logic.Services;
using Objects.Entities;
using Presentation.Helpers;
using Presentation.Models;

namespace Presentation.Pages
{
    public partial class EditProject : BasePage
    {
        public override string ActiveNavigationKey
        {
            get { return "projects"; }
        }

        public int ProjectId { get; private set; }
        public string ProjectName { get; private set; }
        public string ProjectDescription { get; private set; }
        public string ClientName { get; private set; }
        public string ProjectStatus { get; private set; }
        public string ProjectStatusClass { get; private set; }
        public string Priority { get; private set; }
        public string StartDateValue { get; private set; }
        public string EndDateValue { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthorizationHelper.CanManageProjects(CurrentUser))
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
                return;
            }

            int projectId;
            if (!int.TryParse(Request.QueryString["projectId"], out projectId) || projectId <= 0)
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
                return;
            }

            ProjectService projectService = new ProjectService();
            ProjectEntity project = projectService.GetProjectById(projectId);

            if (project == null)
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
                return;
            }

            ProjectId = project.ProjectId;
            ProjectName = project.Name ?? string.Empty;
            ProjectDescription = project.Description ?? string.Empty;
            ClientName = project.ClientName ?? string.Empty;
            ProjectStatus = string.IsNullOrWhiteSpace(project.Status) ? "Planificado" : project.Status;
            ProjectStatusClass = BuildStatusClass(ProjectStatus);
            Priority = string.IsNullOrWhiteSpace(project.Priority) ? "Medio" : project.Priority;
            StartDateValue = project.StartDate.ToString("yyyy-MM-dd");
            EndDateValue = project.EndDate.HasValue ? project.EndDate.Value.ToString("yyyy-MM-dd") : string.Empty;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetCollaboratorData(int projectId)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanManageProjects();
                UserService userService = new UserService();
                ProjectCollaboratorService collaboratorService = new ProjectCollaboratorService();
                List<UserEntity> collaborators = new List<UserEntity>();

                foreach (UserEntity user in userService.GetUsers(new Objects.Filters.UserFilter()))
                {
                    if (user.IsActive && string.Equals(user.RoleName, AuthorizationHelper.CollaboratorRole, StringComparison.OrdinalIgnoreCase))
                    {
                        collaborators.Add(user);
                    }
                }

                IList<ProjectCollaboratorEntity> assignedCollaborators = collaboratorService.GetCollaboratorsByProject(projectId);
                List<int> assignedUserIds = new List<int>();

                foreach (ProjectCollaboratorEntity collaborator in assignedCollaborators)
                {
                    assignedUserIds.Add(collaborator.UserId);
                }

                return new AjaxResponse
                {
                    Success = true,
                    Data = new
                    {
                        Collaborators = collaborators,
                        AssignedUserIds = assignedUserIds
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
        public static AjaxResponse SaveProject(ProjectEntity project, int[] collaboratorUserIds)
        {
            try
            {
                AuthenticatedUser currentUser = WebMethodSessionValidator.RequireUserCanManageProjects();
                ProjectService projectService = new ProjectService();
                ProjectCollaboratorService collaboratorService = new ProjectCollaboratorService();
                ProjectEntity previousProject = projectService.GetProjectById(project.ProjectId);
                var result = projectService.SaveProject(project);

                if (result.Success)
                {
                    collaboratorService.SaveProjectCollaborators(project.ProjectId, collaboratorUserIds == null ? new List<int>() : new List<int>(collaboratorUserIds));
                    ActivityLogWriter.LogProjectSaved(currentUser, previousProject, project, true);
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

        private static string BuildStatusClass(string status)
        {
            if (status == "Completado")
            {
                return "is-teal";
            }

            if (status == "Bloqueado")
            {
                return "is-error";
            }

            if (status == "Planificado")
            {
                return "is-secondary";
            }

            return "is-primary";
        }
    }
}
