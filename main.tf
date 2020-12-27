module "aws-vpc-us-east-1" {
  source             = "./networking/vpc"
  region             = "us-east-1"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  namespace          = var.namespace
  environment        = var.environment
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
}

module "aws-vpc-us-west-2" {
  source             = "./networking/vpc"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  namespace          = var.namespace
  environment        = var.environment
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
}

module "aws-flow-logs-us-east-1" {
  source      = "./flow_logs"
  region      = "us-east-1"
  environment = var.environment
  namespace   = var.namespace
  vpc_id      = module.aws-vpc-us-east-1.id
}

module "aws-flow-logs-us-west-2" {
  source      = "./flow_logs"
  region      = "us-west-2"
  environment = var.environment
  namespace   = var.namespace
  vpc_id      = module.aws-vpc-us-west-2.id
}

//module "eks" {
//  source          = "./eks"
//  name            = var.namespace
//  environment     = var.environment
//  region          = var.region
//  k8s_version     = var.k8s_version
//  vpc_id          = module.vpc.id
//  private_subnets = module.vpc.private_subnets
//  public_subnets  = module.vpc.public_subnets
//  kubeconfig_path = var.kubeconfig_path
//}
//
//module "fargate" {
//  source           = "./fargate"
//  name             = var.namespace
//  environment      = var.environment
//  region           = var.region
//  k8s_version      = var.k8s_version
//  vpc_id           = module.vpc.id
//  private_subnets  = module.vpc.private_subnets
//  public_subnets   = module.vpc.public_subnets
//  kubeconfig_path  = var.kubeconfig_path
//  eks_cluster_name = module.eks.cluster_id
//  depends_on = [
//    module.eks,
//    module.vpc
//  ]
//}
