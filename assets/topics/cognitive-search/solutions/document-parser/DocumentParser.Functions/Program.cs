using Microsoft.Extensions.Hosting;

namespace DocumentParser.Functions
{
    public class Program
    {
        public static void Main()
        {
            var host = new HostBuilder()
                .ConfigureFunctionsWorkerDefaults()

                .Build();

            host.Run();
        }
    }
}