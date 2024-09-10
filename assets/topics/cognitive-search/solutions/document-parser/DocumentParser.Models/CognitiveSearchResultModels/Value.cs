using Newtonsoft.Json;

namespace DocumentParser.Models.CognitiveSearchResultModels
{
    public record Value
    {
        [JsonProperty("@search.score")]
        public double SearchScore { get; set; }

        public string Content { get; set; }
        public string Metadata_Storage_Content_Type { get; set; }
        public string Metadata_Storage_Name { get; set; }
        // public string metadata_storage_path { get; set; }
        public List<string> People { get; set; }
        public List<string> Organizations { get; set; }
        public List<string> Locations { get; set; }
        public List<string> Keyphrases { get; set; }
        // public string masked_text { get; set; }
        public string Language { get; set; }
        public string translated_text { get; set; }
        // public string merged_content { get; set; }
        public List<string> text { get; set; }
        // public List<string> layoutText { get; set; }
        public List<string> ImageTags { get; set; }
        public List<string> ImageCaption { get; set; }
        public List<object> ImageCelebrities { get; set; }
        public List<PiiEntity> Pii_Entities { get; set; }
    }
}