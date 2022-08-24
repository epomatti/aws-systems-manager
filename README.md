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