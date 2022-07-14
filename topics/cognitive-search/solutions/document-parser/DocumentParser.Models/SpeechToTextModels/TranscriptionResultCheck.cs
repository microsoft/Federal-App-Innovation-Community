namespace DocumentParser.Models.SpeechToTextModels
{
    public record TranscriptionResultCheck
    {
        public string Self { get; set; }
        public DateTime LastActionDateTime { get; set; }
        public string Status { get; set; }
        public DateTime CreatedDateTime { get; set; }
        public string Locale { get; set; }
        public string DisplayName { get; set; }
    }
}