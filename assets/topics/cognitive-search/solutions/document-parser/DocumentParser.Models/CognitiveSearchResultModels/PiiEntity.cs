namespace DocumentParser.Models.CognitiveSearchResultModels
{
    public record PiiEntity
    {
        public string text { get; set; }
        public string type { get; set; }
        public string subtype { get; set; }
        public int offset { get; set; }
        public int length { get; set; }
        public double score { get; set; }
    }
}