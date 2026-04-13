using System;

namespace Objects.Entities
{
    [Serializable]
    public class UserEntity
    {
        public int UserId { get; set; }

        public int RoleId { get; set; }

        public string RoleName { get; set; }

        public int GenderId { get; set; }

        public string GenderName { get; set; }

        public int MaritalStatusId { get; set; }

        public string MaritalStatusName { get; set; }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public string Identification { get; set; }

        public DateTime BirthDate { get; set; }

        public string UserName { get; set; }

        public string Password { get; set; }

        public string PasswordHash { get; set; }

        public bool IsActive { get; set; }
    }
}
