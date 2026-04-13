using System;

namespace Objects.Entities
{
    [Serializable]
    public class ActivityLogEntity
    {
        public int ActivityId { get; set; }

        public string EntityType { get; set; }

        public string ActivityType { get; set; }

        public string Description { get; set; }

        public int? RelatedProjectId { get; set; }

        public int? RelatedTaskId { get; set; }

        public int? PerformedByUserId { get; set; }

        public string PerformedByName { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
