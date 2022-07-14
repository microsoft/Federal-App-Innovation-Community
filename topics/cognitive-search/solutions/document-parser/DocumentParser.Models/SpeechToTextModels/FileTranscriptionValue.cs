namespace DocumentParser.Models.SpeechToTextModels
{
    public record FileTranscriptionValue
    {
        public string Self { get; set; }
        public string Name { get; set; }
        public string Kind { get; set; }
        public FileTranscriptionProperties Properties { get; set; }
        public DateTime CreatedDateTime { get; set; }
        public FileTranscriptionLinks Links { get; set; }
    }
}