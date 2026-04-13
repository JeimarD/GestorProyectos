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
    public partial class Dashboard : BasePage
    {
        public override string ActiveNavigationKey
        {
            get { return "dashboard"; }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetDashboardData()
        {
            try
            {
                AuthenticatedUser currentUser = WebMethodSessionValidator.RequireUser();
                ProjectService projectService = new ProjectService();
                TaskService taskService = new TaskService();
                UserService userService = new UserService();
                ActivityService activityService = new ActivityService();

                IList<ProjectEntity> projects = projectService.GetProjects(new ProjectFilter());
                IList<TaskEntity> tasks = taskService.GetTasks(new TaskFilter());
                IList<UserEntity> users = userService.GetUsers(new UserFilter());
                IList<ActivityLogEntity> activities = activityService.GetRecentActivities(10);

                if (AuthorizationHelper.IsCollaborator(currentUser))
                {
                    ProjectCollaboratorService collaboratorService = new ProjectCollaboratorService();
                    IList<int> assignedProjectIds = collaboratorService.GetProjectIdsByUser(currentUser.UserId);
                    List<ProjectEntity> restrictedProjects = new List<ProjectEntity>();
                    List<TaskEntity> restrictedTasks = new List<TaskEntity>();

                    foreach (ProjectEntity project in projects)
                    {
                        if (assignedProjectIds.Contains(project.ProjectId))
                        {
                            restrictedProjects.Add(project);
                        }
                    }

                    foreach (TaskEntity task in tasks)
                    {
                        if (assignedProjectIds.Contains(task.ProjectId))
                        {
                            restrictedTasks.Add(task);
                        }
                    }

                    projects = restrictedProjects;
                    tasks = restrictedTasks;
                    activities = new List<ActivityLogEntity>();
                    users = BuildVisibleUsersFromTasks(users, tasks, currentUser.UserId);
                }

                List<ActivityLogEntity> orderedActivities = new List<ActivityLogEntity>(activities ?? new List<ActivityLogEntity>());
                orderedActivities.Sort(delegate (ActivityLogEntity left, ActivityLogEntity right)
                {
                    return right.ActivityId.CompareTo(left.ActivityId);
                });

                if (orderedActivities.Count > 10)
                {
                    orderedActivities = orderedActivities.GetRange(0, 10);
                }

                return new AjaxResponse
                {
                    Success = true,
                    Data = new
                    {
                        Summary = BuildSummary(projects, tasks, users),
                        Projects = BuildRecentProjects(projects, 6),
                        Workload = BuildWorkload(users, tasks),
                        Activities = orderedActivities
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

        private static DashboardSummaryEntity BuildSummary(IList<ProjectEntity> projects, IList<TaskEntity> tasks, IList<UserEntity> users)
        {
            int totalComments = 0;
            int activeTasks = 0;

            foreach (TaskEntity task in tasks)
            {
                totalComments += task.CommentCount;
                if (!IsCompletedStatus(task.Status))
                {
                    activeTasks++;
                }
            }

            int teamMembers = 0;
            foreach (UserEntity user in users)
            {
                if (user.IsActive)
                {
                    teamMembers++;
                }
            }

            return new DashboardSummaryEntity
            {
                TotalProjects = projects.Count,
                ActiveTasks = activeTasks,
                TotalComments = totalComments,
                TeamMembers = teamMembers
            };
        }

        private static IList<ProjectEntity> BuildRecentProjects(IList<ProjectEntity> projects, int maxRows)
        {
            List<ProjectEntity> source = new List<ProjectEntity>();
            List<ProjectEntity> topProjects = new List<ProjectEntity>();

            foreach (ProjectEntity project in projects ?? new List<ProjectEntity>())
            {
                if (!IsCompletedStatus(project.Status))
                {
                    source.Add(project);
                }
            }

            source.Sort(delegate (ProjectEntity left, ProjectEntity right)
            {
                return right.ProjectId.CompareTo(left.ProjectId);
            });

            for (int index = 0; index < source.Count && topProjects.Count < maxRows; index++)
            {
                topProjects.Add(source[index]);
            }

            return topProjects;
        }

        private static IList<UserWorkloadEntity> BuildWorkload(IList<UserEntity> users, IList<TaskEntity> tasks)
        {
            List<UserWorkloadEntity> workload = new List<UserWorkloadEntity>();
            Dictionary<int, int> assignedTaskCounter = new Dictionary<int, int>();
            int maxTasks = 0;

            foreach (TaskEntity task in tasks)
            {
                if (!task.AssignedUserId.HasValue || IsCompletedStatus(task.Status))
                {
                    continue;
                }

                int userId = task.AssignedUserId.Value;
                if (!assignedTaskCounter.ContainsKey(userId))
                {
                    assignedTaskCounter.Add(userId, 0);
                }

                assignedTaskCounter[userId] = assignedTaskCounter[userId] + 1;
                if (assignedTaskCounter[userId] > maxTasks)
                {
                    maxTasks = assignedTaskCounter[userId];
                }
            }

            foreach (UserEntity user in users)
            {
                if (!user.IsActive)
                {
                    continue;
                }

                int taskCount = assignedTaskCounter.ContainsKey(user.UserId) ? assignedTaskCounter[user.UserId] : 0;
                int loadPercentage = maxTasks == 0 ? 0 : (int)Math.Round((taskCount * 100m) / maxTasks, 0);

                workload.Add(new UserWorkloadEntity
                {
                    UserId = user.UserId,
                    FullName = string.Format("{0} {1}", user.FirstName, user.LastName).Trim(),
                    RoleName = user.RoleName,
                    TaskCount = taskCount,
                    LoadPercentage = loadPercentage
                });
            }

            workload.Sort(delegate (UserWorkloadEntity left, UserWorkloadEntity right)
            {
                return right.TaskCount.CompareTo(left.TaskCount);
            });

            return workload;
        }

        private static IList<UserEntity> BuildVisibleUsersFromTasks(IList<UserEntity> allUsers, IList<TaskEntity> tasks, int currentUserId)
        {
            List<UserEntity> visibleUsers = new List<UserEntity>();
            Dictionary<int, bool> userMap = new Dictionary<int, bool>();

            foreach (TaskEntity task in tasks)
            {
                if (task.AssignedUserId.HasValue)
                {
                    userMap[task.AssignedUserId.Value] = true;
                }
            }

            userMap[currentUserId] = true;

            foreach (UserEntity user in allUsers)
            {
                if (userMap.ContainsKey(user.UserId))
                {
                    visibleUsers.Add(user);
                }
            }

            return visibleUsers;
        }

        private static bool IsCompletedStatus(string status)
        {
            return string.Equals((status ?? string.Empty).Trim(), "Completado", StringComparison.OrdinalIgnoreCase);
        }
    }
}
