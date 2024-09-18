using Newtonsoft.Json;
namespace Models
{    public  class Bike
    {
        [JsonProperty(PropertyName = "id")]
        public string ID { get; set; }
        public string Model {get;set;}
        public string Make {get;set;}
        public double Price {get;set;}
        public int Quantity {get;set;}
    }
}