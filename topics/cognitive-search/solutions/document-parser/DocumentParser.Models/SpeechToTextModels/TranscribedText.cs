namespace DocumentParser.Models.SpeechToTextModels
{
    public record TranscribedText
    {
        public string Source { get; set; }
        public DateTime Timestamp { get; set; }
        public int DurationInTicks { get; set; }
        public string Duration { get; set; }
        public List<TranscribedTextPhrases> CombinedRecognizedPhrases { get; set; }
    }
}