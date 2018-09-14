####################
## Security Group ##
####################

resource "aws_security_group" "workers_sg" {
  name        = "${var.eks_name}-workers-sg"
  description = "${var.workers_sg_description}"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress = "${var.workers_sg_egress}"

  tags = "${
    merge(
      map("Name", format("%s-workers-sg", var.eks_name)),
      map("kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}", "shared")
    )
  }"
}

# Ingress rules
resource "aws_security_group_rule" "workers_ingress_from_control_plane" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.eks_sg.id}"
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id        = "${aws_security_group.workers_sg.id}"
}

resource "aws_security_group_rule" "workers_https_ingress_from_control_plane" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.eks_sg.id}"
  description              = "Allow worker Kubelets and pods to receive SSL communication from the cluster control plane"
  security_group_id        = "${aws_security_group.workers_sg.id}"
}

resource "aws_security_group_rule" "workers_ingress_from_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
  description       = "Allow node to communicate with each other"
  security_group_id = "${aws_security_group.workers_sg.id}"
}

# Optional: SSH ingress rule
resource "aws_security_group_rule" "workers_ingress_ssh_with_source_sg_id" {
  count                    = "${length(var.workers_ingress_ssh_source_sg_ids)}"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "TCP"
  source_security_group_id = "${element(var.workers_ingress_ssh_source_sg_ids, count.index)}"
  description              = "Allow worker nodes to receive SSH connection from custom Security Group ID's"
  security_group_id        = "${aws_security_group.workers_sg.id}"
}

resource "aws_security_group_rule" "workers_ingress_ssh_with_cidr_blocks" {
  count             = "${length(var.workers_ingress_ssh_cidr_blocks) != 0 ? 1 : 0}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = "${var.workers_ingress_ssh_cidr_blocks}"
  description       = "Allow worker nodes to receive SSH connection from custom CIDR blocks"
  security_group_id = "${aws_security_group.workers_sg.id}"
}

###########################
## IAM Role and Policies ##
###########################

resource "aws_iam_role" "workers_iam_role" {
  description           = "${var.workers_iam_role_description}"
  name                  = "${var.eks_name}-worker-nodes-role"
  assume_role_policy    = "${var.workers_assume_role_policy}"
  force_detach_policies = "${var.workers_role_detach_policies}"
}

resource "aws_iam_role_policy_attachment" "workers_policy_attachment" {
  count      = "${length(var.workers_policies)}"
  policy_arn = "${element(var.workers_policies, count.index)}"
  role       = "${aws_iam_role.workers_iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "workers_extra_policy_attachment" {
  count      = "${length(var.workers_extra_policies)}"
  policy_arn = "${element(var.workers_extra_policies, count.index)}"
  role       = "${aws_iam_role.workers_iam_role.name}"
}

resource "aws_iam_instance_profile" "workers_instance_profile" {
  name = "${var.eks_name}-instance-profile"
  role = "${aws_iam_role.workers_iam_role.name}"
}

#######################
## AutoScaling Group ##
#######################

# ASG
resource "aws_autoscaling_group" "workers_asg" {
  name                      = "${aws_launch_configuration.workers_launch_configuration.name}"
  depends_on                = ["aws_launch_configuration.workers_launch_configuration"]
  max_size                  = "${var.workers_asg_max_size}"
  min_size                  = "${var.workers_asg_min_size}"
  health_check_grace_period = "${var.workers_asg_health_check_grace_period}"
  health_check_type         = "${var.workers_asg_health_check_type}"
  desired_capacity          = "${var.workers_asg_desired_capacity}"
  force_delete              = "${var.workers_asg_force_delete}"
  launch_configuration      = "${aws_launch_configuration.workers_launch_configuration.name}"
  vpc_zone_identifier       = ["${aws_subnet.private_subnet.*.id}"]
  termination_policies      = ["${var.workers_asg_termination_policies }"]

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${var.eks_name}-worker-node", "propagate_at_launch", true),
      map("key", format(
        "kubernetes.io/cluster/%s", aws_eks_cluster.eks_cluster.name
        ),
        "value", "owned", "propagate_at_launch", true)
    ),
    var.workers_asg_tags)
  }"]

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Configuration
resource "aws_launch_configuration" "workers_launch_configuration" {
  name_prefix     = "${var.eks_name}-worker-nodes-"
  image_id        = "${var.workers_ami_id}"
  instance_type   = "${var.workers_instance_type}"
  key_name        = "${var.workers_key_name}"
  security_groups = ["${aws_security_group.workers_sg.id}"]

  user_data = "${
    var.workers_custom_user_data != ""
      ? var.workers_custom_user_data
      : data.template_file.init.rendered
  }"

  iam_instance_profile = "${aws_iam_instance_profile.workers_instance_profile.id}"

  root_block_device {
    volume_type = "${var.workers_root_volume_type}"
    volume_size = "${var.workers_root_volume_size}"

    iops = "${var.workers_root_volume_type == "io1" ?
      var.workers_root_iops != 0
        ? var.workers_root_iops
        : var.workers_root_volume_size * 50
      : 0
    }"

    delete_on_termination = "${var.workers_root_delete_on_termination}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

## Autoscaling Policies

# Out
resource "aws_autoscaling_policy" "workers_policy_out" {
  name                   = "${aws_autoscaling_group.workers_asg.name}-out"
  scaling_adjustment     = "${var.workers_out_scaling_adjustment}"
  adjustment_type        = "${var.workers_out_adjustment_type}"
  cooldown               = "${var.workers_out_cooldown}"
  autoscaling_group_name = "${aws_autoscaling_group.workers_asg.name}"
  policy_type            = "${var.workers_out_policy_type}"
}

resource "aws_cloudwatch_metric_alarm" "workers_out_alarm" {
  alarm_name          = "${aws_autoscaling_group.workers_asg.name}-out"
  comparison_operator = "${var.alarm_out_comparison_operator}"
  evaluation_periods  = "${var.alarm_out_evaluation_periods}"
  metric_name         = "${var.alarm_out_metric_name}"
  namespace           = "AWS/EC2"
  period              = "${var.alarm_out_period}"
  statistic           = "${var.alarm_out_statistic}"
  threshold           = "${var.alarm_out_threshold}"

  alarm_actions = ["${aws_autoscaling_policy.workers_policy_out.arn}"]

  dimensions = "${var.alarm_out_dimensions}"
}

# In
resource "aws_autoscaling_policy" "workers_policy_in" {
  name                   = "${aws_autoscaling_group.workers_asg.name}-in"
  scaling_adjustment     = "${var.workers_in_scaling_adjustment}"
  adjustment_type        = "${var.workers_in_adjustment_type}"
  cooldown               = "${var.workers_in_cooldown}"
  autoscaling_group_name = "${aws_autoscaling_group.workers_asg.name}"
  policy_type            = "${var.workers_in_policy_type}"
}

resource "aws_cloudwatch_metric_alarm" "workers_in_alarm" {
  alarm_name          = "${aws_autoscaling_group.workers_asg.name}-in"
  comparison_operator = "${var.alarm_in_comparison_operator}"
  evaluation_periods  = "${var.alarm_in_evaluation_periods}"
  metric_name         = "${var.alarm_in_metric_name}"
  namespace           = "AWS/EC2"
  period              = "${var.alarm_in_period}"
  statistic           = "${var.alarm_in_statistic}"
  threshold           = "${var.alarm_in_threshold}"

  alarm_actions = ["${aws_autoscaling_policy.workers_policy_in.arn}"]

  dimensions = "${var.alarm_in_dimensions}"
}
