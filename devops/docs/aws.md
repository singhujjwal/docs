# Services
## Compute
EC2 is the compute service on AWS
## Storage
### SOFTNAS usage on AWS

Role is very important and the policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "aws-marketplace:MeterUsage",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeInstances",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:DescribeRouteTables",
                "ec2:DescribeAddresses",
                "ec2:DescribeTags",
                "ec2:DescribeInstances",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:ReplaceRoute",
                "ec2:CreateRoute",
                "ec2:DeleteRoute",
                "ec2:AssociateAddress",
                "ec2:DisassociateAddress",
                "s3:CreateBucket",
                "s3:Delete*",
                "s3:Get*",
                "s3:List*",
                "s3:Put*"
            ],
            "Resource": "*"
        }
    ]
}
```