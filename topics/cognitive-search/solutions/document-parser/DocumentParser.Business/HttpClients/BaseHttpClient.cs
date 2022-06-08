using Microsoft.Extensions.DependencyInjection;

namespace DocumentParser.Business.HttpClients
{
    public abstract class BaseHttpClient
    {
        private readonly IHttpClientFactory _httpClientFactory;

        public BaseHttpClient()
        {
            var serviceProvider = new ServiceCollection().AddHttpClient().BuildServiceProvider();
            _httpClientFactory = serviceProvider.GetService<IHttpClientFactory>();
        }

        public HttpClient CreateHttpClient()
        {
            return _httpClientFactory.CreateClient();
        }
    }
}