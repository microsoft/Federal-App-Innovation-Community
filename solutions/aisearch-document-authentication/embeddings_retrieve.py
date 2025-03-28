import os  
from dotenv import load_dotenv  
from openai import AzureOpenAI  
import re  
  
load_dotenv()  
  
# Configure Azure AI Search parameters  
search_endpoint = os.getenv('AZURE_SEARCH_ENDPOINT')  
search_key = os.getenv('AZURE_SEARCH_ADMIN_KEY')  

# Configure Azure OpenAI parameters  
azure_endpoint = os.getenv('AZURE_OPENAI_ENDPOINT')  
azure_openai_api_key = os.getenv('AZURE_OPENAI_KEY')  
azure_openai_api_version = os.getenv('AZURE_OPENAI_VERSION')  
azure_ada_deployment = os.getenv('AZURE_EMBEDDINGS_DEPLOYMENT')  
azure_gpt_deployment = os.getenv('AZURE_GPT_DEPLOYMENT')  

# Simulate getting Entra Object ID header from an HTTP request (replace with actual request headers in a real scenario)  
headers = {  
    'X-MS-CLIENT-PRINCIPAL-ID': 'user_2'  # Example header for demonstration  
}  
user_object_id = headers.get('X-MS-CLIENT-PRINCIPAL-ID')  


def chat_on_your_data():  
    """  
    Perform retrieval queries over documents from the Azure AI Search Index.  
    """ 
    # Define the query and other parameters  
    query = input("You: ")  
    search_index = os.getenv("AZURE_SEARCH_INDEX")
    messages = []  
  
    # Append user query to chat messages  
    messages.append({"role": "user", "content": query})  
  
    print('Processing...')  
  
    # Initialize the AzureOpenAI client  
    client = AzureOpenAI(  
        azure_endpoint=azure_endpoint,  
        api_key=azure_openai_api_key,  
        api_version=azure_openai_api_version,  
    )  
  
    # Create a chat completion with Azure OpenAI  
    completion = client.chat.completions.create(  
        model=azure_gpt_deployment,  
        messages=[  
            {"role": "system", "content": "You are an AI assistant that helps people find information."},  
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
                    # Create a filter query for document access levels  
                    "filter": f"access_level/any(level: level eq '{user_object_id}') or access_level/any(level: level eq 'all')",  
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
  
    try:
        # Extract the response data  
        response_data = completion.to_dict()  
        ai_response = response_data['choices'][0]['message']['content']  
        
        # Clean up the AI response  
        ai_response_cleaned = re.sub(r'\s+\.$', '.', re.sub(r'\[doc\d+\]', '', ai_response))  
        citation = response_data["choices"][0]["message"]["context"]["citations"][0]["url"]  
        ai_response_final = f"{ai_response_cleaned}\n\nCitation(s):\n{citation}"  
    
        # Append AI response to chat messages  
        messages.append({"role": "assistant", "content": ai_response_final})  
    
        print(f"GPT Response: {ai_response_final}\n\n{'-'*100}")  
    except Exception as e:
        # Exception for unauthorized users 
        response_data = completion.to_dict()  
        ai_response = response_data['choices'][0]['message']['content']  
        print(f"GPT Response: User not authorized for the following prompt: {query}\n\n{'-'*100}")  
  
if __name__ == '__main__':  
    while True:  
        chat_on_your_data()  