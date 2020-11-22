variable "name" {
  description = "The name of the stack."
}

variable "environment" {
  description = "The name of your environment."
}

variable "region" {
  description = "The AWS region."
}

variable "k8s_version" {
  description = "Kubernetes version."
}

variable "vpc_id" {
  description = "The VPC the cluster should be created in"
}

variable "private_subnets" {
  description = "List of private subnet IDs"
}

variable "public_subnets" {
  description = "List of private subnet IDs"
}

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
}

variable "fargate_profile_name" {
  default = "fargate-default"
}
