# PVA Chatbot with Cognitive Search, Azure OpenaI GPT4
This solution showcases how to integrate Power Virtual Agents (PVA) classic with Azure OpenAI and Cognitive Search to create a chatbot that can answer questions and retain converation context, so that follow up questions is made in the context of previous conversations.

## Architecture
![Architecture](RefArch.png)

## Requirements
- Azure Subscription
- [Azure OpenAI GPT 4 Model](https://aka.ms/oai/access)
- Cognitive Search Service, with Semantic Search enabled
- Power Virtal Agents (PVA) classic
- Power Automate
- [Bot Framework Composer](https://learn.microsoft.com/en-us/composer/install-composer?tabs=windows)

## Details

### Azure Storage
- A blob container that holds the documents to be searched
- Add a "fileSource" metadata field to every blob uploaded

### Cognitive Search
This is a standard cognitive search with semantic search enabled. The index is created against the blob storage with the above `fileSource` as one of the index fields.
The `fileSource` index field is set as a `Searchable` field and `Retrievable`. The `content` index field is set as a `Searchable`  and `Retrievable` field.

### PowerApp Solution
This solution consists of a bot and 3 Power Automate flows.

#### Steps to import the solution
1. Download the Power App Solution Zip file
2. Follow this [link](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/import-update-export-solutions) to import the solution

#### Environment Variables

- `CognitiveSearch_APIKEY` - The API key for the cognitive search
- `CognitiveSearch_Semantic_Url` - The endpoint url for the Cognitive Search along with version.
  ```
  https://{COGNITIVE SEARCH ENDPOINT URL}/indexes/{{COG SEARCH INDEX NAME}}/docs/search?api-version=2021-04-30-Preview
  ```
- `CogSearch_SemanticConfigName` - The name of the semantic search config
- `OpenAIChatGPT_APIKEY` - Azure OpenAI API Key
- `OpenAIChatGPT_Url` - Azure OpenAI Url
- `OpenAIWebSiteSearch_URL` - The Azure OpenAI endpoint Url for the textdavinci003 model deployment

## References
- [Integrate a PVA chatbot with Azure OpenAI ChatGPT](https://powerusers.microsoft.com/t5/Power-Platform-Integrations/Integrate-a-PVA-chatbot-with-Azure-OpenAI-ChatGPT-using-the-Chat/td-p/2145825)