<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="CreateTask.aspx.cs" Inherits="Presentation.Pages.CreateTask" %>
<asp:Content ID="CreateTaskTitle" ContentPlaceHolderID="HeadTitle" runat="server"><%= IsEditMode ? "Editar tarea" : "Crear tarea" %></asp:Content>
<asp:Content ID="CreateTaskHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
</asp:Content>
<asp:Content ID="CreateTaskTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">search</span>
        <input type="text" placeholder="Buscar arquitectura..." title="Búsqueda visual para futura integración." />
    </div>
</asp:Content>
<asp:Content ID="CreateTaskMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-content create-task-content">
        <input type="hidden" id="selectedProjectId" value="<%= SelectedProjectId %>" />
        <input type="hidden" id="editingTaskId" value="<%= EditingTaskId %>" />
        <div class="create-task-heading">
            <nav class="create-task-breadcrumb">
                <a href="Projects.aspx">Proyectos</a>
                <span class="material-symbols-outlined">chevron_right</span>
                <a href="ProjectDetails.aspx?projectId=<%= SelectedProjectId %>"><%= Server.HtmlEncode(SelectedProjectName) %></a>
                <span class="material-symbols-outlined">chevron_right</span>
                <span><%= IsEditMode ? "Editar tarea" : "Nueva tarea" %></span>
            </nav>
            <h2><%= IsEditMode ? "Editar tarea" : "Crear nueva tarea" %></h2>
        </div>

        <div class="create-task-card">
            <div class="create-task-grid create-task-grid-top">
                <div class="create-task-field">
                    <label for="taskName">Título de la tarea</label>
                    <input type="text" id="taskName" title="Ingrese el nombre de la tarea." placeholder="Ej. Implementar API de autenticación" />
                </div>
                <div class="create-task-field">
                    <label for="projectId">Proyecto relacionado</label>
                    <select id="projectId" title="Seleccione el proyecto relacionado."></select>
                </div>
            </div>

            <div class="create-task-field create-task-description-field">
                <label for="taskDescription">Descripción</label>
                <textarea id="taskDescription" rows="6" title="Describa detalladamente los requisitos de la tarea." placeholder="Escriba los detalles aquí..."></textarea>
            </div>

            <div class="create-task-grid create-task-grid-main">
                <div class="create-task-field">
                    <label for="assignedUserId">Responsable</label>
                    <select id="assignedUserId" title="Seleccione el responsable de la tarea."></select>
                </div>
                <div class="create-task-field">
                    <label for="taskPriority">Prioridad</label>
                    <select id="taskPriority" title="Seleccione la prioridad de la tarea.">
                        <option value="Bajo">Baja</option>
                        <option value="Medio" selected="selected">Media</option>
                        <option value="Alto">Alta</option>
                    </select>
                </div>
                <div class="create-task-field">
                    <label for="taskStatus">Estado</label>
                    <select id="taskStatus" title="Seleccione el estado actual de la tarea.">
                        <option value="Planificado">Planificado</option>
                        <option value="En ejecución">En ejecución</option>
                        <option value="Bloqueado">Bloqueado</option>
                        <option value="Completado">Completado</option>
                    </select>
                </div>
                <div class="create-task-field">
                    <label for="taskStartDate">Fecha de inicio</label>
                    <div class="create-task-input-icon-wrap">
                        <input type="text" id="taskStartDate" title="Seleccione la fecha de inicio." placeholder="Seleccione fecha" />
                        <span class="material-symbols-outlined">calendar_today</span>
                    </div>
                </div>
                <div class="create-task-field">
                    <label for="taskEstimatedEndDate">Fecha fin estimada</label>
                    <div class="create-task-input-icon-wrap">
                        <input type="text" id="taskEstimatedEndDate" title="Seleccione la fecha estimada de fin." placeholder="Seleccione fecha" />
                        <span class="material-symbols-outlined">event_upcoming</span>
                    </div>
                </div>
                <div class="create-task-field">
                    <label for="taskEstimatedHours">Horas estimadas</label>
                    <input type="number" id="taskEstimatedHours" min="0" step="0.5" title="Ingrese las horas estimadas." placeholder="Ej. 16" />
                </div>
                <div class="create-task-field">
                    <label for="taskProgress">Progreso (%)</label>
                    <input type="number" id="taskProgress" min="0" max="100" title="Ingrese el porcentaje de avance." value="0" />
                </div>
            </div>

            <div class="create-task-field create-task-attachments-field">
                <label for="taskAttachments">Archivos adjuntos</label>
                <div class="create-task-attachments-box" id="taskAttachments" title="Puede adjuntar un archivo opcional en formato PNG, JPG, PDF o DOCX.">
                    <div class="create-task-attachments-icon"><span class="material-symbols-outlined">upload_file</span></div>
                    <div>
                        <p>Seleccione un archivo para subirlo junto con la tarea</p>
                        <span>PNG, JPG, PDF o DOCX hasta 10MB</span>
                    </div>
                </div>
                <input type="file" id="taskAttachmentFile" class="create-task-attachment-input" title="Seleccione el archivo adjunto de la tarea." accept=".png,.jpg,.jpeg,.pdf,.docx" />
                <div id="createTaskAttachmentMessage" class="message create-task-message"></div>
            </div>

            <div class="create-task-footer">
                <div id="createTaskMessage" class="message create-task-message"></div>
                <div class="create-task-footer-actions">
                    <a class="create-task-cancel" href="ProjectDetails.aspx?projectId=<%= SelectedProjectId %>">Cancelar</a>
                    <button type="button" class="create-task-submit" id="btnCreateTask"><%= IsEditMode ? "Guardar cambios" : "Crear tarea" %></button>
                </div>
            </div>
        </div>

        <div class="create-task-bottom-grid">
            <section class="create-task-tip-card">
                <div class="create-task-tip-head"><span class="material-symbols-outlined">auto_awesome</span><span>Sugerencia</span></div>
                <p>Defina claramente responsable, prioridad y fechas para que el tablero del proyecto refleje un avance más preciso.</p>
            </section>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="../Scripts/app-common.js"></script>
    <script type="text/javascript">
        $(function () {
            initializeTooltips();
            initializeDatePicker("#taskStartDate");
            initializeDatePicker("#taskEstimatedEndDate");
            loadTaskInitialData();

            $("#btnCreateTask").on("click", saveTask);
            $("#taskStatus").on("change", syncTaskProgressWithStatus);
            $("#projectId").on("change", function () {
                var selectedProjectId = parseInt($(this).val(), 10) || 0;
                loadResponsibleUsers(selectedProjectId, null);
            });
        });

        function loadTaskInitialData() {
            var projectId = parseInt($("#selectedProjectId").val(), 10) || 0;
            var editingTaskId = parseInt($("#editingTaskId").val(), 10) || 0;

            callPageMethod("CreateTask.aspx/GetInitialData", { projectId: projectId }, function (response) {
                if (!response.Success) {
                    showMessage("#createTaskMessage", response.Message, true);
                    return;
                }

                populateSelect("#projectId", response.Data.Projects, false, "ProjectId", "Name");
                renderResponsibleSelect(response.Data.Users || []);

                if (projectId > 0 && editingTaskId === 0) {
                    $("#projectId").val(projectId.toString());
                    $("#projectId").prop("disabled", true);
                    loadResponsibleUsers(projectId, null);
                }

                if (editingTaskId > 0) {
                    loadTaskForEdit(editingTaskId);
                }
            });
        }

        function loadTaskForEdit(taskId) {
            callPageMethod("CreateTask.aspx/GetTaskById", { taskId: taskId }, function (response) {
                if (!response.Success || !response.Data) {
                    showMessage("#createTaskMessage", response.Message || "No fue posible cargar la tarea para edición.", true);
                    return;
                }

                var task = response.Data;
                loadResponsibleUsers(task.ProjectId, function () {
                    $("#taskName").val(task.Name);
                    $("#projectId").val(task.ProjectId.toString());
                    $("#assignedUserId").val((task.AssignedUserId || "").toString());
                    $("#taskPriority").val(task.Priority);
                    $("#taskStatus").val(task.Status);
                    $("#taskStartDate").val(formatJsonDate(task.StartDate));
                    $("#taskEstimatedEndDate").val(formatJsonDate(task.EstimatedEndDate));
                    $("#taskEstimatedHours").val(task.EstimatedHours == null ? "" : task.EstimatedHours);
                    $("#taskProgress").val(task.Progress);
                    $("#taskDescription").val(task.Description);
                });
            });
        }

        function loadResponsibleUsers(projectId, onComplete) {
            if (!projectId || projectId <= 0) {
                renderResponsibleSelect([]);
                if (onComplete) { onComplete(); }
                return;
            }

            callPageMethod("CreateTask.aspx/GetProjectResponsibleUsers", { projectId: projectId }, function (response) {
                if (!response.Success) {
                    showMessage("#createTaskMessage", response.Message, true);
                    renderResponsibleSelect([]);
                    if (onComplete) { onComplete(); }
                    return;
                }

                renderResponsibleSelect(response.Data || []);
                if (onComplete) { onComplete(); }
            });
        }

        function renderResponsibleSelect(users) {
            populateSelect("#assignedUserId", users || [], false, "UserId", "FirstName", "LastName");
            $("#assignedUserId").prepend("<option value=''>Sin asignar</option>");
            if (!users || users.length === 0) {
                $("#assignedUserId").html("<option value=''>Sin colaboradores asignados</option>");
            }
        }

        function syncTaskProgressWithStatus() {
            var status = $("#taskStatus").val();
            if (status === "Planificado") {
                $("#taskProgress").val("0");
            } else if (status === "Completado") {
                $("#taskProgress").val("100");
            }
        }

        function saveTask() {
            var task = {
                TaskId: parseInt($("#editingTaskId").val(), 10) || 0,
                ProjectId: parseInt($("#projectId").val(), 10) || parseInt($("#selectedProjectId").val(), 10) || 0,
                AssignedUserId: emptyToNullableInt($("#assignedUserId").val()),
                Name: $("#taskName").val(),
                Description: $("#taskDescription").val(),
                Status: $("#taskStatus").val(),
                Priority: $("#taskPriority").val(),
                StartDate: toIsoDate($("#taskStartDate").val()),
                EstimatedEndDate: emptyStringToNull(toIsoDate($("#taskEstimatedEndDate").val())),
                EstimatedHours: emptyStringToNull($("#taskEstimatedHours").val()),
                Progress: parseInt($("#taskProgress").val(), 10) || 0
            };

            callPageMethod("CreateTask.aspx/SaveTask", { task: task }, function (response) {
                showMessage("#createTaskMessage", response.Message, !response.Success);
                if (response.Success) {
                    var savedTaskId = resolveSavedTaskId(task, response);
                    if (savedTaskId === 0) {
                        showMessage("#createTaskMessage", "No fue posible identificar la tarea guardada.", true);
                        return;
                    }

                    uploadAttachmentForTask(savedTaskId, function () {
                        setTimeout(function () {
                            window.location.href = "ProjectDetails.aspx?projectId=" + task.ProjectId;
                        }, 700);
                    });
                }
            });
        }

        function resolveSavedTaskId(task, response) {
            var currentTaskId = task.TaskId || 0;
            if (currentTaskId > 0) {
                return currentTaskId;
            }

            if (response && response.Data && response.Data.NewId) {
                return parseInt(response.Data.NewId, 10) || 0;
            }

            return 0;
        }

        function uploadAttachmentForTask(taskId, onSuccess) {
            var fileInput = $("#taskAttachmentFile")[0];
            if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
                showMessage("#createTaskAttachmentMessage", "", false);
                onSuccess();
                return;
            }

            var formData = new FormData();
            formData.append("taskId", taskId.toString());
            formData.append("attachment", fileInput.files[0]);

            $.ajax({
                url: "../Handlers/TaskAttachmentUpload.ashx",
                type: "POST",
                data: formData,
                processData: false,
                contentType: false,
                dataType: "json",
                success: function (uploadResponse) {
                    showMessage("#createTaskAttachmentMessage", uploadResponse.Message, !uploadResponse.Success);
                    if (!uploadResponse.Success) {
                        return;
                    }

                    $("#taskAttachmentFile").val("");
                    onSuccess();
                },
                error: function () {
                    showMessage("#createTaskAttachmentMessage", "No fue posible subir el adjunto.", true);
                }
            });
        }
    </script>
</asp:Content>
