# cloudwatch event. Its gonna trigger lambda
resource "aws_cloudwatch_event_rule" "rule_lambda_punkapi" {
  name                = "rule_lambda_punkapi"
  description         = "Rule thats gonna trigger the punkapi lambda"
  is_enabled          = true
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "target_lambda_punkapi" {
  rule = aws_cloudwatch_event_rule.rule_lambda_punkapi.name
  arn  = aws_lambda_function.lambda_punkapi.arn
}

# lambda
data "archive_file" "lambda_punkapi" {
  type        = "zip"
  source_file = "${path.root}/lambdas/lambda_punkapi/app/app.py"
  output_path = "${path.root}/lambdas/lambda_punkapi/app/app.zip"
}

resource "aws_lambda_function" "lambda_punkapi" {
  filename      = data.archive_file.lambda_punkapi.output_path
  function_name = var.lambda_function_name
  description   = "Get data from punkapi, endpoint random"
  role          = aws_iam_role.iam_for_lambda_punkapi.arn
  handler       = "app.lambda_handler"
  layers        = [aws_lambda_layer_version.libs_layer.arn]
  timeout       = 90

  runtime = "python3.8"
  environment {
    variables = {
      URL_PUNKAPI = "https://api.punkapi.com/v2/beers/random"
      STREAM_NAME = var.kinesis_name
    }
  }
}

resource "aws_lambda_layer_version" "libs_layer" {
  filename   = "${path.root}/lambdas/lambda_punkapi/python.zip"
  layer_name = "libs"

  compatible_runtimes = ["python3.8"]
}

resource "aws_iam_role" "iam_for_lambda_punkapi" {
  name = "iam_for_lambda_punkapi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["kinesis:*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_punkapi.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule_lambda_punkapi.arn
}

# logs
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_raw"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda_punkapi.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
