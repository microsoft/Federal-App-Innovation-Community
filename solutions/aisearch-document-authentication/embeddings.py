import os  
import io  
import re  
import pdfplumber  
from dotenv import load_dotenv  
from azure.storage.blob import BlobServiceClient  
from azure.core.credentials import AzureKeyCredential  
from azure.identity import DefaultAzureCredential  
from azure.search.documents import SearchClient  
from azure.search.documents.indexes import SearchIndexClient  
from azure.search.documents.indexes.models import (  
    SimpleField,  
    SearchFieldDataType,  
    VectorSearch,  
    SearchIndex,  
    SearchableField,  
    SearchField,  
    VectorSearchProfile,  
    HnswAlgorithmConfiguration  
)  
from azure.core.exceptions import ResourceNotFoundError  
from openai import AzureOpenAI  
import tiktoken  
  
# Load environment variables  
load_dotenv()  
  
# Configure Azure AI Search parameters  
search_endpoint = os.getenv('AZURE_SEARCH_ENDPOINT')  
search_key = os.getenv('AZURE_SEARCH_ADMIN_KEY')  
  
def setup_azure_openai():  
    """  
    Sets up Azure OpenAI.  
    """  
    print("Setting up Azure OpenAI...")  
    azure_openai = AzureOpenAI(  
        api_key=os.getenv("AZURE_OPENAI_KEY"),  
        api_version=os.getenv('AZURE_OPENAI_VERSION'),  
        azure_endpoint=os.getenv('AZURE_OPENAI_ENDPOINT')  
    )  
    print("Azure OpenAI setup complete.")  
    return azure_openai  
  
def connect_to_blob_storage():  
    """  
    Connects to Azure Blob Storage.  
    """  
    print("Connecting to Blob Storage...")  
    blob_service_client = BlobServiceClient.from_connection_string(os.getenv("BLOB_CONNECTION_STRING"))  
    container_client = blob_service_client.get_container_client(os.getenv("BLOB_CONTAINER_NAME"))  
    print("Connected to Blob Storage.")  
    return container_client  
  
def load_blob_content(blob_client):  
    """  
    Loads and returns the content of the PDF blob.  
    """  
    blob_name = blob_client.blob_name  
    if not blob_name.lower().endswith('.pdf'):  
        raise ValueError(f"Blob {blob_name} is not a PDF file.")  
      
    blob_data = blob_client.download_blob().readall()  
    pdf_stream = io.BytesIO(blob_data)  
    pages = []  
      
    with pdfplumber.open(pdf_stream) as pdf:  
        for page_num, page in enumerate(pdf.pages, start=1):  
            text = page.extract_text()  
            if text:  
                pages.append({'page_number': page_num, 'text': text})  
    return pages  
  
# Define the mapping of blob names to access levels  
blob_access_levels = {  
    'New_York_State_Route_373.pdf': ['user_1', 'user_2', 'user_3'],  
    # Add more mappings as needed  
}  
  
def get_access_level(blob_name):  
    """  
    Returns the access level for a given blob name.  
    """  
    return blob_access_levels.get(blob_name, ['all'])  
  
def split_text_with_metadata(text, metadata, max_length=800, overlap=75, encoding_name='cl100k_base'):  
    """  
    Splits the text into chunks with metadata.  
    """  
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
  
def vectorize():  
    """  
    Main function that orchestrates the vector workflow.  
    """  
    azure_openai = setup_azure_openai()  
    container_client = connect_to_blob_storage()  
      
    # Read and chunk documents with metadata  
    print("Listing blobs in container...")  
    blob_list = container_client.list_blobs()  
    documents = []  
    for blob in blob_list:  
        if not blob.name.lower().endswith('.pdf'):  
            print(f"Skipping non-PDF blob: {blob.name}")  
            continue  
          
        print(f"Processing blob: {blob.name}")  
        blob_client = container_client.get_blob_client(blob)  
        try:  
            pages = load_blob_content(blob_client)  
            document_link = f'https://{os.getenv("BLOB_ACCOUNT_NAME")}.blob.core.windows.net/{os.getenv("BLOB_CONTAINER_NAME")}/{blob.name}'  
            for page in pages:  
                metadata = {  
                    "blob_name": blob.name,  
                    "document_link": document_link,  
                    "page_number": page['page_number']  
                }  
                chunks = split_text_with_metadata(page['text'], metadata)  
                documents.extend(chunks)  
        except Exception as e:  
            print(f"Failed to process blob {blob.name}: {e}")  
      
    print("Blobs processed and documents chunked.")  
      
    # Generate embeddings  
    print("Generating embeddings...")  
    embeddings = []  
    tokenizer = tiktoken.get_encoding("cl100k_base")  
    max_tokens = 8192  
      
    for i, doc in enumerate(documents):  
        print(f"Processing chunk {i + 1}/{len(documents)}")  
        print(f"Chunk text: {doc['text']}\n")  
        tokens = tokenizer.encode(doc["text"])  
        if len(tokens) > max_tokens:  
            print(f"Skipping document chunk {i + 1} with {len(tokens)} tokens, exceeding max limit of {max_tokens}.")  
            continue  
        response = azure_openai.embeddings.create(input=doc["text"], model=os.getenv("AZURE_EMBEDDINGS_DEPLOYMENT"))  
        embeddings.append({  
            "embedding": response.data[0].embedding,  
            "metadata": doc["metadata"]  
        })  
      
    print("Embeddings generation complete.")  
      
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
  
if __name__ == '__main__':  
    vectorize()  