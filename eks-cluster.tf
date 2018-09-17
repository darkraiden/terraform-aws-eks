####################
## Security Group ##
####################

resource "aws_security_group" "eks_sg" {
  name        = "${var.eks_name}-eks-sg"
  description = "${var.eks_sg_description}"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress = "${var.eks_sg_egress}"

  tags = "${
    merge(
      map("Name", format("%s-eks-sg", var.eks_name)),
      var.eks_sg_tags
    )
  }"
}

# Ingress rules
resource "aws_security_group_rule" "eks_ingress_https_with_cidr_blocks" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = "${var.eks_sg_https_ingress_cidr_blocks}"
  description       = "${var.eks_sg_https_ingress_description}"
  security_group_id = "${aws_security_group.eks_sg.id}"
}

resource "aws_security_group_rule" "eks_ingress_from_worker_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.workers_sg.id}"
  description              = "Allow worker nodes to access the EKS cluster"
  security_group_id        = "${aws_security_group.eks_sg.id}"
}

###########################
## IAM Role and Policies ##
###########################

resource "aws_iam_role" "eks_iam_role" {
  description           = "${var.eks_iam_role_description}"
  name                  = "${var.eks_name}-eks-role"
  assume_role_policy    = "${var.eks_assume_role_policy}"
  force_detach_policies = "${var.eks_role_detach_policies}"
}

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  count      = "${length(var.eks_policies)}"
  policy_arn = "${element(var.eks_policies, count.index)}"
  role       = "${aws_iam_role.eks_iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_extra_policy_attachment" {
  count      = "${length(var.eks_extra_policies)}"
  policy_arn = "${element(var.eks_extra_policies, count.index)}"
  role       = "${aws_iam_role.eks_iam_role.name}"
}

#################
## EKS Cluster ##
#################

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.eks_name}"
  role_arn = "${aws_iam_role.eks_iam_role.arn}"
  version  = "${var.kubernetes_version}"

  vpc_config {
    subnet_ids         = ["${aws_subnet.public_subnet.*.id}", "${aws_subnet.private_subnet.*.id}"]
    security_group_ids = ["${aws_security_group.eks_sg.id}"]
  }
}
