provider "aws" {
  region = "us-east-1"
}

module "ingestao" {
  source       = "./terraform/ingestao_dados"
  kinesis_name = module.kinesis.name_kinesis_firehose_raw_data_beer

  depends_on = [
    module.kinesis
  ]
}

module "cleaned" {
  source      = "./terraform/lake/cleaned"
  kinesis_arn = module.kinesis.arn_kinesis_firehose_raw_data_beer

  depends_on = [
    module.kinesis
  ]
}

module "raw" {
  source      = "./terraform/lake/raw"
  kinesis_arn = module.kinesis.arn_kinesis_firehose_raw_data_beer
  depends_on = [
    module.kinesis
  ]
}

module "kinesis" {
  source = "./terraform/lake/kinesis"

}
