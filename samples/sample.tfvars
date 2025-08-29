# Project
aws_region = "us-east-2"


### Default instances ###
ssm_patchmanager_quicksetup_config_id = "<changeit>"

create_default_ubuntu_instances = true
ubuntu_ami                      = "ami-03d9fcc39480315d4" # Canonical, Ubuntu, 24.04, arm64 noble image
ubuntu_instance_type            = "t4g.micro"

create_default_debian_instances = false
debian_ami                      = "ami-0c758b376a9cf7862" # Debian 12 (20231013-1532)
debian_instance_type            = "t4g.nano"

create_default_windows_instances = false
windows_ami                      = "ami-060b1c20c93e475fd" # Microsoft Windows Server 2022 Full Locale English AMI provided by Amazon
windows_instance_type            = "t3.small"

### ASG ###
create_asg = false

### Maintenance Window ###
create_ssm_maintenance_window_resources  = false
ssm_maintenance_window_schedule_cron     = "cron(37 22 ? * * *)"
ssm_maintenance_window_schedule_timezone = "America/Sao_Paulo"

ssm_maintenance_windows_instance_type = "t4g.micro"

# Scan / Install
ssm_maintenance_window_schedule_run_command_operation = "Scan"
