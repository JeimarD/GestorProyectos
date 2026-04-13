using System;
using System.Web.Script.Services;
using System.Web.Services;
using Logic.Services;
using Objects.Entities;
using Objects.Filters;
using Presentation.Helpers;
using Presentation.Models;

namespace Presentation.Pages
{
    public partial class ProjectDetails : BasePage
    {
        public override string ActiveNavigationKey { get { return "projects"; } }
        public int ProjectId { get; private set; }
        public string ProjectName { get; private set; }
        public string ProjectDescription { get; private set; }
        public string ProjectStatus { get; private set; }
        public string ProjectStatusClass { get; private set; }
        public string ClientName { get; private set; }
        public string Priority { get; private set; }
        public string CreatedByName { get; private set; }
        public int Progress { get; private set; }
        public bool CanEditProject { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthenticatedUser currentUser = CurrentUser;
            int projectId;
            if (!int.TryParse(Request.QueryString["projectId"], out projectId) || projectId <= 0)
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
                return;
            }

            if (!AuthorizationHelper.CanAccessProject(currentUser, projectId))
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
                return;
            }

            ProjectService projectService = new ProjectService();
            var project = projectService.GetProjectById(projectId);
            if (project == null)
            {
                Response.Redirect("~/Pages/Projects.aspx", true);
                return;
            }

            ProjectId = project.ProjectId;
            ProjectName = project.Name;
            ProjectDescription = string.IsNullOrWhiteSpace(project.Description) ? "Proyecto sin descripción adicional." : project.Description;
            ProjectStatus = project.Status;
            ProjectStatusClass = project.Status == "Completado" ? "is-teal" : project.Status == "Bloqueado" ? "is-error" : project.Status == "Planificado" ? "is-secondary" : "is-primary";
            ClientName = project.ClientName;
            Priority = project.Priority;
            CreatedByName = project.CreatedByName;
            Progress = project.Progress;
            CanEditProject = AuthorizationHelper.CanManageProjects(currentUser);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetBoardData(int projectId)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanAccessProject(projectId);
                ProjectService projectService = new ProjectService();
                TaskService taskService = new TaskService();
                var project = projectService.GetProjectById(projectId);
                var tasks = taskService.GetTasks(new TaskFilter { ProjectId = projectId });

                return new AjaxResponse { Success = true, Data = new { Project = project, Tasks = tasks } };
            }
            catch (Exception exception)
            {
                return new AjaxResponse { Success = false, Message = exception.Message, RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null };
            }
        }
    }
}
