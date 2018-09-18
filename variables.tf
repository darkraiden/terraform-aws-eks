variable "eks_name" {
  default = ""
}

#########
## VPC ##
#########

## Networking
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
}

variable "vpc_instance_tenancy" {
  description = "The instance tenancy mode for the VPC - 'default' or 'dedicated' accepted only"
}

variable "public_subnets_count" {
  default = 3
}

variable "private_subnets_count" {
  default = 3
}

## Tags
variable "vpc_tags" {
  description = "Additional tags for the VPC"
  default     = {}
}

variable "private_subnets_tags" {
  description = "Additional tags for the Private Subnets"
  default     = {}
}

variable "public_subnets_tags" {
  description = "Additional tags for the Public Subnets"
  default     = {}
}

variable "eks_sg_tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

#################
## EKS Cluster ##
#################

# Security Group

variable "eks_sg_egress" {
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}

variable "eks_sg_description" {
  default = "Managed by terraform"
}

variable "eks_sg_https_ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "eks_sg_https_ingress_description" {
  default = "Managed by terraform"
}

# IAM Role

variable "eks_iam_role_description" {
  description = "A description of the EKS role"
  default     = "IAM Role for EKS Clusters"
}

variable "eks_assume_role_policy" {
  default = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

variable "eks_role_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying."
  default     = false
}

variable "eks_policies" {
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
  ]
}

variable "eks_extra_policies" {
  description = "A list of Extra Policies to attach to the EKS role"
  default     = []
}

variable "kubernetes_version" {
  description = "The Kubernetes version used by EKS"
  default     = ""
}

##################
## Worker Nodes ##
##################

# Security Group

variable "workers_sg_egress" {
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}

variable "workers_sg_description" {
  default = "Managed by terraform"
}

variable "workers_sg_https_ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "workers_sg_https_ingress_description" {
  default = "Managed by terraform"
}

variable "workers_ingress_ssh_source_sg_ids" {
  description = "List of security group IDs that will be able to SSH to the worker nodes"
  default     = []
}

variable "workers_ingress_ssh_cidr_blocks" {
  description = "List of CIDR blocks that will be able to SSH to the worker nodes"
  default     = []
}

# IAM Role

variable "workers_iam_role_description" {
  description = "A description of the Worker Nodes role"
  default     = "IAM Role for Worker Nodes Clusters"
}

variable "workers_assume_role_policy" {
  default = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

variable "workers_role_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying."
  default     = false
}

variable "workers_policies" {
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

variable "workers_extra_policies" {
  description = "A list of Extra Policies to attach to the EKS role"
  default     = []
}

# Worker Nodes AutoScaling Group

variable "workers_asg_max_size" {
  default = 3
}

variable "workers_asg_min_size" {
  default = 1
}

variable "workers_asg_health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  default     = 300
}

variable "workers_asg_health_check_type" {
  description = "'EC2' or 'ELB'. Controls how health checking is done."
  default     = "EC2"
}

variable "workers_asg_desired_capacity" {
  description = "The number of EC2 instances that should be running in the group."
  default     = 2
}

variable "workers_asg_force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate."
  default     = false
}

variable "workers_asg_termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
  type        = "list"
  default     = ["OldestInstance"]
}

variable "workers_asg_tags" {
  description = "A list of extra tags"
  type        = "list"
  default     = []
}

variable "workers_ami_id" {
  description = "The Worker Nodes AMI ID"
  type        = "string"
}

variable "workers_instance_type" {
  description = "The EC2 instance type"
  type        = "string"
}

variable "workers_key_name" {
  description = "The key name that should be used for the instance"
  type        = "string"
  default     = ""
}

variable "workers_custom_user_data" {
  description = "A custom user data script to be attached to the Worker Nodes Launch Configuration"
  default     = ""
}

variable "workers_extend_user_data" {
  description = "Additional script to be appended to the Worker Nodes templated user data"
  default     = ""
}

variable "workers_root_volume_type" {
  description = "The type of volume. Can be \"standard\", \"gp2\", or \"io1\""
  default     = "gp2"
}

variable "workers_root_volume_size" {
  description = "The size of the volume in gigabytes"
  default     = 20
}

variable "workers_root_iops" {
  description = "The amout of provisioned IOPS. This must be set with a root_volume_type of \"io1\""
  default     = 0
}

variable "workers_root_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination"
  default     = true
}

# Scaling Policies and Alarms

## Out
variable "workers_out_scaling_adjustment" {
  description = "The number of in stance by which to scale the Worker Nodes out"
  default     = 1
}

variable "workers_out_adjustment_type" {
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity"
  default     = "ChangeInCapacity"
}

variable "workers_out_cooldown" {
  description = "The amout of time, in seconds, after a scaling activity completes and before the next scaling activity can start"
  default     = 300
}

variable "workers_out_policy_type" {
  description = "The Worker Nodes Out policy type, either 'SimpleScaling', 'StepScaling' or 'TargetTrackingScaling'"
  default     = "SimpleScaling"
}

variable "alarm_out_comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold when scaling the Worker Nodes out"
  default     = "GreaterThanOrEqualToThreshold"
}

variable "alarm_out_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold when scaling the Worker Nodes out"
  default     = 1
}

variable "alarm_out_metric_name" {
  description = "The name for the alarm's associated metric when scaling the Worker Nodes out"
  default     = "CPUUtilization"
}

variable "alarm_out_period" {
  description = "The period in seconds over which the specified statistic is applied when scaling the Worker Nodes out"
  default     = 60
}

variable "alarm_out_statistic" {
  description = "The statistic to apply to the alarm's associated metric when scaling the Worker Nodes out"
  default     = "Average"
}

variable "alarm_out_threshold" {
  description = "The value against which the specified statistic is compared when scaling the Worker Nodes out"
}

variable "alarm_out_dimensions" {
  description = "The dimensions for the alarm's associated metric when scaling the Worker Nodes out"
  type        = "map"
  default     = {}
}

## In
variable "workers_in_scaling_adjustment" {
  description = "The number of in stance by which to scale the Worker Nodes in"
  default     = -1
}

variable "workers_in_adjustment_type" {
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity"
  default     = "ChangeInCapacity"
}

variable "workers_in_cooldown" {
  description = "The amout of time, in seconds, after a scaling activity completes and before the next scaling activity can start"
  default     = 300
}

variable "workers_in_policy_type" {
  description = "The Worker Nodes In policy type, either 'SimpleScaling', 'StepScaling' or 'TargetTrackingScaling'"
  default     = "SimpleScaling"
}

variable "alarm_in_comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold when scaling the Worker Nodes in"
  default     = "GreaterThanOrEqualToThreshold"
}

variable "alarm_in_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold when scaling the Worker Nodes in"
  default     = 1
}

variable "alarm_in_metric_name" {
  description = "The name for the alarm's associated metric when scaling the Worker Nodes in"
  default     = "CPUUtilization"
}

variable "alarm_in_period" {
  description = "The period in seconds over which the specified statistic is applied when scaling the Worker Nodes in"
  default     = 60
}

variable "alarm_in_statistic" {
  description = "The statistic to apply to the alarm's associated metric when scaling the Worker Nodes in"
  default     = "Average"
}

variable "alarm_in_threshold" {
  description = "The value against which the specified statistic is compared when scaling the Worker Nodes in"
}

variable "alarm_in_dimensions" {
  description = "The dimensions for the alarm's associated metric when scaling the Worker Nodes in"
  type        = "map"
  default     = {}
}
