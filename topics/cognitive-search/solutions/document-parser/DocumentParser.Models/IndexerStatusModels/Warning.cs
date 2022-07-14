namespace DocumentParser.Models.IndexerStatusModels
{
    public record Warning
    {
        public string key { get; set; }
        public string name { get; set; }
        public string message { get; set; }
        public string details { get; set; }
        public string documentationLink { get; set; }
    }
}