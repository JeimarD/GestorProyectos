<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="Presentation.Pages.Reports" %>
<asp:Content ID="ReportsTitle" ContentPlaceHolderID="HeadTitle" runat="server">Reportes</asp:Content>
<asp:Content ID="ReportsHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
</asp:Content>
<asp:Content ID="ReportsTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">analytics</span>
        <input type="text" value="Reportes operativos" readonly="readonly" title="Panel para generar reportes operativos con filtros." />
    </div>
</asp:Content>
<asp:Content ID="ReportsMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-content reports-content">
        <section class="reports-hero">
            <div>
                <span class="reports-kicker">Centro de reportes</span>
                <h2>Reportes ejecutivos</h2>
                <p>Genere reportes detallados de proyectos, tareas por proyecto y carga por usuario con filtros en tiempo real.</p>
            </div>
        </section>

        <section class="reports-grid">
            <article class="reports-card">
                <h3>Proyectos y estatus</h3>
                <p>Lista de proyectos con estado, progreso y condición de fecha (a tiempo o atrasado).</p>
                <div class="reports-form-grid">
                    <div class="reports-field"><label for="projectName">Nombre</label><input type="text" id="projectName" title="Filtra por nombre del proyecto." /></div>
                    <div class="reports-field"><label for="projectStatus">Estatus</label><select id="projectStatus" title="Filtra por estatus del proyecto."><option value="">Todos</option><option value="Planificado">Planificado</option><option value="En ejecución">En ejecución</option><option value="Bloqueado">Bloqueado</option><option value="Completado">Completado</option></select></div>
                    <div class="reports-field"><label for="projectPriority">Prioridad</label><select id="projectPriority" title="Filtra por prioridad del proyecto."><option value="">Todas</option><option value="Bajo">Bajo</option><option value="Medio">Medio</option><option value="Alto">Alto</option></select></div>
                    <div class="reports-field"><label for="projectStartFrom">Inicio desde</label><input type="text" id="projectStartFrom" title="Filtra proyectos con fecha de inicio desde este día." /></div>
                    <div class="reports-field"><label for="projectEndTo">Fin hasta</label><input type="text" id="projectEndTo" title="Filtra proyectos con fecha de fin hasta este día." /></div>
                </div>
                <div class="reports-actions"><button type="button" id="btnProjectStatusReport">Generar reporte</button></div>
            </article>

            <article class="reports-card">
                <h3>Proyecto y tareas</h3>
                <p>Detalle de un proyecto con sus tareas, estatus, progreso y condición de fecha por tarea.</p>
                <div class="reports-form-grid">
                    <div class="reports-field full"><label for="taskProjectId">Proyecto</label><select id="taskProjectId" title="Seleccione el proyecto a incluir en el reporte."><%= ProjectOptionsHtml %></select></div>
                    <div class="reports-field"><label for="taskStatus">Estatus tarea</label><select id="taskStatus" title="Filtra las tareas por estatus."><option value="">Todos</option><option value="Planificado">Planificado</option><option value="En ejecución">En ejecución</option><option value="Bloqueado">Bloqueado</option><option value="Completado">Completado</option></select></div>
                    <div class="reports-field"><label for="taskPriority">Prioridad tarea</label><select id="taskPriority" title="Filtra las tareas por prioridad."><option value="">Todas</option><option value="Bajo">Bajo</option><option value="Medio">Medio</option><option value="Alto">Alto</option></select></div>
                </div>
                <div class="reports-actions"><button type="button" id="btnProjectTaskReport">Generar reporte</button></div>
            </article>

            <article class="reports-card">
                <h3>Usuarios y tareas asignadas</h3>
                <p>Visualice por usuario las tareas asignadas y estado actual de cada una.</p>
                <div class="reports-form-grid">
                    <div class="reports-field full"><label for="userId">Usuario</label><select id="userId" title="Seleccione un usuario específico o deje todos."><%= UserOptionsHtml %></select></div>
                    <div class="reports-field"><label for="userTaskStatus">Estatus tarea</label><select id="userTaskStatus" title="Filtra tareas del usuario por estatus."><option value="">Todos</option><option value="Planificado">Planificado</option><option value="En ejecución">En ejecución</option><option value="Bloqueado">Bloqueado</option><option value="Completado">Completado</option></select></div>
                </div>
                <div class="reports-actions"><button type="button" id="btnUserTaskReport">Generar reporte</button></div>
            </article>
        </section>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="../Scripts/app-common.js"></script>
    <script type="text/javascript">
        $(function () {
            initializeTooltips();
            initializeDatePicker("#projectStartFrom");
            initializeDatePicker("#projectEndTo");

            $("#btnProjectStatusReport").on("click", openProjectStatusReport);
            $("#btnProjectTaskReport").on("click", openProjectTaskReport);
            $("#btnUserTaskReport").on("click", openUserTaskReport);
        });

        function openProjectStatusReport() {
            var query = [];
            query.push("name=" + encodeURIComponent($.trim($("#projectName").val() || "")));
            query.push("status=" + encodeURIComponent($("#projectStatus").val() || ""));
            query.push("priority=" + encodeURIComponent($("#projectPriority").val() || ""));
            query.push("startFrom=" + encodeURIComponent($("#projectStartFrom").val() || ""));
            query.push("endTo=" + encodeURIComponent($("#projectEndTo").val() || ""));
            query.push("tzOffset=" + encodeURIComponent(getClientTimezoneOffset()));
            window.open("ProjectStatusReport.aspx?" + query.join("&"), "_blank");
        }

        function openProjectTaskReport() {
            var projectId = $("#taskProjectId").val() || "";
            if (!projectId) {
                alert("Seleccione un proyecto para generar el reporte.");
                return;
            }

            var query = [];
            query.push("projectId=" + encodeURIComponent(projectId));
            query.push("status=" + encodeURIComponent($("#taskStatus").val() || ""));
            query.push("priority=" + encodeURIComponent($("#taskPriority").val() || ""));
            query.push("tzOffset=" + encodeURIComponent(getClientTimezoneOffset()));
            window.open("ProjectTaskStatusReport.aspx?" + query.join("&"), "_blank");
        }

        function openUserTaskReport() {
            var query = [];
            query.push("userId=" + encodeURIComponent($("#userId").val() || ""));
            query.push("status=" + encodeURIComponent($("#userTaskStatus").val() || ""));
            query.push("tzOffset=" + encodeURIComponent(getClientTimezoneOffset()));
            window.open("UserTaskAssignmentReport.aspx?" + query.join("&"), "_blank");
        }

        function getClientTimezoneOffset() {
            return new Date().getTimezoneOffset();
        }
    </script>
</asp:Content>
