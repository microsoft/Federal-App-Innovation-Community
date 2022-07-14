namespace DocumentParser.Models.IndexerStatusModels
{
    public record Limits
    {
        public string maxRunTime { get; set; }
        public int maxDocumentExtractionSize { get; set; }
        public int maxDocumentContentCharactersToExtract { get; set; }
    }
}