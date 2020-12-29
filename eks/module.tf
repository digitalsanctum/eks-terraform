terraform {
  required_version = "~>0.14"
  backend "s3" {
    bucket  = "${var.namespace}-tf-state-${var.region}"
    key     = "${var.environment}/terraform.tfstate"
    encrypt = true
  }
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.main.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.main.cluster_id
}

locals {
  cluster_name = "${var.namespace}-${var.environment}"
}

resource "aws_iam_policy" "AmazonEKSClusterCloudWatchMetricsPolicy" {
  name = "AmazonEKSClusterCloudWatchMetricsPolicy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "AmazonEKSClusterNLBPolicy" {
  name = "AmazonEKSClusterNLBPolicy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "elasticloadbalancing:*",
                "ec2:CreateSecurityGroup",
                "ec2:Describe*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.namespace}-eks-cluster-role"
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSCloudWatchMetricsPolicy" {
  policy_arn = aws_iam_policy.AmazonEKSClusterCloudWatchMetricsPolicy.arn
  role = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterNLBPolicy" {
  policy_arn = aws_iam_policy.AmazonEKSClusterNLBPolicy.arn
  role = aws_iam_role.eks_cluster_role.name
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name = "/aws/eks/${var.namespace}-${var.environment}/${var.region}/cluster"
  retention_in_days = 30

  tags = {
    Name = "${var.namespace}-${var.environment}-eks-cloudwatch-log-group"
    Environment = var.environment
  }
}

module "main" {
  source = "terraform-aws-modules/eks/aws"
  version = "13.2.1"
  cluster_name = local.cluster_name
  cluster_version = var.k8s_version
  cluster_create_security_group = true
  subnets = concat(var.public_subnets.*.id, var.private_subnets.*.id)
  vpc_id = var.vpc_id
  manage_aws_auth = true


//  map_roles    = var.map_roles
//  map_users    = var.map_users
//  map_accounts = var.map_accounts
}

# Fetch OIDC provider thumbprint for root CA
data "external" "thumbprint" {
  depends_on = [module.main]
  program = ["sh", "${path.module}/oidc_thumbprint.sh", var.region]
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url = data.aws_eks_cluster.cluster.identity[0]["oidc"][0]["issuer"]

  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.namespace}-eks-node-group-role"
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks_node_group_role.name
}

resource "aws_eks_node_group" "main" {
  cluster_name = module.main.cluster_id
  node_group_name = "kube-system"
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  subnet_ids = var.private_subnets.*.id

  scaling_config {
    desired_size = 1
    max_size = 3
    min_size = 1
  }

  instance_types = [
    "t3.small"
  ]

  version = var.k8s_version

  tags = {
    "Name" = "${var.namespace}-${var.environment}-eks-node-group"
    "Environment" = var.environment
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    kubeconfig_name = "eks_${local.cluster_name}"
    clustername = local.cluster_name
    endpoint = data.aws_eks_cluster.cluster.endpoint
    cluster_auth_base64 = data.aws_eks_cluster.cluster.certificate_authority[0].data
  }
}

resource "local_file" "kubeconfig" {
  content = data.template_file.kubeconfig.rendered
  filename = pathexpand("${var.kubeconfig_path}/${var.region}/config")
}


