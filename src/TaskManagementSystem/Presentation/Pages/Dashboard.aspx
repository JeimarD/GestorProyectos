<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Presentation.Pages.Dashboard" %>
<asp:Content ID="DashboardTitle" ContentPlaceHolderID="HeadTitle" runat="server">Dashboard</asp:Content>
<asp:Content ID="DashboardHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
</asp:Content>
<asp:Content ID="DashboardTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">search</span>
        <input type="text" placeholder="Buscar proyectos o tareas..." title="Búsqueda visual del dashboard." />
    </div>
</asp:Content>
<asp:Content ID="DashboardMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-content">
        <section class="dashboard-hero">
            <div>
                <span class="dashboard-hero-kicker">Vista general</span>
                <h2>Panel principal del sistema</h2>
                <p>Resumen visual de proyectos, tareas, actividad reciente y distribución del trabajo del equipo.</p>
            </div>
            <div class="dashboard-hero-actions">
                <a class="dashboard-primary-action" href="Projects.aspx">Gestionar proyectos</a>
            </div>
        </section>

        <section class="dashboard-stats-grid">
            <article class="dashboard-stat-card"><div class="dashboard-stat-head"><div><p>Total de proyectos</p><h3 id="dashboardTotalProjects">0</h3></div><div class="dashboard-stat-icon is-blue"><span class="material-symbols-outlined">folder_shared</span></div></div><div class="dashboard-stat-foot">Proyectos registrados</div></article>
            <article class="dashboard-stat-card"><div class="dashboard-stat-head"><div><p>Tareas activas</p><h3 id="dashboardActiveTasks">0</h3></div><div class="dashboard-stat-icon is-primary"><span class="material-symbols-outlined">assignment_turned_in</span></div></div><div class="dashboard-stat-foot is-primary">Tareas no completadas</div></article>
            <article class="dashboard-stat-card"><div class="dashboard-stat-head"><div><p>Comentarios</p><h3 id="dashboardTotalComments">0</h3></div><div class="dashboard-stat-icon is-teal"><span class="material-symbols-outlined">forum</span></div></div><div class="dashboard-stat-foot">Total de comentarios en tareas</div></article>
            <article class="dashboard-stat-card"><div class="dashboard-stat-head"><div><p>Miembros del equipo</p><h3 id="dashboardTeamMembers">0</h3></div><div class="dashboard-stat-icon is-muted"><span class="material-symbols-outlined">groups</span></div></div><div class="dashboard-stat-foot">Usuarios activos</div></article>
        </section>

        <section class="dashboard-main-grid">
            <div class="dashboard-panel-column">
                <div class="dashboard-section-title-row"><h3>Proyectos</h3><a href="Projects.aspx">Ver todos</a></div>
                <div id="dashboardProjectsContainer"></div>
            </div>

            <div class="dashboard-panel-column">
                <div class="dashboard-section-title-row"><h3>Actividad reciente</h3></div>
                <div class="dashboard-activity-panel">
                    <div id="dashboardActivityContainer"></div>
                    <a class="dashboard-history-button" href="ActivityHistory.aspx">Ver historial de actividad</a>
                </div>
            </div>
        </section>

        <section class="dashboard-workload-panel">
            <div class="dashboard-section-header"><div><h3>Carga activa del equipo</h3><p>Distribución visual del sprint actual</p></div><div class="dashboard-section-tools"><div class="dashboard-workload-search"><span class="material-symbols-outlined">search</span><input type="text" id="workloadUserSearch" placeholder="Buscar usuario..." title="Filtra la carga por nombre de usuario" /></div></div></div>
            <div class="dashboard-member-grid" id="dashboardWorkloadContainer"></div>
        </section>
    </div>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="../Scripts/app-common.js"></script>
    <script type="text/javascript">
        var workloadCache = [];
        var workloadUserSearch = "";

        $(function () {
            initializeTooltips();
            $("#workloadUserSearch").on("keyup", function () {
                workloadUserSearch = $.trim($(this).val()).toLowerCase();
                drawWorkloadCards();
            });
            loadDashboardData();
        });

        function loadDashboardData() {
            callPageMethod("Dashboard.aspx/GetDashboardData", {}, function (response) {
                if (!response.Success || !response.Data) {
                    return;
                }

                renderSummary(response.Data.Summary || {});
                renderProjects(response.Data.Projects || []);
                renderWorkload(response.Data.Workload || []);
                renderActivities(response.Data.Activities || []);
            });
        }

        function renderSummary(summary) {
            $("#dashboardTotalProjects").text(summary.TotalProjects || 0);
            $("#dashboardActiveTasks").text(summary.ActiveTasks || 0);
            $("#dashboardTotalComments").text(summary.TotalComments || 0);
            $("#dashboardTeamMembers").text(summary.TeamMembers || 0);
        }

        function renderProjects(projects) {
            var cards = $.map(projects, function (project, index) {
                var statusClass = getStatusClass(project.Status);
                var progressBarClass = getProgressClass(project.Status);
                var progress = normalizeProgress(project.Progress);
                var iconClass = getIconClass(index);

                return "<article class='dashboard-project-card'><div class='dashboard-project-icon " + iconClass + "'><span class='material-symbols-outlined'>folder</span></div><div class='dashboard-project-body'><div class='dashboard-project-head'><div><h4>" + htmlEncode(project.Name) + "</h4><p>Cliente: " + htmlEncode(project.ClientName || "Sin cliente") + "</p></div><span class='dashboard-badge " + statusClass + "'>" + htmlEncode(project.Status || "Planificado") + "</span></div><div class='dashboard-progress-block'><div class='dashboard-progress-label'><span>Progreso</span><span>" + progress + "%</span></div><div class='dashboard-progress-bar " + progressBarClass + "'><span style='width: " + progress + "%'></span></div></div></div></article>";
            });

            $("#dashboardProjectsContainer").html(cards.length > 0 ? cards.join("") : "<div class='dashboard-empty-state'>No hay proyectos para mostrar.</div>");
        }

        function renderWorkload(workload) {
            workloadCache = (workload || []).slice(0);
            drawWorkloadCards();
        }

        function drawWorkloadCards() {
            var visibleWorkload = $.grep(workloadCache || [], function (member) {
                if (!workloadUserSearch) {
                    return true;
                }

                return ((member.FullName || "") + " " + (member.RoleName || "")).toLowerCase().indexOf(workloadUserSearch) >= 0;
            });

            var cards = $.map(visibleWorkload, function (member, index) {
                var avatarClass = getAvatarClass(index);
                var progressClass = getMiniProgressClass(index);
                var initials = getInitials(member.FullName);
                var load = normalizeProgress(member.LoadPercentage);

                return "<article class='dashboard-member-card'><div class='dashboard-member-avatar " + avatarClass + "'>" + htmlEncode(initials) + "</div><div class='dashboard-member-body'><strong>" + htmlEncode(member.FullName || "Usuario") + "</strong><span>" + htmlEncode(member.RoleName || "Colaborador") + "</span></div><div class='dashboard-member-metric'><p>" + (member.TaskCount || 0) + " tareas</p><div class='dashboard-mini-progress " + progressClass + "'><span style='width: " + load + "%'></span></div></div></article>";
            });

            $("#dashboardWorkloadContainer").html(cards.length > 0 ? cards.join("") : "<div class='dashboard-empty-state'>No hay carga activa registrada.</div>");
        }

        function renderActivities(activities) {
            var items = $.map(activities, function (activity, index) {
                var avatarClass = getAvatarClass(index);
                var initials = getInitials(activity.PerformedByName || "Sistema");
                return "<article class='dashboard-activity-item'><div class='dashboard-activity-avatar " + avatarClass + "'>" + htmlEncode(initials) + "</div><div><p><strong>" + htmlEncode(activity.PerformedByName || "Sistema") + "</strong> " + htmlEncode(activity.Description || "registró un cambio.") + "</p><small>" + htmlEncode(formatJsonDateTime(activity.CreatedAt)) + "</small></div></article>";
            });

            $("#dashboardActivityContainer").html(items.length > 0 ? items.join("") : "<div class='dashboard-empty-state'>No hay actividad reciente.</div>");
        }

        function getStatusClass(status) { if (status === "Completado") { return "is-teal"; } if (status === "Bloqueado") { return "is-slate"; } return "is-primary"; }
        function getProgressClass(status) { if (status === "Completado") { return "is-teal"; } if (status === "Bloqueado") { return "is-slate"; } return ""; }
        function getIconClass(index) { var classes = ["is-blue", "is-teal", "is-slate"]; return classes[index % classes.length]; }
        function getAvatarClass(index) { var classes = ["is-blue", "is-teal", "is-slate", "is-red"]; return classes[index % classes.length]; }
        function getMiniProgressClass(index) { var classes = ["", "is-teal", "is-red", ""]; return classes[index % classes.length]; }
        function normalizeProgress(value) { var progress = parseInt(value, 10); if (isNaN(progress)) { return 0; } if (progress < 0) { return 0; } if (progress > 100) { return 100; } return progress; }
        function getInitials(fullName) { var parts = $.grep((fullName || "").split(" "), function (part) { return $.trim(part) !== ""; }); if (parts.length === 0) { return "SI"; } if (parts.length === 1) { return parts[0].substring(0, 2).toUpperCase(); } return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase(); }
    </script>
</asp:Content>
