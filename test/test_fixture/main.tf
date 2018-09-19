provider "aws" {
  region = "${var.region}"
}

module "eks" {
  source               = "../../"
  eks_name             = "test-kitchen"
  vpc_cidr_block       = "10.0.0.0/16"
  vpc_instance_tenancy = "default"

  workers_ami_id        = "ami-0440e4f6b9713faf6"
  workers_instance_type = "t2.small"
  alarm_out_threshold   = 50
  alarm_in_threshold    = 30

  eks_sg_tags = {
    test        = "this-is-a-test-tag"
    Description = "Managed by Terraform"
  }

  vpc_tags = {
    vpc-tag = "thisIsAVPCTag"
  }
}
