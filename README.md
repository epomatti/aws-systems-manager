# AWS Systems Manager

<img src=".assets/icons/ssm.png" width=48 />

Some of the most important Systems Manager components:

| SSM Feature     | Scenario |
|-----------------|---------|
| Automation      | |
| Run Command     | |
| Inventory       | |
| Compliance      | |
| Patch Manager   | |
| Session Manager | |
| Parameter Store | |

## <img src=".assets/icons/ec2.png" width=30 /> Instances setup

Start by copying the `.auto.tfvars` file template:

> 💡 The sample config AMIs already include the SSM Agent

```sh
cp samples/sample.tfvars .auto.tfvars
```

Generate a temporary key pair:

```sh
mkdir keys
ssh-keygen -f keys/temp_key
```

Create the sandbox infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

Enter the Systems Manager console and check the Fleet Manager blade.

If you prefer using Session Manager with the CLI:

```sh
aws ssm start-session \
    --target instance-id
```

## <img src=".assets/icons/ssm-automation.png" width=30 /> Automation

### Starting & stopping instances

To stop an instance using Automation, use a shared Document:

> ℹ️ Replace the value for "InstanceId"

```sh
aws ssm start-automation-execution \
    --document-name "AWS-StopEC2Instance" \
    --parameters "InstanceId=i-00000000000000000"
```

To start the instance again:

```sh
aws ssm start-automation-execution \
    --document-name "AWS-StartEC2Instance" \
    --parameters "InstanceId=i-00000000000000000"
```

Restart is also an option:

```sh
aws ssm start-automation-execution \
    --document-name "AWS-RestartEC2Instance" \
    --parameters "InstanceId=i-00000000000000000"
```

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
