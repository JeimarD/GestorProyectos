<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Projects.aspx.cs" Inherits="Presentation.Pages.Projects" %>
<asp:Content ID="ProjectsTitle" ContentPlaceHolderID="HeadTitle" runat="server">Proyectos</asp:Content>
<asp:Content ID="ProjectsHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
</asp:Content>
<asp:Content ID="ProjectsTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">search</span>
        <input type="text" id="filterQuickProjectSearch" placeholder="Buscar proyectos, clientes o responsables..." title="Filtra visualmente por nombre, descripción o creador." />
    </div>
</asp:Content>
<asp:Content ID="ProjectsMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-content projects-list-content">
        <section class="projects-list-header">
            <div>
                <h2>Mis proyectos</h2>
                <p>Gestiona y revisa los proyectos activos del ciclo de desarrollo.</p>
            </div>
            <div class="projects-list-header-actions">
                <button type="button" class="projects-filter-toggle" id="btnToggleProjectFilters"><span class="material-symbols-outlined">filter_list</span><span>Filtros</span></button>
                <% if (CanCreateProject) { %>
                <a class="projects-new-button" href="CreateProject.aspx"><span class="material-symbols-outlined">add</span><span>Nuevo proyecto</span></a>
                <% } %>
            </div>
        </section>

        <section class="projects-metrics-grid">
            <article class="projects-metric-card"><div class="projects-metric-icon is-primary"><span class="material-symbols-outlined">rocket_launch</span></div><div><p>Activos</p><h3 id="metricActiveProjects">0</h3></div></article>
            <article class="projects-metric-card"><div class="projects-metric-icon is-teal"><span class="material-symbols-outlined">task_alt</span></div><div><p>Completados</p><h3 id="metricCompletedProjects">0</h3></div></article>
            <article class="projects-metric-card"><div class="projects-metric-icon is-secondary"><span class="material-symbols-outlined">folder_copy</span></div><div><p>Total</p><h3 id="metricTotalProjects">0</h3></div></article>
            <article class="projects-metric-card"><div class="projects-metric-icon is-error"><span class="material-symbols-outlined">warning</span></div><div><p>Bloqueados</p><h3 id="metricDelayedProjects">0</h3></div></article>
        </section>

        <section class="projects-filter-panel is-hidden" id="projectsFilterPanel">
            <div class="projects-filter-grid">
                <div class="projects-filter-field"><label for="filterProjectName">Nombre</label><input type="text" id="filterProjectName" title="Filtra por nombre del proyecto." /></div>
                <div class="projects-filter-field"><label for="filterProjectStatus">Estado</label><select id="filterProjectStatus" title="Filtra por estado del proyecto."><option value="">Todos</option><option value="Planificado">Planificado</option><option value="En ejecución">En ejecución</option><option value="Bloqueado">Bloqueado</option><option value="Completado">Completado</option></select></div>
            </div>
            <div class="projects-filter-actions">
                <button type="button" id="btnSearchProjects" class="projects-filter-button is-primary">Buscar</button>
                <button type="button" id="btnResetProjects" class="projects-filter-button">Limpiar</button>
            </div>
        </section>

        <section class="projects-status-chip-row">
            <button type="button" class="projects-status-chip is-active" data-status="">Todos</button>
            <button type="button" class="projects-status-chip" data-status="En ejecución">En ejecución</button>
            <button type="button" class="projects-status-chip" data-status="Planificado">Backlog</button>
            <button type="button" class="projects-status-chip" data-status="Bloqueado">Bloqueados</button>
            <button type="button" class="projects-status-chip" data-status="Completado">Done</button>
        </section>

        <div id="projectMessage" class="message projects-list-message"></div>
        <section class="projects-grid" id="projectsGrid"></section>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="../Scripts/app-common.js"></script>
    <script type="text/javascript">
        var canManageProjectOperations = <%= CanManageProjectOperations ? "true" : "false" %>;
        var projectsCache = [];
        var quickSearchCache = [];

        $(function () {
            initializeTooltips();
            searchProjects();
            $("#btnSearchProjects").on("click", searchProjects);
            $("#btnResetProjects").on("click", resetProjectFilters);
            $("#btnToggleProjectFilters").on("click", toggleProjectFilters);
            $("#filterQuickProjectSearch").on("keyup", applyQuickProjectSearch);
            $(".projects-status-chip").on("click", function () {
                $(".projects-status-chip").removeClass("is-active");
                $(this).addClass("is-active");
                $("#filterProjectStatus").val($(this).data("status") || "");
                searchProjects();
            });
        });

        function searchProjects() {
            var filter = { Name: emptyStringToNull($.trim($("#filterProjectName").val())), Status: emptyStringToNull($("#filterProjectStatus").val()) };
            callPageMethod("Projects.aspx/SearchProjects", { filter: filter }, function (response) {
                if (!response.Success) {
                    projectsCache = [];
                    quickSearchCache = [];
                    renderProjects([]);
                    updateProjectMetrics([]);
                    showMessage("#projectMessage", response.Message, true);
                    return;
                }

                projectsCache = $.makeArray(response.Data || []);
                projectsCache.sort(function (left, right) {
                    return (parseInt(right.ProjectId, 10) || 0) - (parseInt(left.ProjectId, 10) || 0);
                });
                quickSearchCache = projectsCache.slice(0);
                renderProjects(projectsCache);
                updateProjectMetrics(projectsCache);
                showMessage("#projectMessage", "", false);
            });
        }

        function deleteProject(projectId) {
            if (!confirm("¿Desea eliminar este proyecto?")) { return; }
            callPageMethod("Projects.aspx/DeleteProject", { projectId: projectId }, function (response) {
                showMessage("#projectMessage", response.Message, !response.Success);
                if (response.Success) { searchProjects(); }
            });
        }

        function resetProjectFilters() {
            $("#filterProjectName, #filterQuickProjectSearch").val("");
            $("#filterProjectStatus").val("");
            $(".projects-status-chip").removeClass("is-active");
            $(".projects-status-chip[data-status='']").addClass("is-active");
            searchProjects();
        }

        function toggleProjectFilters() { $("#projectsFilterPanel").toggleClass("is-hidden"); }

        function applyQuickProjectSearch() {
            var searchValue = $.trim($("#filterQuickProjectSearch").val()).toLowerCase();
            if (!searchValue) { renderProjects(quickSearchCache); updateProjectMetrics(quickSearchCache); return; }
            var filtered = $.grep(quickSearchCache, function (project) {
                var haystack = ((project.Name || "") + " " + (project.ClientName || "") + " " + (project.Description || "") + " " + (project.Status || "") + " " + (project.Priority || "") + " " + (project.CreatedByName || "")).toLowerCase();
                return haystack.indexOf(searchValue) >= 0;
            });
            renderProjects(filtered);
            updateProjectMetrics(filtered);
        }

        function renderProjects(projects) {
            var projectList = $.makeArray(projects || []);
            var cards = $.map(projectList, function (project, index) {
                var statusClass = getProjectStatusClass(project.Status);
                var progress = normalizeProgress(project.Progress);
                var progressClass = getProjectProgressClass(project.Status);
                var iconClass = getProjectIconClass(index);
                var phaseLabel = getProjectPhaseLabel(project.Status);
                var initials = getProjectInitials(project.Name);
                var delayed = project.Status === "Bloqueado";
                var delayedIcon = delayed ? "<span class='material-symbols-outlined projects-warning-icon' title='Proyecto bloqueado'>error</span>" : "";
                var priorityClass = getProjectPriorityClass(project.Priority);
                var ownerInitials = getOwnerInitials(project.CreatedByName);

                return "<article class='projects-card " + (delayed ? "is-priority" : "") + "'>" +
                    "<div class='projects-card-top'><div class='projects-card-logo " + iconClass + "'><span>" + htmlEncode(initials) + "</span></div><span class='projects-status-badge " + statusClass + "'>" + htmlEncode(project.Status) + "</span></div>" +
                    "<h3>" + htmlEncode(project.Name) + delayedIcon + "</h3>" +
                    "<p class='projects-card-client'>Cliente: " + htmlEncode(project.ClientName || "Sin cliente") + "</p>" +
                    "<p class='projects-card-description'>" + htmlEncode(project.Description || "Proyecto registrado sin descripción adicional.") + "</p>" +
                    "<div class='projects-card-progress'><div class='projects-card-progress-label'><span>" + htmlEncode(phaseLabel) + "</span><span>" + progress + "%</span></div><div class='projects-card-progress-bar'><span class='" + progressClass + "' style='width: " + progress + "%;'></span></div></div>" +
                    "<div class='projects-card-meta'><span>Inicio: " + htmlEncode(formatDisplayDate(project.StartDate)) + "</span><span>Prioridad: " + htmlEncode(project.Priority || "Medio") + "</span></div>" +
                    "<div class='projects-card-meta'><span>Fin: " + htmlEncode(formatDisplayDate(project.EndDate) || "Pendiente") + "</span><span>Responsable: " + htmlEncode(project.CreatedByName || "Sistema") + "</span></div>" +
                    "<div class='projects-card-footer'><div class='projects-card-real-footer'><span class='projects-priority-pill " + priorityClass + "'>" + htmlEncode(project.Priority || "Medio") + "</span><div class='projects-owner-chip'><span class='projects-team-bubble is-slate'>" + htmlEncode(ownerInitials) + "</span><span>" + htmlEncode(project.CreatedByName || "Sistema") + "</span></div></div><div class='projects-card-actions'><button type='button' class='projects-card-action projects-card-action-static' onclick='openProjectDetail(" + project.ProjectId + ")'><span class='material-symbols-outlined'>visibility</span></button>" + (canManageProjectOperations ? "<button type='button' class='projects-card-action projects-card-action-danger' onclick='deleteProject(" + project.ProjectId + ")'><span class='material-symbols-outlined'>delete</span></button>" : "") + "</div></div>" +
                    "</article>";
            });
            $("#projectsGrid").html(cards.length > 0 ? cards.join("") : "<div class='projects-empty-state'>No hay proyectos para mostrar.</div>");
        }

        function updateProjectMetrics(projects) {
            projects = $.makeArray(projects || []);
            var completed = 0, active = 0, delayed = 0, total = projects.length;
            $.each(projects, function (_, project) {
                if (project.Status === "Completado") { completed++; } else { active++; }
                if (project.Status === "Bloqueado") { delayed++; }
            });
            $("#metricActiveProjects").text(active);
            $("#metricCompletedProjects").text(completed);
            $("#metricTotalProjects").text(total);
            $("#metricDelayedProjects").text(delayed);
        }

        function openProjectDetail(projectId) { window.location.href = "ProjectDetails.aspx?projectId=" + projectId; }
        function getProjectStatusClass(status) { if (status === "Completado") { return "is-teal"; } if (status === "Bloqueado") { return "is-error"; } if (status === "Planificado") { return "is-secondary"; } return "is-primary"; }
        function getProjectProgressClass(status) { if (status === "Completado") { return "is-teal"; } if (status === "Bloqueado") { return "is-error"; } return "is-primary"; }
        function getProjectPhaseLabel(status) { if (status === "Completado") { return "Entrega completada"; } if (status === "Bloqueado") { return "Bloqueado por seguimiento"; } if (status === "Planificado") { return "Fase de definición"; } return "Desarrollo en curso"; }
        function getProjectIconClass(index) { var classes = ["is-blue", "is-teal", "is-slate"]; return classes[index % classes.length]; }
        function getProjectPriorityClass(priority) { if (priority === "Alto") { return "is-high"; } if (priority === "Bajo") { return "is-low"; } return "is-medium"; }
        function getProjectInitials(name) { if (!name) { return "PR"; } var parts = $.grep(name.split(" "), function (part) { return $.trim(part) !== ""; }); if (parts.length === 1) { return parts[0].substring(0, 2).toUpperCase(); } return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase(); }
        function getOwnerInitials(name) { if (!name || name === "Sistema") { return "SI"; } var parts = $.grep(name.split(" "), function (part) { return $.trim(part) !== ""; }); if (parts.length === 1) { return parts[0].substring(0, 2).toUpperCase(); } return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase(); }
        function formatDisplayDate(value) { var normalized = formatJsonDate(value); if (!normalized) { return ""; } var parts = normalized.split("-"); return parts.length === 3 ? parts[2] + "/" + parts[1] + "/" + parts[0] : normalized; }
        function normalizeProgress(value) { var progress = parseInt(value, 10); if (isNaN(progress)) { return 0; } if (progress < 0) { return 0; } if (progress > 100) { return 100; } return progress; }
    </script>
</asp:Content>
