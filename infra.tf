locals {
  // common tags applied to all resources
  common_tags = {
    Project = "15719.p1"
  }
}

locals {
  ami_name = "cmu-advcc-p1"
  ami_owner = "973134072933"
}

// Use these for VPC and Subnet configurations

data "aws_region" "current" {
  current = true
}
resource "aws_default_vpc" "default" {
  tags {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${data.aws_region.current.id}a"

  tags {
    Name = "Default subnet for ${data.aws_region.current.id}a"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "${data.aws_region.current.id}b"

  tags {
    Name = "Default subnet for ${data.aws_region.current.id}b"
  }
}

/*
IAM role attached to the launch configuration. This governs what resources our web service ec2 instances has access to.
*/

resource "aws_iam_role" "role-for-ec2" {
  name = "role-for-ec2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

// Create an IAM policy to allow web service to access cloudwatch metrics and logs
resource "aws_iam_policy" "ec2-iam-policy" {
  name        = "ec2-iam-policy"
  description = "ec2-iam-policy"

  #This policy:
  #Allows ec2 instance to have full access to CloudWatch
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:Describe*",
                "cloudwatch:*",
                "logs:*",
                "sns:*",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "events.amazonaws.com"
                }
            }
        }
    ]
}
EOF
}

# Attach the AMI policy to the AMI role for ec2.
resource "aws_iam_role_policy_attachment" "ec2-policy-attach" {
  role       = "${aws_iam_role.role-for-ec2.name}"
  policy_arn = "${aws_iam_policy.ec2-iam-policy.arn}"
}

resource "aws_iam_instance_profile" "profile-for-ec2" {
  name = "profile-for-ec2"
  role = "${aws_iam_role.role-for-ec2.name}"
}

/*
1. Security group, enabling access to ports 80 and 8080 of the VMs running the application
*/

resource "aws_security_group" "security-group-alb-asg" {
  // TODO: fill this out
}

/*
2. Launch configuration - a specification of the EC2 instance properties (referring to the AMI, as well as instance type and security group) to be used when there is a need to provision additional instances
Use the following parameters:
- AMI Name: ${local.ami_name} (cmu-advcc-p1)
- AMI Owner: ${local.ami_owner} (973134072933)
- Instance Type: c5.large
- IAM Instance Profile: ${aws_iam_instance_profile.profile-for-ec2.name} (provide this for monitoring and supervision)
- Detailed Monitoring: enabled
*/

resource "aws_launch_configuration" "launch-config" {
  // TODO: fill this out
}

/*
3. Application Load Balancer which acts as an HTTP endpoint for the application, and forwards the requests to the individual VM instances
*/

resource "aws_alb" "alb" {
  // TODO: fill this out
}

/*
4. Target Group, that encompasses the VM instances serving the application
- Use / for port 80 Health Check
- Use /heartbeat for port 8080 Health Check
*/

resource "aws_alb_target_group" "target-group" {
  // TODO: fill this out
}

resource "aws_alb_target_group" "target-group-heartbeat" {
  // TODO: fill this out
}

/*
5. LB Listener, that forwards all the requests at ports 80 or 8080 to the target group comprising the instances running the application
*/

resource "aws_lb_listener" "alb_listener" {
  // TODO: fill this out
}

resource "aws_lb_listener" "alb_listener_heartbeat" {
  // TODO: fill this out
}

/*
6. Auto-Scaling Group, associated with the above launch configuration and target group
*/

resource "aws_autoscaling_group" "asg" {
  // TODO: fill this out
}

/*
7. CloudWatch Alarms, firing when instances in the ASG cross a given metric threshold
*/

// TODO: fill this out

/*
8. Auto-Scaling Policies (one for scale-out and one for scale-in), associated with their parent auto-scaling group and the CloudWatch alarms (which trigger the policies)
*/

// TODO: fill this out

// output load-balancer-dns
output "load-balancer-dns" {
  value = "${aws_alb.alb.dns_name}"
}
