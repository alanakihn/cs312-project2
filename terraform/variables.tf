// terraform/variables.tf
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the existing SSH AWS key pair"
  type        = string
}
