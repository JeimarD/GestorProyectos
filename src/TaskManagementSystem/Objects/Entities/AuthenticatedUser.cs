using System;

namespace Objects.Entities
{
    [Serializable]
    public class AuthenticatedUser
    {
        public int UserId { get; set; }

        public int RoleId { get; set; }

        public string RoleName { get; set; }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public string UserName { get; set; }

        public string FullName
        {
            get { return string.Format("{0} {1}", FirstName, LastName).Trim(); }
        }
    }
}
