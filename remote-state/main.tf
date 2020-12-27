variable "prefix" {
  default = "digitalsanctum-eks-demo"
}

module "aws-state-us-east-1" {
  source = "./dynamodb-s3"
  region = "us-east-1"
  prefix = var.prefix
}

module "aws-state-us-west-2" {
  source = "./dynamodb-s3"
  region = "us-west-2"
  prefix = var.prefix
}
