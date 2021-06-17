data "aws_caller_identity" "current" {}

# firehose
resource "aws_kinesis_firehose_delivery_stream" "cleaned_data_beer" {
  name        = "kinesis-firehose-extended-s3-cleaned-data-beer"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = var.kinesis_arn
    role_arn           = aws_iam_role.firehose_role_cleaned.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role_cleaned.arn
    bucket_arn = aws_s3_bucket.cleaned_data_beer_bucket.arn

    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_kinesis_firehose_data_beer_transformation.arn}:$LATEST"
        }
      }
    }
  }

}


resource "aws_s3_bucket" "cleaned_data_beer_bucket" {
  bucket        = "${data.aws_caller_identity.current.account_id}_cleaned_data_beer"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "firehose_role_cleaned" {
  name = "firehose_role_cleaned"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# lambda
data "archive_file" "lambda_databeer_transformation" {
  type        = "zip"
  source_file = "../../lambdas/lambda_databeer_transformation/app/app.py"
  output_path = "../../lambdas/lambda_databeer_transformation/app.zip"
}

resource "aws_lambda_function" "lambda_kinesis_firehose_data_beer_transformation" {
  filename      = data.archive_file.lambda_databeer_transformation.output_path
  function_name = "lambda_kinesis_firehose_data_beer_transformation"
  description   = "Transform json data into a table and save a csv"
  role          = aws_iam_role.firehose_role_cleaned.arn
  handler       = "app.lambda_handler"

  runtime = "python3.8"
}
