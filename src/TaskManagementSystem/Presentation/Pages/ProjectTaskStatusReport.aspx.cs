using System;
using System.Collections.Generic;
using Logic.Services;
using Microsoft.Reporting.WebForms;
using Objects.Entities;
using Objects.Filters;
using Presentation.Helpers;

namespace Presentation.Pages
{
    public partial class ProjectTaskStatusReport : Helpers.BasePage
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
            int projectId;
            if (!int.TryParse(Request.QueryString["projectId"], out projectId) || projectId <= 0)
            {
                throw new ApplicationException("Debe seleccionar un proyecto para generar el reporte.");
            }

            string status = ToNullableString(Request.QueryString["status"]);
            string priority = ToNullableString(Request.QueryString["priority"]);

            ProjectService projectService = new ProjectService();
            TaskService taskService = new TaskService();
            ProjectEntity project = projectService.GetProjectById(projectId);
            IList<TaskEntity> tasks = taskService.GetTasks(new TaskFilter { ProjectId = projectId, Status = status });
            IList<ProjectTaskReportRow> rows = BuildRows(tasks, priority);

            reportViewerProjectTask.Reset();
            reportViewerProjectTask.LocalReport.ReportPath = Server.MapPath("~/Reports/ProjectTaskStatusReport.rdlc");
            reportViewerProjectTask.LocalReport.DataSources.Clear();
            reportViewerProjectTask.LocalReport.DataSources.Add(new ReportDataSource("ProjectTaskDataSet", rows));
            reportViewerProjectTask.LocalReport.SetParameters(new[]
            {
                new ReportParameter("ProjectName", project == null ? "Proyecto" : project.Name),
                new ReportParameter("GeneratedAt", GetViewerNow().ToString("dd/MM/yyyy hh:mm tt")),
                new ReportParameter("FilterSummary", BuildFilterSummary(status, priority))
            });
            reportViewerProjectTask.LocalReport.Refresh();
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

        private static IList<ProjectTaskReportRow> BuildRows(IList<TaskEntity> tasks, string priority)
        {
            List<ProjectTaskReportRow> rows = new List<ProjectTaskReportRow>();
            DateTime today = DateTime.Today;
            List<TaskEntity> sortedTasks = new List<TaskEntity>(tasks ?? new List<TaskEntity>());

            sortedTasks.Sort(delegate (TaskEntity left, TaskEntity right)
            {
                return left.TaskId.CompareTo(right.TaskId);
            });

            foreach (TaskEntity task in sortedTasks)
            {
                if (!string.IsNullOrWhiteSpace(priority) && !string.Equals(task.Priority, priority, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                bool delayed = task.EstimatedEndDate.HasValue && task.EstimatedEndDate.Value.Date < today && !string.Equals(task.Status, "Completado", StringComparison.OrdinalIgnoreCase);

                rows.Add(new ProjectTaskReportRow
                {
                    TaskId = task.TaskId,
                    TaskName = task.Name,
                    AssignedUserName = string.IsNullOrWhiteSpace(task.AssignedUserName) ? "Sin asignar" : task.AssignedUserName,
                    Status = task.Status,
                    Priority = task.Priority,
                    ProgressText = task.Progress + "%",
                    StartDate = task.StartDate.ToString("dd/MM/yyyy"),
                    EstimatedEndDate = task.EstimatedEndDate.HasValue ? task.EstimatedEndDate.Value.ToString("dd/MM/yyyy") : "Pendiente",
                    DateCondition = delayed ? "Atrasada" : "A tiempo",
                    CommentCount = task.CommentCount,
                    AttachmentCount = task.AttachmentCount
                });
            }

            return rows;
        }

        private static string BuildFilterSummary(string status, string priority)
        {
            List<string> parts = new List<string>();
            if (!string.IsNullOrWhiteSpace(status))
            {
                parts.Add("Estatus tarea: " + status);
            }

            if (!string.IsNullOrWhiteSpace(priority))
            {
                parts.Add("Prioridad tarea: " + priority);
            }

            return parts.Count == 0 ? "Sin filtros adicionales." : string.Join(" | ", parts.ToArray());
        }

        private static string ToNullableString(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        [Serializable]
        public class ProjectTaskReportRow
        {
            public int TaskId { get; set; }
            public string TaskName { get; set; }
            public string AssignedUserName { get; set; }
            public string Status { get; set; }
            public string Priority { get; set; }
            public string ProgressText { get; set; }
            public string StartDate { get; set; }
            public string EstimatedEndDate { get; set; }
            public string DateCondition { get; set; }
            public int CommentCount { get; set; }
            public int AttachmentCount { get; set; }
        }
    }
}
