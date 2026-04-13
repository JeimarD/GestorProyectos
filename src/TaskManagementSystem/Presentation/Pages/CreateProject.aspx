<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="CreateProject.aspx.cs" Inherits="Presentation.Pages.CreateProject" %>
<asp:Content ID="CreateProjectTitle" ContentPlaceHolderID="HeadTitle" runat="server">Crear proyecto</asp:Content>
<asp:Content ID="CreateProjectHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
</asp:Content>
<asp:Content ID="CreateProjectTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">search</span>
        <input type="text" placeholder="Buscar recursos..." title="Búsqueda visual disponible para futuras integraciones." />
    </div>
</asp:Content>
<asp:Content ID="CreateProjectMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-content create-project-content">
        <div class="create-project-heading">
            <nav class="create-project-breadcrumb"><a href="Projects.aspx">Proyectos</a><span class="material-symbols-outlined">chevron_right</span><span>Crear nuevo</span></nav>
            <h1>Crear nuevo proyecto</h1>
            <p>Defina la base del proyecto y deje preparados sus datos clave para el seguimiento posterior.</p>
        </div>

        <div class="create-project-grid">
            <div class="create-project-main-column">
                <section class="create-project-card">
                    <h3><span class="material-symbols-outlined">description</span>Detalles principales</h3>
                    <div class="create-project-form-stack">
                        <div class="create-project-field"><label for="projectName">Nombre del proyecto</label><input type="text" id="projectName" placeholder="Ej. Motor Core de Integración" title="Ingrese el nombre del proyecto." /></div>
                        <div class="create-project-field"><label for="projectClient">Cliente</label><input type="text" id="projectClient" placeholder="Seleccione o escriba el cliente" title="Campo visual para futura integración de clientes." /></div>
                        <div class="create-project-field"><label for="projectDescription">Descripción</label><textarea id="projectDescription" rows="5" placeholder="Describa objetivos, alcance y requerimientos técnicos..." title="Ingrese una descripción breve del proyecto."></textarea></div>
                    </div>
                </section>

                <section class="create-project-card">
                    <h3><span class="material-symbols-outlined">groups</span>Equipo asignado</h3>
                    <div class="create-project-team-copy"><strong>Asignar colaboradores al proyecto</strong><p>Estos usuarios podrán ver el proyecto y crear/actualizar tareas dentro del mismo.</p></div>
                    <div id="createProjectCollaboratorList" class="edit-project-collaborator-list"></div>
                    <div id="createProjectCollaboratorEmpty" class="edit-project-collaborator-empty is-hidden">No hay colaboradores activos disponibles para asignar.</div>
                    <div id="createProjectCollaboratorMessage" class="message create-project-message"></div>
                    <div class="edit-project-collaborator-counter">Asignados: <strong id="createProjectCollaboratorCount">0</strong></div>
                </section>
            </div>

            <div class="create-project-side-column">
                <section class="create-project-card is-soft">
                    <h4>Timeline y prioridad</h4>
                    <div class="create-project-form-stack">
                        <div class="create-project-field has-icon"><label for="projectStartDate">Fecha de inicio</label><div class="create-project-input-icon-wrap"><input type="text" id="projectStartDate" placeholder="Seleccione fecha" title="Seleccione la fecha de inicio." /><span class="material-symbols-outlined">calendar_today</span></div></div>
                        <div class="create-project-field has-icon"><label for="projectEndDate">Fecha de fin</label><div class="create-project-input-icon-wrap"><input type="text" id="projectEndDate" placeholder="Seleccione fecha" title="Seleccione la fecha de fin si aplica." /><span class="material-symbols-outlined">event_upcoming</span></div></div>
                        <div class="create-project-field"><label for="projectStatus">Estado inicial</label><select id="projectStatus" title="Seleccione el estado actual del proyecto."><option value="Planificado">Planificado</option><option value="En ejecución">En ejecución</option><option value="Bloqueado">Bloqueado</option><option value="Completado">Completado</option></select></div>
                        <div class="create-project-field"><label>Nivel de prioridad</label><div class="create-project-priority-grid"><button type="button" class="create-project-priority" data-priority="Bajo">Bajo</button><button type="button" class="create-project-priority is-active" data-priority="Medio">Medio</button><button type="button" class="create-project-priority" data-priority="Alto">Alto</button></div><input type="hidden" id="projectPriority" value="Medio" /></div>
                    </div>
                </section>

                <section class="create-project-actions-card"><button type="button" class="create-project-submit" id="btnCreateProject">Crear proyecto</button><a class="create-project-cancel" href="Projects.aspx">Cancelar</a><div id="createProjectMessage" class="message create-project-message"></div></section>
                <section class="create-project-tip-card"><div class="create-project-tip-head"><span class="material-symbols-outlined">auto_awesome</span><span>Consejo</span></div><p>Definir una descripción clara y fechas realistas ayuda a organizar mejor el trabajo del equipo y el seguimiento del proyecto.</p></section>
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
            loadCollaboratorData();
            $("#btnCreateProject").on("click", saveProject);
            $(".create-project-priority").on("click", function () {
                $(".create-project-priority").removeClass("is-active");
                $(this).addClass("is-active");
                $("#projectPriority").val($(this).data("priority"));
            });
        });

        function saveProject() {
            var collaboratorUserIds = getSelectedCollaboratorUserIds();
            var project = { ProjectId: 0, Name: $("#projectName").val(), ClientName: $("#projectClient").val(), Description: $("#projectDescription").val(), StartDate: toIsoDate($("#projectStartDate").val()), EndDate: emptyStringToNull(toIsoDate($("#projectEndDate").val())), Status: $("#projectStatus").val(), Priority: $("#projectPriority").val() };
            callPageMethod("CreateProject.aspx/SaveProject", { project: project, collaboratorUserIds: collaboratorUserIds }, function (response) {
                showMessage("#createProjectMessage", response.Message, !response.Success);
                if (response.Success) { setTimeout(function () { window.location.href = "Projects.aspx"; }, 700); }
            });
        }

        function loadCollaboratorData() {
            callPageMethod("CreateProject.aspx/GetCollaboratorData", {}, function (response) {
                if (!response.Success) {
                    showMessage("#createProjectCollaboratorMessage", response.Message, true);
                    return;
                }

                renderCollaboratorList(response.Data.Collaborators || []);
            });
        }

        function renderCollaboratorList(collaborators) {
            var rows = $.map(collaborators || [], function (user) {
                var userId = parseInt(user.UserId, 10);
                var fullName = $.trim((user.FirstName || "") + " " + (user.LastName || ""));
                if (!fullName) {
                    fullName = user.UserName || "Usuario";
                }

                return "<label class='edit-project-collaborator-item'><input type='checkbox' class='create-project-collaborator-check' value='" + userId + "' title='Asigna este colaborador al proyecto.' /><div><strong>" + htmlEncode(fullName) + "</strong><span>@" + htmlEncode(user.UserName || "") + "</span></div></label>";
            });

            $("#createProjectCollaboratorList").html(rows.join(""));
            $("#createProjectCollaboratorEmpty").toggleClass("is-hidden", rows.length > 0);
            updateCollaboratorCounter();
            $(".create-project-collaborator-check").on("change", updateCollaboratorCounter);
        }

        function updateCollaboratorCounter() {
            $("#createProjectCollaboratorCount").text(getSelectedCollaboratorUserIds().length);
        }

        function getSelectedCollaboratorUserIds() {
            var selected = [];
            $(".create-project-collaborator-check:checked").each(function () {
                selected.push(parseInt($(this).val(), 10));
            });
            return selected;
        }
    </script>
</asp:Content>
