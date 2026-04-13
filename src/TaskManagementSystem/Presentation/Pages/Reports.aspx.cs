using System.Collections.Generic;
using System.Text;
using Logic.Services;
using Objects.Entities;
using Objects.Filters;
using Presentation.Helpers;

namespace Presentation.Pages
{
    public partial class Reports : BasePage
    {
        public override string ActiveNavigationKey
        {
            get { return "reports"; }
        }

        public string ProjectOptionsHtml { get; private set; }
        public string UserOptionsHtml { get; private set; }

        protected void Page_Load(object sender, System.EventArgs e)
        {
            if (!AuthorizationHelper.CanViewReports(CurrentUser))
            {
                Response.Redirect("~/Pages/Dashboard.aspx", true);
                return;
            }

            LoadOptions();
        }

        private void LoadOptions()
        {
            ProjectService projectService = new ProjectService();
            UserService userService = new UserService();

            IList<ProjectEntity> projects = projectService.GetProjects(new ProjectFilter());
            IList<UserEntity> users = userService.GetUsers(new UserFilter());

            ProjectOptionsHtml = BuildProjectOptions(projects);
            UserOptionsHtml = BuildUserOptions(users);
        }

        private static string BuildProjectOptions(IList<ProjectEntity> projects)
        {
            StringBuilder builder = new StringBuilder();
            builder.Append("<option value=''>Seleccione...</option>");

            foreach (ProjectEntity project in projects)
            {
                builder.Append("<option value='");
                builder.Append(project.ProjectId);
                builder.Append("'>");
                builder.Append(System.Web.HttpUtility.HtmlEncode(project.Name));
                builder.Append("</option>");
            }

            return builder.ToString();
        }

        private static string BuildUserOptions(IList<UserEntity> users)
        {
            StringBuilder builder = new StringBuilder();
            builder.Append("<option value=''>Todos</option>");

            foreach (UserEntity user in users)
            {
                if (!user.IsActive)
                {
                    continue;
                }

                builder.Append("<option value='");
                builder.Append(user.UserId);
                builder.Append("'>");
                builder.Append(System.Web.HttpUtility.HtmlEncode((user.FirstName + " " + user.LastName).Trim()));
                builder.Append("</option>");
            }

            return builder.ToString();
        }
    }
}
