variable "name" {
  description = "The name of the stack."
  default = "pcs-infra"
}

variable "environment" {
  description = "The name of your environment."
}

variable "region" {
  description = "The AWS region."
}

variable "availability_zones" {
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "A list of CIDRs for private subnets in the VPC."
  default     = ["10.0.0.0/20", "10.0.32.0/20", "10.0.64.0/20"]
}

variable "public_subnets" {
  description = "A list of CIDRs for public subnets in your VPC."
  default     = ["10.0.16.0/20", "10.0.48.0/20", "10.0.80.0/20"]
}

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to."
  default     = "./.kube"
}

variable "k8s_version" {
  description = "Kubernetes version"
  default = "1.18"
}

