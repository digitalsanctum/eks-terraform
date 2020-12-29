output "kubectl_config" {
  description = "Path to new kubectl config file"
  value = pathexpand("${var.kubeconfig_path}/${var.region}/config")
}

output "cluster_id" {
  description = "ID of the created cluster"
  value = module.main.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint of the created cluster"
  value = module.main.cluster_endpoint
}
