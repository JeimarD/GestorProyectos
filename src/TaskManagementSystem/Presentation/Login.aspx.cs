using System;
using System.Web.Script.Services;
using System.Web.Services;
using Logic.Services;
using Objects.Entities;
using Presentation.Helpers;
using Presentation.Models;

namespace Presentation
{
    public partial class Login : BasePage
    {
        protected override bool RequiresAuthentication
        {
            get { return false; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Request.QueryString["logout"] == "1")
            {
                CookieSessionManager.ClearAuthenticationCookie();
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (CookieSessionManager.GetCurrentUser() != null)
            {
                Response.Redirect("~/Pages/Dashboard.aspx", true);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse Authenticate(LoginRequest request)
        {
            try
            {
                AuthService authService = new AuthService();
                AuthenticatedUser user = authService.Authenticate(request);

                if (user == null)
                {
                    return new AjaxResponse
                    {
                        Success = false,
                        Message = "Usuario o contraseña inválidos."
                    };
                }

                CookieSessionManager.CreateAuthenticationCookie(user);

                return new AjaxResponse
                {
                    Success = true,
                    RedirectUrl = "Pages/Dashboard.aspx"
                };
            }
            catch (Exception exception)
            {
                return new AjaxResponse
                {
                    Success = false,
                    Message = exception.Message
                };
            }
        }
    }
}
