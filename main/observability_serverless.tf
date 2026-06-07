resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/project-bedrock-cluster/cluster"
  retention_in_days = 7
  tags              = { Project = "karatu-2025-capstone" }
}

resource "aws_s3_bucket" "assets_bucket" {
  bucket        = "bedrock-assets-alt-soe-025-4831"
  force_destroy = true
  tags          = { Project = "karatu-2025-capstone" }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.assets_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.asset_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3_bucket]
}

resource "aws_iam_role" "lambda_role" {
  name = "project-bedrock-lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = { Project = "karatu-2025-capstone" }
}

resource "aws_iam_role_policy" "lambda_logging_policy" {
  name = "project-bedrock-lambda-logging"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}

resource "aws_lambda_function" "asset_processor" {
  filename      = "lambda_placeholder.zip"
  function_name = "bedrock-asset-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  tags          = { Project = "karatu-2025-capstone" }
}

resource "aws_lambda_permission" "allow_s3_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asset_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets_bucket.arn
}
