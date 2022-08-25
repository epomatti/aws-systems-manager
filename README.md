# AWS Systems Manager

Some of the most important Systems Manager components:

- **Automation:** Database snapshots
- **Run Command:** EC2 commands, automation, packages
- **Inventory:** Information collected for inventory
- **Compliance:** Validates instances against compliance setup
- **Patch Manager:** Select and deploy patches on EC2 and on-premises
- **Session Manager:** Allows connectivity to EC2 instances without administrative ports
- **Parameter Store:** Parameters and variables administration

EC2 instances will require the Systems Manager agent.

Create the EC2 role:

```sh
aws iam create-role --role-name 'EC2SSMRole' --assume-role-policy-document 'file://trust-policy.json'
aws iam attach-role-policy --policy-arn 'arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore' --role-name 'EC2SSMRole'
```

Create instance profile & key pair:

```sh
# Instance Profile
aws iam create-instance-profile --instance-profile-name 'EC2SSMRoleInstanceProfile'
aws iam add-role-to-instance-profile --role-name 'EC2SSMRole' --instance-profile-name 'EC2SSMRoleInstanceProfile'

# Key Pair
aws ec2 import-key-pair --key-name 'ssm-keypair-sandbox' --public-key-material 'fileb://~/.ssh/id_rsa.pub'
```

Create the instances:

```sh
# Linux Development
aws ec2 run-instances --image-id 'ami-0568773882d492fc8' --count 1 --instance-type 't2.micro' --key-name 'ssm-keypair-sandbox' --iam-instance-profile 'Name=EC2SSMRoleInstanceProfile' --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DevLinux}, {Key=Environment,Value=Development}]'

# Linux Production
aws ec2 run-instances --image-id 'ami-0568773882d492fc8' --count 1 --instance-type 't2.micro' --key-name 'ssm-keypair-sandbox' --iam-instance-profile 'Name=EC2SSMRoleInstanceProfile' --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ProdLinux}, {Key=Environment,Value=Production}]'

# Windows Development
aws ec2 run-instances --image-id 'ami-02bddcf6b9473bd61' --count 1 --instance-type 't2.micro' --key-name 'ssm-keypair-sandbox' --iam-instance-profile 'Name=EC2SSMRoleInstanceProfile'  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DevWindows}, {Key=Environment,Value=Development}]'

# Windows Production
aws ec2 run-instances --image-id 'ami-02bddcf6b9473bd61' --count 1 --instance-type 't2.micro' --key-name 'ssm-keypair-sandbox' --iam-instance-profile 'Name=EC2SSMRoleInstanceProfile'  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ProdWindows}, {Key=Environment,Value=Production}]'
```


