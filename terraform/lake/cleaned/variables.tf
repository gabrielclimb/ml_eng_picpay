variable "kinesis_arn" {
  type        = string
  description = "kinesis arn"
}

variable "lambda_function_name" {
  type    = string
  default = "lambda_databeer_transformation"
}
