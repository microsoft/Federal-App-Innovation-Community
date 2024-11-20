from pyngrok import ngrok, conf  
import subprocess  
from dotenv import load_dotenv  
import os  

# Load environment variables from .env file  
load_dotenv()  

# Set up Ngrok configuration  
ngrok_config = conf.PyngrokConfig(  
    api_key=os.getenv("ngrok_authtoken")  
)

# Create a public URL for your local FastAPI app  
public_url = ngrok.connect(8000)  
print("Ngrok Tunnel URL:", public_url)  

# Run your FastAPI app  
subprocess.run(["uvicorn", "apim_api:app", "--host", "0.0.0.0", "--port", "8000", "--reload"])  
