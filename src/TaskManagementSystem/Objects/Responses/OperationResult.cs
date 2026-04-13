using System;

namespace Objects.Responses
{
    [Serializable]
    public class OperationResult
    {
        public bool Success { get; set; }

        public string Message { get; set; }

        public int? NewId { get; set; }
    }
}
