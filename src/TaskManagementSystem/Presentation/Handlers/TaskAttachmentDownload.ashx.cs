using System;
using System.IO;
using System.Web;
using Logic.Services;
using Objects.Entities;
using Presentation.Helpers;

namespace Presentation.Handlers
{
    public class TaskAttachmentDownload : IHttpHandler
    {
        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            try
            {
                AuthenticatedUser currentUser = CookieSessionManager.GetCurrentUser();
                if (currentUser == null)
                {
                    context.Response.StatusCode = 401;
                    context.Response.Write("La sesión expiró. Inicie sesión nuevamente.");
                    return;
                }

                int attachmentId;
                if (!int.TryParse(context.Request.QueryString["attachmentId"], out attachmentId) || attachmentId <= 0)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("El adjunto solicitado no es válido.");
                    return;
                }

                TaskService taskService = new TaskService();
                TaskAttachmentEntity attachment = taskService.GetAttachmentById(attachmentId);
                if (attachment == null)
                {
                    context.Response.StatusCode = 404;
                    context.Response.Write("El adjunto solicitado no existe.");
                    return;
                }

                AuthorizationHelper.EnsureCanAccessTask(currentUser, attachment.TaskId);

                string normalizedRelativePath = (attachment.FilePath ?? string.Empty).Replace('\\', '/').TrimStart('/');
                if (!normalizedRelativePath.StartsWith("App_Data/Uploads/Tasks/", StringComparison.OrdinalIgnoreCase))
                {
                    context.Response.StatusCode = 403;
                    context.Response.Write("El adjunto solicitado no es válido.");
                    return;
                }

                string absolutePath = context.Server.MapPath("~/" + normalizedRelativePath);

                if (!File.Exists(absolutePath))
                {
                    context.Response.StatusCode = 404;
                    context.Response.Write("El archivo solicitado no se encontró en el servidor.");
                    return;
                }

                context.Response.Clear();
                context.Response.ContentType = MimeMapping.GetMimeMapping(attachment.FileName);
                context.Response.AddHeader("Content-Disposition", "attachment; filename=\"" + SanitizeHeaderValue(attachment.FileName) + "\"");
                context.Response.TransmitFile(absolutePath);
                context.Response.Flush();
            }
            catch (Exception exception)
            {
                context.Response.StatusCode = 500;
                context.Response.Write(exception.Message);
            }
            finally
            {
                context.ApplicationInstance.CompleteRequest();
            }
        }

        private static string SanitizeHeaderValue(string value)
        {
            string sanitized = (value ?? "adjunto").Replace("\r", string.Empty).Replace("\n", string.Empty);
            return string.IsNullOrWhiteSpace(sanitized) ? "adjunto" : sanitized;
        }
    }
}
