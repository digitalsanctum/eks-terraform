variable "namespace" {
  description = "The name of the stack."
  type        = string
  default     = "digitalsanctum-eks"
}

variable "environment" {
  description = "The name of your environment."
  type        = string
  default     = "test"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-west-2"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
  type        = string
}

variable "private_subnets" {
  description = "A list of CIDRs for private subnets in the VPC."
  default     = ["10.0.0.0/20", "10.0.32.0/20", "10.0.64.0/20"]
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of CIDRs for public subnets in your VPC."
  default     = ["10.0.16.0/20", "10.0.48.0/20", "10.0.80.0/20"]
  type        = list(string)
}

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to."
  default     = "./.kube"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version"
  default     = "1.18"
  type        = string
}
