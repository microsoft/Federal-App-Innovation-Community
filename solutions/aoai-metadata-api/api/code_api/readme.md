# CODE_API  
  
## Overview  
`code_api` is designed to capture metadata (in code) from each Azure OpenAI API call and store it in a MySQL or Cosmos database. The metadata captured includes prompts (system & user), tokens, completions, models, costs, and projects. This metadata is not limited and can be adjusted to capture more metadata based on needs. In the MySQL database, data is organized using a relational schema, ensuring efficient storage and retrieval at the project level. Conversely, in the Cosmos DB, data is stored in JSON format, allowing for flexible data types and eliminating the need for a rigid relational schema.
***Note: ONLY FOR Azure OpenAI Solutions that include regular chat and RAG methods***.  
  
## Contents  
This sub-directory contains 1 python API script and 3 python API tester scripts (Chat, RAG (Index), RAG (Query)):  
### Python API script
1. `code_api.py`: Python API script created to insert the Azure OpenAI metadata into the MySQL database after each completion from the API call. 
Use this api when you call directly in your code.  
    To date, only the following Azure OpenAI components are compatible with this API:  
    - **Models**:  
        - ***gpt-4o (2024-05-13 and 2024-08-06)***: configured for regional API. Although API will still execute, pricing differs between Global & Regional deployments. 
        - ***gpt-4o-mini (2024-07-18)***: configured for regional API. Although API will still execute, pricing differs between Global & Regional deployments. 
        - ***gpt-4 (turbo-2024-04-09)***
        - ***text-embedding-ada-002 (2)***
    - **Regions**:  
        - ***East US***
        - ***East US 2***
### Python API tester scripts 

<img width="905" alt="flow_chart_codeapi_v1" src="https://github.com/user-attachments/assets/978bb9e5-17c8-472a-8222-63a88cdc43a8">

Note: All tester scripts located in `/api_testers`
1. `call_norag_api.py`: Designed to test the code_api using eligible GPT models specifically for chat scenarios where Retrieval-Augmented Generation (RAG) is not needed. 
2. `call_rag_index_api.py`: Designed to test the code_api using eligible ADA models specifically 
for indexing scenarios, where embeddings for documents are generated. 
3. `call_rag_query_api.py`: Designed to test the code_api using eligible GPT and ADA models, specifically for RAG scenarios, where embeddings for queries are generated and documents are retrieved from a vector store.
    
    To use the each of the tester python file, complete the following:  
    1. **Set minimum .env variables to execute the api**  
```sh  
    azure_mysql_password = "MySQL server admin password"  
    azure_mysql_host = "MySQL server host"  
    azure_mysql_user = "MySQL admin user"  
    azure_mysql_schema = "MySQL schema (should be aoai_api)"  
    azure_cosmosdb_key = "Azure CosmosDB api key"
    azure_cosmosdb_endpoint = "Azure CosmosDB endpoint"
    OPENAI_API_BASE = "AOAI Endpoint"  
    OPENAI_API_VERSION = "AOAI API Version"  
    OPENAI_API_KEY = "AOAI API Key"  
    OPENAI_GPT_MODEL = "AOAI GPT Model deployment name" 
    OPENAI_ADA_MODEL = "AOAI ADA Model deployment name" 
    AZURE_AI_SEARCH_URL = "Azure AI Search endpoint (needed for RAG testers only)"
    AZURE_AI_SEARCH_KEY = "Azure AI Search key (needed for RAG testers only)"
    AZURE_AI_SEARCH_INDEX = 'Azure AI Search index name (needed for RAG testers only)'
```  
2. **Navigate to the code_api Directory:**  
```sh  
    cd api/code_api 
```  
3. **Run the API locally on your machine using this command:**  
```sh  
    uvicorn code_api:app --reload  
```  
Note: If you build the API from the docker file provided, you must switch to run on port 8000 with the following command (set docker .env variables in `/docker_env/.env`):  
```sh  
    docker run -p 8000:80 --env-file ./docker_env/.env code_api:v1  
```  
Docker build command **code_api**: `docker build -f api/code_api/Dockerfile -t code_api:v1 .` 

4. **Run the python script from the terminal:**  
```sh  
    python call_norag_api.py  
```  
    
Note - The following data should be passed as payload to the API:
```python 
        data = {  
            "system_prompt": "",  # System prompt given to the AOAI model.

            "user_prompt": "",  # User prompt in which the end-user asks the model. 

            "time_asked": "", # Time in which the user prompt was asked.

            "response": "",  # Model's answer to the user prompt

            "search_score": None, # Search score returned from retrieved docs in Azure AI Search index

            "deployment_model": "", # Model's deployment name here

            "name_model": "",  # Model here

            "version_model": "",  # Model version here. NOT API VERSION.

            "region": "East US 2",  # AOAI resource region here

            "project": "",  # Project/App name here.
            
            "api_name": "", # The url of the API used. 

            "retrieve": False, # Set True if you are querying over documents in vector store. 

            "database": "" # Set to cosmosdb or mysqldb depending on desired platform
        }  
```
  
## Modifying Metadata Capturing for MySQL 
  
If you want to modify the metadata captured, follow these steps:  
  
1. **Modify the SQL Schema**:  
    - For instance, if you want to start capturing a user credential, create a new table called `users` in the SQL database and create a relationship with the `prompt` table using `prompt_id`.  
    - Example SQL commands to create a `users` table and add a foreign key relationship:  
      ```sql  
      CREATE TABLE users (  
          user_id INT AUTO_INCREMENT PRIMARY KEY,  
          prompt_id INT,  
          username VARCHAR(50) NOT NULL,     
          CONSTRAINT fk_prompt FOREIGN KEY (prompt_id) REFERENCES prompt(prompt_id)  
      );  
      ```  
  
2. **Update the Python Script**:  
    - Modify the `code_api.py` script to include the logic for capturing and inserting the new metadata:
        - Add `username` as a param for API payload.
        - Add new parameter to `sql_connect()` to accept `username`.    
      - Insert the `username` and `prompt_id` into the created `users` table. 
    - Example function modification:  
    ```python  
      def sql_connect(system_prompt, user_prompt, prompt_cost, response, completion_cost, deployment_model, prompt_token_count, response_token_count, project, username):  
          # Connect to MySQL  
          connection = mysql.connector.connect(  
              host=os.getenv("azure_mysql_host"),  
              user=os.getenv("azure_mysql_user"),  
              password=os.getenv("azure_mysql_password"),  
              database=os.getenv("azure_mysql_schema")  
          )  
          cursor = connection.cursor()  
  
          # Existing code...  
  
          # Insert user login information into the users table with prompt_id (comes from the latest prompt_id inserted)  
          sql = "INSERT INTO users (prompt_id, username) VALUES (%s, %s)"  
          val = (prompt_id, username)  
          cursor.execute(sql, val)  
  
          # Commit the changes  
          connection.commit()  
      ```  

