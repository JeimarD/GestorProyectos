using System;
using System.Collections.Generic;
using Logic.Services;
using Microsoft.Reporting.WebForms;
using Objects.Entities;
using Objects.Filters;
using Presentation.Helpers;

namespace Presentation.Pages
{
    public partial class ProjectStatusReport : Helpers.BasePage
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
            ProjectFilter filter = new ProjectFilter
            {
                Name = ToNullableString(Request.QueryString["name"]),
                Status = ToNullableString(Request.QueryString["status"])
            };

            string priority = ToNullableString(Request.QueryString["priority"]);
            DateTime? startFrom = ParseDate(Request.QueryString["startFrom"]);
            DateTime? endTo = ParseDate(Request.QueryString["endTo"]);

            ProjectService projectService = new ProjectService();
            IList<ProjectEntity> projects = projectService.GetProjects(filter);
            IList<ProjectStatusReportRow> rows = BuildRows(projects, priority, startFrom, endTo);

            reportViewerProjectStatus.Reset();
            reportViewerProjectStatus.LocalReport.ReportPath = Server.MapPath("~/Reports/ProjectStatusReport.rdlc");
            reportViewerProjectStatus.LocalReport.DataSources.Clear();
            reportViewerProjectStatus.LocalReport.DataSources.Add(new ReportDataSource("ProjectStatusDataSet", rows));
            reportViewerProjectStatus.LocalReport.SetParameters(new[]
            {
                new ReportParameter("GeneratedAt", GetViewerNow().ToString("dd/MM/yyyy hh:mm tt")),
                new ReportParameter("FilterSummary", BuildFilterSummary(filter, priority, startFrom, endTo))
            });
            reportViewerProjectStatus.LocalReport.Refresh();
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

        private static IList<ProjectStatusReportRow> BuildRows(IList<ProjectEntity> projects, string priority, DateTime? startFrom, DateTime? endTo)
        {
            List<ProjectStatusReportRow> rows = new List<ProjectStatusReportRow>();
            DateTime today = DateTime.Today;
            List<ProjectEntity> sortedProjects = new List<ProjectEntity>(projects ?? new List<ProjectEntity>());

            sortedProjects.Sort(delegate (ProjectEntity left, ProjectEntity right)
            {
                return left.ProjectId.CompareTo(right.ProjectId);
            });

            foreach (ProjectEntity project in sortedProjects)
            {
                if (!string.IsNullOrWhiteSpace(priority) && !string.Equals(project.Priority, priority, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                if (startFrom.HasValue && project.StartDate.Date < startFrom.Value.Date)
                {
                    continue;
                }

                if (endTo.HasValue)
                {
                    DateTime compareDate = project.EndDate.HasValue ? project.EndDate.Value.Date : project.StartDate.Date;
                    if (compareDate > endTo.Value.Date)
                    {
                        continue;
                    }
                }

                bool delayed = project.EndDate.HasValue && project.EndDate.Value.Date < today && !string.Equals(project.Status, "Completado", StringComparison.OrdinalIgnoreCase);

                rows.Add(new ProjectStatusReportRow
                {
                    ProjectId = project.ProjectId,
                    ProjectName = project.Name,
                    ClientName = project.ClientName,
                    Status = project.Status,
                    Priority = project.Priority,
                    ProgressText = project.Progress + "%",
                    StartDate = project.StartDate.ToString("dd/MM/yyyy"),
                    EndDate = project.EndDate.HasValue ? project.EndDate.Value.ToString("dd/MM/yyyy") : "Pendiente",
                    DateCondition = delayed ? "Atrasado" : "A tiempo"
                });
            }

            return rows;
        }

        private static string BuildFilterSummary(ProjectFilter filter, string priority, DateTime? startFrom, DateTime? endTo)
        {
            List<string> parts = new List<string>();

            if (!string.IsNullOrWhiteSpace(filter.Name))
            {
                parts.Add("Nombre: " + filter.Name);
            }

            if (!string.IsNullOrWhiteSpace(filter.Status))
            {
                parts.Add("Estatus: " + filter.Status);
            }

            if (!string.IsNullOrWhiteSpace(priority))
            {
                parts.Add("Prioridad: " + priority);
            }

            if (startFrom.HasValue)
            {
                parts.Add("Inicio desde: " + startFrom.Value.ToString("dd/MM/yyyy"));
            }

            if (endTo.HasValue)
            {
                parts.Add("Fin hasta: " + endTo.Value.ToString("dd/MM/yyyy"));
            }

            return parts.Count == 0 ? "Sin filtros (todos los registros)." : string.Join(" | ", parts.ToArray());
        }

        private static string ToNullableString(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private static DateTime? ParseDate(string value)
        {
            DateTime parsed;
            return DateTime.TryParse(value, out parsed) ? (DateTime?)parsed : null;
        }

        [Serializable]
        public class ProjectStatusReportRow
        {
            public int ProjectId { get; set; }
            public string ProjectName { get; set; }
            public string ClientName { get; set; }
            public string Status { get; set; }
            public string Priority { get; set; }
            public string ProgressText { get; set; }
            public string StartDate { get; set; }
            public string EndDate { get; set; }
            public string DateCondition { get; set; }
        }
    }
}
