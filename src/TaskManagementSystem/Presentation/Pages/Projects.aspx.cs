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
    public partial class Projects : BasePage
    {
        public bool CanCreateProject
        {
            get { return AuthorizationHelper.CanCreateProjects(CurrentUser); }
        }

        public bool CanManageProjectOperations
        {
            get { return AuthorizationHelper.CanManageProjects(CurrentUser); }
        }

        public override string ActiveNavigationKey
        {
            get { return "projects"; }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse SearchProjects(ProjectFilter filter)
        {
            try
            {
                AuthenticatedUser currentUser = WebMethodSessionValidator.RequireUser();
                ProjectService projectService = new ProjectService();
                IList<ProjectEntity> projects = projectService.GetProjects(filter);

                if (AuthorizationHelper.IsCollaborator(currentUser))
                {
                    ProjectCollaboratorService collaboratorService = new ProjectCollaboratorService();
                    IList<int> allowedProjectIds = collaboratorService.GetProjectIdsByUser(currentUser.UserId);
                    List<ProjectEntity> visibleProjects = new List<ProjectEntity>();

                    foreach (ProjectEntity project in projects)
                    {
                        if (allowedProjectIds.Contains(project.ProjectId))
                        {
                            visibleProjects.Add(project);
                        }
                    }

                    projects = visibleProjects;
                }

                List<ProjectEntity> orderedProjects = new List<ProjectEntity>(projects);
                orderedProjects.Sort(delegate (ProjectEntity left, ProjectEntity right)
                {
                    return right.ProjectId.CompareTo(left.ProjectId);
                });

                return new AjaxResponse
                {
                    Success = true,
                    Data = orderedProjects
                };
            }
            catch (Exception exception)
            {
                return BuildErrorResponse(exception);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse SaveProject(ProjectEntity project)
        {
            try
            {
                var currentUser = WebMethodSessionValidator.RequireUserCanManageProjects();
                ProjectService projectService = new ProjectService();

                if (project.ProjectId == 0)
                {
                    project.CreatedByUserId = currentUser.UserId;
                }

                ProjectEntity previousProject = project.ProjectId > 0 ? projectService.GetProjectById(project.ProjectId) : null;

                var result = projectService.SaveProject(project);

                if (result.Success)
                {
                    int projectId = project.ProjectId > 0 ? project.ProjectId : (result.NewId ?? 0);
                    if (project.ProjectId == 0)
                    {
                        project.ProjectId = projectId;
                    }

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
                return BuildErrorResponse(exception);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse DeleteProject(int projectId)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanManageProjects();
                ProjectService projectService = new ProjectService();
                var result = projectService.DeleteProject(projectId);

                return new AjaxResponse
                {
                    Success = result.Success,
                    Message = result.Message
                };
            }
            catch (Exception exception)
            {
                return BuildErrorResponse(exception);
            }
        }

        private static AjaxResponse BuildErrorResponse(Exception exception)
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
