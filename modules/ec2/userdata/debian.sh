#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Skipping upgrade on purpose for Patch Manager testing
apt update

# General
region=us-east-2
platform="arm64"

### SSM Agent ###
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.$region.amazonaws.com/amazon-ssm-$region/latest/debian_$platform/amazon-ssm-agent.deb
dpkg -i amazon-ssm-agent.deb
systemctl status amazon-ssm-agent


### CloudWatch Agent ###
# TODO: Waiting for Debian S3 support
# https://github.com/aws/amazon-cloudwatch-agent/issues/722
wget https://amazoncloudwatch-agent-$region.s3.$region.amazonaws.com/ubuntu/$platform/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

ssmParameterName=AmazonCloudWatch-linux-for-PatchManager
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:$ssmParameterName -s
