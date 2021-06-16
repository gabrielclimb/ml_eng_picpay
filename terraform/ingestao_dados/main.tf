# lambda
resource "aws_lambda_function" "lambda_punkapi" {
  image_uri     = "ecr path"
  function_name = var.lambda_function_name
  description   = "Get data from punkapi, endpoint random"
  role          = aws_iam_role.iam_for_lambda.arn

  environment {
    variables = {
      URL_PUNKAPI = "https://api.punkapi.com/v2/beers/random"
    }
  }
}

resource "aws_iam_role" "iam_for_lambda_punkapi" {
  name = "iam_for_lambda_punkapi"

  assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
    }
    EOF
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_punkapi.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule_lambda_rule_punkapi.arn
}

# cloudwatch event. Its gonna trigger lambda
resource "aws_cloudwatch_event_rule" "rule_lambda_rule_punkapi" {
  name        = "rule_lambda_punkapi"
  description = "Rule thats gonna trigger the punkapi lambda"
  is_enabled = true
  schedule_expression ="rate(5 minute)"
  tags = var.ingestion_tags
}

resource "aws_cloudwatch_event_target" "target_lambda_punkapi" {
  rule      = aws_cloudwatch_event_rule.rule_lambda_rule_punkapi.name
  arn       = aws_lambda_function.lambda_punkapi.arn
}

# logs
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
        }
    ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda_punkapi.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}