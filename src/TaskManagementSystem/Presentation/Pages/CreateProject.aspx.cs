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
    public partial class CreateProject : BasePage
    {
        public override string ActiveNavigationKey
        {
            get { return "projects"; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthorizationHelper.CanManageProjects(CurrentUser))
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetCollaboratorData()
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanManageProjects();
                UserService userService = new UserService();
                List<UserEntity> collaborators = new List<UserEntity>();

                foreach (UserEntity user in userService.GetUsers(new UserFilter()))
                {
                    if (user.IsActive && string.Equals(user.RoleName, AuthorizationHelper.CollaboratorRole, StringComparison.OrdinalIgnoreCase))
                    {
                        collaborators.Add(user);
                    }
                }

                return new AjaxResponse
                {
                    Success = true,
                    Data = new
                    {
                        Collaborators = collaborators
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
                ProjectEntity previousProject = null;

                if (project.ProjectId == 0)
                {
                    project.CreatedByUserId = currentUser.UserId;
                }
                else
                {
                    previousProject = projectService.GetProjectById(project.ProjectId);
                }

                var result = projectService.SaveProject(project);

                if (result.Success)
                {
                    int projectId = project.ProjectId > 0 ? project.ProjectId : (result.NewId ?? 0);
                    if (project.ProjectId == 0)
                    {
                        project.ProjectId = projectId;
                    }

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
    }
}
