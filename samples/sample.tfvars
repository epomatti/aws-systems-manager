aws_region = "us-east-2"


### Default instances ###
create_default_instances = false

# Canonical, Ubuntu, 22.04 LTS, arm64 jammy image build on 2023-05-16
linux_ami           = "ami-08fdd91d87f63bb09"
linux_instance_type = "t4g.micro"

# Microsoft Windows Server 2022 Full Locale English AMI provided by Amazon
windows_ami           = "ami-060b1c20c93e475fd"
windows_instance_type = "t3.small"


### ASG ###
create_asg = false


### Maintenance Window ###
create_ssm_maintenance_window_resources  = true
ssm_maintenance_window_schedule_cron     = "cron(45 0 ? * * *)"
ssm_maintenance_window_schedule_timezone = "America/Sao_Paulo"

ssm_maintenance_windows_instance_type = "t4g.micro"

# Scan / Install
ssm_maintenance_window_schedule_run_command_operation = "Scan"
