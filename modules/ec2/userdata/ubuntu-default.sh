#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Skipping upgrade on purpose for Patch Manager testing
apt update

# CloudWatch Agent
platform="arm64"
region="us-east-2"
wget https://amazoncloudwatch-agent-$region.s3.$region.amazonaws.com/ubuntu/$platform/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

ssmParameterName=AmazonCloudWatch-linux
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:$ssmParameterName


reboot
