using System;

namespace Objects.Entities
{
    [Serializable]
    public class TaskAttachmentEntity
    {
        public int AttachmentId { get; set; }

        public int TaskId { get; set; }

        public string FileName { get; set; }

        public string FilePath { get; set; }

        public int? UploadedByUserId { get; set; }

        public DateTime UploadedAt { get; set; }
    }
}
