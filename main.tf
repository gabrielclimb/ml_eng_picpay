provider "aws" {
}

module "ingestao" {
  source = "terraform/ingestao_dados"
  
}

module "lake" {
  source = "terraform/lake"
  
}