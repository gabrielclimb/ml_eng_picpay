
resource "aws_kinesis_firehose_delivery_stream" "raw_data_beer" {
  name        = "kinesis-firehose-extended-s3-raw-data-beer"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = var.kinesis_arn
    role_arn           = aws_iam_role.firehose_role_raw.arn
  }

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role_raw.arn
    bucket_arn          = aws_s3_bucket.raw_data_beer_bucket.arn
    buffer_interval     = 60
    prefix              = "tb_data_beer_raw/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "error/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_stream_logging_stream.name
    }
  }
}

resource "aws_cloudwatch_log_group" "kinesis_firehose_stream_logging_group" {
  name = "/aws/kinesisfirehose/kinesis-firehose-extended-s3-raw-data-beer"
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_stream_logging_stream" {
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
  name           = "S3Delivery"
}

resource "aws_s3_bucket" "raw_data_beer_bucket" {
  bucket        = "picpay-raw-databeer"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "firehose_role_raw" {
  name = "firehose_role_raw"

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
    name = "kinesis_full_acces"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "kinesis:*",
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
