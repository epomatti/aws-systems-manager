# AWS Systems Manager

Some of the most important Systems Manager components:

- **Automation**
- **Run Command**
- **Inventory**
- **Compliance**
- **Patch Manager**
- **Session Manager**
- **Parameter Store**

EC2 instances will require the Systems Manager agent. Use an image that has it or install it.

<img src=".assets/ssm.png" width=500 />


## Instances setup

Generate a temporary key pair:

```sh
mkdir ./keys && ssh-keygen -f ./keys/aws_id_rsa
```

Create the IAM and EC2 essential objects:

```sh
bash aws-init.sh
```

Create the instances:

```sh
# Linux Development
aws ec2 run-instances --image-id 'ami-08fdd91d87f63bb09' --count 1 --instance-type 't4g.nano' --key-name 'ssm-keypair-sandbox' --iam-instance-profile 'Name=EC2SSMRoleInstanceProfile' --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DevLinux}, {Key=Environment,Value=Development}]'

# Linux Production
aws ec2 run-instances --image-id 'ami-08fdd91d87f63bb09' --count 1 --instance-type 't4g.nano' --key-name 'ssm-keypair-sandbox' --iam-instance-profile 'Name=EC2SSMRoleInstanceProfile' --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ProdLinux}, {Key=Environment,Value=Production}]'

# Windows Development
aws ec2 run-instances --image-id 'ami-02bddcf6b9473bd61' --count 1 --instance-type 't2.micro' --key-name 'ssm-keypair-sandbox' --iam-instance-profile 'Name=EC2SSMRoleInstanceProfile'  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DevWindows}, {Key=Environment,Value=Development}]'

# Windows Production
aws ec2 run-instances --image-id 'ami-02bddcf6b9473bd61' --count 1 --instance-type 't2.micro' --key-name 'ssm-keypair-sandbox' --iam-instance-profile 'Name=EC2SSMRoleInstanceProfile'  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ProdWindows}, {Key=Environment,Value=Production}]'
```

To check everything is ok go to Systems Manager and check the Fleet Manager blade.

## Automation

Example running an automation from an existing document using the Console:

1. In the Systems Manager service, go to the "Shared Resources" > "Documents" blade
2. Search for `AWS-StopEC2Instance`
3. Click in "Execute the automation" and proceed with the execution

## Run Command

### Windows Updates

List Windows updates:

1. Search for `AWS-FindWindowsUpdates`
2. Run command
3. Update level: All
4. Tags: Environment=Production

Apply Windows updates:

1. Search for `AWS-InstallMissingWindowsUpdates`
2. Run command
3. Update level: All
4. Tags: Environment=Production

### Update Linux SSH authorized keys

Use RunCommand to modify the `authorized_keys` file.

Test your local connection to an instance:

```sh
ssh -i ./keys/aws_id_rsa ubuntu@<publid-ip>
```

Create a **new pair** of keys:

```sh
mkdir -p ./keys/new && ssh-keygen -f ./keys/new/aws_id_rsa
```

As a test, check that running `AWS-RunShellScript` document works:

```sh
aws ssm send-command \
    --targets "Key=tag:Name,Values=DevLinux" \
    --document-name "AWS-RunShellScript" \
    --comment "Changing the key pair" \
    --parameters "commands='cp /home/ubuntu/.ssh/authorized_keys /tmp/copy_of_authorized_keys'" \
    --output text
```

Now proceed with method of choice for adding or replacing the actual key.

## Patch Manager

Inventory is important for this.

With a scheduling:

1. Go to Configure Patching
2. Select instance tags
3. Select the patching schedule, with a maintenance window
4. Select between Scan Only, or Scan and Install

## Configuration Compliance

To simulate a compliance issue, execute this command to require a custom software that will not be installed in your instance:

```sh
aws ssm put-compliance-items --resource-id i-08f2c5c184b18ee15 --resource-type ManagedInstance --compliance-type Custom:CorporateSoftware --execution-summary ExecutionTime=1597815633 --items Id=Version-2.0,Title=CorporateSoftware,Severity=CRITICAL,Status=NON_COMPLIANT --region us-east-2
```

Now your instance should be identified as non-compliant.

---

### Clean Up

Terminate the EC2 instances.

Run the following script to clean the other objects:

```sh
bash aws-destroy.sh
```
