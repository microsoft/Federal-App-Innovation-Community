namespace DocumentParser.Models.SpeechToTextModels
{
    public record Transcription
    {
        public Transcription()
        {
            Properties = new TranscriptionProperties() { WordLevelTimestampsEnabled = true };
            Locale = "en-US";
            DisplayName = "Transcription of container using default model for en-US";
        }

        public IEnumerable<string> ContentUrls { get; set; }
        public TranscriptionProperties Properties { get; set; }
        public string Locale { get; set; }
        public string DisplayName { get; set; }
    }
}