using System;

namespace Objects.Filters
{
    [Serializable]
    public class UserFilter
    {
        public string FirstName { get; set; }

        public string LastName { get; set; }

        public string Identification { get; set; }

        public int? RoleId { get; set; }
    }
}
