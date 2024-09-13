namespace DocumentParser.Models.SpeechToTextModels
{
    public record TranscriptionResultProperties
    {
        public bool DiarizationEnabled { get; set; }
        public bool WordLevelTimestampsEnabled { get; set; }
        public IEnumerable<int> Channels { get; set; }
        public string PunctuationMode { get; set; }
        public string ProfanityFilterMode { get; set; }
    }
}