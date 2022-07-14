namespace DocumentParser.Models.SpeechToTextModels
{
    public record FileTranscriptionResult
    {
        public IEnumerable<FileTranscriptionValue> Values { get; set; }
    }
}