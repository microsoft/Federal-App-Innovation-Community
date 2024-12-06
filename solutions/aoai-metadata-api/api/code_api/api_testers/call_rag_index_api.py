'''
This script is designed to test the MySQL API using eligible ADA models specifically 
for indexing scenarios, where embeddings for documents are generated.

Updated 10/15/24
'''

import os  
from langchain_community.vectorstores.azuresearch import AzureSearch  
from langchain_openai import AzureOpenAIEmbeddings  
from dotenv import load_dotenv  
from langchain_community.document_loaders import Docx2txtLoader
from langchain_text_splitters import CharacterTextSplitter  
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
endpoint = os.getenv('OPENAI_API_BASE')
api_version = os.getenv('OPENAI_API_VERSION')  
address = os.getenv('AZURE_AI_SEARCH_URL')  
index_name = os.getenv('AZURE_AI_SEARCH_INDEX')
password = os.getenv('AZURE_AI_SEARCH_KEY')  
ada_model = os.getenv('OPENAI_ADA_MODEL')

source_content_pairs = [] 
page_content_string = ""  
# Initialize an empty set to store unique sources  
sources_set = set() 
# Start the indexing of Documents 
embeddings = AzureOpenAIEmbeddings(azure_endpoint=endpoint, api_key=api_key, api_version=api_version, azure_deployment=ada_model)  
vector_store = AzureSearch(  
    azure_search_endpoint=address,   
    azure_search_key=password,   
    index_name=index_name,  
    embedding_function=embeddings.embed_query  
)  
file_path = os.path.join("..", "..", "..", "test_data", "peach_fly_usecase.docx") # Upload your .docx document to ../../../test_data and specify the name here
loader = Docx2txtLoader(file_path)  
documents = loader.load()  
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)  
docs = text_splitter.split_documents(documents)  
for doc in docs:
    source_content_pairs.append((doc.metadata['source'], doc.page_content))  
vectorize = vector_store.add_documents(documents=docs)  
formatted_strings = []  
for count, item in enumerate(vectorize, start=1):  
    formatted_strings.append(f'{item}\ndoc: {count}\n\n')  
embedding_content_string = '\n\n'.join(formatted_strings)

time_asked = get_time()  # Make sure time is captured right after adding docs to vector store
for source, content in source_content_pairs:  
    page_content_string += content + "\nSource: " + source + "\n\n"   
document_text = page_content_string.strip()

# print(document_text)
# Call MySQL API to capture metadata (make sure api is running locally)
url = "https://code-api.azurewebsites.net/code_api"  

# The following data must be sent as payload with each API request.
data = {  
    "system_prompt": "", 
    "user_prompt": document_text,  # The page_content found in chunks from file. 
    "time_asked": time_asked, # Time in which the user prompt was asked.
    "response": embedding_content_string, # The embedding representations returned from line 53
    "deployment_model": ada_model, # Input your **ADA** model's deployment name here.
    "name_model": "text-embedding-ada-002",  # Input you **ADA** model here.
    "version_model": "2",  # Input your model version here. NOT API VERSION.
    "region": "East US 2",  # Input your AOAI resource region here
    "project": "Embeddings Index (API Test)",  # Input your project name here. Following the system prompt for this test currently :)
    "api_name": url,  # Input the url of the API used. 
    "database": "cosmosdb" # Set to cosmosdb or mysqldb depending on desired platform
}  

response = requests.post(url, headers={"Content-Type": "application/json"}, data=json.dumps(data))  

print(response.status_code)  
print(response.json())  