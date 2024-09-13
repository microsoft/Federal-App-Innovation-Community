using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;
using Azure.Storage.Sas;
using DocumentParser.Business.HttpClients;
using DocumentParser.Models.SpeechToTextModels;
using Microsoft.Extensions.Logging;
using System.Text;

namespace DocumentParser.Business
{
    public class SpeechToTextManager
    {
        private readonly ILogger _logger;

        public SpeechToTextManager(ILogger logger)
        {
            _logger = logger;
        }

        public async Task PostTextFromAudioFileAsync(string blobName)
        {
            /*
             * 1. Get the blob from audiofiles container
             * 2. PAss it to Speech service and get text
             * 3. Write the text to a blob to documents container
             * 4. Call the cognitivesearchHttpClient code to return text.
             */

            _logger.LogInformation("Getting blob SAS url to process file.");
            SpeechToTextHttpClient speechBatchClient = new SpeechToTextHttpClient(_logger);
            Uri contentUri = GetBlobSASUrlForFile(blobName);

            TranscribedText transcribedText = await speechBatchClient.PostFileForTranscription(contentUri).ConfigureAwait(false);

            UploadTextToBlob(transcribedText, blobName);
        }

        private readonly string _connectionString = Environment.GetEnvironmentVariable("DocumentBlobStorage");

        private Uri GetBlobSASUrlForFile(string fileName)
        {
            // Check whether the connection string can be parsed.

            string containerName = Environment.GetEnvironmentVariable("SpeechToText_AudioFile_Container");
            BlobServiceClient blobServiceClient = new BlobServiceClient(_connectionString);
            BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(containerName);
            containerClient.CreateIfNotExists(PublicAccessType.Blob);

            BlobClient blobClient = containerClient.GetBlobClient(fileName);

            BlobSasBuilder sasBuilder = new BlobSasBuilder()
            {
                BlobContainerName = blobClient.GetParentBlobContainerClient().Name,
                BlobName = fileName,
                Resource = "b"
            };

            sasBuilder.ExpiresOn = DateTimeOffset.UtcNow.AddHours(1);
            sasBuilder.SetPermissions(BlobSasPermissions.Read | BlobSasPermissions.Write);

            Uri sasUri = blobClient.GenerateSasUri(sasBuilder);

            return sasUri;
        }

        private async Task UploadTextToBlob(TranscribedText transcribedText, string blobName)
        {
            string containerName = Environment.GetEnvironmentVariable("CognitiveSearch_Document_Container");

            _logger.LogInformation($"Uploading the transcribed text to '{containerName}' container.");
            BlobServiceClient blobServiceClient = new BlobServiceClient(_connectionString);
            BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(containerName);
            containerClient.CreateIfNotExists(PublicAccessType.Blob);

            using MemoryStream ms = new MemoryStream(Encoding.UTF8.GetBytes(transcribedText.CombinedRecognizedPhrases.FirstOrDefault().Display));
            BlobClient blobClient = containerClient.GetBlobClient($"{blobName}.txt");

            await blobClient.UploadAsync(ms).ConfigureAwait(false);
            var extensions = Path.GetExtension(blobName).Split('.');
            await blobClient.SetHttpHeadersAsync(new BlobHttpHeaders()
            {
                ContentType = $"audio/{extensions[extensions.Length - 1]}"
            }).ConfigureAwait(false);

            //Set the content type

            _logger.LogInformation($"Finished uploading the transcribed text to '{containerName}' container.");
        }
    }
}