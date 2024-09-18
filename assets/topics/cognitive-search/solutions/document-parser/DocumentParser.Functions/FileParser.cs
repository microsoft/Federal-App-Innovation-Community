using DocumentParser.Business;
using DocumentParser.Models.CognitiveSearchResultModels;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace DocumentParser.Functions
{
    public class FileParser
    {
        private readonly ILogger _logger;

        public FileParser(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<FileParser>();
        }

        [Function("FileParser")]
        public async Task<bool> Run([BlobTrigger("%CognitiveSearch_Document_Container%/{name}", Connection = "DocumentBlobStorage")] byte[] myBlob, string name)
        {
            _logger.LogInformation($"Function kicked for blob\n Name: {name}");

            CognitiveSearchResult result = await new CognitiveSearchHttpClient(_logger).GetExtractedText(name).ConfigureAwait(false);

            //TODO: Get Blob properties

            //Post message to Service Bus
            await ServiceBusManager.PostMessageToTopic(result, _logger).ConfigureAwait(false);

            return true;
        }
    }
}