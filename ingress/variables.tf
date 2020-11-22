variable "name" {
  description = "The name of the stack."
}

variable "environment" {
  description = "The name of your environment."
}

variable "region" {
  description = "The AWS region."
}

variable "vpc_id" {
  description = "The VPC the cluser should be created in"
}

variable "cluster_id" {
  description = "The ID of the cluster where the ingress controller should be attached"
}

variable "cluster_name" {
  description = "The Name of the cluster where the ingress controller should be attached"
}

variable "alb_ingress_controller_version" {
  default = "v1.1.5"
}
