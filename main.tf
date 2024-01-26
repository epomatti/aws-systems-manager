terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  ignore_tags {
    # Ignores dynamic tags added by the Patch Policy
    key_prefixes = [
      "QSConfigName-"
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

  ssm_patchmanager_quicksetup_config_id = var.ssm_patchmanager_quicksetup_config_id
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

module "ssm" {
  source = "./modules/ssm"
}

### Instances ###
module "ubuntu_default" {
  count                   = var.create_default_ubuntu_instances == true ? 1 : 0
  source                  = "./modules/ec2"
  workload                = local.workload
  iam_instance_profile_id = module.iam.instance_profile_id
  key_name                = aws_key_pair.default.key_name
  instance_type           = var.ubuntu_instance_type
  ami                     = var.ubuntu_ami
  security_group_id       = module.sg.sg_id
  subnet_id               = module.vpc.subnet_id
  user_data_file          = "ubuntu.sh"
  instance_label          = "ubuntu-default"
  environment_tag         = "Development"
  platform_tag            = "Linux"

  depends_on = [module.ssm]
}

module "debian_default" {
  count                   = var.create_default_debian_instances == true ? 1 : 0
  source                  = "./modules/ec2"
  workload                = local.workload
  iam_instance_profile_id = module.iam.instance_profile_id
  key_name                = aws_key_pair.default.key_name
  instance_type           = var.debian_instance_type
  ami                     = var.debian_ami
  security_group_id       = module.sg.sg_id
  subnet_id               = module.vpc.subnet_id
  user_data_file          = "debian.sh"
  instance_label          = "debian"
  environment_tag         = "Development"
  platform_tag            = "Linux"

  depends_on = [module.ssm]
}

module "windows_default" {
  count                   = var.create_default_windows_instances == true ? 1 : 0
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

  depends_on = [module.ssm]
}

### ASG ###
module "asg" {
  count         = var.create_asg == true ? 1 : 0
  source        = "./modules/asg"
  workload      = local.workload
  instance_type = var.ubuntu_instance_type
  ami           = var.ubuntu_ami
  vpc_id        = module.vpc.vpc_id
  key_name      = aws_key_pair.default.key_name
  subnet_id     = module.vpc.subnet_id
}

### Maintenance Window ###
locals {
  ssm_wm_create = var.create_ssm_maintenance_window_resources == true ? 1 : 0
}

module "mw_linux" {
  count                   = local.ssm_wm_create
  source                  = "./modules/ec2"
  workload                = local.workload
  iam_instance_profile_id = module.iam.instance_profile_id
  key_name                = aws_key_pair.default.key_name
  instance_type           = var.ssm_maintenance_windows_instance_type
  ami                     = var.ubuntu_ami
  security_group_id       = module.sg.sg_id
  subnet_id               = module.vpc.subnet_id
  user_data_file          = "ubuntu-default.sh"
  instance_label          = "linux-maint-wind"
  environment_tag         = "MaintenanceWindow"
  platform_tag            = "Linux"
}

module "maintenance_window" {
  count               = local.ssm_wm_create
  source              = "./modules/maintenance-window"
  schedule_cron       = var.ssm_maintenance_window_schedule_cron
  schedule_timezone   = var.ssm_maintenance_window_schedule_timezone
  instance_id_targets = [module.mw_linux[0].instance_id]

  ssm_maintenance_window_schedule_run_command_operation = var.ssm_maintenance_window_schedule_run_command_operation
}
