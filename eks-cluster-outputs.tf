output "eks_cluster_endpoint" {
  description = "The EKS cluster endpoint"
  value       = "${aws_eks_cluster.eks_cluster.endpoint}"
}

output "eks_cluster_certificate_authority" {
  description = "The EKS cluster Certificate Authority for the client authentication"
  value       = "${aws_eks_cluster.eks_cluster.certificate_authority.0.data}"
}

output "eks_cluster_name" {
  description = "The EKS Cluster name"
  value       = "${aws_eks_cluster.eks_cluster.name}"
}

output "eks_cluster_iam_role_arn" {
  description = "The EKS cluster IAM Role ARN"
  value       = "${aws_iam_role.eks_iam_role.arn}"
}

output "eks_cluster_iam_role_name" {
  description = "The EKS cluster IAM Role Name"
  value       = "${aws_iam_role.eks_iam_role.name}"
}
