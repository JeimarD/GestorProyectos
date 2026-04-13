using System;
using Objects.Entities;

namespace Presentation.Helpers
{
    public static class WebMethodSessionValidator
    {
        public static AuthenticatedUser RequireUser()
        {
            AuthenticatedUser currentUser = CookieSessionManager.GetCurrentUser();

            if (currentUser == null)
            {
                throw new ApplicationException("La sesión expiró. Inicie sesión nuevamente.");
            }

            return currentUser;
        }

        public static AuthenticatedUser RequireUserCanManageUsers()
        {
            AuthenticatedUser currentUser = RequireUser();
            AuthorizationHelper.EnsureCanManageUsers(currentUser);
            return currentUser;
        }

        public static AuthenticatedUser RequireUserCanManageProjects()
        {
            AuthenticatedUser currentUser = RequireUser();
            AuthorizationHelper.EnsureCanManageProjects(currentUser);
            return currentUser;
        }

        public static AuthenticatedUser RequireUserCanViewReports()
        {
            AuthenticatedUser currentUser = RequireUser();
            AuthorizationHelper.EnsureCanViewReports(currentUser);
            return currentUser;
        }

        public static AuthenticatedUser RequireUserCanAccessProject(int projectId)
        {
            AuthenticatedUser currentUser = RequireUser();
            AuthorizationHelper.EnsureCanAccessProject(currentUser, projectId);
            return currentUser;
        }

        public static AuthenticatedUser RequireUserCanAccessTask(int taskId)
        {
            AuthenticatedUser currentUser = RequireUser();
            AuthorizationHelper.EnsureCanAccessTask(currentUser, taskId);
            return currentUser;
        }
    }
}
