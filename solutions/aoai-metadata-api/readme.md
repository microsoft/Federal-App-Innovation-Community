# Azure OpenAI Metadata API

This repository provides a comprehensive solution for capturing and storing essential metadata from Azure OpenAI API calls. It supports integration with both **MySQL** and **Cosmos** databases, ensuring flexibility and scalability for your data management needs.

## API's 
[Choosing an API](api/readme.md)
1. [code_api](api/code_api/readme.md): Created for capturing AOAI API metadata (in code) into a MySQL or Cosmos database for chat (chat completions), RAG (Index), and RAG (Querying). 
2. [apim_api](api/apim_api/readme.md): Created for capturing AOAI API metadata (in APIM policy) into a MySQL or Cosmos database for chat (chat completions), RAG (Index), and RAG (Querying). 

## Getting started
To get started with this repository, please set up you environment in the following steps:

**Build the Azure environment**
- For directions on building the Azure architecture for API's, please [click here](architecture_setup/readme.md).
  - To ***execute the API's locally***, you will need ***access*** to at least the created ***mysql server*** or ***cosmos db***.  

**Create .venv environment in code interpretor**
- Steps reflect creating .venv in VsCode
```
1. Open the command palette: CTRL + SHIFT + P
2. Search: Python: Create Environment
3. Select: Venv
4. Select the latest version of Python installed on your device.
5. .venv environment created
```

**Install the necessary libraries**
```sh
pip install -r requirements.txt  
```

**Set Env Variables**
```sh  
    OPENAI_API_BASE = "AOAI Endpoint"  
    OPENAI_API_VERSION = "AOAI API Version"  
    OPENAI_API_KEY = "AOAI API Key"  
    OPENAI_GPT_MODEL = "AOAI GPT Model deployment name" 
    OPENAI_ADA_MODEL = "AOAI ADA Model deployment name" 
    AZURE_AI_SEARCH_URL = "Azure AI Search endpoint"
    AZURE_AI_SEARCH_KEY = "Azure AI Search key"
    AZURE_AI_SEARCH_INDEX = 'Azure AI Search index name'
    azure_mysql_password = "MySQL server admin password"  
    azure_mysql_host = "MySQL server host"  
    azure_mysql_user = "MySQL admin user"  
    azure_mysql_schema = "MySQL schema (should be aoai_api)"  
    azure_cosmosdb_key = "Azure CosmosDB api key"
    azure_cosmosdb_endpoint = "Azure CosmosDB endpoint" 
    APIM_API_KEY = "APIM API Key"
    APIM_COMPLETIONS_URL = "APIM AOAI Completions URL"
    APIM_EMBEDDINGS_URL = "APIM AOAI Embeddings URL"
    ngrok_authtoken = "ngrok token to convert local api to public domain (for testing only)"
```  
- ***Note: Env variables in Azure will not need "" at each end of the string.***

## Security Best Practices for Using APIs  
  
### 1. Store API Secrets Securely  
- **Environment Variables**: Always store your API secrets in environment variables, typically in a `.env` file. This isolates sensitive information from your codebase, reducing the risk of accidental exposure. Environment variables can be configured and stored in Azure App Service once deployed. 
- **Version Control**: By default, the `.env` file for storing secrets have been added to `.gitignore`, preventing those file from being tracked by version control systems like Git.  
- **Access Control**: Restrict access to the environment variables to only those who need it. Use role-based access controls (RBAC) to enforce this.  
  
### 2. Network Restrictions  
- **IP Whitelisting**: By default, the resources created in Azure using the provided ARM templates in this repository have network restrictions that limit access to your specific IPV4 address. This adds an extra layer of security by ensuring that only trusted IP addresses can access these resources:
  - **App Service**: Ensures that only traffic from your specified IPV4 address can reach your app service.  
  - **Cosmos DB**: Limits database access to your specified IPV4 address, reducing the risk of unauthorized data access.  
  - **MySQL Flexible Server**: Restricts database access to your specified IPV4 address, enhancing security.  
  
### 3. Extra Security Considerations
- **Encryption**: Ensure that all data transmitted to and from your APIs is encrypted using HTTPS. Azure takes care of this when deployed to an App Service.  
- **API Gateway**: Utilize an API Gateway such as ***Azure API Management (APIM)*** to manage, secure, and monitor your API traffic. APIM offers features like rate limiting, IP whitelisting, and detailed analytics, which can significantly enhance the security and performance of your APIs.  
- **Authentication and Authorization**: Implement authentication and authorization mechanisms to ensure that only authorized users and applications can access your APIs. Consider using standards like OAuth 2.0 and JWT (JSON Web Tokens) with APIM.  
- **Regular Audits**: Periodically review and audit your security practices to identify and address potential vulnerabilities.  

## Additional Resources  
  
For further reading and additional support, you might find the following resources helpful:  
  
- [Azure OpenAI Models Pricing](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/)  
- [Azure Database for MySQL](https://learn.microsoft.com/en-us/azure/mysql/)  
- [MySQL Workbench Installer](https://dev.mysql.com/downloads/workbench/)  
- [Azure OpenAI PTU](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/provisioned-throughput-onboarding)  
- [TikToken - OpenAI LLM Token Counter](https://github.com/openai/tiktoken)
  
