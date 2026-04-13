<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="TaskDetails.aspx.cs" Inherits="Presentation.Pages.TaskDetails" %>
<asp:Content ID="TaskDetailsTitle" ContentPlaceHolderID="HeadTitle" runat="server">Detalle de tarea</asp:Content>
<asp:Content ID="TaskDetailsHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
</asp:Content>
<asp:Content ID="TaskDetailsTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">search</span>
        <input type="text" placeholder="Buscar tareas..." title="Búsqueda visual para futuras integraciones." />
    </div>
</asp:Content>
<asp:Content ID="TaskDetailsTopbarRight" ContentPlaceHolderID="TopbarActionsContent" runat="server">
    <div class="project-detail-top-actions">
        <a class="projects-new-button" href="CreateTask.aspx?projectId=<%= ProjectId %>">Crear tarea</a>
    </div>
</asp:Content>
<asp:Content ID="TaskDetailsMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-content task-details-content">
        <nav class="task-details-breadcrumb">
            <a href="Projects.aspx">Proyectos</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <a href="ProjectDetails.aspx?projectId=<%= ProjectId %>"><%= Server.HtmlEncode(ProjectName) %></a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span>Detalle de tarea</span>
        </nav>

        <div class="task-details-grid">
            <div class="task-details-main-column">
                <section class="task-details-header-card">
                    <div class="task-details-header-top">
                        <span class="projects-status-badge <%= TaskStatusClass %>"><%= Server.HtmlEncode(TaskStatus) %></span>
                        <div class="task-details-header-actions">
                            <a href="CreateTask.aspx?taskId=<%= TaskId %>" class="task-details-action-button">Editar</a>
                        </div>
                    </div>
                    <h1><%= Server.HtmlEncode(TaskName) %></h1>
                    <div class="task-details-meta-grid">
                        <div><p>Encargado</p><strong><%= Server.HtmlEncode(AssignedUserName) %></strong></div>
                        <div><p>Inicio</p><strong><%= Server.HtmlEncode(StartDateText) %></strong></div>
                        <div><p>Fin estimada</p><strong><%= Server.HtmlEncode(EstimatedEndDateText) %></strong></div>
                        <div><p>Prioridad</p><strong><%= Server.HtmlEncode(Priority) %></strong></div>
                        <div><p>Estimado</p><strong><%= Server.HtmlEncode(EstimatedHoursText) %></strong></div>
                        <div><p>Progreso</p><strong><%= Progress %>%</strong></div>
                    </div>
                    <div class="task-details-description-block">
                        <h2>Descripción</h2>
                        <div><%= Server.HtmlEncode(TaskDescription) %></div>
                    </div>
                </section>

                <section class="task-details-comments-card">
                    <div class="task-details-section-head"><h2>Discusión</h2><span><%= CommentCount %> comentarios</span></div>
                    <div id="taskCommentsContainer" class="task-details-comments-list"></div>
                    <div class="task-details-comment-box">
                        <textarea id="taskCommentText" rows="3" placeholder="Agregar un comentario..." title="Escriba un comentario para la tarea."></textarea>
                        <div class="task-details-comment-actions"><button type="button" id="btnSaveTaskComment" class="projects-new-button">Comentar</button></div>
                    </div>
                </section>
            </div>

            <div class="task-details-side-column">
                <section class="task-details-side-card">
                    <h3>Acciones</h3>
                    <div class="task-details-action-stack">
                        <button type="button" id="btnCompleteTask" class="task-details-side-action" <%= IsTaskCompleted ? "disabled=\"disabled\"" : string.Empty %>><%= IsTaskCompleted ? "Tarea completada" : "Marcar como completada" %></button>
                        <button type="button" id="btnDeleteTask" class="task-details-side-action is-danger">Eliminar tarea</button>
                    </div>
                </section>

                <section class="task-details-side-card">
                    <div class="task-details-section-head"><h3>Adjuntos</h3><span id="taskAttachmentCount"><%= AttachmentCount %></span></div>
                    <div class="task-attachment-upload-box">
                        <input type="file" id="taskAttachmentFile" title="Seleccione un archivo para adjuntar a la tarea." accept=".png,.jpg,.jpeg,.pdf,.docx" />
                        <button type="button" id="btnUploadAttachment" class="task-details-side-action">Subir archivo</button>
                    </div>
                    <div id="taskAttachmentMessage" class="message"></div>
                    <div id="taskAttachmentsContainer" class="task-details-attachments-list"></div>
                </section>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="../Scripts/app-common.js"></script>
    <script type="text/javascript">
        $(function () {
            initializeTooltips();
            loadTaskDetailSupport();
            $("#btnSaveTaskComment").on("click", saveTaskComment);
            $("#btnCompleteTask").on("click", markTaskAsCompleted);
            $("#btnDeleteTask").on("click", deleteTask);
            $("#btnUploadAttachment").on("click", uploadTaskAttachment);
        });

        function loadTaskDetailSupport() {
            callPageMethod("TaskDetails.aspx/GetDetailData", { taskId: <%= TaskId %> }, function (response) {
                if (!response.Success) { return; }
                renderComments(response.Data.Comments || []);
                renderAttachments(response.Data.Attachments || []);
            });
        }

        function renderComments(comments) {
            var items = $.map(comments, function (comment) {
                return "<article class='task-comment-item'><div class='task-comment-head'><strong>" + htmlEncode(comment.UserName) + "</strong><span>" + htmlEncode(formatJsonDateTime(comment.CreatedAt)) + "</span></div><p>" + htmlEncode(comment.CommentText) + "</p></article>";
            });
            $("#taskCommentsContainer").html(items.join("") || "<div class='task-comment-empty'>No hay comentarios registrados.</div>");
        }

        function renderAttachments(attachments) {
            $("#taskAttachmentCount").text((attachments || []).length);

            var items = $.map(attachments, function (attachment) {
                var downloadUrl = "../Handlers/TaskAttachmentDownload.ashx?attachmentId=" + attachment.AttachmentId;
                var fileName = attachment.FileName || "Adjunto";
                return "<article class='task-attachment-item'><div class='task-attachment-meta'><strong title='" + htmlEncode(fileName) + "'>" + htmlEncode(fileName) + "</strong><span>" + htmlEncode(formatJsonDateTime(attachment.UploadedAt)) + "</span></div><a class='task-attachment-download' href='" + downloadUrl + "'>Descargar</a></article>";
            });
            $("#taskAttachmentsContainer").html(items.join("") || "<div class='task-comment-empty'>No hay adjuntos registrados.</div>");
        }

        function uploadTaskAttachment() {
            var fileInput = $("#taskAttachmentFile")[0];
            if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
                showMessage("#taskAttachmentMessage", "Seleccione un archivo antes de subirlo.", true);
                return;
            }

            var formData = new FormData();
            formData.append("taskId", "<%= TaskId %>");
            formData.append("attachment", fileInput.files[0]);

            $.ajax({
                url: "../Handlers/TaskAttachmentUpload.ashx",
                type: "POST",
                data: formData,
                processData: false,
                contentType: false,
                dataType: "json",
                success: function (response) {
                    showMessage("#taskAttachmentMessage", response.Message, !response.Success);
                    if (!response.Success) {
                        return;
                    }

                    $("#taskAttachmentFile").val("");
                    loadTaskDetailSupport();
                },
                error: function () {
                    showMessage("#taskAttachmentMessage", "No fue posible subir el archivo. Intente de nuevo.", true);
                }
            });
        }

        function saveTaskComment() {
            var comment = { TaskId: <%= TaskId %>, CommentText: $("#taskCommentText").val() };
            callPageMethod("TaskDetails.aspx/SaveComment", { comment: comment }, function (response) {
                if (!response.Success) { return; }
                $("#taskCommentText").val("");
                loadTaskDetailSupport();
            });
        }

        function markTaskAsCompleted() {
            callPageMethod("TaskDetails.aspx/MarkTaskAsCompleted", { taskId: <%= TaskId %> }, function (response) {
                if (!response.Success) {
                    return;
                }

                window.location.reload();
            });
        }

        function deleteTask() {
            if (!confirm("¿Desea eliminar esta tarea?")) {
                return;
            }

            callPageMethod("TaskDetails.aspx/DeleteTask", { taskId: <%= TaskId %> }, function (response) {
                if (!response.Success) {
                    alert(response.Message || "No fue posible eliminar la tarea.");
                    return;
                }

                window.location.href = "ProjectDetails.aspx?projectId=<%= ProjectId %>";
            });
        }
    </script>
</asp:Content>
