'''
This script is designed to index documents and create vector representations of those indexes using the Azure OpenAI Service (AOAI). 
It operates through Azure API Management (APIM) by utilizing the embeddings URL. Metadata captured in APIM policy.

Notes:
- Additional params set in code must be passed to the POST in headers. 
- APIM will handle returning the request, response and url payload to `apim_api`.
- Line 36 APIM Embeddings URL: "https://<APIM Resource>.azure-api.net/<API>/deployments/{model}/embeddings?api-version={version}"

Updates:
- Updated header values passed to API (lines 69-70). These values will now come from APIM payload to `apim_api`.
- Modified chunk size and overlap for splitting the .docx 

Updated: 10/02/24
'''

import os  
from langchain_community.vectorstores.azuresearch import AzureSearch  
from langchain_openai import AzureOpenAIEmbeddings  
from dotenv import load_dotenv  
from langchain_community.document_loaders import Docx2txtLoader
from langchain_text_splitters import CharacterTextSplitter, RecursiveCharacterTextSplitter
from datetime import datetime, timezone  
import requests  
import json  
  
def get_time():  
    # Capture the current date and time in UTC (MySQL Native timezone)  
    current_utc_time = datetime.now(timezone.utc)  
    # Format the date and time to the desired string format  
    formatted_time = current_utc_time.strftime('%Y-%m-%d %H:%M:%S')  
    return formatted_time  
  
load_dotenv()  
api_key = os.getenv('OPENAI_API_KEY')  
api_version = os.getenv('OPENAI_API_VERSION')  
address = os.getenv('AZURE_AI_SEARCH_URL')  
index_name = os.getenv('AZURE_AI_SEARCH_INDEX')
password = os.getenv('AZURE_AI_SEARCH_KEY')  
ada_model = os.getenv('OPENAI_ADA_MODEL')
embeddings_url = os.getenv("APIM_EMBEDDINGS_URL")
embeddings_url = embeddings_url.replace("{model}", ada_model).replace("{version}", api_version)  

source_content_pairs = [] 
source_content_string = ""  

# Start the indexing of Documents 
file_path = os.path.join("..", "..", "..", "test_data", "peach_fly_usecase.docx") # Upload your .docx document to ../../../test_data and specify the name here
loader = Docx2txtLoader(file_path)  
documents = loader.load()  
text_splitter = CharacterTextSplitter(chunk_size=2000, chunk_overlap=20, separator='\n\n')  
# text_splitter = RecursiveCharacterTextSplitter(chunk_size=700, chunk_overlap=20, length_function=len)
docs = text_splitter.split_documents(documents)  
for doc in docs:
    print(doc)
    source_content_pairs.append((doc.metadata['source']))  
counter = 1
for source in source_content_pairs:  
    source_content_string += f"(Source #{counter}: {source}) "  
    counter += 1 
source = source_content_string.strip()
time_asked = get_time()  # Make sure time is captured right before adding docs to vector store
embeddings = AzureOpenAIEmbeddings(
    azure_endpoint=embeddings_url,
    api_key=api_key,
    api_version=api_version,
    azure_deployment=ada_model,
    default_headers={
        'Content-Type': 'application/json',
        "system_prompt": '',  # Leave empty string.
        "user_prompt": source,  # The source (file path) in which indexes were created from.
        "time_asked": get_time(),  # Time in which the user prompt was asked.
        "deployment_model": ada_model,  # Input your model's deployment name here
        "name_model": "text-embedding-ada-002",  # Input your model here
        "version_model": "2",  # Input your model version here. NOT API VERSION.
        "region": "East US 2",  # Input your AOAI resource region here
        "project": "Embeddings Index (API Test)",  # Input your project name here.
        "database": "cosmosdb",  # Specify here cosmosdb or mysql as database.
        "retrieve": "False"  # Must specify True or False here as string.
    }
)
vector_store = AzureSearch(  
    azure_search_endpoint=address,   
    azure_search_key=password,   
    index_name=index_name,  
    embedding_function=embeddings.embed_query
)  
response = vector_store.add_documents(documents=docs)  
print("Job complete.")