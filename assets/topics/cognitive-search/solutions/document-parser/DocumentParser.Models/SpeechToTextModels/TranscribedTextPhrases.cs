namespace DocumentParser.Models.SpeechToTextModels
{
    public record TranscribedTextPhrases
    {
        public int Channel { get; set; }
        public string Lexical { get; set; }
        public string Itn { get; set; }
        public string MaskedITN { get; set; }
        public string Display { get; set; }
    }
}