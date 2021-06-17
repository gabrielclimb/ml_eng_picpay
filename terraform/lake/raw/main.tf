data "aws_caller_identity" "current" {}

resource "aws_kinesis_firehose_delivery_stream" "raw_data_beer" {
  name        = "kinesis-firehose-extended-s3-raw-data-beer"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = var.kinesis_arn
    role_arn           = aws_iam_role.firehose_role_raw.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role_raw.arn
    bucket_arn = aws_s3_bucket.raw_data_beer_bucket.arn
  }
}

resource "aws_s3_bucket" "raw_data_beer_bucket" {
  bucket        = "${data.aws_caller_identity.current.account_id}_raw_data_beer"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "firehose_role_raw" {
  name = "firehose_role_raw"

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
