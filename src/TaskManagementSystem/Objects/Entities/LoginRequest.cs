using System;

namespace Objects.Entities
{
    [Serializable]
    public class LoginRequest
    {
        public string UserName { get; set; }

        public string Password { get; set; }
    }
}
