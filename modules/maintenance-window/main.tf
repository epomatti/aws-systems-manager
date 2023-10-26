resource "aws_ssm_maintenance_window" "default" {
  name                       = "TerraformWindow"
  description                = "Maintenance scheduled by Terraform"
  schedule                   = var.schedule_cron
  duration                   = 3
  cutoff                     = 1
  schedule_timezone          = var.schedule_timezone
  allow_unassociated_targets = false
}

resource "aws_ssm_maintenance_window_target" "linux" {
  window_id         = aws_ssm_maintenance_window.default.id
  name              = "LinuxTargets"
  description       = "Updates Linux instances"
  resource_type     = "INSTANCE"
  owner_information = "Terraform"

  targets {
    key    = "tag:Environment"
    values = ["MaintenanceWindow"]
  }
}

resource "aws_ssm_maintenance_window_task" "aws_run_patch_baseline" {
  name            = "AWS-RunPatchBaseline"
  description     = "Run command to apply patch baseline"
  max_concurrency = 2
  max_errors      = 1
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.default.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.linux.id]
  }

  task_invocation_parameters {

    # https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-aws-runpatchbaseline.html
    run_command_parameters {
      document_version = "$LATEST"
      service_role_arn = aws_iam_role.default.arn
      timeout_seconds  = 600

      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }

      # Scan / Install
      parameter {
        name   = "Operation"
        values = [var.ssm_maintenance_window_schedule_run_command_operation]
      }
    }
  }

  depends_on = [aws_iam_role.default]
}


# Execution Role
resource "aws_iam_role" "default" {
  name = "terraform-maintenance-window-ec2role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy" "default" {
  name = "terraform-maintenance-window-policy"
  role = aws_iam_role.default.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:SendCommand",
          "ssm:CancelCommand",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:GetCommandInvocation",
          "ssm:GetAutomationExecution",
          "ssm:StartAutomationExecution",
          "ssm:ListTagsForResource",
          "ssm:GetParameters"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "states:DescribeExecution",
          "states:StartExecution"
        ],
        "Resource" : [
          "arn:aws:states:*:*:execution:*:*",
          "arn:aws:states:*:*:stateMachine:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : [
          "arn:aws:lambda:*:*:function:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "resource-groups:ListGroups",
          "resource-groups:ListGroupResources"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "tag:GetResources"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "ssm.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}
