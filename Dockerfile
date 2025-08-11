FROM python:3.9-slim

RUN apt-get update && apt-get install -y wget unzip \
 && wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip \
 && unzip terraform_1.5.7_linux_amd64.zip \
 && mv terraform /usr/local/bin/terraform \
 && rm terraform_1.5.7_linux_amd64.zip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir boto3

WORKDIR /app
COPY python_script.py .

ENTRYPOINT ["python", "python_script.py"]
CMD []
