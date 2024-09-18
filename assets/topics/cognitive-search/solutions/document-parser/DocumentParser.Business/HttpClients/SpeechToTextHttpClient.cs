using DocumentParser.Models.SpeechToTextModels;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Diagnostics;
using System.Net.Http.Json;

namespace DocumentParser.Business.HttpClients
{
    public class SpeechToTextHttpClient : BaseHttpClient
    {
        private HttpClient _httpClient;
        private readonly ILogger _logger;

        public SpeechToTextHttpClient(ILogger logger)
        {
            _logger = logger;
        }

        public async Task<TranscribedText> PostFileForTranscription(Uri blobSASUrl)
        {
            _logger.LogInformation("Posting Speech Transcription.");
            string url = Environment.GetEnvironmentVariable("SpeechToText_Url");

            Transcription transcription = new Transcription()
            {
                ContentUrls = new string[] { blobSASUrl.AbsoluteUri }
            };

            _httpClient = CreateHttpClient();
            _httpClient.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", Environment.GetEnvironmentVariable("SpeechToText_APIKey"));
            HttpResponseMessage response = await _httpClient.PostAsJsonAsync<Transcription>(url, transcription).ConfigureAwait(false);
            response.EnsureSuccessStatusCode();

            TranscribedText transcribedText = null;
            if (response.IsSuccessStatusCode)
            {
                TranscriptionResult transcriptionResult = JsonConvert.DeserializeObject<TranscriptionResult>(await response.Content.ReadAsStringAsync().ConfigureAwait(false));

                transcribedText = await GetTranscriptionResult(transcriptionResult).ConfigureAwait(false);
            }
            else
            {
                _logger.LogInformation($"Getting data failed. Reason - {await response.Content.ReadAsStringAsync().ConfigureAwait(false)}");
            }
            return transcribedText;
        }

        private async Task<TranscribedText> GetTranscriptionResult(TranscriptionResult transcriptionResult)
        {
            const string SUCCESS = "Succeeded";
            string url = transcriptionResult.Self;

            TranscriptionResultCheck response;

            _httpClient = CreateHttpClient();
            _httpClient.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", Environment.GetEnvironmentVariable("SpeechToText_APIKey"));

            //Wait till the transcription succeeds - for 30 sec or if status is sucess
            int timeout = (int)TimeSpan.Parse(Environment.GetEnvironmentVariable("SpeechToText_TimeOut")).TotalSeconds;
            Stopwatch stopwatch = Stopwatch.StartNew();
            _logger.LogInformation($"Checking status of transcription..");
            do
            {

                response = await _httpClient.GetFromJsonAsync<TranscriptionResultCheck>(url).ConfigureAwait(false);
                //Sleep for 1sec to avoid 429.
                Thread.Sleep(1000);
            } while (!response.Status.Equals(SUCCESS, StringComparison.InvariantCultureIgnoreCase)
                    || stopwatch.Elapsed.TotalSeconds > timeout);

            if (response == null || !response.Status.Equals(SUCCESS, StringComparison.InvariantCultureIgnoreCase))
            {
                _logger.LogInformation($"Finished checking transcription status. Status: {(response?.Status) ?? "FAILED"}");
                return null;
            }

            _logger.LogInformation($"Finished checking status of transcription. Status: {response.Status}");

            _logger.LogInformation($"Getting the content url of the transcribed text.");
            //Now get the Content Url of the audio
            FileTranscriptionResult fileResult = await _httpClient.GetFromJsonAsync<FileTranscriptionResult>(transcriptionResult.Links.Files).ConfigureAwait(false);

            _logger.LogInformation($"Getting the transcribed text...");
            //Now get the text
            string contentUrl = fileResult.Values.Where(item => item.Kind.Equals("Transcription", StringComparison.InvariantCultureIgnoreCase)).FirstOrDefault().Links.ContentUrl;
            TranscribedText transcribedText = await _httpClient.GetFromJsonAsync<TranscribedText>(contentUrl).ConfigureAwait(false);
            return transcribedText;
        }
    }
}