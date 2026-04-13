<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="ProjectDetails.aspx.cs" Inherits="Presentation.Pages.ProjectDetails" %>
<asp:Content ID="ProjectDetailsTitle" ContentPlaceHolderID="HeadTitle" runat="server">Detalle del proyecto</asp:Content>
<asp:Content ID="ProjectDetailsHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
</asp:Content>
<asp:Content ID="ProjectDetailsTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">search</span>
        <input type="text" id="projectDetailQuickSearch" placeholder="Buscar tareas, miembros o prioridades..." title="Filtra visualmente las tareas del proyecto." />
    </div>
</asp:Content>
<asp:Content ID="ProjectDetailsTopbarRight" ContentPlaceHolderID="TopbarActionsContent" runat="server">
    <div class="project-detail-top-actions">
        <a class="project-detail-action-button is-muted" href="Projects.aspx"><span class="material-symbols-outlined">west</span><span>Volver</span></a>
        <% if (CanEditProject) { %>
        <a class="project-detail-action-button is-muted" href="EditProject.aspx?projectId=<%= ProjectId %>"><span class="material-symbols-outlined">edit</span><span>Editar proyecto</span></a>
        <% } %>
        <a class="project-detail-action-button is-primary" href="CreateTask.aspx?projectId=<%= ProjectId %>"><span class="material-symbols-outlined">add</span><span>Nueva tarea</span></a>
    </div>
</asp:Content>
<asp:Content ID="ProjectDetailsMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-content project-detail-content">
        <input type="hidden" id="projectDetailId" value="<%= ProjectId %>" />
        <section class="project-detail-hero">
            <div class="project-detail-header">
                <div class="project-detail-header-main">
                    <span class="project-detail-kicker">Vista de proyecto</span>
                    <div class="project-detail-status-row">
                        <h2 id="projectDetailName"><%= Server.HtmlEncode(ProjectName) %></h2>
                        <span id="projectDetailStatusBadge" class="projects-status-badge <%= ProjectStatusClass %>"><%= Server.HtmlEncode(ProjectStatus) %></span>
                    </div>
                    <p class="project-detail-updated-text">Cliente: <strong><%= Server.HtmlEncode(ClientName) %></strong></p>
                    <p id="projectDetailDescription"><%= Server.HtmlEncode(ProjectDescription) %></p>
                </div>
            </div>

            <div class="project-detail-header-side">
                <article class="project-detail-summary-pill is-priority">
                    <div class="project-detail-summary-icon"><span class="material-symbols-outlined">priority_high</span></div>
                    <div><span>Prioridad</span><strong id="projectDetailPriority"><%= Server.HtmlEncode(Priority) %></strong></div>
                </article>
                <article class="project-detail-summary-pill is-progress">
                    <div class="project-detail-summary-icon"><span class="material-symbols-outlined">timeline</span></div>
                    <div><span>Progreso</span><strong id="projectDetailProgress"><%= Progress %>%</strong></div>
                </article>
                <article class="project-detail-summary-pill is-owner">
                    <div class="project-detail-summary-icon"><span class="material-symbols-outlined">person</span></div>
                    <div><span>Responsable</span><strong><%= Server.HtmlEncode(CreatedByName) %></strong></div>
                </article>
            </div>
        </section>

        <section class="project-detail-board">
            <div class="project-detail-column">
                <div class="project-detail-column-head">
                    <div class="project-detail-column-title"><span class="project-detail-column-bar is-secondary"></span><h3>Backlog</h3><span id="countPlanificado" class="project-detail-column-count">0</span></div>
                    <span class="material-symbols-outlined project-detail-column-menu">more_horiz</span>
                </div>
                <div id="columnPlanificado" class="project-detail-column-body"></div>
                <a class="project-detail-add-task" href="CreateTask.aspx?projectId=<%= ProjectId %>"><span class="material-symbols-outlined">add</span><span>Añadir tarea</span></a>
            </div>
            <div class="project-detail-column">
                <div class="project-detail-column-head">
                    <div class="project-detail-column-title"><span class="project-detail-column-bar is-primary"></span><h3>En ejecución</h3><span id="countEnEjecucion" class="project-detail-column-count">0</span></div>
                    <span class="material-symbols-outlined project-detail-column-menu">more_horiz</span>
                </div>
                <div id="columnEnEjecucion" class="project-detail-column-body"></div>
            </div>
            <div class="project-detail-column">
                <div class="project-detail-column-head">
                    <div class="project-detail-column-title"><span class="project-detail-column-bar is-error"></span><h3>Bloqueado</h3><span id="countBloqueado" class="project-detail-column-count">0</span></div>
                    <span class="material-symbols-outlined project-detail-column-menu">more_horiz</span>
                </div>
                <div id="columnBloqueado" class="project-detail-column-body"></div>
            </div>
            <div class="project-detail-column">
                <div class="project-detail-column-head">
                    <div class="project-detail-column-title"><span class="project-detail-column-bar is-teal"></span><h3>Done</h3><span id="countCompletado" class="project-detail-column-count">0</span></div>
                    <span class="material-symbols-outlined project-detail-column-menu">more_horiz</span>
                </div>
                <div id="columnCompletado" class="project-detail-column-body"></div>
            </div>
        </section>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="../Scripts/app-common.js"></script>
    <script type="text/javascript">
        var boardTasksCache = [];

        $(function () {
            initializeTooltips();
            loadProjectBoard();
            $("#projectDetailQuickSearch").on("keyup", filterBoardTasks);
        });

        function loadProjectBoard() {
            var projectId = parseInt($("#projectDetailId").val(), 10) || 0;
            callPageMethod("ProjectDetails.aspx/GetBoardData", { projectId: projectId }, function (response) {
                if (!response.Success) { return; }
                boardTasksCache = $.makeArray(response.Data.Tasks || []);
                renderBoard(boardTasksCache);
            });
        }

        function filterBoardTasks() {
            var searchValue = $.trim($("#projectDetailQuickSearch").val()).toLowerCase();
            if (!searchValue) { renderBoard(boardTasksCache); return; }
            var filtered = $.grep(boardTasksCache, function (task) {
                var haystack = ((task.Name || "") + " " + (task.Description || "") + " " + (task.AssignedUserName || "") + " " + (task.Priority || "")).toLowerCase();
                return haystack.indexOf(searchValue) >= 0;
            });
            renderBoard(filtered);
        }

        function renderBoard(tasks) {
            renderColumn("Planificado", "#columnPlanificado", "#countPlanificado", tasks);
            renderColumn("En ejecución", "#columnEnEjecucion", "#countEnEjecucion", tasks);
            renderColumn("Bloqueado", "#columnBloqueado", "#countBloqueado", tasks);
            renderColumn("Completado", "#columnCompletado", "#countCompletado", tasks);
        }

        function renderColumn(status, bodySelector, countSelector, tasks) {
            var filtered = $.grep(tasks || [], function (task) { return task.Status === status; });
            var cards = $.map(filtered, function (task) {
                var progress = normalizeProgress(task.Progress);
                var doneClass = status === "Completado" ? " is-done" : "";
                var doneIcon = status === "Completado" ? "<div class='project-task-done-flag'><span class='material-symbols-outlined'>check_circle</span></div>" : "";

                return "<article class='project-task-card'>" +
                    doneIcon +
                    "<div class='project-task-card-top'><span class='projects-priority-pill " + getTaskPriorityClass(task.Priority) + "'>" + htmlEncode(task.Priority || "Medio") + "</span><a class='project-task-edit-link' href='TaskDetails.aspx?taskId=" + task.TaskId + "'>Ver detalle<span class='material-symbols-outlined'>arrow_outward</span></a></div>" +
                    "<h4 class='project-task-title" + doneClass + "'>" + htmlEncode(task.Name) + "</h4>" +
                    "<div class='project-task-meta'><span>Encargado: <strong>" + htmlEncode(task.AssignedUserName || "Sin asignar") + "</strong></span><span>Inicio: <strong>" + htmlEncode(formatDisplayDate(task.StartDate)) + "</strong></span></div>" +
                    "<div class='project-task-meta'><span>Fin estimada: <strong>" + htmlEncode(formatDisplayDate(task.EstimatedEndDate) || "Pendiente") + "</strong></span><span>Horas: <strong>" + htmlEncode((task.EstimatedHours || 0).toString()) + "</strong></span></div>" +
                    "<div class='project-task-footer'><div class='project-task-counter'><span class='material-symbols-outlined'>attachment</span><span>" + htmlEncode((task.AttachmentCount || 0).toString()) + "</span></div><div class='project-task-counter'><span class='material-symbols-outlined'>chat_bubble</span><span>" + htmlEncode((task.CommentCount || 0).toString()) + "</span></div><div class='project-task-progress'><span>" + progress + "%</span><div class='project-task-progress-track'><div class='project-task-progress-fill' style='width: " + progress + "%;'></div></div></div></div>" +
                    "</article>";
            });

            $(countSelector).text(filtered.length);
            $(bodySelector).html(cards.join("") || "<div class='project-task-empty'><span class='material-symbols-outlined'>drag_indicator</span><p>Sin tareas en esta columna.</p></div>");
        }

        function getTaskPriorityClass(priority) {
            if (priority === "Alto") { return "is-high"; }
            if (priority === "Bajo") { return "is-low"; }
            return "is-medium";
        }

        function formatDisplayDate(value) {
            var normalized = formatJsonDate(value);
            if (!normalized) { return ""; }
            var parts = normalized.split("-");
            return parts.length === 3 ? parts[2] + "/" + parts[1] + "/" + parts[0] : normalized;
        }

        function normalizeProgress(value) {
            var progress = parseInt(value, 10);
            if (isNaN(progress)) { return 0; }
            if (progress < 0) { return 0; }
            if (progress > 100) { return 100; }
            return progress;
        }
    </script>
</asp:Content>
