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

# IAM requires permission for this
ssmParameterName=AmazonCloudWatch-linux-for-PatchManager
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:$ssmParameterName -s


### Nat Instance ###
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

apt install -y iptables-persistent
iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
iptables-save  > /etc/iptables/rules.v4


reboot
