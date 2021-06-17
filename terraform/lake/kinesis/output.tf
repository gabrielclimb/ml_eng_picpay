output "name_kinesis_firehose_raw_data_beer" {
  value = aws_kinesis_stream.kinesis_stream_data_beer.name
}

output "arn_kinesis_firehose_raw_data_beer" {
  value = aws_kinesis_stream.kinesis_stream_data_beer.arn
}
