using System;
using Presentation.Helpers;

namespace Presentation
{
    public partial class Default : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Dashboard.aspx", true);
        }
    }
}
