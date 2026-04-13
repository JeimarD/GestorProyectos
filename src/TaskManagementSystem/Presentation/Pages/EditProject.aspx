<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="EditProject.aspx.cs" Inherits="Presentation.Pages.EditProject" %>
<asp:Content ID="EditProjectTitle" ContentPlaceHolderID="HeadTitle" runat="server">Editar proyecto</asp:Content>
<asp:Content ID="EditProjectHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
</asp:Content>
<asp:Content ID="EditProjectTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">edit_square</span>
        <input type="text" value="Configuración del proyecto" readonly="readonly" title="Vista de configuración para actualizar la información del proyecto." />
    </div>
</asp:Content>
<asp:Content ID="EditProjectMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-content create-project-content edit-project-content">
        <input type="hidden" id="projectId" value="<%= ProjectId %>" />

        <div class="create-project-heading">
            <nav class="create-project-breadcrumb"><a href="Projects.aspx">Proyectos</a><span class="material-symbols-outlined">chevron_right</span><a href="ProjectDetails.aspx?projectId=<%= ProjectId %>">Detalle</a><span class="material-symbols-outlined">chevron_right</span><span>Editar</span></nav>
            <h1>Editar proyecto</h1>
            <p>Actualice la información clave del proyecto y mantenga su estado operativo al día.</p>
        </div>

        <section class="edit-project-hero">
            <div>
                <span class="edit-project-kicker">Ficha del proyecto</span>
                <h2><%= Server.HtmlEncode(ProjectName) %></h2>
                <p>Cliente: <strong><%= Server.HtmlEncode(ClientName) %></strong></p>
            </div>
            <span class="projects-status-badge <%= ProjectStatusClass %>"><%= Server.HtmlEncode(ProjectStatus) %></span>
        </section>

        <div class="edit-project-grid">
            <div class="create-project-main-column">
                <section class="create-project-card">
                    <h3><span class="material-symbols-outlined">badge</span>Identidad del proyecto</h3>
                    <div class="create-project-form-stack">
                        <div class="create-project-field"><label for="projectName">Nombre del proyecto</label><input type="text" id="projectName" value="<%= Server.HtmlEncode(ProjectName) %>" title="Nombre oficial del proyecto." /></div>
                        <div class="create-project-field"><label for="projectClient">Cliente</label><input type="text" id="projectClient" value="<%= Server.HtmlEncode(ClientName) %>" title="Organización cliente responsable del proyecto." /></div>
                        <div class="create-project-field"><label for="projectDescription">Descripción</label><textarea id="projectDescription" rows="5" title="Resumen funcional y técnico del proyecto."><%= Server.HtmlEncode(ProjectDescription) %></textarea></div>
                    </div>
                </section>

                <section class="create-project-card">
                    <h3><span class="material-symbols-outlined">group</span>Equipo principal</h3>
                    <div class="create-project-team-copy"><strong>Asignar colaboradores al proyecto</strong><p>Solo los colaboradores asignados podrán ver y trabajar sobre este proyecto.</p></div>
                    <div id="projectCollaboratorList" class="edit-project-collaborator-list"></div>
                    <div id="projectCollaboratorEmpty" class="edit-project-collaborator-empty is-hidden">No hay colaboradores activos disponibles para asignar.</div>
                    <div id="projectCollaboratorMessage" class="message create-project-message"></div>
                    <div class="edit-project-collaborator-counter">Asignados: <strong id="projectCollaboratorCount">0</strong></div>
                    <div class="edit-project-collaborator-note">Los roles Administrador y Lider de Proyecto mantienen acceso total aunque no estén asignados.</div>
                </section>
            </div>

            <div class="create-project-side-column">
                <section class="create-project-card is-soft">
                    <h4>Timeline y estado</h4>
                    <div class="create-project-form-stack">
                        <div class="create-project-field has-icon"><label for="projectStartDate">Fecha de inicio</label><div class="create-project-input-icon-wrap"><input type="text" id="projectStartDate" value="<%= StartDateValue %>" title="Fecha de arranque del proyecto." /><span class="material-symbols-outlined">calendar_today</span></div></div>
                        <div class="create-project-field has-icon"><label for="projectEndDate">Fecha de fin</label><div class="create-project-input-icon-wrap"><input type="text" id="projectEndDate" value="<%= EndDateValue %>" title="Fecha objetivo de cierre del proyecto." /><span class="material-symbols-outlined">event_upcoming</span></div></div>

                        <div class="create-project-field">
                            <label>Estado</label>
                            <div class="edit-project-status-group">
                                <button type="button" class="edit-project-status-option" data-status="Planificado">Planificado</button>
                                <button type="button" class="edit-project-status-option" data-status="En ejecución">En ejecución</button>
                                <button type="button" class="edit-project-status-option" data-status="Bloqueado">Bloqueado</button>
                                <button type="button" class="edit-project-status-option" data-status="Completado">Completado</button>
                            </div>
                            <input type="hidden" id="projectStatus" value="<%= Server.HtmlEncode(ProjectStatus) %>" />
                        </div>

                        <div class="create-project-field"><label>Nivel de prioridad</label><div class="create-project-priority-grid"><button type="button" class="create-project-priority" data-priority="Bajo">Bajo</button><button type="button" class="create-project-priority" data-priority="Medio">Medio</button><button type="button" class="create-project-priority" data-priority="Alto">Alto</button></div><input type="hidden" id="projectPriority" value="<%= Server.HtmlEncode(Priority) %>" /></div>
                    </div>
                </section>

                <section class="create-project-actions-card"><button type="button" class="create-project-submit" id="btnSaveProject">Guardar cambios</button><a class="create-project-cancel" href="ProjectDetails.aspx?projectId=<%= ProjectId %>">Cancelar</a><div id="editProjectMessage" class="message create-project-message"></div></section>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="../Scripts/app-common.js"></script>
    <script type="text/javascript">
        $(function () {
            initializeTooltips();
            initializeDatePicker("#projectStartDate");
            initializeDatePicker("#projectEndDate");
            setStatusSelection($("#projectStatus").val());
            setPrioritySelection($("#projectPriority").val());
            loadCollaboratorData();

            $("#btnSaveProject").on("click", saveProject);

            $(".edit-project-status-option").on("click", function () {
                setStatusSelection($(this).data("status"));
            });

            $(".create-project-priority").on("click", function () {
                setPrioritySelection($(this).data("priority"));
            });
        });

        function setStatusSelection(status) {
            $("#projectStatus").val(status || "Planificado");
            $(".edit-project-status-option").removeClass("is-active");
            $(".edit-project-status-option[data-status='" + $("#projectStatus").val() + "']").addClass("is-active");
        }

        function setPrioritySelection(priority) {
            $("#projectPriority").val(priority || "Medio");
            $(".create-project-priority").removeClass("is-active");
            $(".create-project-priority[data-priority='" + $("#projectPriority").val() + "']").addClass("is-active");
        }

        function saveProject() {
            var projectId = parseInt($("#projectId").val(), 10) || 0;
            var collaboratorUserIds = getSelectedCollaboratorUserIds();
            var project = {
                ProjectId: projectId,
                Name: $("#projectName").val(),
                ClientName: $("#projectClient").val(),
                Description: $("#projectDescription").val(),
                StartDate: toIsoDate($("#projectStartDate").val()),
                EndDate: emptyStringToNull(toIsoDate($("#projectEndDate").val())),
                Status: $("#projectStatus").val(),
                Priority: $("#projectPriority").val()
            };

            callPageMethod("EditProject.aspx/SaveProject", { project: project, collaboratorUserIds: collaboratorUserIds }, function (response) {
                showMessage("#editProjectMessage", response.Message, !response.Success);
                if (response.Success) {
                    setTimeout(function () {
                        window.location.href = "ProjectDetails.aspx?projectId=" + projectId;
                    }, 700);
                }
            });
        }

        function loadCollaboratorData() {
            var projectId = parseInt($("#projectId").val(), 10) || 0;
            callPageMethod("EditProject.aspx/GetCollaboratorData", { projectId: projectId }, function (response) {
                if (!response.Success) {
                    showMessage("#projectCollaboratorMessage", response.Message, true);
                    return;
                }

                renderCollaboratorList(response.Data.Collaborators || [], response.Data.AssignedUserIds || []);
            });
        }

        function renderCollaboratorList(collaborators, assignedUserIds) {
            var assigned = {};
            $.each(assignedUserIds || [], function (_, value) {
                assigned[parseInt(value, 10)] = true;
            });

            var rows = $.map(collaborators || [], function (user) {
                var userId = parseInt(user.UserId, 10);
                var checked = assigned[userId] ? " checked='checked'" : "";
                var fullName = $.trim((user.FirstName || "") + " " + (user.LastName || ""));
                if (!fullName) {
                    fullName = user.UserName || "Usuario";
                }

                return "<label class='edit-project-collaborator-item'><input type='checkbox' class='edit-project-collaborator-check' value='" + userId + "'" + checked + " title='Incluye o excluye este colaborador del proyecto.' /><div><strong>" + htmlEncode(fullName) + "</strong><span>@" + htmlEncode(user.UserName || "") + "</span></div></label>";
            });

            $("#projectCollaboratorList").html(rows.join(""));
            $("#projectCollaboratorEmpty").toggleClass("is-hidden", rows.length > 0);
            updateCollaboratorCounter();

            $(".edit-project-collaborator-check").on("change", updateCollaboratorCounter);
        }

        function updateCollaboratorCounter() {
            $("#projectCollaboratorCount").text(getSelectedCollaboratorUserIds().length);
        }

        function getSelectedCollaboratorUserIds() {
            var selected = [];
            $(".edit-project-collaborator-check:checked").each(function () {
                selected.push(parseInt($(this).val(), 10));
            });
            return selected;
        }
    </script>
</asp:Content>
