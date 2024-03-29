resource "aws_iam_instance_profile" "default" {
  name = "${var.workload}-intance-profile"
  role = aws_iam_role.default.id
}

resource "aws_iam_role" "default" {
  name = "${var.workload}-ec2role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    "QSConfigId-${var.ssm_patchmanager_quicksetup_config_id}" = "${var.ssm_patchmanager_quicksetup_config_id}"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Required to install the SSM agent - SSM
resource "aws_iam_role_policy_attachment" "AmazonSSMReadOnlyAccess" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# Required to install the SSM agent - Server policy
resource "aws_iam_role_policy_attachment" "cloudwatc-agent-server-policy" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


resource "aws_iam_role_policy" "aws_quicksetup_patchpolicy" {
  name = "quicksetup-patchpolicy-baselineoverrides-s3"
  role = aws_iam_role.default.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::aws-quicksetup-patchpolicy-*"
      }
    ]
  })
}

