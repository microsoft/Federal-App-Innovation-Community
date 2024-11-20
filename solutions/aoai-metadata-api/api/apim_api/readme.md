# APIM_API  
  
## Overview  
`apim_api` is designed to capture metadata from an Azure API Management (APIM) policy, which manages the Azure OpenAI API call. The APIM policy calls the api to store metadata in a MySQL or Cosmos database. The metadata captured includes prompts (system & user), tokens, completions, models, costs, and projects. This metadata is not limited and can be adjusted to capture more metadata based on needs. In the MySQL database, data is organized using a relational schema, ensuring efficient storage and retrieval at the project level. Conversely, in the Cosmos DB, data is stored in JSON format, allowing for flexible data types and eliminating the need for a rigid relational schema.
***Note: ONLY FOR Azure OpenAI Solutions that include regular chat and RAG methods***. 

For the APIM Policy to execute this API, please navigate to `./APIM/policy.txt` (copy the content into APIM)
  
## Contents  
This sub-directory contains 1 python API script and 1 python API tester script (Chat Only):  
### Python API script
1. `apim_api.py`: Similiar API to `code_api` except, the response from API is handled differently, allowing APIM to pass response to API in a policy. 
***Use when calling in APIM policy***.
  
    To date, only the following Azure OpenAI components are compatible with both APIs:  
    - **Models**:  
        - ***gpt-4o (2024-05-13 and 2024-08-06)***: configured for regional API. Although API will still execute, pricing differs between Global & Regional deployments. 
        - ***gpt-4o-mini (2024-07-18)***: configured for regional API. Although API will still execute, pricing differs between Global & Regional deployments. 
        - ***gpt-4 (turbo-2024-04-09)***
        - ***text-embedding-ada-002 (2)***
    - **Regions**:  
        - ***East US***
        - ***East US 2***
### Python API tester scripts 

<img width="956" alt="flow_chart_apimapi_v1" src="https://github.com/user-attachments/assets/2850d96e-b195-4af3-8bda-85e3b47796a6">

Note: All tester scripts located in `/api_testers`
1. `call_apim_api.py`: Designed to test the apim_api using eligible GPT models specifically for chat scenarios where Retrieval-Augmented Generation (RAG) is not needed. 
2. `call_apim_index.py`: Designed to test the apim_api using eligible ADA models specifically for indexing scenarios, where embeddings for documents are generated. 
3. `call_apim_query.py`: Designed to test the apim_api using eligible GPT and ADA models, specifically for RAG scenarios, where embeddings for queries are generated and documents are retrieved from a vector store.

To use the each of the tester python file, complete the following:  
1. **Set the minimum .env variables to execute the api (ngrok_authtoken not needed if running in Azure)**
```sh  
    azure_mysql_password = "MySQL server admin password"  
    azure_mysql_host = "MySQL server host"  
    azure_mysql_user = "MySQL admin user"  
    azure_mysql_schema = "MySQL schema (should be aoai_api)"  
    azure_cosmosdb_key = "Azure CosmosDB api key"
    azure_cosmosdb_endpoint = "Azure CosmosDB endpoint"
    OPENAI_GPT_MODEL = "AOAI GPT Model deployment name" 
    OPENAI_ADA_MODEL = "AOAI ADA Model deployment name" 
    APIM_API_KEY = "APIM API Key"
    APIM_COMPLETIONS_URL = "APIM AOAI Completions URL"
    APIM_EMBEDDINGS_URL = "APIM AOAI Embeddings URL"
    ngrok_authtoken = "ngrok token to convert local api to public domain (for testing only)"
```  
[Click Here](https://dashboard.ngrok.com/) if you do not have an ngrok token. 

2. **Navigate to the code_api Directory:**  
```sh  
    cd api/apim_api 
```  

3. **Run the API locally on your machine using this command:** 
- Modify `run_with_ngrok.py` line 19 with the api's python file name. 
    - Ex: `subprocess.run(["uvicorn", "apim_api:app", "--host", "0.0.0.0", "--port", "8000", "--reload"])`
    - In the terminal execute, which will give your local API a public domain. (***Use this domain in APIM policy***):
        ```sh  
            python run_with_ngrok.py
        ```  
    - Example domain: https://1234abcd.ngrok.io

Note: If you build the API from the docker file provided, you must switch to run on port 8000 with the following command (set docker .env variables in `/docker_env/.env`):  
```sh  
    docker run -p 8000:80 --env-file ./docker_env/.env apim_api:v1  
```  
Docker build command **apim_api**: `docker build -f api/apim_api/Dockerfile -t apim_api:v1 .` 

4. **Run the python script from the terminal:**  
```sh  
    python call_apim_api.py  
```  
    
Note - The following data should be passed as headers to the API:
```python 
        headers = {  
        'Content-Type':'application/json',

        "system_prompt": "",  # System prompt given to the AOAI model.

        "user_prompt": "",  # User prompt in which the end-user asks the model. 

        "time_asked": "", # Time in which the user prompt was asked.

        "deployment_model": "", # Input your model's deployment name here

        "name_model": "",  # Input you model here

        "version_model": "",  # Input your model version here. NOT API VERSION.

        "region": "",  # Input your AOAI resource region here

        "project": "",  # Input your project name here. Following the system prompt for this test currently :)

        "database": "", # Specify here cosmosdb or mysql as database. 

        "retrieve": "" # Must specify True or False here as string (will only be passed in header as string)
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

