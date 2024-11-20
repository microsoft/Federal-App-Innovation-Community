'''
UPDATES:
    - Added if checks for Embeddings Index (API Test) project (lines 234 and 273) to explicity set response tokens to 0
    - Modified the requested user prompt for Embeddings Index (API Test) ONLY to remove sources in string for token and cost processing
        - Caused inconsistencies in token count for user prompt 

To run this api locally use: uvicorn code_api:app --reload

Last update: 10/15/2024
'''

from fastapi import FastAPI, HTTPException  
from pydantic import BaseModel, Field 
import mysql.connector  
import os  
from dotenv import load_dotenv  
import re  
import tiktoken  
from azure.cosmos import CosmosClient, exceptions, PartitionKey  
from datetime import datetime, timezone
import json
  
load_dotenv()  
app = FastAPI()  
  
class RequestData(BaseModel):  
    system_prompt: str  = Field(default="")  
    user_prompt: str  = Field(default="")  
    time_asked: str  = Field(default="")  
    response: str  = Field(default="")  
    search_score: float = Field(default=None)
    deployment_model: str = Field(default="")  
    name_model: str = Field(default="")  
    version_model: str = Field(default="")    
    region: str = Field(default="")    
    project: str = Field(default="")    
    api_name: str = Field(default="")   
    retrieve: bool = Field(default=False)
    database: str = Field(default="")
  
def aoai_metadata(system_prompt, user_prompt, response, name_model, version_model, region, retrieve):  
    def token_amount(text, name_model):  
        if name_model in ['gpt-4o', 'gpt-4o-', 'gpt-4o-mini']:  
            encoding = tiktoken.get_encoding('o200k_base')  
            return len(encoding.encode(text)) 
        elif name_model in ['text-embedding-ada-002', 'gpt-4']:
            encoding = tiktoken.get_encoding('cl100k_base')
            return len(encoding.encode(text)) 
        return 0   
    if retrieve == False:
        prompt_token_count = token_amount(text=system_prompt, name_model=name_model) + token_amount(text=user_prompt, name_model=name_model) + 11
        response_token_count = token_amount(text=response, name_model=name_model) 
        if region in ['East US', 'East US 2']:  
            # Pricing gpt-4o - 2024-05-13  
            if name_model == 'gpt-4o' and version_model == '2024-05-13':  
                prompt_cost = round((prompt_token_count / 1000) * .005, 5)  
                completion_cost = round(((prompt_token_count + response_token_count) / 1000) * .015, 5)  
            # Pricing gpt-4o-mini - 2024-07-18  
            elif name_model == 'gpt-4o-mini' and version_model == '2024-07-18':  
                prompt_cost = round((prompt_token_count / 1000) * .000165, 5)  
                completion_cost = round(((prompt_token_count + response_token_count) / 1000) * .00066, 5)  
            # Pricing gpt-4o - 2024-08-06  
            elif name_model == 'gpt-4o' and version_model == '2024-08-06':  
                prompt_cost = round((prompt_token_count / 1000) * .00275, 5)  
                completion_cost = round(((prompt_token_count + response_token_count) / 1000) * .011, 5)
            # Pricing gpt-4 - turbo-2024-04-09
            elif name_model == 'gpt-4' and version_model == 'turbo-2024-04-09':  
                prompt_cost = 0  
                completion_cost = 0
            # Pricing text-embedding-ada-002 - 2
            elif name_model == 'text-embedding-ada-002' and version_model == '2':
                prompt_cost = round((prompt_token_count / 1000) * .0001, 5)
                completion_cost = round(((prompt_token_count + response_token_count) / 1000) * .0001, 5) 
            else:  
                raise HTTPException(status_code=400, detail="Invalid model or version.")  
            return prompt_token_count, prompt_cost, response_token_count, completion_cost  
        else:  
            raise HTTPException(status_code=400, detail="East US & East US 2 regions only available.")  
    elif retrieve == True:
        split_models = name_model.split(',')  # must send gpt and ada model in the following string: 'gpt-4o, text-embedding-ada-002'
        split_models = [s.strip() for s in split_models] 
        gpt_model = split_models[0]  
        ada_model = split_models[1]  
        prompt_token_count = token_amount(text=system_prompt, name_model=gpt_model) + token_amount(text=user_prompt, name_model=gpt_model) + 11
        user_prompt_token_count_embeddings = token_amount(text=user_prompt, name_model=ada_model) 
        response_token_count = token_amount(text=response, name_model=gpt_model) 
        if region in ['East US', 'East US 2']:
            # Pricing gpt-4o (2024-05-13) and text-embedding-ada-002 (2)
            if gpt_model == 'gpt-4o' and ada_model == 'text-embedding-ada-002' and version_model == '2024-05-13, 2':
                 prompt_cost = round((prompt_token_count / 1000) * .005, 5) + round((user_prompt_token_count_embeddings / 1000) * .0001, 5)
                 completion_cost = round(((prompt_token_count + response_token_count) / 1000) * .015, 5)
            # Pricing gpt-4o (2024-08-06) and text-embedding-ada-002 (2)
            elif gpt_model == 'gpt-4o' and ada_model == 'text-embedding-ada-002' and version_model == '2024-08-06, 2':
                 prompt_cost = round((prompt_token_count / 1000) * .005, 5) + round((user_prompt_token_count_embeddings / 1000) * .0001, 5)
                 completion_cost = round(((prompt_token_count + response_token_count) / 1000) * .015, 5)
            # Pricing gpt-4o (2024-08-06) and text-embedding-ada-002 (2)
            elif gpt_model == 'gpt-4o-mini' and ada_model == 'text-embedding-ada-002' and version_model == '2024-07-18, 2':
                 prompt_cost = round((prompt_token_count / 1000) * .000165, 6) + round((user_prompt_token_count_embeddings / 1000) * .0001, 6)
                 completion_cost = round(((prompt_token_count + response_token_count) / 1000) * .00066, 5)
            # Pricing gpt-4 (turbo-2024-04-09) and text-embedding-ada-002 (2)
            elif gpt_model == 'gpt-4' and ada_model == 'text-embedding-ada-002' and version_model == 'turbo-2024-04-09, 2':
                 prompt_cost = round((user_prompt_token_count_embeddings / 1000) * .0001, 5)
                 completion_cost = 0
            else:  
                raise HTTPException(status_code=400, detail="Invalid model or version.")  
            return prompt_token_count, prompt_cost, response_token_count, completion_cost 
        else:
            raise HTTPException(status_code=400, detail="East US & East US 2 regions only available.")  

# function for inserting data to MySQL database 
def sql_connect(system_prompt, user_prompt, time_asked, prompt_cost, response, search_score, completion_cost, name_model, version_model, 
                deployment_model, prompt_token_count, response_token_count, project, api_name):  
    try:  
        # Establish a connection to the MySQL server  
        mydb = mysql.connector.connect(  
            host=os.getenv("azure_mysql_host"),  
            user=os.getenv("azure_mysql_user"),  
            password=os.getenv("azure_mysql_password"),  
            database=os.getenv("azure_mysql_schema")  
        )  
  
        # Define a cursor object  
        mycursor = mydb.cursor()  
  
        # Check if system_prompt already exists in the aoaisystm table  
        mycursor.execute("SELECT system_id FROM aoaisystem WHERE system_prompt = %s", (system_prompt,))  
        result = mycursor.fetchone()  
  
        # If the system_prompt exists, use the corresponding system_id, otherwise create a new one  
        if result:  
            system_id = result[0]  
        else:  
            # Insert a new system_prompt into the aoaisystm table  
            print("Warning: System_id not found for this prompt. Creating new id and adding prompt!")  
            mycursor.execute("SELECT MAX(prompt_number) FROM aoaisystem")  
            result = mycursor.fetchone()  
            prompt_number = result[0] if result[0] else 0  
            prompt_number = prompt_number + 1  # Increment the latest prompt_number by 1  
            sql = "INSERT INTO aoaisystem (system_prompt, system_proj, prompt_number) VALUES (%s, %s, %s)"  
            val = (system_prompt, project, prompt_number)  
            mycursor.execute(sql, val)  
            system_id = mycursor.lastrowid  # Get the ID of the last inserted row  
  
        # Insert into prompt table with connection to system prompt  
        sql = "INSERT INTO prompt (system_id, user_prompt, tokens, price, timestamp) VALUES (%s, %s, %s, %s, %s)"  
        val = (system_id, user_prompt, prompt_token_count, prompt_cost, time_asked)  
        mycursor.execute(sql, val)  
        prompt_id = mycursor.lastrowid  
  
        # Check if api_name already exists in the python_api table  
        mycursor.execute("SELECT api_id FROM python_api WHERE api_name = %s", (api_name,))  
        result = mycursor.fetchone()  
        if result:  
            api_id = result[0]  
        else:  
            # Insert API Name into python_api table (since there will be an API for No Rag and Rag)  
            sql = "INSERT INTO python_api (api_name) VALUES (%s)"  
            val = (api_name,)  
            mycursor.execute(sql, val)  
            api_id = mycursor.lastrowid  
  
        mycursor.execute("SELECT model_id FROM models WHERE model = %s", (deployment_model,))  
        result = mycursor.fetchone()  
  
        # If the model exists, use the corresponding model_id, otherwise create a new one  
        if result:  
            model_id = result[0]  
        else:  
            print("Warning: Model_id not found for this model. Creating new id and adding model!")  
            mycursor.execute("SELECT MAX(model_id) FROM models")  
            result = mycursor.fetchone()  
            model_id = result[0] if result[0] else 0  
            # Increment the latest model_id by 1  
            model_id = model_id + 1  
  
            # Define regex patterns for models  
            ada_pattern = re.compile(r'(?i)ada')  # Case insensitive match for 'ada' anywhere in the string  
            gpt4o_pattern = re.compile(r'(?i)gpt-?4o')  # Case insensitive match for 'gpt-4o' or 'gpt4o' anywhere in the string  

            # ADA model only insert to MySQL
            if name_model == 'text-embedding-ada-002' and version_model == '2':  # Insert for ada-002 (2)
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, None, 0.000100, 'cl100k_base')  
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid 

            # GPT model only inserts to MySQL
            elif name_model == 'gpt-4o' and version_model == '2024-05-13': # Insert for gpt-4o (turbo-2024-05-13)
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, .005000, 0.015000, 'o200k_base')  
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid  
            elif name_model == 'gpt-4o' and version_model == '2024-08-06': # Insert for gpt-4o (turbo-2024-08-06)
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, .0027500, 0.011000, 'o200k_base')  
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid 
            elif name_model == 'gpt-4o-mini' and version_model == '2024-07-18': # Insert for gpt-4o-mini (2024-07-18)
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, .000165, 0.000660, 'o200k_base')  
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid 
            elif name_model == 'gpt-4' and version_model == 'turbo-2024-04-09': # Insert for gpt-4 (turbo-2024-04-09)
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, 0.0, 0.0, 'cl100k_base')  
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid

            # GPT & ADA model inserts to MySQL
            elif name_model == 'gpt-4o, text-embedding-ada-002' and version_model == "2024-05-13, 2": # Insert for gpt-4o (2024-05-13) + ada-002 (2)
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, .005+.0001, 0.015000, 'o200k_base, cl100k_base')  # prompt_price = prompt_price <text..ada-002> + prompt_price <gpt-4o>
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid  
            elif name_model == 'gpt-4o, text-embedding-ada-002' and version_model == "2024-08-06, 2": # Insert for gpt-4o (2024-08-06) + ada-002 (2)
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, .00275+.0001, 0.011, 'o200k_base, cl100k_base')  # prompt_price = prompt_price <text..ada-002> + prompt_price <gpt-4o>
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid  
            elif name_model == 'gpt-4o-mini, text-embedding-ada-002' and version_model == "2024-07-18, 2": # Insert for gpt-4o-mini (2024-07-18) + ada-002 (2)
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, .000165+.0001, 0.00066, 'o200k_base, cl100k_base')  # prompt_price = prompt_price <text..ada-002> + prompt_price <gpt-4o>
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid  
            elif name_model == 'gpt-4, text-embedding-ada-002' and version_model == "turbo-2024-04-09, 2": # Insert for gpt-4 (turbo-2024-04-09) + ada-002 (2)
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, 0.0+.0001, 0.0, 'o200k_base, cl100k_base')  # prompt_price = prompt_price <text..ada-002> + prompt_price <gpt-4o>
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid  
            else:  
                sql = "INSERT INTO models (model, prompt_price, completion_price, tiktoken_encoding) VALUES (%s, %s, %s, %s)"  
                val = (deployment_model, None, None, None)  
                mycursor.execute(sql, val)  
                model_id = mycursor.lastrowid  
  
        # Insert into chat_completions table based on model used  
        if project == "Embeddings Index (API Test)":    # Indexing project will have zero response token count, as tokens are only handled in prompt. 
            response_token_count = 0
        sql = "INSERT INTO chat_completions (model_id, prompt_id, api_id, chat_completion, tokens, price, search_score) VALUES (%s, %s, %s, %s, %s, %s, %s)"  
        val = (model_id, prompt_id, api_id, response, response_token_count, completion_cost, search_score)  
        mycursor.execute(sql, val)  
  
        # Save the changes  
        mydb.commit()  
        return {"message": f"{mycursor.rowcount} record(s) inserted into {os.getenv('azure_mysql_schema')} database."}  
    except Exception as e:  
        raise HTTPException(status_code=500, detail=f"Failed to access MySQL DB with error: {e}")  

# function for inserting into cosmos database 
def cosmosdb_connect(system_prompt, user_prompt, time_asked, prompt_cost, response, search_score, completion_cost, 
                deployment_model, prompt_token_count, response_token_count, project, api_name, version_model):
    # Initialize Cosmos env variables 
    endpoint = os.getenv("azure_cosmosdb_endpoint")  
    key = os.getenv("azure_cosmosdb_key")            

    # Function to get the highest existing id (since ids stored as string, grab them all, then convert to int for max value) 
    def get_highest_id(container):  
        query = "SELECT c.id FROM c"  
        items = list(container.query_items(  
            query=query,  
            enable_cross_partition_query=True  
        ))  
        # Convert all IDs to integers and find the max  
        ids = [int(item['id']) for item in items if item['id'].isdigit()] 
        print(f"All IDs: {ids}") 
        return max(ids) if ids else 0
    
    # Function to get current date and time
    def get_time():
        current_utc_time = datetime.now(timezone.utc)   
        formatted_time = current_utc_time.strftime('%Y-%m-%d %H:%M:%S') 
        return formatted_time 
    
    time_asked = get_time()

    if project == "Embeddings Index (API Test)":  # Indexing project will have zero response token count, as tokens are only handled in prompt. 
            response_token_count = 0

    # Initialize the Cosmos client 
    client = CosmosClient(endpoint, key)  
    
    # Create a database  
    database_name = 'AOAI_Cosmos_Metadata'  
    try:  
        database = client.create_database_if_not_exists(id=database_name)  
    except exceptions.CosmosResourceExistsError:  
        database = client.get_database_client(database_name)  
    
    # Create a container  
    container_name = 'Metadata'  
    partition_key_path = '/Project'  # Replace with your partition key path  
    try:  
        container = database.create_container_if_not_exists(  
            id=container_name,  
            partition_key=PartitionKey(path=partition_key_path),  
            offer_throughput=400  
        )  
    except exceptions.CosmosResourceExistsError:  
        container = database.get_container_client(container_name)  
    
    # Get the highest existing id and increment it  
    highest_id = get_highest_id(container)
    print(f"\nMax id: {highest_id}")
    new_id = highest_id + 1
    
    # Define the JSON document to insert  
    document = {  
        "id": str(new_id),  # Incremented ID  
        "Project": project,  
        "System_prompt": system_prompt,  
        "User_prompt": user_prompt,  
        "Prompt_tokens": prompt_token_count,  
        "Prompt_price": prompt_cost,
        "Time_asked": time_asked,  
        "Ai_response": response, 
        "Search_score": search_score, 
        "Response_tokens": response_token_count,  
        "Completion_price": completion_cost,  
        "Time_answered": time_asked,  
        "Ai_model_deployment": deployment_model,  
        "Ai_model_version": version_model,
        "API": api_name 
    }  
    
    # Insert the JSON document into the container  
    try:  
        container.create_item(body=document)  
        return f"Document inserted successfully with id: {new_id}"
    except exceptions.CosmosHttpResponseError as e:  
        return f"An error occurred: {e.message}"
  
def main(system_prompt, user_prompt, time_asked, prompt_cost, response, search_score, completion_cost, name_model, version_model, deployment_model, prompt_token_count, 
         response_token_count, project, api_name, database):  
    if database == "mysqldb":
        return sql_connect(system_prompt=system_prompt, user_prompt=user_prompt, time_asked=time_asked, prompt_cost=prompt_cost, response=response, search_score=search_score,
                            completion_cost=completion_cost, name_model=name_model, version_model=version_model, deployment_model=deployment_model, 
                            prompt_token_count=prompt_token_count, response_token_count=response_token_count, project=project, api_name=api_name) 
    elif database == "cosmosdb":
        return cosmosdb_connect(system_prompt=system_prompt, user_prompt=user_prompt, time_asked=time_asked, prompt_cost=prompt_cost, 
                                response=response, search_score=search_score, completion_cost=completion_cost, deployment_model=deployment_model, prompt_token_count=prompt_token_count, 
                                response_token_count=response_token_count, project=project, api_name=api_name, version_model=version_model)
    else:
        return "Database must be mysqldb or cosmosdb. Please specifiy one these values."
 
  
@app.post("/code_api")  
def process_data(data: RequestData):  
    if data.project == "Embeddings Index (API Test)":  
        pattern = r'Source: [^\s]*(?:\\[^\\\s]*)*\.[a-zA-Z0-9]+'  
        filtered_user_prompt = re.sub(pattern, '', data.user_prompt)  

        prompt_token_count, prompt_cost, response_token_count, completion_cost = aoai_metadata(  
        system_prompt=data.system_prompt,  
        user_prompt=filtered_user_prompt,  
        response=data.response,  
        name_model=data.name_model,  
        version_model=data.version_model,  
        region=data.region, 
        retrieve=data.retrieve,  
        )  
    else:
        prompt_token_count, prompt_cost, response_token_count, completion_cost = aoai_metadata(  
        system_prompt=data.system_prompt,  
        user_prompt=data.user_prompt,  
        response=data.response,  
        name_model=data.name_model,  
        version_model=data.version_model,  
        region=data.region, 
        retrieve=data.retrieve,  
        )  
  
    result = main(  
        system_prompt=data.system_prompt,  
        user_prompt=data.user_prompt,  
        time_asked=data.time_asked,  
        prompt_cost=prompt_cost,  
        response=data.response, 
        search_score=data.search_score, 
        completion_cost=completion_cost,
        name_model=data.name_model,
        version_model=data.version_model,  
        deployment_model=data.deployment_model,  
        prompt_token_count=prompt_token_count,  
        response_token_count=response_token_count,  
        project=data.project,  
        api_name=data.api_name,  
        database=data.database
    )  
  
    return result  