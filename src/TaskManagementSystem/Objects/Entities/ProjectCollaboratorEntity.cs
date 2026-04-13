using System;

namespace Objects.Entities
{
    [Serializable]
    public class ProjectCollaboratorEntity
    {
        public int ProjectId { get; set; }

        public int UserId { get; set; }

        public string UserName { get; set; }

        public string FullName { get; set; }

        public string RoleName { get; set; }
    }
}
