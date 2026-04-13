using System;
using System.Collections.Generic;
using DataAccess.Repositories;
using Objects.Entities;
using Objects.Filters;
using Objects.Responses;

namespace Logic.Services
{
    public class ProjectService
    {
        private readonly ProjectRepository _projectRepository;

        public ProjectService()
        {
            _projectRepository = new ProjectRepository();
        }

        public IList<ProjectEntity> GetProjects(ProjectFilter filter)
        {
            return _projectRepository.GetProjects(filter ?? new ProjectFilter());
        }

        public ProjectEntity GetProjectById(int projectId)
        {
            if (projectId <= 0)
            {
                throw new ApplicationException("El proyecto seleccionado no es válido.");
            }

            return _projectRepository.GetProjectById(projectId);
        }

        public OperationResult SaveProject(ProjectEntity project)
        {
            if (project == null)
            {
                throw new ApplicationException("La información del proyecto es obligatoria.");
            }

            if (string.IsNullOrWhiteSpace(project.Name) || string.IsNullOrWhiteSpace(project.Status))
            {
                throw new ApplicationException("Debe indicar nombre y estado del proyecto.");
            }

            if (string.IsNullOrWhiteSpace(project.ClientName))
            {
                throw new ApplicationException("Debe indicar el cliente del proyecto.");
            }

            if (string.IsNullOrWhiteSpace(project.Priority))
            {
                throw new ApplicationException("Debe indicar la prioridad del proyecto.");
            }

            if (project.Status != "Planificado" && project.Status != "En ejecución" && project.Status != "Bloqueado" && project.Status != "Completado")
            {
                throw new ApplicationException("El estado del proyecto no es válido.");
            }

            if (project.Priority != "Bajo" && project.Priority != "Medio" && project.Priority != "Alto")
            {
                throw new ApplicationException("La prioridad del proyecto no es válida.");
            }

            if (project.StartDate == DateTime.MinValue)
            {
                throw new ApplicationException("Debe seleccionar la fecha de inicio del proyecto.");
            }

            return _projectRepository.SaveProject(project);
        }

        public OperationResult DeleteProject(int projectId)
        {
            if (projectId <= 0)
            {
                throw new ApplicationException("El proyecto seleccionado no es válido.");
            }

            return _projectRepository.DeleteProject(projectId);
        }
    }
}
