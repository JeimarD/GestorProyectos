using System;
using System.Security.Cryptography;
using System.Text;

namespace Logic.Helpers
{
    public static class PasswordHasher
    {
        public static string ComputeSha256(string value)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(value ?? string.Empty);
                byte[] hash = sha256.ComputeHash(bytes);
                StringBuilder builder = new StringBuilder();

                foreach (byte item in hash)
                {
                    builder.Append(item.ToString("x2"));
                }

                return builder.ToString().ToUpperInvariant();
            }
        }
    }
}
