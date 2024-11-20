# API Comparison: `apim_api` vs. `code_api`  
  
This README provides a detailed comparison between `apim_api` and `code_api`, helping you decide which approach best suits your needs.  
  
## Overview  
  
- **`code_api`**: Offers greater flexibility in the data you can pass to your Metadata API as payload, allowing for the tracking of both native Azure OpenAI metrics and external metrics. ***This API supports Azure OpenAI streaming for the AI response.*** 
- **`apim_api`**: Provides optimal automation for capturing and storing Azure OpenAI metrics with extra security, reducing the development overhead. ***This API does not support Azure OpenAI streaming for AI response***, since the API expects the full response body to submit metadata to either a cosmos or mysql database. Other forms of streaming can be implemented that are not Azure OpenAI native.  
  
## Key Considerations  
  
### Flexibility and Customization  
- **`code_api`**: High flexibility and customization, ideal for applications where you want more control over the metrics you capture, including external metrics from other APIs such as Azure AI Search, Bing Search, etc.  
- **`apim_api`**: Limited to native Azure OpenAI metrics but allows for some additional parameters to be sent as headers. Ideal for scenarios where less customization is needed.  
  
### Development and Maintenance Overhead  
- **`code_api`**: Requires frequent coding since there is little automation in capturing metrics before sending them to the Metadata API. Higher development and maintenance overhead.  
- **`apim_api`**: Lower development overhead due to the automation provided by APIM policies. Metrics are captured and stored automatically without much manual intervention.  
  
### Complexity of Implementation  
- **`code_api`**: More complex as it requires developers to manage the parsing and data insertion manually.  
- **`apim_api`**: Simplified through APIM policies. Native Azure OpenAI metrics are captured and stored automatically, with additional parameters handled via headers.  
  
### Frequency of Deployment  
- **`code_api`**: Suitable for environments where frequent updates and custom logic are required.  
- **`apim_api`**: Better for stable environments with less frequent updates. Metrics are captured every time the APIM API is called, automating the process.  
  
### Use Case Scenarios  
- **`code_api`**: Recommended for projects needing high customization and the ability to track various metrics, including those not native to Azure OpenAI.  
- **`apim_api`**: Ideal for projects that benefit from automation and security, with a streamlined approach to capturing and storing metrics.  
  
## Decision Matrix  
  
| Criteria                        | `code_api`                         | `apim_api`                         |  
|---------------------------------|------------------------------------|------------------------------------|  
| Flexibility                     | High                               | Low                                |  
| Customization                   | High                               | Low                                |  
| Development Overhead            | Higher                             | Lower                              |  
| Maintenance Overhead            | Higher                             | Lower                              |  
| Complexity of Implementation    | Higher                             | Lower                              |  
| Frequency of Deployment         | Frequent updates acceptable        | Stable, less frequent updates      |  
| Use Case                        | High customization and complexity  | Stability and streamlined approach |  
  

## Conclusion  
  
By considering the factors listed above, you can determine whether `code_api` or `apim_api` is the best fit for your project.  
  
- Choose **`code_api`** if your project requires high flexibility, customization, and can handle higher development and maintenance overhead. This approach is ideal for capturing a wide range of metrics, including those not native to Azure OpenAI.  
- Choose **`apim_api`** if your project benefits from a stable, streamlined approach with lower overhead and automation. This method is optimal for capturing and storing native Azure OpenAI metrics with minimal manual intervention, though it is limited in capturing additional metrics after the response is returned to the user.  
