using Newtonsoft.Json;

namespace DocumentParser.Models.IndexerStatusModels
{
    public record IndexerRefreshStatus
    {
        [JsonProperty("@odata.context")]
        public string OdataContext { get; set; }

        public string name { get; set; }
        public string status { get; set; }
        public LastResult lastResult { get; set; }
        public List<ExecutionHistory> executionHistory { get; set; }
        public Limits limits { get; set; }
        public CurrentState currentState { get; set; }
    }
}