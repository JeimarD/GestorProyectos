using System;

namespace Objects.Entities
{
    [Serializable]
    public class UserWorkloadEntity
    {
        public int UserId { get; set; }

        public string FullName { get; set; }

        public string RoleName { get; set; }

        public int TaskCount { get; set; }

        public int LoadPercentage { get; set; }
    }
}
