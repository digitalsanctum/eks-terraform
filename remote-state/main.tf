provider "aws" {
  region = "us-west-2"
}

locals {
  name = "pcs-infra"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.name}-terraform-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${local.name}-terraform-state-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
