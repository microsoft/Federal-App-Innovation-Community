namespace DocumentParser.Models.IndexerStatusModels
{
    public record ExecutionHistory
    {
        public string status { get; set; }
        public object statusDetail { get; set; }
        public object errorMessage { get; set; }

        //public DateTime startTime { get; set; }
        //public DateTime endTime { get; set; }
        public int itemsProcessed { get; set; }

        public int itemsFailed { get; set; }
        public string initialTrackingState { get; set; }
        public string finalTrackingState { get; set; }
        public string mode { get; set; }
        public List<object> errors { get; set; }
        public List<Warning> warnings { get; set; }
        public object metrics { get; set; }
    }
}