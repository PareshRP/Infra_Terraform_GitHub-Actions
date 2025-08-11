FROM python:3.9-slim

RUN pip install --no-cache-dir boto3

WORKDIR /app
COPY python_script.py .

ENTRYPOINT ["python", "python_script.py"]
CMD []
