# AWS EKS Cluster and Worker Nodes Terraform Module

Terraform module which creates an EKS cluster and an Autoscaling Group running the Kubernetes Worker Nodes.

These types of resources are supported:

* [EKS Cluster](https://www.terraform.io/docs/providers/aws/r/eks_cluster.html)
* [Autoscaling Group](https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html)
* [Launch Configuration](https://www.terraform.io/docs/providers/aws/r/launch_configuration.html)
* [Autoscaling Policy](https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html)
* [Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* [Security Group Rule](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html)
* [Policy Attachment](https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html)
* [Instance Profile](https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html)
* [IAM Role](https://www.terraform.io/docs/providers/aws/r/iam_role.html)
* [Cloudwatch Alarm](https://www.terraform.io/docs/providers/aws/r/cloudwatch_alarm.html)

## Usage

```hcl
module "eks" {
  source               = "github.com/darkraiden/terraform-aws-eks"
  eks_name             = "prod-eks"
  vpc_cidr_block       = "10.0.0.0/16"
  vpc_instance_tenancy = "default"

  workers_ami_id        = "ami-dea4d5a1"
  workers_instance_type = "t2.small"
  alarm_out_threshold   = 50
  alarm_in_threshold    = 30

  eks_tags = {
    test        = "this-is-a-test-tag"
    Description = "Managed by Terraform"
  }

  vpc_tags = {
    vpc-tag = "thisIsAVPCTag"
  }
}
```

## Inputs

| Name                                  | Description                                                                                                                                                                                                        | Type   | Default                                                                                                                                                                                           | Required |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :----: | :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :------: |
| alarm_in_comparison_operator          | The arithmetic operation to use when comparing the specified Statistic and Threshold when scaling the Worker Nodes in                                                                                              | string | `GreaterThanOrEqualToThreshold`                                                                                                                                                                   | no       |
| alarm_in_dimensions                   | The dimensions for the alarm's associated metric when scaling the Worker Nodes in                                                                                                                                  | map    | `<map>`                                                                                                                                                                                           | no       |
| alarm_in_evaluation_periods           | The number of periods over which data is compared to the specified threshold when scaling the Worker Nodes in                                                                                                      | string | `1`                                                                                                                                                                                               | no       |
| alarm_in_metric_name                  | The name for the alarm's associated metric when scaling the Worker Nodes in                                                                                                                                        | string | `CPUUtilization`                                                                                                                                                                                  | no       |
| alarm_in_period                       | The period in seconds over which the specified statistic is applied when scaling the Worker Nodes in                                                                                                               | string | `60`                                                                                                                                                                                              | no       |
| alarm_in_statistic                    | The statistic to apply to the alarm's associated metric when scaling the Worker Nodes in                                                                                                                           | string | `Average`                                                                                                                                                                                         | no       |
| alarm_in_threshold                    | The value against which the specified statistic is compared when scaling the Worker Nodes in                                                                                                                       | string | -                                                                                                                                                                                                 | yes      |
| alarm_out_comparison_operator         | The arithmetic operation to use when comparing the specified Statistic and Threshold when scaling the Worker Nodes out                                                                                             | string | `GreaterThanOrEqualToThreshold`                                                                                                                                                                   | no       |
| alarm_out_dimensions                  | The dimensions for the alarm's associated metric when scaling the Worker Nodes out                                                                                                                                 | map    | `<map>`                                                                                                                                                                                           | no       |
| alarm_out_evaluation_periods          | The number of periods over which data is compared to the specified threshold when scaling the Worker Nodes out                                                                                                     | string | `1`                                                                                                                                                                                               | no       |
| alarm_out_metric_name                 | The name for the alarm's associated metric when scaling the Worker Nodes out                                                                                                                                       | string | `CPUUtilization`                                                                                                                                                                                  | no       |
| alarm_out_period                      | The period in seconds over which the specified statistic is applied when scaling the Worker Nodes out                                                                                                              | string | `60`                                                                                                                                                                                              | no       |
| alarm_out_statistic                   | The statistic to apply to the alarm's associated metric when scaling the Worker Nodes out                                                                                                                          | string | `Average`                                                                                                                                                                                         | no       |
| alarm_out_threshold                   | The value against which the specified statistic is compared when scaling the Worker Nodes out                                                                                                                      | string | -                                                                                                                                                                                                 | yes      |
| eks_assume_role_policy                |                                                                                                                                                                                                                    | string | `{   "Version": "2012-10-17",   "Statement": [     {       "Effect": "Allow",       "Principal": {         "Service": "eks.amazonaws.com"       },       "Action": "sts:AssumeRole"     }   ] } ` | no       |
| eks_extra_policies                    | A list of Extra Policies to attach to the EKS role                                                                                                                                                                 | string | `<list>`                                                                                                                                                                                          | no       |
| eks_iam_role_description              | A description of the EKS role                                                                                                                                                                                      | string | `IAM Role for EKS Clusters`                                                                                                                                                                       | no       |
| eks_name                              |                                                                                                                                                                                                                    | string | ``                                                                                                                                                                                                | no       |
| eks_policies                          |                                                                                                                                                                                                                    | string | `<list>`                                                                                                                                                                                          | no       |
| eks_role_detach_policies              | Specifies to force detaching any policies the role has before destroying.                                                                                                                                          | string | `false`                                                                                                                                                                                           | no       |
| eks_sg_description                    |                                                                                                                                                                                                                    | string | `Managed by terraform`                                                                                                                                                                            | no       |
| eks_sg_egress                         |                                                                                                                                                                                                                    | string | `<list>`                                                                                                                                                                                          | no       |
| eks_sg_https_ingress_cidr_blocks      |                                                                                                                                                                                                                    | string | `<list>`                                                                                                                                                                                          | no       |
| eks_sg_https_ingress_description      |                                                                                                                                                                                                                    | string | `Managed by terraform`                                                                                                                                                                            | no       |
| eks_tags                              | A map of tags to add to all resources                                                                                                                                                                              | string | `<map>`                                                                                                                                                                                           | no       |
| kubernetes_version                    | The Kubernetes version used by EKS                                                                                                                                                                                 | string | ``                                                                                                                                                                                                | no       |
| private_subnets_count                 |                                                                                                                                                                                                                    | string | `3`                                                                                                                                                                                               | no       |
| public_subnets_count                  |                                                                                                                                                                                                                    | string | `3`                                                                                                                                                                                               | no       |
| vpc_cidr_block                        | The CIDR block for the VPC                                                                                                                                                                                         | string | -                                                                                                                                                                                                 | yes      |
| vpc_instance_tenancy                  | The instance tenancy mode for the VPC - 'default' or 'dedicated' accepted only                                                                                                                                     | string | -                                                                                                                                                                                                 | yes      |
| vpc_tags                              | Additional tags for the VPC                                                                                                                                                                                        | string | `<map>`                                                                                                                                                                                           | no       |
| workers_ami_id                        | The Worker Nodes AMI ID                                                                                                                                                                                            | string | -                                                                                                                                                                                                 | yes      |
| workers_asg_desired_capacity          | The number of EC2 instances that should be running in the group.                                                                                                                                                   | string | `2`                                                                                                                                                                                               | no       |
| workers_asg_force_delete              | Allows deleting the autoscaling group without waiting for all instances in the pool to terminate.                                                                                                                  | string | `false`                                                                                                                                                                                           | no       |
| workers_asg_health_check_grace_period | Time (in seconds) after instance comes into service before checking health                                                                                                                                         | string | `300`                                                                                                                                                                                             | no       |
| workers_asg_health_check_type         | 'EC2' or 'ELB'. Controls how health checking is done.                                                                                                                                                              | string | `EC2`                                                                                                                                                                                             | no       |
| workers_asg_max_size                  |                                                                                                                                                                                                                    | string | `3`                                                                                                                                                                                               | no       |
| workers_asg_min_size                  |                                                                                                                                                                                                                    | string | `1`                                                                                                                                                                                               | no       |
| workers_asg_subnet_ids                | A list of VPC subnet IDs                                                                                                                                                                                           | list   | -                                                                                                                                                                                                 | yes      |
| workers_asg_tags                      | A list of extra tags                                                                                                                                                                                               | list   | `<list>`                                                                                                                                                                                          | no       |
| workers_asg_termination_policies      | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | list   | `<list>`                                                                                                                                                                                          | no       |
| workers_assume_role_policy            |                                                                                                                                                                                                                    | string | `{   "Version": "2012-10-17",   "Statement": [     {       "Effect": "Allow",       "Principal": {         "Service": "ec2.amazonaws.com"       },       "Action": "sts:AssumeRole"     }   ] } ` | no       |
| workers_custom_user_data              | A custom user data script to be attached to the Worker Nodes Launch Configuration                                                                                                                                  | string | ``                                                                                                                                                                                                | no       |
| workers_extra_policies                | A list of Extra Policies to attach to the EKS role                                                                                                                                                                 | string | `<list>`                                                                                                                                                                                          | no       |
| workers_iam_role_description          | A description of the Worker Nodes role                                                                                                                                                                             | string | `IAM Role for Worker Nodes Clusters`                                                                                                                                                              | no       |
| workers_in_adjustment_type            | Specifies whether the adjustment is an absolute number or a percentage of the current capacity                                                                                                                     | string | `ChangeInCapacity`                                                                                                                                                                                | no       |
| workers_in_cooldown                   | The amout of time, in seconds, after a scaling activity completes and before the next scaling activity can start                                                                                                   | string | `300`                                                                                                                                                                                             | no       |
| workers_in_policy_type                | The Worker Nodes In policy type, either 'SimpleScaling', 'StepScaling' or 'TargetTrackingScaling'                                                                                                                  | string | `SimpleScaling`                                                                                                                                                                                   | no       |
| workers_in_scaling_adjustment         | The number of in stance by which to scale the Worker Nodes in                                                                                                                                                      | string | `-1`                                                                                                                                                                                              | no       |
| workers_ingress_ssh_cidr_blocks       | List of CIDR blocks that will be able to SSH to the worker nodes                                                                                                                                                   | string | `<list>`                                                                                                                                                                                          | no       |
| workers_ingress_ssh_source_sg_ids     | List of security group IDs that will be able to SSH to the worker nodes                                                                                                                                            | string | `<list>`                                                                                                                                                                                          | no       |
| workers_instance_type                 | The EC2 instance type                                                                                                                                                                                              | string | -                                                                                                                                                                                                 | yes      |
| workers_key_name                      | The key name that should be used for the instance                                                                                                                                                                  | string | ``                                                                                                                                                                                                | no       |
| workers_out_adjustment_type           | Specifies whether the adjustment is an absolute number or a percentage of the current capacity                                                                                                                     | string | `ChangeInCapacity`                                                                                                                                                                                | no       |
| workers_out_cooldown                  | The amout of time, in seconds, after a scaling activity completes and before the next scaling activity can start                                                                                                   | string | `300`                                                                                                                                                                                             | no       |
| workers_out_policy_type               | The Worker Nodes Out policy type, either 'SimpleScaling', 'StepScaling' or 'TargetTrackingScaling'                                                                                                                 | string | `SimpleScaling`                                                                                                                                                                                   | no       |
| workers_out_scaling_adjustment        | The number of in stance by which to scale the Worker Nodes out                                                                                                                                                     | string | `1`                                                                                                                                                                                               | no       |
| workers_policies                      |                                                                                                                                                                                                                    | string | `<list>`                                                                                                                                                                                          | no       |
| workers_role_detach_policies          | Specifies to force detaching any policies the role has before destroying.                                                                                                                                          | string | `false`                                                                                                                                                                                           | no       |
| workers_root_delete_on_termination    | Whether the volume should be destroyed on instance termination                                                                                                                                                     | string | `true`                                                                                                                                                                                            | no       |
| workers_root_iops                     | The amout of provisioned IOPS. This must be set with a root_volume_type of "io1"                                                                                                                                   | string | `0`                                                                                                                                                                                               | no       |
| workers_root_volume_size              | The size of the volume in gigabytes                                                                                                                                                                                | string | `20`                                                                                                                                                                                              | no       |
| workers_root_volume_type              | The type of volume. Can be "standard", "gp2", or "io1"                                                                                                                                                             | string | `gp2`                                                                                                                                                                                             | no       |
| workers_sg_description                |                                                                                                                                                                                                                    | string | `Managed by terraform`                                                                                                                                                                            | no       |
| workers_sg_egress                     |                                                                                                                                                                                                                    | string | `<list>`                                                                                                                                                                                          | no       |
| workers_sg_https_ingress_cidr_blocks  |                                                                                                                                                                                                                    | string | `<list>`                                                                                                                                                                                          | no       |
| workers_sg_https_ingress_description  |                                                                                                                                                                                                                    | string | `Managed by terraform`                                                                                                                                                                            | no       |

## Outputs

| Name                              | Description                                                         |
| --------------------------------- | ------------------------------------------------------------------- |
| eks_cluster_certificate_authority | The EKS cluster Certificate Authority for the client authentication |
| eks_cluster_endpoint              | The EKS cluster endpoint                                            |
| eks_cluster_iam_role_arn          | The EKS cluster IAM Role ARN                                        |
| eks_cluster_iam_role_name         | The EKS cluster IAM Role Name                                       |
| eks_cluster_name                  | The EKS Cluster name                                                |
| kubeconfig                        | The kubernetes config                                               |
| private_subnets                   |                                                                     |
| public_subnets                    |                                                                     |
| vpc_id                            | VPC outputs produced at the end of a terraform apply                |
| workers_config_map_aws_auth       | The AWS Auth config map                                             |

## Configure Kubernetes

The module comes with some outputs that will help you set up your Kubernetes stack. We're after the following outputs:

* kubeconfig
* workers_config_map_aws_auth

Create a reference to the module's outputs by creating an `outputs.tf` file with the following snippet:

```hcl
output "workers_config_map_aws_auth" {
  value = "${module.<modulename>.workers_config_map_aws_auth}"
}

output "kubeconfig" {
  value = "${module.<modulename>.kubeconfig}"
}
```

Once terraform applies the resources to AWS, run the following command:

```bash
$ terraform output
```

Copy the `kubeconfig` output to a file in a your `~/.kube` folder - you can test the connectivity to the Kubernetes cluster by typing:

```bash
$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   10d
```

Copy the `workers_config_map_aws_auth` output to a file called `aws_workers_config_map.yaml` and create the configmap by typing the following command:

```bash
$ kubectl apply -f aws_workers_config_map.yaml
```

## Tests

This module has been packaged with awspec tests through test kitchen. To run them:

1. Install rvm and the ruby version specified in the Gemfile
2. Install bundler and the gems from our Gemfile:

```bash
$ sudo gem install bundler; bundle install --path vendor/bundle
```

3. Test using `bundle exec kitchen test` from the root of the project.

## To Do's

- [ ] Add Unit Tests

## Author

Module is maintained by [Davide Di Mauro](https://github.com/darkraiden).

## License

Apache 2 Licensed.
