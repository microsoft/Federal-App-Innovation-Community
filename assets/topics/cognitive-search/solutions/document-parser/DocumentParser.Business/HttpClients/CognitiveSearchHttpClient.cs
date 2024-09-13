using DocumentParser.Business.HttpClients;
using DocumentParser.Models;
using DocumentParser.Models.CognitiveSearchResultModels;
using DocumentParser.Models.IndexerStatusModels;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Diagnostics;
using System.Net.Http.Json;

namespace DocumentParser.Business
{
    public class CognitiveSearchHttpClient : BaseHttpClient
    {
        private HttpClient _httpClient;
        private readonly ILogger _logger;

        private string API_KEY = Environment.GetEnvironmentVariable("CognitiveSearch.APIKEY");
        private const int TIMEOUT_IN_MINUTES = 1;

        public CognitiveSearchHttpClient(ILogger logger)
        {
            _logger = logger;
        }

        private async Task RefreshIndexer()
        {
            _logger.LogInformation("Refreshing indexer...");
            _httpClient = CreateHttpClient();

            _httpClient.DefaultRequestHeaders.Add("api-key", API_KEY);
            string url = Environment.GetEnvironmentVariable("CognitiveSearch_RefreshIndexer_URL");

            try
            {
                HttpResponseMessage response = await _httpClient.PostAsync(url, null);

                response.EnsureSuccessStatusCode();
                _logger.LogInformation($"Refreshing indexer. Result={response.StatusCode}");
            }
            catch (Exception ex)
            {
            }
        }

        private async Task<bool> GetStatusOfIndexer()

        {
            //1 update indexer
            RefreshIndexer();

            //Now check the status
            _httpClient = CreateHttpClient();

            _httpClient.DefaultRequestHeaders.Add("api-key", API_KEY);
            string url = Environment.GetEnvironmentVariable("CognitiveSearch_GetIndexStatus_URL");

            bool result = false;
            Stopwatch stopwatch = Stopwatch.StartNew();

            //do this for 1 mins
            while (!result || stopwatch.Elapsed.TotalMinutes > 3)
            {
                _logger.LogInformation("Checking status of index refresh...");
                IndexerRefreshStatus response = null;
                try
                {
                    response = await _httpClient.GetFromJsonAsync<IndexerRefreshStatus>(url);
                    result = (string.Compare(response?.lastResult.status, "success", StringComparison.InvariantCultureIgnoreCase) == 0) ? true : false;
                    _logger.LogInformation($"current status of index refresh - {response?.lastResult.status}");
                }
                catch (Exception ex)
                {
                    _logger.LogInformation($"current status of index refresh - {ex.Message }");
                }

                Thread.Sleep(1000);
            }
            stopwatch.Stop();

            _logger.LogInformation($"Finished checking status of index refresh. Out of the loop. Final result={result }");

            return result;
        }

        private static SearchParameter GenerateSearchParameters(string blobFileName)
        {
            return new SearchParameter()
            {
                search = "*",
                searchFields = "content",
                filter = $"metadata_storage_name eq '{blobFileName}'"
            };
        }

        public async Task<CognitiveSearchResult> GetExtractedText(string blobFileName)
        {
            _logger.LogInformation($"Start to get data from uploaded file...");

            bool isSuccess = await GetStatusOfIndexer().ConfigureAwait(false);

            if (isSuccess)
            {
                _logger.LogInformation($"Refresh succedeed. Now parsing extracted data.");

                _httpClient = CreateHttpClient();
                _httpClient.DefaultRequestHeaders.Add("api-key", API_KEY);
                string url = Environment.GetEnvironmentVariable("CognitiveSearch_Search_URL");

                SearchParameter searchParam = GenerateSearchParameters(blobFileName);
                HttpResponseMessage response = await _httpClient.PostAsJsonAsync<SearchParameter>(url, searchParam).ConfigureAwait(false);

                response.EnsureSuccessStatusCode();

                if (response.IsSuccessStatusCode)
                {
                    _logger.LogInformation("Got data. Bundling it up.");
                    return JsonConvert.DeserializeObject<CognitiveSearchResult>(await response.Content.ReadAsStringAsync().ConfigureAwait(false));
                }
                else
                {
                    _logger.LogInformation($"Getting data failed. Reason - {await response.Content.ReadAsStringAsync().ConfigureAwait(false)}");
                }
            }
            _logger.LogInformation($"Refresh failed. No data is parsed.");
            return new CognitiveSearchResult();
        }
    }
}