using Newtonsoft.Json;

namespace DocumentParser.Models.CognitiveSearchResultModels
{
    public record CognitiveSearchResult
    {
        [JsonProperty("@odata.context")]
        public string OdataContext { get; set; }

        public List<Value> value { get; set; }
    }
}