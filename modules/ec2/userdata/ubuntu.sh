#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Skipping upgrade on purpose for Patch Manager testing
apt update

# General
region=us-east-2
platform="arm64"

# CloudWatch Agent
wget https://amazoncloudwatch-agent-$region.s3.$region.amazonaws.com/ubuntu/$platform/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# IAM requires permission for this
ssmParameterName=AmazonCloudWatch-linux-for-PatchManager
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:$ssmParameterName -s
