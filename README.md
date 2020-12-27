# eks-terraform

This repository is home to the foundational, setup once infrastructure for an AWS EKS cluster.

What's included:

* A VPC with public and private subnets
* An EKS Cluster with mixed Fargate and EC2 workgroups
* Includes nginx deploy for infrastructure verification purposes only

## Usage

To establish remote state using S3 and locking via a DynamoDB table, run the following:
```shell
cd remote-state
tf init
tf plan
tf apply -auto-approve 
```

## References

* [Set up the ALB Ingress Controller on an Amazon EKS cluster for Fargate](https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/)
