provider "aws" {
    region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_bucket" "example" {
    bucket = "example-bucket-${random_id.suffix.hex}"
}

resource "aws_iam_role" "lambda_exec_role" {
    name = "lambda_exec_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    })
}

resource "aws_lambda_function" "example_lambda" {
    function_name = "example-lambda-${random_id.suffix.hex}"
    runtime = "nodejs18.x"
    handler = "index.handler"
    role = aws_iam_role.lambda_exec.arn
    filename = data.archive_file.lambda_zip.output_path
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    environment {
        variables = {
            LOG_LEVEL = "info" 
        }
    }
}

resource "aws_iam_role" "lambda_exec" {
  name = "example_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
