variable "aws_region" {
  type = string
}

# Ubuntu
variable "ubuntu_instance_type" {
  type = string
}

variable "ubuntu_ami" {
  type = string
}

variable "create_default_ubuntu_instances" {
  type    = bool
  default = true
}

# Debian
variable "debian_instance_type" {
  type = string
}

variable "debian_ami" {
  type = string
}

variable "create_default_debian_instances" {
  type    = bool
  default = true
}

# Windows

variable "create_default_windows_instances" {
  type    = bool
  default = true
}

variable "windows_instance_type" {
  type = string
}

variable "windows_ami" {
  type = string
}

### ASG ###

variable "create_asg" {
  type = bool
}


### Maintenance Window ###
variable "create_ssm_maintenance_window_resources" {
  type    = bool
  default = true
}

variable "ssm_maintenance_window_schedule_cron" {
  type    = string
  default = "cron(30 22 ? * * *)"
}

variable "ssm_maintenance_window_schedule_timezone" {
  type    = string
  default = "America/Sao_Paulo"
}

variable "ssm_maintenance_window_schedule_run_command_operation" {
  type    = string
  default = "Scan"
}

variable "ssm_maintenance_windows_instance_type" {
  type = string
}

variable "ssm_patchmanager_quicksetup_config_id" {
  type        = string
  description = "This needs to be added to the instance profile or role as a tag"
}
