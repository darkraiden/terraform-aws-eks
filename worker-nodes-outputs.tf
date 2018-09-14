output "workers_config_map_aws_auth" {
  description = "The AWS Auth config map"
  value       = "${local.config_map_aws_auth}"
}

output "kubeconfig" {
  description = "The kubernetes config"
  value       = "${local.kubeconfig}"
}
