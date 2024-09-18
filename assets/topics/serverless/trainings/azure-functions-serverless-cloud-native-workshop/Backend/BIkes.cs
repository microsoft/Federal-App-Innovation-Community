using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Models;

namespace Company.Function
{
    public static class Bikes
    {
        [FunctionName("Bikes")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            Models.Bike[] abk;
            try
            {
                abk                                                     = await DAL.GetAllBikesAsync();
            }
            catch (Exception exError)
            {
                return new StatusCodeResult(500);
            }

            return new JsonResult(abk);
        }
    }
}
