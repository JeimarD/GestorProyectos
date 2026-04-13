using System;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Security;
using Objects.Entities;

namespace Presentation.Helpers
{
    public static class CookieSessionManager
    {
        public const string CookieName = "TaskManagementAuth";
        private const string CookieProtectionPurpose = "TaskManagementAuthCookie.v1";
        private const int SessionDurationHours = 8;

        public static void CreateAuthenticationCookie(AuthenticatedUser user)
        {
            if (user == null)
            {
                throw new ArgumentNullException("user");
            }

            DateTime expiresAtUtc = DateTime.UtcNow.AddHours(SessionDurationHours);
            AuthCookiePayload payload = new AuthCookiePayload
            {
                UserId = user.UserId,
                RoleId = user.RoleId,
                RoleName = user.RoleName,
                FirstName = user.FirstName,
                LastName = user.LastName,
                UserName = user.UserName,
                ExpiresAtUtc = expiresAtUtc
            };

            string protectedValue = ProtectPayload(payload);
            HttpCookie cookie = new HttpCookie(CookieName, protectedValue);
            cookie.HttpOnly = true;
            cookie.Expires = expiresAtUtc.ToLocalTime();
            cookie.Secure = IsSecureRequest();
            cookie.Path = "/";

            HttpContext.Current.Response.Cookies.Remove(CookieName);
            HttpContext.Current.Response.Cookies.Add(cookie);
        }

        public static AuthenticatedUser GetCurrentUser()
        {
            HttpCookie cookie = HttpContext.Current.Request.Cookies[CookieName];

            if (cookie == null)
            {
                return null;
            }

            AuthCookiePayload protectedPayload = UnprotectPayload(cookie.Value);
            if (protectedPayload == null)
            {
                return null;
            }

            if (protectedPayload.ExpiresAtUtc <= DateTime.UtcNow)
            {
                return null;
            }

            if (protectedPayload.UserId <= 0 || protectedPayload.RoleId <= 0)
            {
                return null;
            }

            return new AuthenticatedUser
            {
                UserId = protectedPayload.UserId,
                RoleId = protectedPayload.RoleId,
                RoleName = protectedPayload.RoleName,
                FirstName = protectedPayload.FirstName,
                LastName = protectedPayload.LastName,
                UserName = protectedPayload.UserName
            };
        }

        public static void ClearAuthenticationCookie()
        {
            HttpCookie cookie = new HttpCookie(CookieName, string.Empty);
            cookie.HttpOnly = true;
            cookie.Secure = IsSecureRequest();
            cookie.Path = "/";
            cookie.Expires = DateTime.Now.AddDays(-1);

            HttpContext.Current.Response.Cookies.Remove(CookieName);
            HttpContext.Current.Response.Cookies.Add(cookie);
        }

        private static string ProtectPayload(AuthCookiePayload payload)
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            string payloadJson = serializer.Serialize(payload);
            byte[] payloadBytes = Encoding.UTF8.GetBytes(payloadJson);
            byte[] protectedBytes = MachineKey.Protect(payloadBytes, CookieProtectionPurpose);

            if (protectedBytes == null || protectedBytes.Length == 0)
            {
                throw new ApplicationException("No fue posible proteger la cookie de autenticación.");
            }

            return HttpServerUtility.UrlTokenEncode(protectedBytes);
        }

        private static AuthCookiePayload UnprotectPayload(string cookieValue)
        {
            if (string.IsNullOrWhiteSpace(cookieValue))
            {
                return null;
            }

            try
            {
                byte[] protectedBytes = HttpServerUtility.UrlTokenDecode(cookieValue);
                if (protectedBytes == null || protectedBytes.Length == 0)
                {
                    return null;
                }

                byte[] payloadBytes = MachineKey.Unprotect(protectedBytes, CookieProtectionPurpose);
                if (payloadBytes == null || payloadBytes.Length == 0)
                {
                    return null;
                }

                string payloadJson = Encoding.UTF8.GetString(payloadBytes);
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                return serializer.Deserialize<AuthCookiePayload>(payloadJson);
            }
            catch
            {
                return null;
            }
        }

        private static bool IsSecureRequest()
        {
            return HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.IsSecureConnection;
        }

        [Serializable]
        private class AuthCookiePayload
        {
            public int UserId { get; set; }

            public int RoleId { get; set; }

            public string RoleName { get; set; }

            public string FirstName { get; set; }

            public string LastName { get; set; }

            public string UserName { get; set; }

            public DateTime ExpiresAtUtc { get; set; }
        }
    }
}
