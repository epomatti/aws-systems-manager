terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  ignore_tags {
    key_prefixes = [
      "QSConfigName-",
      "QSConfigId-",
    ]
  }
}

locals {
  workload   = "ssm"
  public_key = file("./keys/temp_key.pub")
}

### Shared ###
module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
  workload   = local.workload
}

module "iam" {
  source   = "./modules/iam"
  workload = local.workload
}

resource "aws_key_pair" "default" {
  key_name   = "ssm-key"
  public_key = local.public_key
}

module "sg" {
  source   = "./modules/sg"
  workload = local.workload
  vpc_id   = module.vpc.vpc_id
}

### Instances ###
module "ubuntu_default" {
  source                  = "./modules/ec2"
  workload                = local.workload
  iam_instance_profile_id = module.iam.instance_profile_id
  key_name                = aws_key_pair.default.key_name
  instance_type           = var.linux_instance_type
  ami                     = var.linux_ami
  security_group_id       = module.sg.sg_id
  subnet_id               = module.vpc.subnet_id
  user_data_file          = "ubuntu-default.sh"
  instance_label          = "ubuntu-default"
  environment_tag         = "Development"
  platform_tag            = "Linux"
}

module "windows_default" {
  source                  = "./modules/ec2"
  workload                = local.workload
  iam_instance_profile_id = module.iam.instance_profile_id
  key_name                = aws_key_pair.default.key_name
  instance_type           = var.windows_instance_type
  ami                     = var.windows_ami
  security_group_id       = module.sg.sg_id
  subnet_id               = module.vpc.subnet_id
  user_data_file          = "windows-default.txt"
  instance_label          = "windows-default"
  environment_tag         = "Development"
  platform_tag            = "Windows"
}

# ASG
module "asg" {
  count         = var.create_asg == true ? 1 : 0
  source        = "./modules/asg"
  workload      = local.workload
  instance_type = var.linux_instance_type
  ami           = var.linux_ami
  vpc_id        = module.vpc.vpc_id
  key_name      = aws_key_pair.default.key_name
  subnet_id     = module.vpc.subnet_id
}

# Maintenance Window
module "mw_linux" {
  source                  = "./modules/ec2"
  workload                = local.workload
  iam_instance_profile_id = module.iam.instance_profile_id
  key_name                = aws_key_pair.default.key_name
  instance_type           = var.linux_instance_type
  ami                     = var.linux_ami
  security_group_id       = module.sg.sg_id
  subnet_id               = module.vpc.subnet_id
  user_data_file          = "ubuntu-default.sh"
  instance_label          = "linux-maintenance-window"
  environment_tag         = "MaintenanceWindow"
  platform_tag            = "Linux"
}

module "maintenance_window" {
  source              = "./modules/maintenance-window"
  schedule_cron       = var.ssm_maintenance_window_schedule_cron
  schedule_timezone   = var.ssm_maintenance_window_schedule_timezone
  instance_id_targets = [module.mw_linux.instance_id]
}
