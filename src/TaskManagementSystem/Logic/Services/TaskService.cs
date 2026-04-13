using System;
using System.Collections.Generic;
using DataAccess.Repositories;
using Objects.Entities;
using Objects.Filters;
using Objects.Responses;

namespace Logic.Services
{
    public class TaskService
    {
        private readonly TaskRepository _taskRepository;

        public TaskService()
        {
            _taskRepository = new TaskRepository();
        }

        public IList<TaskEntity> GetTasks(TaskFilter filter)
        {
            return _taskRepository.GetTasks(filter ?? new TaskFilter());
        }

        public TaskEntity GetTaskById(int taskId)
        {
            if (taskId <= 0)
            {
                throw new ApplicationException("La tarea seleccionada no es válida.");
            }

            return _taskRepository.GetTaskById(taskId);
        }

        public OperationResult SaveTask(TaskEntity task)
        {
            if (task == null)
            {
                throw new ApplicationException("La información de la tarea es obligatoria.");
            }

            if (task.ProjectId <= 0 || string.IsNullOrWhiteSpace(task.Name) || string.IsNullOrWhiteSpace(task.Status))
            {
                throw new ApplicationException("Debe indicar proyecto, nombre y estado de la tarea.");
            }

            if (string.IsNullOrWhiteSpace(task.Priority))
            {
                throw new ApplicationException("Debe indicar la prioridad de la tarea.");
            }

            if (task.StartDate == DateTime.MinValue)
            {
                throw new ApplicationException("Debe seleccionar la fecha de inicio de la tarea.");
            }

            if (task.Status != "Planificado" && task.Status != "En ejecución" && task.Status != "Bloqueado" && task.Status != "Completado")
            {
                throw new ApplicationException("El estado de la tarea no es válido.");
            }

            if (task.Priority != "Bajo" && task.Priority != "Medio" && task.Priority != "Alto")
            {
                throw new ApplicationException("La prioridad de la tarea no es válida.");
            }

            if (task.Progress < 0 || task.Progress > 100)
            {
                throw new ApplicationException("El progreso debe estar entre 0 y 100.");
            }

            if (task.EstimatedEndDate.HasValue && task.EstimatedEndDate.Value.Date < task.StartDate.Date)
            {
                throw new ApplicationException("La fecha de fin estimada no puede ser menor que la fecha de inicio.");
            }

            return _taskRepository.SaveTask(task);
        }

        public OperationResult DeleteTask(int taskId)
        {
            if (taskId <= 0)
            {
                throw new ApplicationException("La tarea seleccionada no es válida.");
            }

            return _taskRepository.DeleteTask(taskId);
        }

        public IList<TaskCommentEntity> GetComments(int taskId)
        {
            if (taskId <= 0)
            {
                throw new ApplicationException("La tarea seleccionada no es válida.");
            }

            return _taskRepository.GetComments(taskId);
        }

        public IList<TaskAttachmentEntity> GetAttachments(int taskId)
        {
            if (taskId <= 0)
            {
                throw new ApplicationException("La tarea seleccionada no es válida.");
            }

            return _taskRepository.GetAttachments(taskId);
        }

        public TaskAttachmentEntity GetAttachmentById(int attachmentId)
        {
            if (attachmentId <= 0)
            {
                throw new ApplicationException("El adjunto seleccionado no es válido.");
            }

            return _taskRepository.GetAttachmentById(attachmentId);
        }

        public OperationResult SaveAttachment(TaskAttachmentEntity attachment)
        {
            if (attachment == null)
            {
                throw new ApplicationException("La información del adjunto es obligatoria.");
            }

            if (attachment.TaskId <= 0)
            {
                throw new ApplicationException("Debe indicar la tarea del adjunto.");
            }

            if (string.IsNullOrWhiteSpace(attachment.FileName) || string.IsNullOrWhiteSpace(attachment.FilePath))
            {
                throw new ApplicationException("El archivo del adjunto no es válido.");
            }

            return _taskRepository.SaveAttachment(attachment);
        }

        public OperationResult SaveComment(TaskCommentEntity comment)
        {
            if (comment == null || comment.TaskId <= 0 || comment.UserId <= 0 || string.IsNullOrWhiteSpace(comment.CommentText))
            {
                throw new ApplicationException("Debe indicar la tarea y el comentario.");
            }

            return _taskRepository.SaveComment(comment);
        }
    }
}
