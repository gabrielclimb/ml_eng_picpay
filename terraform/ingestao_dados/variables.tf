variable "lambda_function_name" {
  type    = string
  default = "lambda_punkapi_random"
}

variable "kinesis_name" {
  type        = string
  description = "kinesis name"
}
