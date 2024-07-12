resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }]
    }) 
}

resource "aws_iam_policy_attachment" "s3_policy_attachment" {
    name = "s3_policy_attachment"
    roles = [ aws_iam_role.lambda_role.name ]
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "athena_policy_attachment" {
    name = "athena_policy_attachment"
    roles = [ aws_iam_role.lambda_role.name ]
    policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
    name = "lambda_policy_attachment"
    roles = [ aws_iam_role.lambda_role.name ]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "glue_policy_attachment" {
    name = "glue_policy_attachment"
    roles = [ aws_iam_role.lambda_role.name ]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "archive_file" "lambda_source_archive" {
  type = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/my-lambda.zip"
}

resource "aws_lambda_function" "piyars_lambda" {
    function_name = "piyars_lambda"
    filename = "${path.module}/my-lambda.zip"

    runtime = "python3.9"
    handler = "lambda.lambda_handler"
    memory_size = 256

    source_code_hash = data.archive_file.lambda_source_archive.output_base64sha256

    role = aws_iam_role.lambda_role.arn
}


resource "aws_lambda_function" "ctas_lambda" {
    function_name = "ctas_lambda"
    filename = "${path.module}/my-lambda.zip"

    runtime = "python3.9"
    handler = "ctas_lambda.lambda_handler"
    memory_size = 256

    source_code_hash = data.archive_file.lambda_source_archive.output_base64sha256

    role = aws_iam_role.lambda_role.arn

    timeout = 890
}


resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.piyars_lambda.arn
  principal = "s3.amazonaws.com"
}

resource "aws_s3_bucket_notification" "notification" {
  bucket = aws_s3_bucket.s3bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.piyars_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "source-data/"
  }

  depends_on = [
    aws_lambda_permission.allow_bucket
  ]
}


resource "aws_cloudwatch_event_rule" "hourly_lambda_trigger" {
  name                = "hourly-lambda-trigger"
  description         = "Triggers the Lambda function every hour"
  schedule_expression = "cron(0 * ? * * *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.hourly_lambda_trigger.name
  arn       = aws_lambda_function.ctas_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ctas_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.hourly_lambda_trigger.arn
}