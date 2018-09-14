output "workers_config_map_aws_auth" {
  value = "${module.eks.workers_config_map_aws_auth}"
}

output "kubeconfig" {
  value = "${module.eks.kubeconfig}"
}
