output "kubectl_config" {
  description = "Path to new kubectl config file"
  value = pathexpand("${var.kubeconfig_path}/config")
}

output "cluster_id" {
  description = "ID of the created cluster"
  value = module.main.cluster_id
}

output "cluster_name" {
  description = "Name of the created cluster"
  value = local.cluster_name
}
