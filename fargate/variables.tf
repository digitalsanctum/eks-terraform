variable "namespace" {
  description = "The name of the stack."
}

variable "region" {}

variable "environment" {
  description = "The name of your environment."
}

variable "private_subnets" {
  description = "List of private subnet IDs"
}

variable "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
}

variable "fargate_profile_name" {
  default = "default"
}
