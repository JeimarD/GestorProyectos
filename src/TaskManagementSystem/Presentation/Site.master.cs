using System;
using Presentation.Helpers;

namespace Presentation
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected string GetBodyCssClass()
        {
            BasePage page = Page as BasePage;
            return page == null ? "dashboard-body" : page.BodyCssClass;
        }

        protected string GetNavigationClass(string key)
        {
            BasePage page = Page as BasePage;
            return page != null && page.ActiveNavigationKey == key ? "is-active" : string.Empty;
        }

        protected string GetCurrentUserName()
        {
            BasePage page = Page as BasePage;
            return page == null ? string.Empty : page.CurrentUserName;
        }

        protected string GetCurrentRoleName()
        {
            BasePage page = Page as BasePage;
            return page == null ? string.Empty : page.CurrentRoleName;
        }

        protected string GetCurrentUserInitials()
        {
            BasePage page = Page as BasePage;
            return page == null ? "US" : page.CurrentUserInitials;
        }

        protected bool ShowUsersNavigation()
        {
            BasePage page = Page as BasePage;
            return page != null && page.ShowUsersNavigation;
        }

        protected bool ShowReportsNavigation()
        {
            BasePage page = Page as BasePage;
            return page != null && page.ShowReportsNavigation;
        }

        protected bool ShowSidebarPrimaryAction()
        {
            BasePage page = Page as BasePage;
            return page != null && !string.IsNullOrWhiteSpace(page.SidebarPrimaryActionText) && !string.IsNullOrWhiteSpace(page.SidebarPrimaryActionUrl);
        }

        protected string GetSidebarPrimaryActionText()
        {
            BasePage page = Page as BasePage;
            return page == null ? string.Empty : page.SidebarPrimaryActionText;
        }

        protected string GetSidebarPrimaryActionUrl()
        {
            BasePage page = Page as BasePage;
            return page == null ? string.Empty : page.SidebarPrimaryActionUrl;
        }
    }
}
