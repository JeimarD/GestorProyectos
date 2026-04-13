using System;

namespace Objects.Entities
{
    [Serializable]
    public class TaskEntity
    {
        public int TaskId { get; set; }

        public int ProjectId { get; set; }

        public string ProjectName { get; set; }

        public int? AssignedUserId { get; set; }

        public string AssignedUserName { get; set; }

        public int? CreatedByUserId { get; set; }

        public string Name { get; set; }

        public string Description { get; set; }

        public string Status { get; set; }

        public string Priority { get; set; }

        public DateTime StartDate { get; set; }

        public int Progress { get; set; }

        public decimal? EstimatedHours { get; set; }

        public DateTime? EstimatedEndDate { get; set; }

        public DateTime? DueDate
        {
            get { return EstimatedEndDate; }
            set { EstimatedEndDate = value; }
        }

        public int CommentCount { get; set; }

        public int AttachmentCount { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
