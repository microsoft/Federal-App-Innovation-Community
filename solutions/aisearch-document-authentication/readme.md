# AI Search Document Authentication with Entra ID

This project demonstrates how to authenticate users to specific documents in an Azure AI Search index using Entra object IDs. 
The project consists of two main Python scripts: `embeddings.py` and `embeddings_retrieve.py`. 
This README file provides instructions for setting up and running both scripts over your own Azure AI Search and Azure OpenAI
instances. 

## Table of Contents
+ [Prerequisites](#prerequisites)
+ [Environment Variables](#env-vars)
+ [Vectorize Script](#script_1)
+ [Retrieval Script](#script_2)


## Prerequisites <a name="prerequisites"></a>
1. Azure Storage account with documents store in a blob container. 
2. Azure AI Search resource deployed. 
3. Azure OpenAI resource deployed with `ada` and `gpt` model deployments. 
4. Python 3.10 or later installed. 
5. Required Python packages installed. You can install them using:
    ```powershell
    pip install -r requirements.txt
    ```

## Environment Variables <a name="env-vars"></a>
Create a .env file in the root directory and populate it with the following variables. Replace the placeholder values with your own:

```
AZURE_OPENAI_VERSION=
AZURE_OPENAI_ENDPOINT=
AZURE_OPENAI_KEY= 
AZURE_GPT_DEPLOYMENT=
AZURE_EMBEDDINGS_DEPLOYMENT=  
AZURE_SEARCH_ENDPOINT=  
AZURE_SEARCH_ADMIN_KEY=
AZURE_SEARCH_INDEX=   
BLOB_CONTAINER_NAME=
BLOB_CONNECTION_STRING= 
BLOB_ACCOUNT_NAME=
```
- `AZURE_OPENAI_VERSION`: The API version of Azure OpenAI you are using.
- `AZURE_OPENAI_ENDPOINT`: Your Azure OpenAI endpoint URL, typically in the format https://<your-openai-endpoint>.openai.azure.com/.
- `AZURE_OPENAI_KEY`: Your Azure OpenAI API key, which is used to authenticate API requests.
- `AZURE_GPT_DEPLOYMENT`: The name of your GPT deployment, which specifies the model deployment you want to use.
- `AZURE_EMBEDDINGS_DEPLOYMENT`: The name of your embeddings deployment, used for generating document embeddings.
- `AZURE_SEARCH_ENDPOINT`: Your Azure AI Search endpoint URL, typically in the format https://<your-search-endpoint>.search.windows.net.
- `AZURE_SEARCH_ADMIN_KEY`: Your Azure AI Search admin API key, used to manage the search service.
- `AZURE_SEARCH_INDEX`: The name of your Azure AI Search index, where your documents will be or are already stored.
- `BLOB_CONTAINER_NAME`: The name of your Azure Blob Storage container, where your blobs (files) are stored.
- `BLOB_CONNECTION_STRING`: Your Azure Blob Storage connection string, used to connect to your blob storage account.
- `BLOB_ACCOUNT_NAME`: Your Azure Blob Storage account name.

***Note***: By setting these environment variables, you will be able to execute each script immediately, with minimal configuration.

### embeddings.py <a name="script_1"></a>
This script performs the following tasks:
1. Connects to Azure Blob Storage to list and read PDF documents.
2. Splits documents into chunks with associated metadata.
3. Generates embeddings for document chunks using Azure OpenAI.
4. Creates a search index in Azure AI Search.
5. Uploads document chunks and their embeddings to the search index, including access levels for each document.

#### Key Sections in `embeddings.py`
##### Document Access Levels
 
The `blob_access_levels` dictionary maps PDF filenames to lists of Entra object IDs representing users who have access to each document. If a document is accessible to everyone, use the value `"all"`.
```python
# Define the mapping of blob names to access levels  
blob_access_levels = {  
    'New_York_State_Route_373.pdf': ['user_1', 'user_2', 'user_3'],  
    # Add more mappings as needed  
}  

def get_access_level(blob_name):  
    """Returns the access level for a given blob name."""  
    return blob_access_levels.get(blob_name, ['all'])  
```

##### Splitting Documents into Chunks
The `split_text_with_metadata` function splits the text into chunks and includes metadata, such as the access level. The access level is stored as a list of strings.
```python
def split_text_with_metadata(text, metadata, max_length=800, overlap=75, encoding_name='cl100k_base'):  
    """Splits the text into chunks with metadata."""  
    tokenizer = tiktoken.get_encoding(encoding_name)  
    tokens = tokenizer.encode(text)  
    chunks = []  
    start = 0  
    end = max_length  
  
    while start < len(tokens):  
        chunk = tokens[start:end]  
        chunk_text = tokenizer.decode(chunk)  
        chunk_metadata = metadata.copy()  
        chunk_metadata.update({  
            'start_token': start,  
            'end_token': end,  
            'chunk_length': len(chunk),  
            'chunk_text_preview': chunk_text[:50] + '...',  
            'access_level': get_access_level(metadata['blob_name'])  # Store as a list of strings  
        })  
        chunks.append({  
            'text': chunk_text,  
            'metadata': chunk_metadata  
        })  
        start = end - overlap  
        end = start + max_length  
  
    return chunks  
```

##### Creating the Search Index with Access Levels
When building the search index fields (lines 181-195), a field called `access_level` is created to store the Entra object IDs as a collection for each document. By storing these IDs as a collection, multiple Entra object IDs can be associated with a single document.
```python
# Create Search Index  
print("Creating search index...")  
credential = AzureKeyCredential(os.getenv("AZURE_SEARCH_ADMIN_KEY"))  
search_index_client = SearchIndexClient(endpoint=os.getenv("AZURE_SEARCH_ENDPOINT"), credential=credential)  
fields = [  
    SimpleField(name="id", type=SearchFieldDataType.String, key=True),  
    SearchableField(name="content", type=SearchFieldDataType.String),  
    SearchableField(name="blob_name", type=SearchFieldDataType.String),  
    SearchableField(name="document_link", type=SearchFieldDataType.String),  
    SearchableField(name="page_number", type=SearchFieldDataType.String),  
    SearchField(  
        name="embedding",  
        type=SearchFieldDataType.Collection(SearchFieldDataType.Single),  
        searchable=True,  
        vector_search_dimensions=1536,  
        vector_search_profile_name="myHnswProfile"  
    ),  
    SearchField(name="access_level", type=SearchFieldDataType.Collection(SearchFieldDataType.String))  # Store as a collection of strings  
]  
vector_search = VectorSearch(  
    algorithms=[  
        HnswAlgorithmConfiguration(name="myHnsw")  
    ],  
    profiles=[  
        VectorSearchProfile(  
            name="myHnswProfile",  
            algorithm_configuration_name="myHnsw"  
        )  
    ]  
)  
index = SearchIndex(name=os.getenv("AZURE_SEARCH_INDEX"), fields=fields, vector_search=vector_search)    
search_index_client.create_index(index)  
print("Search index created.")  
```

##### Uploading Documents with Access Levels
When uploading documents to the search index, the access levels are included as part of the metadata.
```python
# Upload chunks and embeddings to Azure AI Search  
print("Uploading documents to search index...")  
search_client = SearchClient(endpoint=os.getenv("AZURE_SEARCH_ENDPOINT"), index_name=os.getenv("AZURE_SEARCH_INDEX"), credential=credential)      
documents_to_upload = []  
  
for i, doc in enumerate(embeddings):  
    documents_to_upload.append({  
        "id": str(i),  
        "content": documents[i]["text"],  
        "embedding": doc["embedding"],  
        "blob_name": doc["metadata"]["blob_name"],  
        "document_link": doc["metadata"]["document_link"],  
        "page_number": str(doc["metadata"]["page_number"]),  
        "access_level": doc["metadata"]["access_level"]  # Store as a collection of strings  
    })  
search_client.upload_documents(documents=documents_to_upload)  
print("Documents uploaded to search index.")  
```

##### Running the Script
To run the `embeddings.py` script, simply execute the following command:
```powershell
python embeddings.py
```

#### Conclusion of `embeddings.py`
`embeddings.py` demonstrates how to use Entra object IDs to authenticate users for specific documents in an Azure AI Search index. By following these instructions, you can set up and run the `embeddings.py` script to manage document access levels effectively.

### embeddings_retrieve.py <a name="script_2"></a>
This script performs the following tasks:
1. Retrieves the Entra object ID from the request header.
2. Uses the Entra object ID to filter document access levels in the Azure AI Search index.
3. Executes a chat completion request with Azure OpenAI, retrieving only the documents that the user has access to.

#### Key Sections in `embeddings_retrieve.py`
##### Retrieving Entra Object ID
The script retrieves the Entra object ID from the request header X-MS-CLIENT-PRINCIPAL-ID.
```python
# In a real web service scenario, you would get the headers from the HTTP request  
headers = {  
    'X-MS-CLIENT-PRINCIPAL-ID': 'user_3'  # Example header for demonstration  
}  
user_object_id = headers.get('X-MS-CLIENT-PRINCIPAL-ID')  
```

##### Azure OpenAI Chat Completion with Document Retrieval
The script performs a chat completion request with Azure OpenAI, using the filter param to ensure only accessible documents are retrieved.

***Note***: The filter is defined and used on **line 77**. It filters the Azure AI Search index to retrieve documents where the user's Entra object ID is found in the `access_level` field or where the `access_level` is labeled as "all".
```python
# Create a chat completion with Azure OpenAI  
completion = client.chat.completions.create(  
    model=azure_gpt_deployment,  
    messages=[  
        {"role": "system", "content": "You are an AI assistant that helps people find information. Ensure the Markdown responses are correctly formatted before responding."},  
        {"role": "user", "content": query}  
    ],  
    max_tokens=800,  
    temperature=0.7,  
    top_p=0.95,  
    frequency_penalty=0,  
    presence_penalty=0,  
    stop=None,  
    stream=False,  
    extra_body={  
        "data_sources": [{  
            "type": "azure_search",  
            "parameters": {  
                "endpoint": search_endpoint,  
                "index_name": search_index,  
                "semantic_configuration": "default",  
                "query_type": "vector_simple_hybrid",  
                "fields_mapping": {},  
                "in_scope": True,  
                "role_information": "You are an AI assistant that helps people find information.",  
                "filter": f"access_level/any(level: level eq '{user_object_id}') or access_level/any(level: level eq 'all')" ,  # Filter by user-specific metadata  
                "strictness": 3,  
                "top_n_documents": 5,  
                "authentication": {  
                    "type": "api_key",  
                    "key": search_key  
                },  
                "embedding_dependency": {  
                    "type": "deployment_name",  
                    "deployment_name": azure_ada_deployment  
                }  
            }  
        }]  
    }  
)  
```

##### Running the Script
To run the `embeddings_retrieve.py` script, simply execute the following command:
```powershell
python embeddings_retrieve.py  
```

The script will prompt you to enter a query and then process the request, filtering documents based on the user's access level and retrieving relevant information using Azure OpenAI.
