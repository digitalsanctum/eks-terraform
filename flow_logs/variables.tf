variable "region" {}

variable "namespace" {
  description = "The namespace of the stack."
}

variable "environment" {
  description = "The name of your environment."
}

variable "vpc_id" {
  description = "The VPC the cluster should be created in"
}
