# AWS Systems Manager

<img src=".assets/icons/ssm.png" width=48 /> <img src=".assets/icons/ssm-automation.png" width=48 /> <img src=".assets/icons/ssm-runcommand.png" width=48 /> <img src=".assets/icons/ssm-inventory.png" width=48 /> <img src=".assets/icons/ssm-patchmanager.png" width=48 /> <img src=".assets/icons/ssm-compliance.png" width=30 />

Some of the most important Systems Manager components:

| SSM Feature     | Example scenarios |
|-----------------|---------|
| Automation      | Controlling the state (start, stop, restart) EC2 instances. |
| Run Command     | 1. Find and apply Windows updates. <br/> 2. Update SSH authorized keys on Linux machines.  |
| Inventory       | |
| Patch Manager   | |
| Compliance      | |
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

## <img src=".assets/icons/ssm-runcommand.png" width=30 /> Run Command

### Windows Updates

Use the document `AWS-FindWindowsUpdates` to find updates for Windows:

```sh
aws ssm send-command \
    --document-name "AWS-FindWindowsUpdates" \
    --parameters "UpdateLevel=All" \
    --targets Key=tag:Environment,Values=Development Key=tag:Platform,Values=Windows
```

Check the console for status and execution output.

You can now use the document `AWS-InstallMissingWindowsUpdates` to install the missing Windows updates:

```sh
aws ssm send-command \
    --document-name "AWS-InstallMissingWindowsUpdates" \
    --parameters "UpdateLevel=All" \
    --targets Key=tag:Environment,Values=Development Key=tag:Platform,Values=Windows
```

After applying the updates, you can check for missing updates one more time to confirm it all went well.

### Update Linux SSH authorized keys

Use RunCommand to execute a custom code and edit the `authorized_keys` file.

Test your local connection to an instance:

```sh
ssh -i ./keys/temp_key ubuntu@<publid-ip>
```

Create a **new pair** of keys:

```sh
ssh-keygen -f ./keys/new_temp_key
```

Using `AWS-RunShellScript`, backup the `authorized_keys` file:

```sh
aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --comment "Backup the key pair" \
    --targets Key=tag:Environment,Values=Development Key=tag:Platform,Values=Linux \
    --parameters "commands='cp /home/ubuntu/.ssh/authorized_keys /tmp/copy_of_authorized_keys'" \
    --output text
```

Now proceed with method of choice for adding or replacing the actual key.

Use a safe method in production. For this test you can do:

```sh
aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --comment "Backup the key pair" \
    --targets Key=tag:Environment,Values=Development Key=tag:Platform,Values=Linux \
    --parameters "commands='echo PUBLIC_KEY >> /home/ubuntu/.ssh/authorized_keys'" \
    --output text
```

## <img src=".assets/icons/ssm-inventory.png" width=30 /> Inventory

Create an inventory association, that is required for Patch Manager.

## <img src=".assets/icons/ssm-patchmanager.png" width=30 /> Patch Manager

Inventory is important for this.

With a scheduling:

1. Go to Configure Patching
2. Select instance tags
3. Select the patching schedule, with a maintenance window
4. Select between Scan Only, or Scan and Install

## <img src=".assets/icons/ssm-compliance.png" width=30 /> Compliance

To simulate a compliance issue, execute this command to require a custom software that will not be installed in your instance:

```sh
aws ssm put-compliance-items \
    --resource-id i-08f2c5c184b18ee15 \
    --resource-type ManagedInstance \
    --compliance-type Custom:CorporateSoftware \
    --execution-summary ExecutionTime=1597815633 \
    --items Id=Version-2.0,Title=CorporateSoftware,Severity=CRITICAL,Status=NON_COMPLIANT \
    --region us-east-2
```

Now your instance should be identified as non-compliant.

---

### Clean Up

Terminate the EC2 instances.

Run the following script to clean the other objects:

```sh
bash aws-destroy.sh
```
