using System;
using System.Collections.Generic;
using Logic.Services;
using Microsoft.Reporting.WebForms;
using Objects.Entities;
using Objects.Filters;
using Presentation.Helpers;

namespace Presentation.Pages
{
    public partial class UserTaskAssignmentReport : Helpers.BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthorizationHelper.CanViewReports(CurrentUser))
            {
                Response.Redirect("~/Pages/Dashboard.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                LoadReport();
            }
        }

        private void LoadReport()
        {
            int userId;
            string status = ToNullableString(Request.QueryString["status"]);
            int? filterUserId = int.TryParse(Request.QueryString["userId"], out userId) && userId > 0 ? (int?)userId : null;

            TaskService taskService = new TaskService();
            UserService userService = new UserService();

            IList<TaskEntity> tasks = taskService.GetTasks(new TaskFilter { AssignedUserId = filterUserId, Status = status });
            IList<UserEntity> users = userService.GetUsers(new UserFilter());
            IList<UserTaskAssignmentReportRow> rows = BuildRows(tasks, users);

            reportViewerUserTask.Reset();
            reportViewerUserTask.LocalReport.ReportPath = Server.MapPath("~/Reports/UserTaskAssignmentReport.rdlc");
            reportViewerUserTask.LocalReport.DataSources.Clear();
            reportViewerUserTask.LocalReport.DataSources.Add(new ReportDataSource("UserTaskAssignmentDataSet", rows));
            reportViewerUserTask.LocalReport.SetParameters(new[]
            {
                new ReportParameter("GeneratedAt", GetViewerNow().ToString("dd/MM/yyyy hh:mm tt")),
                new ReportParameter("FilterSummary", BuildFilterSummary(filterUserId, status, users))
            });
            reportViewerUserTask.LocalReport.Refresh();
        }

        private DateTime GetViewerNow()
        {
            int timezoneOffsetMinutes;
            if (int.TryParse(Request.QueryString["tzOffset"], out timezoneOffsetMinutes) && timezoneOffsetMinutes >= -840 && timezoneOffsetMinutes <= 840)
            {
                return DateTime.UtcNow.AddMinutes(-timezoneOffsetMinutes);
            }

            return DateTime.Now;
        }

        private static IList<UserTaskAssignmentReportRow> BuildRows(IList<TaskEntity> tasks, IList<UserEntity> users)
        {
            Dictionary<int, UserEntity> userMap = new Dictionary<int, UserEntity>();
            foreach (UserEntity user in users)
            {
                userMap[user.UserId] = user;
            }

            List<UserTaskAssignmentReportRow> rows = new List<UserTaskAssignmentReportRow>();
            List<TaskEntity> sortedTasks = new List<TaskEntity>(tasks ?? new List<TaskEntity>());

            sortedTasks.Sort(delegate (TaskEntity left, TaskEntity right)
            {
                return left.TaskId.CompareTo(right.TaskId);
            });

            foreach (TaskEntity task in sortedTasks)
            {
                string fullName = "Sin asignar";
                string roleName = "-";

                if (task.AssignedUserId.HasValue && userMap.ContainsKey(task.AssignedUserId.Value))
                {
                    UserEntity user = userMap[task.AssignedUserId.Value];
                    fullName = (user.FirstName + " " + user.LastName).Trim();
                    roleName = user.RoleName;
                }
                else if (!string.IsNullOrWhiteSpace(task.AssignedUserName))
                {
                    fullName = task.AssignedUserName;
                }

                rows.Add(new UserTaskAssignmentReportRow
                {
                    UserName = fullName,
                    RoleName = roleName,
                    ProjectName = task.ProjectName,
                    TaskName = task.Name,
                    Status = task.Status,
                    ProgressText = task.Progress + "%",
                    StartDate = task.StartDate.ToString("dd/MM/yyyy"),
                    EstimatedEndDate = task.EstimatedEndDate.HasValue ? task.EstimatedEndDate.Value.ToString("dd/MM/yyyy") : "Pendiente"
                });
            }

            return rows;
        }

        private static string BuildFilterSummary(int? userId, string status, IList<UserEntity> users)
        {
            List<string> parts = new List<string>();

            if (userId.HasValue)
            {
                foreach (UserEntity user in users)
                {
                    if (user.UserId == userId.Value)
                    {
                        parts.Add("Usuario: " + (user.FirstName + " " + user.LastName).Trim());
                        break;
                    }
                }
            }

            if (!string.IsNullOrWhiteSpace(status))
            {
                parts.Add("Estatus tarea: " + status);
            }

            return parts.Count == 0 ? "Sin filtros (todos los usuarios y tareas)." : string.Join(" | ", parts.ToArray());
        }

        private static string ToNullableString(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        [Serializable]
        public class UserTaskAssignmentReportRow
        {
            public string UserName { get; set; }
            public string RoleName { get; set; }
            public string ProjectName { get; set; }
            public string TaskName { get; set; }
            public string Status { get; set; }
            public string ProgressText { get; set; }
            public string StartDate { get; set; }
            public string EstimatedEndDate { get; set; }
        }
    }
}
