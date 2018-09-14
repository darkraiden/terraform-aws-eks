# Get all availability zones of a given AWS Region
data "aws_availability_zones" "all" {}

data "template_file" "init" {
  template = "${file("${path.module}/templates/worker-nodes-init.tpl")}"

  vars {
    authority_data = "${aws_eks_cluster.eks_cluster.certificate_authority.0.data}"
    eks_endpoint   = "${aws_eks_cluster.eks_cluster.endpoint}"
    eks_name       = "${aws_eks_cluster.eks_cluster.name}"
  }
}

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.workers_iam_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks_cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.eks_cluster.name}"
KUBECONFIG
}
