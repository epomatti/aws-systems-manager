#!/bin/bash

aws ec2 delete-key-pair --key-name 'ssm-keypair-sandbox'
aws iam remove-role-from-instance-profile --role-name 'EC2SSMRole' --instance-profile-name 'EC2SSMRoleInstanceProfile'
aws iam delete-instance-profile --instance-profile-name 'EC2SSMRoleInstanceProfile'
aws iam detach-role-policy --policy-arn 'arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore' --role-name 'EC2SSMRole'
aws iam delete-role --role-name 'EC2SSMRole'
