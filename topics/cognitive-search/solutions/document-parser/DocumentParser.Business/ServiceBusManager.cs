using Azure.Messaging.ServiceBus;
using DocumentParser.Models.CognitiveSearchResultModels;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Security.Cryptography;
using System.Text;

namespace DocumentParser.Business
{
    public static class ServiceBusManager
    {
        private static List<Byte[]> _fileContentsCache = new List<Byte[]>();

        public static async Task PostMessageToTopic(CognitiveSearchResult result, ILogger _logger)
        {
            string connectionString = Environment.GetEnvironmentVariable("ServiceBusConnection");

            string topicName = Environment.GetEnvironmentVariable("ServiceBus_TopicName");

            ServiceBusClient client;
            ServiceBusSender sender;

            client = new ServiceBusClient(connectionString);
            sender = client.CreateSender(topicName);

            ServiceBusMessage messageToPost = new ServiceBusMessage(JsonConvert.SerializeObject(result));

            string personTypeText = "";
            var personTypes = result.value[0].Pii_Entities.Where(item => string.Compare(item.text, "senator", StringComparison.InvariantCultureIgnoreCase) == 0);
            if (personTypes.Any())
            {
                personTypeText = personTypes.FirstOrDefault().text;
            }

            string personText = "";
            var persons = result.value[0].Pii_Entities.Where(item => string.Compare(item.text, "Mazie K. Hirono", StringComparison.InvariantCultureIgnoreCase) == 0
            && string.Compare(item.type, "Person", StringComparison.InvariantCultureIgnoreCase) == 0);

            if (persons.Any())
            {
                personText = persons.FirstOrDefault().text;
            }

            //TODO: Store the hashed string in cache
            //Check for duplicates

            _logger.LogInformation("Detecting for duplicates...");

            messageToPost.ApplicationProperties.Add("IsDuplicate", false);

            messageToPost.ApplicationProperties.Add("Content_Type", result.value[0].Metadata_Storage_Content_Type);

            if (!_fileContentsCache.Any())
            {
                _logger.LogInformation($"No duplicates found. isDuplicate: false");

                _fileContentsCache.Add(string.Join(' ', result.value[0].Content).SHA256ToByteArray());
                messageToPost.ApplicationProperties.Add("Organizations", string.Join(",", result.value[0].Organizations.ToArray()));
                messageToPost.ApplicationProperties.Add("PersonType", personTypeText);
                messageToPost.ApplicationProperties.Add("Person", personText);
            }
            else
            {
                if (_fileContentsCache.Any(item => item.SequenceEqual(string.Join(' ', result.value[0].Content).SHA256ToByteArray())))
                {
                    _logger.LogInformation($"{result.value[0].Metadata_Storage_Name} is duplicate. isDuplicate: true");
                    messageToPost.ApplicationProperties["IsDuplicate"] = true;
                }
                else
                {
                    _logger.LogInformation($"No duplicates found. isDuplicate: false");
                    messageToPost.ApplicationProperties.Add("Organizations", string.Join(",", result.value[0].Organizations.ToArray()));
                    messageToPost.ApplicationProperties.Add("PersonType", personTypeText);
                    messageToPost.ApplicationProperties.Add("Person", personText);
                }
            }

            _logger.LogInformation($"Posting to Message broker.");
            IList<ServiceBusMessage> messagesToPost = new List<ServiceBusMessage>();
            messagesToPost.Add(messageToPost);

            await sender.SendMessagesAsync(messagesToPost).ConfigureAwait(false);

            _logger.LogInformation($"Finished posting to Message broker.");

            await sender.DisposeAsync().ConfigureAwait(false);
            await client.DisposeAsync().ConfigureAwait(false);
        }

        private static List<byte[]> GetFileContentsFromCache()
        {
            return new List<byte[]>();
        }

        private static byte[] SHA256ToByteArray(this string s)
        {
            return SHA256.HashData(Encoding.UTF8.GetBytes(s));
        }
    }
}