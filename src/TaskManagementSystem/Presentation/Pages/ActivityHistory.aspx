<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="ActivityHistory.aspx.cs" Inherits="Presentation.Pages.ActivityHistory" %>
<asp:Content ID="ActivityHistoryTitle" ContentPlaceHolderID="HeadTitle" runat="server">Historial de actividad</asp:Content>
<asp:Content ID="ActivityHistoryTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">history</span>
        <input type="text" value="Auditoría de actividad" readonly="readonly" title="Vista de auditoría de acciones recientes del sistema." />
    </div>
</asp:Content>
<asp:Content ID="ActivityHistoryMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-content activity-history-content">
        <section class="activity-history-header">
            <div>
                <h2>Historial de actividad</h2>
                <p>Consulta de acciones recientes del sistema con filtros por usuario, entidad y fechas.</p>
            </div>
            <a class="dashboard-secondary-action" href="Dashboard.aspx">Volver al dashboard</a>
        </section>

        <section class="activity-history-filters">
            <div class="activity-history-filter-grid">
                <div class="activity-history-field"><label for="activityUserName">Usuario</label><input type="text" id="activityUserName" placeholder="Nombre del usuario" title="Filtra por nombre del usuario que realizó la actividad." /></div>
                <div class="activity-history-field"><label for="activityEntityType">Entidad</label><select id="activityEntityType" title="Filtra por tipo de entidad afectada."><option value="">Todas</option><option value="Project">Proyecto</option><option value="Task">Tarea</option><option value="TaskComment">Comentario</option></select></div>
                <div class="activity-history-field"><label for="activityType">Acción</label><select id="activityType" title="Filtra por tipo de acción registrada."><option value="">Todas</option><option value="Create">Creación</option><option value="Update">Actualización</option><option value="StatusChange">Cambio de estado</option></select></div>
                <div class="activity-history-field"><label for="activityFromDate">Desde</label><input type="date" id="activityFromDate" title="Fecha inicial del rango de consulta." /></div>
                <div class="activity-history-field"><label for="activityToDate">Hasta</label><input type="date" id="activityToDate" title="Fecha final del rango de consulta." /></div>
                <div class="activity-history-field"><label for="activityMaxRows">Límite de consulta</label><select id="activityMaxRows" title="Cantidad máxima de registros a consultar."><option value="100" selected="selected">100</option><option value="200">200</option><option value="500">500</option></select></div>
            </div>
            <div class="activity-history-actions">
                <button type="button" id="btnApplyActivityFilters" class="projects-new-button">Aplicar filtros</button>
                <button type="button" id="btnClearActivityFilters" class="task-details-action-button">Limpiar</button>
            </div>
            <div id="activityHistoryMessage" class="message"></div>
        </section>

        <section class="activity-history-table-panel">
            <table class="activity-history-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Fecha</th>
                        <th>Usuario</th>
                        <th>Entidad</th>
                        <th>Acción</th>
                        <th>Descripción</th>
                        <th>Proyecto</th>
                        <th>Tarea</th>
                    </tr>
                </thead>
                <tbody id="activityHistoryRows"></tbody>
            </table>
            <div class="activity-history-pagination" id="activityHistoryPagination"></div>
        </section>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="../Scripts/app-common.js"></script>
    <script type="text/javascript">
        var activityCache = [];
        var activityCurrentPage = 1;
        var activityPageSize = 10;

        $(function () {
            initializeTooltips();
            loadActivityHistory();
            $("#btnApplyActivityFilters").on("click", loadActivityHistory);
            $("#btnClearActivityFilters").on("click", clearActivityFilters);
        });

        function loadActivityHistory() {
            var filter = {
                UserName: $("#activityUserName").val(),
                EntityType: $("#activityEntityType").val(),
                ActivityType: $("#activityType").val(),
                FromDate: $("#activityFromDate").val(),
                ToDate: $("#activityToDate").val(),
                TimezoneOffsetMinutes: new Date().getTimezoneOffset(),
                MaxRows: parseInt($("#activityMaxRows").val(), 10) || 200
            };

            callPageMethod("ActivityHistory.aspx/GetActivityHistory", { filter: filter }, function (response) {
                showMessage("#activityHistoryMessage", response.Message, !response.Success);

                if (!response.Success) {
                    return;
                }

                activityCache = $.makeArray(response.Data || []).sort(function (left, right) {
                    return (parseInt(right.ActivityId, 10) || 0) - (parseInt(left.ActivityId, 10) || 0);
                });
                activityCurrentPage = 1;
                renderActivityRows();
            });
        }

        function clearActivityFilters() {
            $("#activityUserName").val("");
            $("#activityEntityType").val("");
            $("#activityType").val("");
            $("#activityFromDate").val("");
            $("#activityToDate").val("");
            $("#activityMaxRows").val("100");
            loadActivityHistory();
        }

        function renderActivityRows() {
            var total = activityCache.length;
            var totalPages = Math.max(1, Math.ceil(total / activityPageSize));
            if (activityCurrentPage > totalPages) { activityCurrentPage = totalPages; }
            if (activityCurrentPage < 1) { activityCurrentPage = 1; }

            var startIndex = (activityCurrentPage - 1) * activityPageSize;
            var rows = activityCache.slice(startIndex, startIndex + activityPageSize);
            var html = $.map(rows, function (item) {
                var projectCell = item.RelatedProjectId ? "<a href='ProjectDetails.aspx?projectId=" + item.RelatedProjectId + "'>#" + item.RelatedProjectId + "</a>" : "-";
                var taskCell = item.RelatedTaskId ? "<a href='TaskDetails.aspx?taskId=" + item.RelatedTaskId + "'>#" + item.RelatedTaskId + "</a>" : "-";

                return "<tr>" +
                    "<td>" + htmlEncode((item.ActivityId || 0).toString()) + "</td>" +
                    "<td>" + htmlEncode(formatJsonDateTime(item.CreatedAt)) + "</td>" +
                    "<td>" + htmlEncode(item.PerformedByName || "Sistema") + "</td>" +
                    "<td>" + htmlEncode(item.EntityType || "-") + "</td>" +
                    "<td>" + htmlEncode(item.ActivityType || "-") + "</td>" +
                    "<td>" + htmlEncode(item.Description || "-") + "</td>" +
                    "<td>" + projectCell + "</td>" +
                    "<td>" + taskCell + "</td>" +
                    "</tr>";
            });

            $("#activityHistoryRows").html(html.length > 0 ? html.join("") : "<tr><td colspan='8' class='activity-history-empty'>No se encontraron registros con los filtros seleccionados.</td></tr>");
            renderActivityPagination(totalPages);
        }

        function renderActivityPagination(totalPages) {
            if (totalPages <= 1) {
                $("#activityHistoryPagination").html("");
                return;
            }

            var html = [];
            html.push("<button type='button' class='users-page-button' " + (activityCurrentPage === 1 ? "disabled='disabled'" : "") + " onclick='changeActivityPage(" + (activityCurrentPage - 1) + ")'><span class='material-symbols-outlined'>chevron_left</span></button>");
            for (var page = 1; page <= totalPages; page++) {
                html.push("<button type='button' class='users-page-button " + (page === activityCurrentPage ? "is-current" : "") + "' onclick='changeActivityPage(" + page + ")'>" + page + "</button>");
            }
            html.push("<button type='button' class='users-page-button' " + (activityCurrentPage === totalPages ? "disabled='disabled'" : "") + " onclick='changeActivityPage(" + (activityCurrentPage + 1) + ")'><span class='material-symbols-outlined'>chevron_right</span></button>");
            $("#activityHistoryPagination").html(html.join(""));
        }

        function changeActivityPage(page) {
            activityCurrentPage = page;
            renderActivityRows();
        }
    </script>
</asp:Content>
