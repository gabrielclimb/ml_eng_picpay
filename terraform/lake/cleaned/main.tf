# firehose
resource "aws_kinesis_firehose_delivery_stream" "cleaned_data_beer" {
  name        = "kinesis-firehose-extended-s3-cleaned-data-beer"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = var.kinesis_arn
    role_arn           = aws_iam_role.firehose_role_cleaned.arn
  }

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role_cleaned.arn
    bucket_arn          = aws_s3_bucket.cleaned_data_beer_bucket.arn
    buffer_interval     = 60
    prefix              = "tb_data_beer_cleaned/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "error/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_stream_logging_stream.name
    }
    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_databeer_transformation.arn}:$LATEST"
        }
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "kinesis_firehose_stream_logging_group" {
  name = "/aws/kinesisfirehose/kinesis-firehose-extended-s3-cleaned-data-beer"
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_stream_logging_stream" {
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
  name           = "S3Delivery"
}

resource "aws_s3_bucket" "cleaned_data_beer_bucket" {
  bucket        = "picpay-cleaned-databeer"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "firehose_role_cleaned" {
  name = "firehose_role_cleaned"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "firehose.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  inline_policy {
    name = "full_acces"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "kinesis:*",
            "lambda:*",
            "cloudwatch:*",
            "s3:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

# lambda
data "archive_file" "lambda_databeer_transformation" {
  type        = "zip"
  source_file = "${path.root}/lambdas/${var.lambda_function_name}/app/app.py"
  output_path = "${path.root}/lambdas/${var.lambda_function_name}/app/app.zip"
}

resource "aws_lambda_function" "lambda_databeer_transformation" {
  filename      = data.archive_file.lambda_databeer_transformation.output_path
  function_name = "lambda_databeer_transformation"
  description   = "Transform json data into a table and save a csv"
  role          = aws_iam_role.iam_for_lambda_transformation.arn
  handler       = "app.lambda_handler"

  runtime = "python3.8"
}

resource "aws_iam_role" "iam_for_lambda_transformation" {
  name = "iam_for_lambda_transformation"

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
          Action = [
            "kinesis:*",
            "lambda:*",
            "cloudwatch:*",
            "s3:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

# Logs lambda
resource "aws_cloudwatch_log_group" "logs_lambda_cleaned" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_cleaned"
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
  role       = aws_iam_role.iam_for_lambda_transformation.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

