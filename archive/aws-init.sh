#!/bin/bash

# EC2 Role
aws iam create-role --role-name 'EC2SSMRole' --assume-role-policy-document 'file://trust-policy.json'
aws iam attach-role-policy --policy-arn 'arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore' --role-name 'EC2SSMRole'

# Instance Profile
aws iam create-instance-profile --instance-profile-name 'EC2SSMRoleInstanceProfile'
aws iam add-role-to-instance-profile --role-name 'EC2SSMRole' --instance-profile-name 'EC2SSMRoleInstanceProfile'

# Import Key Pair
aws ec2 import-key-pair --key-name 'ssm-keypair-sandbox' --public-key-material 'fileb://./keys/aws_id_rsa.pub'
