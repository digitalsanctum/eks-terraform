terraform {
  required_version = "~>0.13"
  backend "s3" {
    bucket  = "pcs-infra-terraform-state"
    key     = "test/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 3.17"
  region  = var.region
}

module "vpc" {
  source             = "./vpc"
  name               = var.name
  environment        = var.environment
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

//module "flow_logs" {
//  source = "./flow_logs"
//  environment = var.environment
//  name = var.name
//  vpc_id = module.vpc.id
//}

module "eks" {
  source          = "./eks"
  name            = var.name
  environment     = var.environment
  region          = var.region
  k8s_version     = var.k8s_version
  vpc_id          = module.vpc.id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  kubeconfig_path = var.kubeconfig_path
}

module "fargate" {
  source           = "./fargate"
  name             = var.name
  environment      = var.environment
  region           = var.region
  k8s_version      = var.k8s_version
  vpc_id           = module.vpc.id
  private_subnets  = module.vpc.private_subnets
  public_subnets   = module.vpc.public_subnets
  kubeconfig_path  = var.kubeconfig_path
  eks_cluster_name = module.eks.cluster_name
}

module "app" {
  source          = "./app"
  fargate_profile = module.fargate.fargate_profile
  cluster_id      = module.eks.cluster_id
}

module "ingress" {
  source       = "./ingress"
  name         = var.name
  environment  = var.environment
  region       = var.region
  vpc_id       = module.vpc.id
  cluster_id   = module.eks.cluster_id
  cluster_name = module.eks.cluster_name
}
