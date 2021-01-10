variable "namespace" {
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
  description = "The VPC the cluster should be created in."
}

variable "private_subnets" {
  description = "List of private subnet IDs."
}

variable "public_subnets" {
  description = "List of private subnet IDs."
}

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to."
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default = ["515292396565"]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
//  default = [
//    {
//      rolearn  = "arn:aws:iam::515292396565:role/digitalsanctum-demo-eks-fargate-pod-execution-role"
//      username = "digitalsanctum-demo-eks-fargate-pod-execution-role"
//      groups   = ["system:masters"]
//    },
//  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::515292396565:user/shane"
      username = "admin"
      groups   = ["system:masters", "system:nodes", "system:bootstrappers"]
    }
  ]
}
