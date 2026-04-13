using System;
using System.Web.Script.Services;
using System.Web.Services;
using Logic.Services;
using Objects.Entities;
using Objects.Filters;
using Presentation.Helpers;
using Presentation.Models;

namespace Presentation.Pages
{
    public partial class Users : BasePage
    {
        public override string ActiveNavigationKey
        {
            get { return "users"; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthorizationHelper.CanManageUsers(CurrentUser))
            {
                Response.Redirect("~/Pages/Dashboard.aspx", true);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetInitialData()
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanManageUsers();

                CatalogService catalogService = new CatalogService();
                UserService userService = new UserService();

                return new AjaxResponse
                {
                    Success = true,
                    Data = new
                    {
                        Roles = catalogService.GetRoles(),
                        Genders = catalogService.GetGenders(),
                        MaritalStatuses = catalogService.GetMaritalStatuses(),
                        Users = userService.GetUsers(new UserFilter())
                    }
                };
            }
            catch (Exception exception)
            {
                return BuildErrorResponse(exception);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse SearchUsers(UserFilter filter)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanManageUsers();
                UserService userService = new UserService();

                return new AjaxResponse
                {
                    Success = true,
                    Data = userService.GetUsers(filter)
                };
            }
            catch (Exception exception)
            {
                return BuildErrorResponse(exception);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse SaveUser(UserEntity user)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanManageUsers();
                UserService userService = new UserService();
                var result = userService.SaveUser(user);

                return new AjaxResponse
                {
                    Success = result.Success,
                    Message = result.Message,
                    Data = result
                };
            }
            catch (Exception exception)
            {
                return BuildErrorResponse(exception);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse DeleteUser(int userId)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanManageUsers();
                UserService userService = new UserService();
                var result = userService.DeleteUser(userId);

                return new AjaxResponse
                {
                    Success = result.Success,
                    Message = result.Message
                };
            }
            catch (Exception exception)
            {
                return BuildErrorResponse(exception);
            }
        }

        private static AjaxResponse BuildErrorResponse(Exception exception)
        {
            return new AjaxResponse
            {
                Success = false,
                Message = exception.Message,
                RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null
            };
        }
    }
}
