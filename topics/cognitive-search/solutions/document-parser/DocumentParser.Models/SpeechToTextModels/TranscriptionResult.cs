namespace DocumentParser.Models.SpeechToTextModels
{
    public record TranscriptionResult
    {
        public string Self { get; set; }
        public TranscriptionResultModel Model { get; set; }
        public TranscriptionResultLinks Links { get; set; }
        public TranscriptionProperties Properties { get; set; }
        public DateTime LastActionDateTime { get; set; }
        public string Status { get; set; }
        public DateTime CreatedDateTime { get; set; }
        public string Locale { get; set; }
        public string DisplayName { get; set; }
    }
}