variable "aws_region" {
  type = string
}

variable "linux_instance_type" {
  type = string
}

variable "linux_ami" {
  type = string
}

variable "windows_instance_type" {
  type = string
}

variable "windows_ami" {
  type = string
}

variable "create_asg" {
  type = bool
}

variable "ssm_maintenance_window_schedule_cron" {
  type    = string
  default = "cron(30 22 ? * * *)"
}

variable "ssm_maintenance_window_schedule_timezone" {
  type    = string
  default = "America/Sao_Paulo"
}
