using System;
using System.Collections.Generic;
using DataAccess.Repositories;
using Objects.Entities;

namespace Logic.Services
{
    public class ProjectCollaboratorService
    {
        private readonly ProjectCollaboratorRepository _projectCollaboratorRepository;

        public ProjectCollaboratorService()
        {
            _projectCollaboratorRepository = new ProjectCollaboratorRepository();
        }

        public IList<int> GetProjectIdsByUser(int userId)
        {
            if (userId <= 0)
            {
                throw new ApplicationException("El usuario seleccionado no es válido.");
            }

            return _projectCollaboratorRepository.GetProjectIdsByUser(userId);
        }

        public bool IsUserCollaborator(int projectId, int userId)
        {
            if (projectId <= 0 || userId <= 0)
            {
                return false;
            }

            return _projectCollaboratorRepository.IsUserCollaborator(projectId, userId);
        }

        public IList<ProjectCollaboratorEntity> GetCollaboratorsByProject(int projectId)
        {
            if (projectId <= 0)
            {
                throw new ApplicationException("El proyecto seleccionado no es válido.");
            }

            return _projectCollaboratorRepository.GetCollaboratorsByProject(projectId);
        }

        public void SaveProjectCollaborators(int projectId, IList<int> userIds)
        {
            if (projectId <= 0)
            {
                throw new ApplicationException("El proyecto seleccionado no es válido.");
            }

            _projectCollaboratorRepository.SaveProjectCollaborators(projectId, userIds ?? new List<int>());
        }
    }
}
