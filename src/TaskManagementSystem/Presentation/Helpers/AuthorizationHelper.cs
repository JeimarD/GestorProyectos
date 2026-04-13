using System;
using Logic.Services;
using Objects.Entities;

namespace Presentation.Helpers
{
    public static class AuthorizationHelper
    {
        public const string AdministratorRole = "Administrador";
        public const string ProjectLeaderRole = "Lider de Proyecto";
        public const string CollaboratorRole = "Colaborador";

        public static bool IsAdministrator(AuthenticatedUser user)
        {
            return HasRole(user, AdministratorRole);
        }

        public static bool IsProjectLeader(AuthenticatedUser user)
        {
            return HasRole(user, ProjectLeaderRole);
        }

        public static bool IsCollaborator(AuthenticatedUser user)
        {
            return HasRole(user, CollaboratorRole);
        }

        public static bool CanManageUsers(AuthenticatedUser user)
        {
            return IsAdministrator(user);
        }

        public static bool CanManageProjects(AuthenticatedUser user)
        {
            return IsAdministrator(user) || IsProjectLeader(user);
        }

        public static bool CanViewReports(AuthenticatedUser user)
        {
            return IsAdministrator(user) || IsProjectLeader(user);
        }

        public static bool CanCreateProjects(AuthenticatedUser user)
        {
            return IsAdministrator(user) || IsProjectLeader(user);
        }

        public static bool CanUseProjectTaskManagement(AuthenticatedUser user)
        {
            return IsAdministrator(user) || IsProjectLeader(user) || IsCollaborator(user);
        }

        public static bool CanAccessProject(AuthenticatedUser user, int projectId)
        {
            if (user == null || projectId <= 0)
            {
                return false;
            }

            if (CanManageProjects(user))
            {
                return true;
            }

            if (!IsCollaborator(user))
            {
                return false;
            }

            ProjectCollaboratorService collaboratorService = new ProjectCollaboratorService();
            return collaboratorService.IsUserCollaborator(projectId, user.UserId);
        }

        public static bool CanAccessTask(AuthenticatedUser user, int taskId)
        {
            if (user == null || taskId <= 0)
            {
                return false;
            }

            TaskService taskService = new TaskService();
            TaskEntity task = taskService.GetTaskById(taskId);
            return task != null && CanAccessProject(user, task.ProjectId);
        }

        public static void EnsureCanManageUsers(AuthenticatedUser user)
        {
            if (!CanManageUsers(user))
            {
                throw new ApplicationException("No tiene permisos para gestionar usuarios.");
            }
        }

        public static void EnsureCanManageProjects(AuthenticatedUser user)
        {
            if (!CanManageProjects(user))
            {
                throw new ApplicationException("No tiene permisos para gestionar proyectos.");
            }
        }

        public static void EnsureCanViewReports(AuthenticatedUser user)
        {
            if (!CanViewReports(user))
            {
                throw new ApplicationException("No tiene permisos para ver reportes.");
            }
        }

        public static void EnsureCanUseProjectTaskManagement(AuthenticatedUser user)
        {
            if (!CanUseProjectTaskManagement(user))
            {
                throw new ApplicationException("No tiene permisos para gestionar tareas.");
            }
        }

        public static void EnsureCanAccessProject(AuthenticatedUser user, int projectId)
        {
            if (!CanAccessProject(user, projectId))
            {
                throw new ApplicationException("No tiene permisos para acceder a este proyecto.");
            }
        }

        public static void EnsureCanAccessTask(AuthenticatedUser user, int taskId)
        {
            if (!CanAccessTask(user, taskId))
            {
                throw new ApplicationException("No tiene permisos para acceder a esta tarea.");
            }
        }

        private static bool HasRole(AuthenticatedUser user, string roleName)
        {
            return user != null
                && !string.IsNullOrWhiteSpace(user.RoleName)
                && string.Equals(user.RoleName.Trim(), roleName, StringComparison.OrdinalIgnoreCase);
        }
    }
}
