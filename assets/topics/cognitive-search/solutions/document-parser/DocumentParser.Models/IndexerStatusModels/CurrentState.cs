namespace DocumentParser.Models.IndexerStatusModels
{
    public record CurrentState
    {
        public string mode { get; set; }
        public string allDocsInitialTrackingState { get; set; }
        public string allDocsFinalTrackingState { get; set; }
        public object resetDocsInitialTrackingState { get; set; }
        public object resetDocsFinalTrackingState { get; set; }
        public List<object> resetDocumentKeys { get; set; }
        public List<object> resetDatasourceDocumentIds { get; set; }
    }
}