output "bucket_name_raw_data_beer" {
  value = aws_s3_bucket.raw_data_beer_bucket.id
}

output "arn_kinesis_firehose_raw_data_beer" {
  value = aws_kinesis_firehose_delivery_stream.raw_data_beer.arn
}
