terraform {
  required_version = "~>0.14"
  backend "s3" {
    bucket  = "${var.namespace}-tf-state-${var.region}"
    key     = "${var.environment}/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

resource "aws_flow_log" "main" {
  iam_role_arn = aws_iam_role.vpc-flow-logs-role.arn
  log_destination = aws_cloudwatch_log_group.vpc.arn
  traffic_type = "ALL"
  vpc_id = var.vpc_id
}

resource "aws_cloudwatch_log_group" "vpc" {
  name = "/aws/vpc/${var.namespace}-${var.environment}-${var.region}/flow"
  retention_in_days = 7

  tags = {
    name = "${var.namespace}-${var.environment}-${var.region}-vpc-cloudwatch-log-group"
    environment = var.environment
  }
}

resource "aws_iam_role" "vpc-flow-logs-role" {
  name = "${var.namespace}-${var.environment}-${var.region}-vpc-flow-logs-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "vpc-flow-logs-policy" {
  name = "${var.namespace}-${var.environment}-${var.region}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc-flow-logs-role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}
