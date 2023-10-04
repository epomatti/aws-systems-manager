terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  workload = "ssmdemo"
}

module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
  workload   = local.workload
}

module "iam" {
  source   = "./modules/iam"
  workload = local.workload
}

module "sg" {
  source   = "./modules/sg"
  workload = local.workload
  vpc_id   = module.vpc.vpc_id
}

module "ubuntu" {
  source                  = "./modules/ec2"
  workload                = local.workload
  iam_instance_profile_id = module.iam.instance_profile_id
  instance_type           = var.linux_instance_type
  ami                     = var.linux_ami
  security_group_id       = module.sg.sg_id
  subnet_id               = module.vpc.subnet_id
  user_data_file          = "ubuntu-default.sh"
  instance_label          = "ubuntu-default"
}
