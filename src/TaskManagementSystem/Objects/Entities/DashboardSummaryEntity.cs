using System;

namespace Objects.Entities
{
    [Serializable]
    public class DashboardSummaryEntity
    {
        public int TotalProjects { get; set; }

        public int ActiveTasks { get; set; }

        public int TotalComments { get; set; }

        public int TeamMembers { get; set; }
    }
}
