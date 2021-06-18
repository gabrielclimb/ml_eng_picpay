resource "aws_kinesis_stream" "kinesis_stream_data_beer" {
  name             = "kinesis_stream_data_beer"
  shard_count      = 1
  retention_period = 48

  enforce_consumer_deletion = true

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
}
