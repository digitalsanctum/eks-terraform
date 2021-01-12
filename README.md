# eks-terraform

This repository is an example of deploying a Kubernetes cluster on AWS (AWS EKS) using Terraform. 

What's included:

* A VPC with public and private subnets
* An EKS Cluster with mixed Fargate and EC2 workgroups
* Includes nginx deploy for infrastructure verification purposes only

## Usage

To establish remote state using S3 and locking via a DynamoDB table (one-time setup), run the following:
```shell
cd remote-state
tf init
tf plan
tf apply -auto-approve 
```

To deploy a VPC, EKS Cluster with Fargate profile and ALB Ingress Controller, run the following from the project root:
```shell
tf init
tf plan
tf apply -auto-approve
```

## Installing the Kubernetes Dashbaord

Follow the instructions here: https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

## Deploy a Test App (nginx)

```shell
kubectl apply -f nginx.yaml
```

## Destroy

```shell
terraform state rm module.aws-alb-ingress-controller.kubernetes_deployment.alb_ingress
terraform destroy -auto-approve
```

## References

* [Set up the ALB Ingress Controller on an Amazon EKS cluster for Fargate](https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/)
