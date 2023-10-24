variable "schedule_cron" {
  type = string
}

variable "schedule_timezone" {
  type = string
}

variable "instance_id_targets" {
  type = list(string)
}

variable "ssm_maintenance_window_schedule_run_command_operation" {
  type = string
}
