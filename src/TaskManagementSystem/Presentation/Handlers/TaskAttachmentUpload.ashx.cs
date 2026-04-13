using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using Logic.Services;
using Objects.Entities;
using Objects.Responses;
using Presentation.Helpers;

namespace Presentation.Handlers
{
    public class TaskAttachmentUpload : IHttpHandler
    {
        private const int MaxFileSizeInBytes = 10 * 1024 * 1024;
        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".png",
            ".jpg",
            ".jpeg",
            ".pdf",
            ".docx"
        };

        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            JavaScriptSerializer serializer = new JavaScriptSerializer();

            try
            {
                AuthenticatedUser currentUser = CookieSessionManager.GetCurrentUser();
                if (currentUser == null)
                {
                    context.Response.StatusCode = 401;
                    context.Response.Write(serializer.Serialize(new { Success = false, Message = "La sesión expiró. Inicie sesión nuevamente." }));
                    return;
                }

                int taskId;
                if (!int.TryParse(context.Request.Form["taskId"], out taskId) || taskId <= 0)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write(serializer.Serialize(new { Success = false, Message = "La tarea seleccionada no es válida." }));
                    return;
                }

                AuthorizationHelper.EnsureCanAccessTask(currentUser, taskId);

                HttpPostedFile file = context.Request.Files["attachment"];
                if (file == null || file.ContentLength <= 0)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write(serializer.Serialize(new { Success = false, Message = "Debe seleccionar un archivo para adjuntar." }));
                    return;
                }

                if (file.ContentLength > MaxFileSizeInBytes)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write(serializer.Serialize(new { Success = false, Message = "El archivo supera el tamaño máximo permitido de 10MB." }));
                    return;
                }

                string originalFileName = SanitizeFileName(file.FileName);
                string extension = Path.GetExtension(originalFileName);

                if (string.IsNullOrWhiteSpace(extension) || !AllowedExtensions.Contains(extension))
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write(serializer.Serialize(new { Success = false, Message = "Tipo de archivo no permitido. Use PNG, JPG, PDF o DOCX." }));
                    return;
                }

                TaskService taskService = new TaskService();
                TaskEntity task = taskService.GetTaskById(taskId);
                if (task == null)
                {
                    context.Response.StatusCode = 404;
                    context.Response.Write(serializer.Serialize(new { Success = false, Message = "La tarea seleccionada no existe." }));
                    return;
                }

                string relativeDirectory = string.Format("App_Data/Uploads/Tasks/{0}", taskId);
                string absoluteDirectory = context.Server.MapPath("~/" + relativeDirectory);
                Directory.CreateDirectory(absoluteDirectory);

                string storedFileName = Guid.NewGuid().ToString("N") + extension.ToLowerInvariant();
                string absolutePath = Path.Combine(absoluteDirectory, storedFileName);
                string relativePath = string.Format("{0}/{1}", relativeDirectory, storedFileName);

                file.SaveAs(absolutePath);

                try
                {
                    OperationResult result = taskService.SaveAttachment(new TaskAttachmentEntity
                    {
                        TaskId = taskId,
                        FileName = originalFileName,
                        FilePath = relativePath,
                        UploadedByUserId = currentUser.UserId
                    });

                    context.Response.Write(serializer.Serialize(new
                    {
                        Success = result.Success,
                        Message = result.Message,
                        Data = new { AttachmentId = result.NewId }
                    }));
                }
                catch
                {
                    if (File.Exists(absolutePath))
                    {
                        File.Delete(absolutePath);
                    }

                    throw;
                }
            }
            catch (Exception exception)
            {
                context.Response.StatusCode = context.Response.StatusCode == 200 ? 500 : context.Response.StatusCode;
                context.Response.Write(serializer.Serialize(new { Success = false, Message = exception.Message }));
            }
        }

        private static string SanitizeFileName(string fileName)
        {
            string safeFileName = Path.GetFileName(fileName ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(safeFileName))
            {
                return "adjunto";
            }

            char[] invalidChars = Path.GetInvalidFileNameChars();
            foreach (char invalidChar in invalidChars)
            {
                safeFileName = safeFileName.Replace(invalidChar, '_');
            }

            return safeFileName;
        }
    }
}
