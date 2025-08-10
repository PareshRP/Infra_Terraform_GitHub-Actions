import boto3
import logging
import sys
import subprocess

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_bucket_name(terraform_dir):
    try:
        result = subprocess.run(
            ["terraform", "output", "-raw", "s3_bucket_name"],
            cwd=terraform_dir,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to get bucket name from Terraform: {e.stderr}")
        sys.exit(1)

def upload_file(bucket_name, file_path, object_name=None):
    s3 = boto3.client('s3')
    if object_name is None:
        object_name = file_path.split('/')[-1]
    try:
        s3.upload_file(file_path, bucket_name, object_name)
        logger.info(f"✅ File '{file_path}' uploaded to bucket '{bucket_name}' as '{object_name}'")
    except Exception as e:
        logger.error(f"❌ Failed to upload file: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        logger.error("Usage: python python_script.py <terraform_dir> <file_path>")
        sys.exit(1)

    terraform_dir = sys.argv[1]
    file_path = sys.argv[2]

    bucket_name = get_bucket_name(terraform_dir)
    logger.info(f"Using bucket: {bucket_name}")
    upload_file(bucket_name, file_path)
