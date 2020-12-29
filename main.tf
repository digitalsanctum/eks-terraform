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

module "aws-eks-us-east-1" {
  source          = "./eks"
  namespace       = var.namespace
  environment     = var.environment
  region          = "us-east-1"
  k8s_version     = var.k8s_version
  vpc_id          = module.aws-vpc-us-east-1.id
  private_subnets = module.aws-vpc-us-east-1.private_subnets
  public_subnets  = module.aws-vpc-us-east-1.public_subnets
  kubeconfig_path = var.kubeconfig_path
}

module "aws-eks-us-west-2" {
  source          = "./eks"
  namespace       = var.namespace
  environment     = var.environment
  region          = "us-west-2"
  k8s_version     = var.k8s_version
  vpc_id          = module.aws-vpc-us-west-2.id
  private_subnets = module.aws-vpc-us-west-2.private_subnets
  public_subnets  = module.aws-vpc-us-west-2.public_subnets
  kubeconfig_path = var.kubeconfig_path
}

module "aws-eks-fargate-us-east-1" {
  source               = "./fargate"
  namespace            = var.namespace
  environment          = var.environment
  region               = "us-east-1"
  private_subnets      = module.aws-vpc-us-east-1.private_subnets
  eks_cluster_name     = module.aws-eks-us-east-1.cluster_id
  eks_cluster_endpoint = module.aws-eks-us-east-1.cluster_endpoint
}

module "aws-eks-fargate-us-west-2" {
  source               = "./fargate"
  namespace            = var.namespace
  environment          = var.environment
  region               = "us-west-2"
  private_subnets      = module.aws-vpc-us-west-2.private_subnets
  eks_cluster_name     = module.aws-eks-us-west-2.cluster_id
  eks_cluster_endpoint = module.aws-eks-us-west-2.cluster_endpoint
}
