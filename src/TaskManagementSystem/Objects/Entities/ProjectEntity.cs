using System;

namespace Objects.Entities
{
    [Serializable]
    public class ProjectEntity
    {
        public int ProjectId { get; set; }

        public string Name { get; set; }

        public string ClientName { get; set; }

        public string Description { get; set; }

        public DateTime StartDate { get; set; }

        public DateTime? EndDate { get; set; }

        public string Status { get; set; }

        public string Priority { get; set; }

        public int Progress { get; set; }

        public int? CreatedByUserId { get; set; }

        public string CreatedByName { get; set; }
    }
}
