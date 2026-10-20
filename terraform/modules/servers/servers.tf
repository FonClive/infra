#################################
# IAM Role for SSM Access
#################################
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.key_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Environment = var.environments
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.key_name}-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

#################################
# EC2 Instances
#################################
resource "aws_instance" "this" {
  count = var.ec2_parameters.instance_count

  ami           = var.ec2_parameters.ami_id
  instance_type = var.ec2_parameters.instance_type

  # distribute evenly across subnets
  subnet_id = element(var.ec2_parameters.subnet_ids, count.index % length(var.ec2_parameters.subnet_ids))
  
  # Attach IAM instance profile for SSM access
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = var.security_group_ids
  
  # User data to ensure SSM agent is installed and running
  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Log output for debugging
              exec > >(tee /var/log/user-data.log)
              exec 2>&1
              
              echo "Starting SSM Agent installation and configuration..."
              
              # Detect OS
              if [ -f /etc/os-release ]; then
                . /etc/os-release
                OS=$ID
              fi
              
              # Install or update SSM agent based on OS
              case "$OS" in
                amzn|rhel|centos)
                  echo "Detected Amazon Linux/RHEL/CentOS"
                  # Amazon Linux 2 and newer have SSM pre-installed
                  yum install -y amazon-ssm-agent || yum update -y amazon-ssm-agent
                  systemctl enable amazon-ssm-agent
                  systemctl start amazon-ssm-agent
                  ;;
                ubuntu|debian)
                  echo "Detected Ubuntu/Debian"
                  # Update package list
                  apt-get update
                  # Install SSM agent if not present
                  if ! dpkg -l | grep -q amazon-ssm-agent; then
                    # Download and install SSM agent
                    cd /tmp
                    wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
                    dpkg -i amazon-ssm-agent.deb
                  fi
                  systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || systemctl enable amazon-ssm-agent
                  systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || systemctl start amazon-ssm-agent
                  ;;
                *)
                  echo "Unknown OS: $OS"
                  exit 1
                  ;;
              esac
              
              # Verify SSM agent is running
              sleep 5
              if systemctl is-active --quiet amazon-ssm-agent || systemctl is-active --quiet snap.amazon-ssm-agent.amazon-ssm-agent.service; then
                echo "SSM Agent is running successfully"
              else
                echo "WARNING: SSM Agent failed to start"
                systemctl status amazon-ssm-agent || systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service
                exit 1
              fi
              
              echo "SSM Agent setup complete"
              EOF
  
  tags = merge(
    {
      Name        = "instance-${count.index}"
      Environment = var.environments
    },
    lookup(var.ec2_parameters, "tags", {})
  )
}

