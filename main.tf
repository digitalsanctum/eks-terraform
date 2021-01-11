
terraform {
  required_version = "~>0.14"
  backend "s3" {
    bucket  = "digitalsanctum-eks-tf-state"
    key     = "test/terraform.tfstate"
    dynamodb_table = "digitalsanctum-eks-tf-state-lock"
    encrypt = true
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}

module "aws-vpc" {
  source             = "./networking/vpc"
  region             = var.region
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  namespace          = var.namespace
  environment        = var.environment
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
}

//module "aws-flow-logs-us-west-2" {
//  source      = "./flow_logs"
//  region      = "us-west-2"
//  environment = var.environment
//  namespace   = var.namespace
//  vpc_id      = module.aws-vpc-us-west-2.id
//}

module "aws-eks" {
  source          = "./eks"
  namespace       = var.namespace
  environment     = var.environment
  region          = var.region
  k8s_version     = var.k8s_version
  vpc_id          = module.aws-vpc.id
  private_subnets = module.aws-vpc.private_subnets
  public_subnets  = module.aws-vpc.public_subnets
  kubeconfig_path = var.kubeconfig_path
}

module "aws-eks-fargate" {
  source               = "./fargate"
  namespace            = var.namespace
  environment          = var.environment
  region               = var.region
  private_subnets      = module.aws-vpc.private_subnets
  eks_cluster_name     = module.aws-eks.cluster_id
  eks_cluster_endpoint = module.aws-eks.cluster_endpoint
}

module "aws-alb-ingress-controller" {
  source      = "./ingress"
  namespace   = var.namespace
  environment = var.environment
  region      = var.region
  cluster_id  = module.aws-eks.cluster_id
  vpc_id      = module.aws-vpc.id
}
