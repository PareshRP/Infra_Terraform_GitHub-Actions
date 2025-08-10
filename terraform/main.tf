provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
    bucket = "example-bucket"
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
    function_name = "example-lambda"
    runtime = "nodejs14.x"
    handler = "index.handler"
    role = aws_iam_role.lambda_exec.arn
    filename = "${path.module}/lambda.zip"
    source_code_hash = filebase64sha256("${path.module}/lambda.zip")
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