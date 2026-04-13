using System;
using System.Web;
using Objects.Entities;

namespace Presentation.Helpers
{
    public class BasePage : System.Web.UI.Page
    {
        public AuthenticatedUser CurrentUser
        {
            get { return CookieSessionManager.GetCurrentUser(); }
        }

        public virtual string ActiveNavigationKey
        {
            get { return string.Empty; }
        }

        public virtual string BodyCssClass
        {
            get { return "dashboard-body"; }
        }

        public virtual string SidebarPrimaryActionText
        {
            get
            {
                if (!AuthorizationHelper.CanCreateProjects(CurrentUser))
                {
                    return string.Empty;
                }

                return "Nuevo proyecto";
            }
        }

        public virtual string SidebarPrimaryActionUrl
        {
            get
            {
                if (!AuthorizationHelper.CanCreateProjects(CurrentUser))
                {
                    return string.Empty;
                }

                return "~/Pages/CreateProject.aspx";
            }
        }

        public bool ShowUsersNavigation
        {
            get { return AuthorizationHelper.CanManageUsers(CurrentUser); }
        }

        public bool ShowReportsNavigation
        {
            get { return AuthorizationHelper.CanViewReports(CurrentUser); }
        }

        public string CurrentUserName
        {
            get { return CurrentUser == null ? string.Empty : CurrentUser.FullName; }
        }

        public string CurrentRoleName
        {
            get { return CurrentUser == null ? string.Empty : CurrentUser.RoleName; }
        }

        public string CurrentUserInitials
        {
            get
            {
                if (CurrentUser == null)
                {
                    return "US";
                }

                string first = string.IsNullOrWhiteSpace(CurrentUser.FirstName) ? string.Empty : CurrentUser.FirstName.Substring(0, 1).ToUpperInvariant();
                string last = string.IsNullOrWhiteSpace(CurrentUser.LastName) ? string.Empty : CurrentUser.LastName.Substring(0, 1).ToUpperInvariant();
                string initials = first + last;

                return string.IsNullOrWhiteSpace(initials) ? "US" : initials;
            }
        }

        protected virtual bool RequiresAuthentication
        {
            get { return true; }
        }

        protected override void OnLoad(EventArgs e)
        {
            if (RequiresAuthentication && CookieSessionManager.GetCurrentUser() == null)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            base.OnLoad(e);
        }
    }
}
