using System;

namespace Objects.Filters
{
    [Serializable]
    public class TaskFilter
    {
        public string Name { get; set; }

        public int? ProjectId { get; set; }

        public int? AssignedUserId { get; set; }

        public string Status { get; set; }
    }
}
