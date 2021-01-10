variable "namespace" {}

module "aws-state-us-west-2" {
  source = "./dynamodb-s3"
  region = "us-west-2"
  prefix = var.namespace
}
