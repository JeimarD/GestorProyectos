using System;

namespace Presentation.Models
{
    [Serializable]
    public class AjaxResponse
    {
        public bool Success { get; set; }

        public string Message { get; set; }

        public string RedirectUrl { get; set; }

        public object Data { get; set; }
    }
}
