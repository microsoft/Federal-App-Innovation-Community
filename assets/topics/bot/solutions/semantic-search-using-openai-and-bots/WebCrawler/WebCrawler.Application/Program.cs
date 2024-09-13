using Azure.Storage.Blobs;
using HtmlAgilityPack;
using Newtonsoft.Json;
using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.Net.Http;
using System.Runtime.CompilerServices;
using System.Text;
using static System.Net.Mime.MediaTypeNames;
using System.Text.RegularExpressions;
using System.Configuration;

namespace WebCrawler.Application
{
    internal class Program
    {
        private static string _domain = "";
        private static string _partialDomain = "";
        private static readonly int _numberOfLinksToParse = 300;

        private static async Task Main(string[] args)
        {
            string startUrl = "";
            if (args.Any())
            {
                startUrl = args[0];

                _domain = $"https://{startUrl.Split('/', StringSplitOptions.RemoveEmptyEntries)[1]}";
                string[] domains = startUrl.Split('/', StringSplitOptions.RemoveEmptyEntries)[1].Split('.');
                for (int i = 1; i < domains.Length; i++)
                {
                    _partialDomain += $".{domains[i]}";
                }
            }
            else
            {
                Console.WriteLine("Invalid number of arguments. Must provide a valid full url of a website without trailing '/'. Example:https://learn.microsoft.com");
                return;
            }

            //Get the links in recursive manner
            var visited = new HashSet<string>();
            Crawl(startUrl, visited);

            Console.WriteLine();
            Console.WriteLine("Finished Parsing. Now extracting contents for the urls.");

            //Get the file contents for each site
            ConcurrentBag<HtmlParserOutput> contents = GetFileContentsAsync(visited);

            //Add the contents to the blob
            await AddItemsToBlob(contents.AsEnumerable<HtmlParserOutput>()).ConfigureAwait(true);

            Console.WriteLine();
            Console.Write("Finished. Press any key to exit.");
            Console.ReadKey();
        }

        private static ConcurrentBag<HtmlParserOutput> GetFileContentsAsync(HashSet<string> visited)
        {
            HttpClient client = HttpClientFactory.Create();

            ConcurrentBag<HtmlParserOutput> contents = new ConcurrentBag<HtmlParserOutput>();

            Parallel.ForEach(visited, url =>
            {
                try
                {
                    string websiteContent = client.GetStringAsync(url).Result;
                    var doc = new HtmlDocument();
                    doc.LoadHtml(websiteContent);
                    contents.Add(new HtmlParserOutput()
                    {
                        Url = url,
                        Contents = doc.DocumentNode.InnerText.RemoveExtraSpaces()
                    });
                }
                catch
                {
                    var ex = "";
                }
            });
            return contents;
        }

        private static async Task AddItemsToBlob(IEnumerable<HtmlParserOutput> docs)
        {
            Console.WriteLine();
            Console.WriteLine("Now uploading contents to the blob.");

            BlobServiceClient bloblClient = new BlobServiceClient(ConfigurationManager.AppSettings["StorageConnectionString"]);
            BlobContainerClient containerClient = bloblClient.GetBlobContainerClient(ConfigurationManager.AppSettings["ContainerName"]);

            foreach (HtmlParserOutput doc in docs)
            {
                BlobClient blob = containerClient.GetBlobClient((Guid.NewGuid().ToString()));
                using (MemoryStream ms = new MemoryStream(Encoding.UTF8.GetBytes(doc.Contents)))
                {
                    blob.UploadAsync(ms);
                }
                IDictionary<string, string> metadata = new Dictionary<string, string>();
                metadata.Add("fileSource", doc.Url);
                blob.SetMetadataAsync(metadata);
            };
        }

        private static void Crawl(string url, HashSet<string> visited)
        {
            if (visited.Contains(url) || visited.Count == _numberOfLinksToParse) return;

            visited.Add(url);

            Console.WriteLine(url);

            try
            {
                var web = new HtmlWeb();
                var doc = web.Load(url);

                var links = doc.DocumentNode.Descendants("a")
                    .Select(a => a.GetAttributeValue("href", null))
                    .Where(u => !string.IsNullOrEmpty(u)

                     && !u.Equals("/", StringComparison.InvariantCultureIgnoreCase)
                     && (u.StartsWith("https:", StringComparison.InvariantCultureIgnoreCase)
                    || u.StartsWith("/", StringComparison.InvariantCultureIgnoreCase))
                    && !u.EndsWith(".pdf", StringComparison.InvariantCultureIgnoreCase))
                    .ToList();

                foreach (var link in links)
                {
                    string urlToParse = link;

                    if (link.StartsWith("/", StringComparison.InvariantCultureIgnoreCase))
                    {
                        urlToParse = $"{_domain}{link}";
                    }

                    if (!urlToParse.Contains(_partialDomain, StringComparison.InvariantCultureIgnoreCase))
                    {
                        continue;
                    }

                    Crawl($"{urlToParse}", visited);
                }
            }
            catch (Exception ex)
            {
                //If invalid site, do not track
                visited.Remove(url);
                Console.WriteLine($"*** ERROR ****: Could not load web page '{url}'. Skipping page.");
            }
        }
    }
}