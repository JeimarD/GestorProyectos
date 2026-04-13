using System;

namespace Objects.Entities
{
    [Serializable]
    public class TaskCommentEntity
    {
        public int CommentId { get; set; }

        public int TaskId { get; set; }

        public int UserId { get; set; }

        public string UserName { get; set; }

        public string CommentText { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
