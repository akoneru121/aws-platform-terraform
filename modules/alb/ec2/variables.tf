variable "name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "target_group_arn" {}
variable "alb_sg_id" {}
variable "ssh_cidr_blocks" { type = list(string) }
