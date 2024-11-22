'''
This script is intended to query/chat over documents stored in Azure AI Search index using (RAG). 
It leverages the Azure OpenAI Service (AOAI) and is accessed through Azure API Management (APIM). 
The script utilizes both the chat completions and embeddings URLs provided by APIM. Metadata captured in APIM policy.

Notes:
- Additional params set in code must be passed to the POST in headers. 
- APIM will handle returning the request, response and url payload to `apim_api`.

Updated: 10/02/24
'''
import os
from langchain_community.retrievers import AzureAISearchRetriever
from dotenv import load_dotenv
from langchain.chains.retrieval import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_openai import AzureChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain.chains import create_history_aware_retriever
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.messages import HumanMessage
from datetime import datetime, timezone 

load_dotenv()
api_key = os.getenv('APIM_API_KEY')  
endpoint = os.getenv('OPENAI_API_BASE')
api_version = os.getenv('OPENAI_API_VERSION')  
address = os.getenv('AZURE_AI_SEARCH_URL')  
index_name = os.getenv('AZURE_AI_SEARCH_INDEX')
password = os.getenv('AZURE_AI_SEARCH_KEY')  
gpt_model = os.getenv('OPENAI_GPT_MODEL')
ada_model = os.getenv('OPENAI_ADA_MODEL')
completions_url = os.getenv("APIM_COMPLETIONS_URL")
completions_url = completions_url.replace("{model}", gpt_model).replace("{version}", api_version)  

def get_time():  
    # Capture the current date and time in UTC (MySQL Native timezone)  
    current_utc_time = datetime.now(timezone.utc)  
    # Format the date and time to the desired string format  
    formatted_time = current_utc_time.strftime('%Y-%m-%d %H:%M:%S')  
    return formatted_time 
 
# Create system prompts
contextualize_q_system_prompt = """Given a chat history and the latest user question \
which might reference context in the chat history, formulate a standalone question \
which can be understood without the chat history. Do NOT answer the question, \
just reformulate it if needed and otherwise return it as is."""

qa_system_prompt = """You are a q/a assistant. A friendly bot designed to have unqiue conversations. \
You must be talkative and provide lots of specific details from the conversation context. \
Only answer questions based on given context. If answer not in context, say I do not know. \
Context: {context}
"""

# Empty list to capture chat history
chat_history = []

while True:
    # Collect user prompt
    query = input("\nYou: ")
    time_asked = get_time()

    # Create AI Search retriever and AOAI LLM 
    retriever = AzureAISearchRetriever(service_name=address,api_key=password,top_k=1, index_name=index_name)
    llm = AzureChatOpenAI(azure_endpoint=completions_url, 
                        api_key=api_key, 
                        temperature=0.7,
                        default_headers={
            'Content-Type': 'application/json',
            "system_prompt": f'',  # Leave empty string.
            "user_prompt": query.strip(),  # User prompt in which the end-user asks the model. (strip any leading or trailing whitespace)
            "time_asked": time_asked,  # Time in which the user prompt was asked.
            "deployment_model": f"{gpt_model}, {ada_model}",  # Input your model's deployment name here
            "name_model": "gpt-4o, text-embedding-ada-002",  # Input your models here
            "version_model": "2024-05-13, 2",  # Input your model version here. NOT API VERSION.
            "region": "East US 2",  # Input your AOAI resource region here
            "project": "Retriever (API Test)",  # Input your project name here. 
            "database": "cosmosdb",  # Specify here cosmosdb or mysql as database.
            "retrieve": "True"  # Must specify True or False here as string.
        })

    # Create prompt template for history prompt, then history aware retriever 
    contextualize_q_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", contextualize_q_system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )
    history_aware_retriever = create_history_aware_retriever(
        llm, retriever, contextualize_q_prompt
    )

    # Create prompt template, then chain for LLM to answer questions 
    qa_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", qa_system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )

    combine_docs_chain = create_stuff_documents_chain(llm=llm, prompt=qa_prompt)

    # Create chain to retrieve documents and LLM to answer questions (combining history aware and combine_docs chains)
    retrieval_chain = create_retrieval_chain(retriever=history_aware_retriever, combine_docs_chain=combine_docs_chain)

    # Create final chain to chat over docuemnts with history
    chain = retrieval_chain.invoke({"input": query, "chat_history": chat_history})
    chat_history.extend([HumanMessage(content=query), chain["answer"]])
    # print(chain)
    sources = [] 
    page_contents = []
    for doc in chain['context']:
        source = doc.metadata['metadata']
        page_content = doc.page_content
        sources.append(source)
        page_contents.append(page_content)
    # Print out LLM answer and sources. 
    print(f"\nAnswer: {chain['answer']}")
    source = "".join(sources)
    print(f"\nSource: {source}\n\n")