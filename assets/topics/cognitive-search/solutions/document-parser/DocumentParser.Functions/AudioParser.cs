using DocumentParser.Business;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace DocumentParser.Functions
{
    public class AudioParser
    {
        private readonly ILogger _logger;

        private readonly List<string> _validAudioFiles = Environment.GetEnvironmentVariable("SpeechToText_ValidAudioFileExtensions").Split('#').ToList();

        public AudioParser(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<AudioParser>();
        }

        [Function("AudioParser")]
        public async Task Run([BlobTrigger("%SpeechToText_AudioFile_Container%/{name}", Connection = "DocumentBlobStorage")] byte[] myBlob, string name)
        {
            string nameOfFunction = this.GetType().Name;
            _logger.LogInformation($"{nameOfFunction}: Audio parsing started for '{name}'");

            if (_validAudioFiles.Any(item => item.Equals(Path.GetExtension(name), StringComparison.InvariantCultureIgnoreCase)))
            {
                await new SpeechToTextManager(_logger).PostTextFromAudioFileAsync(name).ConfigureAwait(false);
            }
            else
            {
                _logger.LogInformation($"{nameOfFunction}: '{name}' - ERROR; Unsupported audio format. Supported formats: .wav; .mp3 ");
            }

            _logger.LogInformation($"{nameOfFunction}: Finished Audio parsing started for '{name}'{Environment.NewLine}");
        }
    }
}