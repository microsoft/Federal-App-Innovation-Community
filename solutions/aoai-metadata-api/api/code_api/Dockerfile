FROM python:3.11.7-slim  
  
# Create app directory  
RUN mkdir /app  
  
# Copy requirements.txt from the build context root to /app in the container  
COPY ../../requirements.txt /app/requirements.txt  
  
# Copy the FastAPI application files to /app in the container  
COPY api/code_api/code_api.py /app/code_api.py 
  
# Set the working directory  
WORKDIR /app  
  
# Install dependencies  
RUN pip install --no-cache-dir -r requirements.txt  
  
# Command to run the FastAPI application  
CMD ["uvicorn", "code_api:app", "--host", "0.0.0.0", "--port", "80"]  
