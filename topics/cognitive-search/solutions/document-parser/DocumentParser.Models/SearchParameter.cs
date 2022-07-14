namespace DocumentParser.Models
{
    public record SearchParameter
    {
        public string search { get; set; }
        public string searchFields { get; set; }
        public string filter { get; set; }
        public string highlight { get; set; }
    }
}