# Ansible EC2 Server Provisioning

This directory contains Ansible playbooks and roles for provisioning and configuring EC2 instances.

## 🎯 Overview

The provisioning setup supports multiple server types with different roles:
- **Frontend Servers**: Nginx web server + Portfolio application
- **SonarQube Servers**: Code quality and analysis platform
- **Monitoring Servers**: Prometheus metrics collection
- **All Servers**: Puppet, SSH access management, and base configuration

## 📁 Directory Structure

```
ansible/
├── roles/                      # Ansible roles
│   ├── nginx/                 # Web server configuration
│   ├── portfolio-app/         # Portfolio application deployment
│   ├── sonarqube/             # SonarQube installation and config
│   ├── prometheuse/           # Prometheus monitoring
│   ├── puppet/                # Puppet agent configuration
│   └── ssh_access/            # SSH access management
├── inventory/
│   └── aws_ec2.yml            # Dynamic EC2 inventory via SSM
├── group_vars/
│   ├── all/                   # Variables for all hosts
│   └── ec2.yaml               # EC2-specific variables
├── provision-servers.yml      # Main provisioning playbook
└── site.yml                   # Legacy site playbook
```

## 🚀 Usage

### Via GitHub Actions (Recommended)

1. **Go to Actions tab** in GitHub
2. **Select "Provision EC2 Servers with Ansible"** workflow
3. **Click "Run workflow"**
4. **Configure options**:
   - **Target Group**: Which servers to provision (all, role_frontend, role_sonarqube, role_monitor)
   - **Tags**: Which roles to apply (comma-separated: base,ssh,web,sonarqube,monitoring)
   - **Dry Run**: Test without making changes

### Manual Execution

#### Prerequisites:
```bash
# Install dependencies
pip install ansible boto3 botocore

# Install AWS Session Manager plugin
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb

# Configure AWS credentials
aws configure
```

#### Run Provisioning:

```bash
cd infra/ansible

# Provision all servers with all roles
ansible-playbook -i inventory/aws_ec2.yml provision-servers.yml

# Provision specific server group
ansible-playbook -i inventory/aws_ec2.yml provision-servers.yml --limit role_frontend

# Run specific roles only
ansible-playbook -i inventory/aws_ec2.yml provision-servers.yml --tags web,portfolio

# Dry run (check mode)
ansible-playbook -i inventory/aws_ec2.yml provision-servers.yml --check

# Verbose output
ansible-playbook -i inventory/aws_ec2.yml provision-servers.yml -vvv
```

## 🏷️ Available Tags

| Tag | Description | Roles Applied |
|-----|-------------|---------------|
| `base` | Base system configuration | System updates, common packages |
| `ssh` | SSH access management | ssh_access |
| `puppet` | Puppet agent setup | puppet |
| `web` | Web server setup | nginx |
| `portfolio` | Portfolio app deployment | portfolio-app |
| `monitoring` | Prometheus monitoring | prometheuse |
| `sonarqube` | SonarQube code analysis | sonarqube |
| `verify` | Post-provisioning health checks | Verification tasks |

## 🎭 Server Roles

### Frontend Servers (`role_frontend`)
- Nginx web server
- Portfolio application
- Accessible on port 80/443

**EC2 Tag Required**: `Role=frontend`

### SonarQube Servers (`role_sonarqube`)
- SonarQube Community Edition
- PostgreSQL database (optional external)
- Accessible on port 9000
- Default credentials: `admin/admin`

**EC2 Tag Required**: `Role=sonarqube`

### Monitoring Servers (`role_monitor`)
- Prometheus metrics collection
- Accessible on port 9090

**EC2 Tag Required**: `Role=monitor`

## 📝 Role Details

### SonarQube Role

**Features**:
- Automated installation of SonarQube 10.3+
- Java 17 setup
- PostgreSQL database (embedded or external)
- Systemd service management
- Configurable memory and system limits

**Variables** (`roles/sonarqube/defaults/main.yml`):
```yaml
sonarqube_version: "10.3.0.82913"
sonarqube_web_port: 9000
sonarqube_db_embedded: true
sonarqube_java_opts: "-Xmx512m -Xms128m"
```

**Access**: http://[server-ip]:9000
**Default Credentials**: admin/admin (change on first login)

### Portfolio App Role

**Features**:
- Git repository cloning
- Static file deployment
- Nginx site configuration
- Automatic service reload

### Nginx Role

**Features**:
- Nginx installation
- SSL/TLS configuration (if enabled)
- Virtual host setup
- Security hardening

## 🔍 Verification

### Check Inventory
```bash
# List all discovered instances
ansible-inventory -i inventory/aws_ec2.yml --list

# Show inventory graph
ansible-inventory -i inventory/aws_ec2.yml --graph

# List specific group
ansible-inventory -i inventory/aws_ec2.yml --graph role_frontend
```

### Test Connectivity
```bash
# Ping all hosts
ansible all -i inventory/aws_ec2.yml -m ping

# Run ad-hoc command
ansible all -i inventory/aws_ec2.yml -m shell -a "uptime"

# Check specific service
ansible role_frontend -i inventory/aws_ec2.yml -m systemd -a "name=nginx state=started" --become
```

### Service Health Checks
```bash
# Check all services
ansible all -i inventory/aws_ec2.yml -m shell -a "systemctl status nginx sonarqube prometheus" --become

# Check SonarQube status
curl http://[sonarqube-ip]:9000/api/system/status

# Check Prometheus
curl http://[prometheus-ip]:9090/-/healthy
```

## 🔧 Troubleshooting

### SSM Connection Issues

1. **Check SSM agent status**:
```bash
aws ssm describe-instance-information \
  --filters "Key=tag:Role,Values=frontend" \
  --query 'InstanceInformationList[*].[InstanceId,PingStatus]' \
  --output table
```

2. **Verify IAM instance profile**:
```bash
aws ec2 describe-instances --instance-ids i-xxxxx \
  --query 'Reservations[0].Instances[0].IamInstanceProfile'
```

3. **Check SSM logs on instance**:
```bash
# Connect via SSM
aws ssm start-session --target i-xxxxx

# View logs
sudo tail -f /var/log/amazon/ssm/amazon-ssm-agent.log
```

### Ansible Issues

1. **Increase verbosity**: Add `-vvv` to ansible-playbook command
2. **Check syntax**: `ansible-playbook provision-servers.yml --syntax-check`
3. **Verify variables**: `ansible all -i inventory/aws_ec2.yml -m debug -a "var=hostvars[inventory_hostname]"`

### Service Issues

1. **Check service status**:
```bash
ansible all -i inventory/aws_ec2.yml -m shell -a "systemctl status [service-name]" --become
```

2. **View service logs**:
```bash
ansible all -i inventory/aws_ec2.yml -m shell -a "journalctl -u [service-name] -n 50" --become
```

## 🔐 Security Notes

- **No SSH keys required**: Uses AWS SSM Session Manager
- **IAM-based access**: Controlled via AWS IAM policies
- **Session logging**: Can be enabled via SSM session manager
- **Change default passwords**: Especially for SonarQube (admin/admin)
- **Firewall configuration**: Ensure security groups are properly configured

## 📚 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [AWS SSM Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [SonarQube Documentation](https://docs.sonarqube.org/latest/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Nginx Documentation](https://nginx.org/en/docs/)

## 🤝 Contributing

When adding new roles:
1. Create role structure: `ansible-galaxy init roles/[role-name]`
2. Add role to `provision-servers.yml`
3. Add appropriate tags
4. Update this README
5. Test with `--check` mode first

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review GitHub Actions logs
3. Check Ansible verbose output
4. Review AWS CloudWatch logs
