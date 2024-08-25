# AWS Alteon ADC Deployment with Terraform
This Terraform project deploys an AWS VPC with management, data, and server subnets, security groups, network interfaces, and an EC2 instance configured with specific user data.

## Prerequisites

- Terraform installed on your local machine.
- AWS CLI installed and configured with your credentials.

### Installing AWS CLI

To install AWS CLI, follow these steps:

1. **Download the AWS CLI Installer**

   For Windows, download the installer from [AWS CLI Windows Installer](https://awscli.amazonaws.com/AWSCLIV2.msi).

   For macOS, you can use Homebrew:

   ```sh
   brew install awscli
   ```

   For Linux, you can use a package manager like `apt` for Debian-based distributions:

   ```sh
   sudo apt-get update
   sudo apt-get install awscli
   ```

   Or `yum` for Red Hat-based distributions:

   ```sh
   sudo yum install awscli
   ```

2. **Verify the Installation**

   After installation, verify that AWS CLI is installed correctly by running:

   ```sh
   aws --version
   ```

3. **Configure AWS CLI**

   Configure your AWS CLI with your credentials by running:

   ```sh
   aws configure
   ```

   You will be prompted to enter your AWS Access Key ID, Secret Access Key, region, and output format.

By ensuring that AWS CLI is installed and configured, you will be able to interact with AWS services from your local machine.

### 2. Configure Variables

Copy the example `terraform.tfvars.example` file to `terraform.tfvars`:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Edit the `terraform.tfvars` file to customize the values according to your environment:

```plaintext
# AWS region to deploy the resources
region = "us-east-1"

# CIDR block for the VPC
vpc_cidr = "10.0.0.0/16"

# List of CIDR blocks for the subnets, should be /24
subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

# Availability zone for the subnets
availability_zone = "a"

# EC2 instance type
instance_type = "c4.large"

# AMI ID for the EC2 instance
ami_id = "ami-09fd2b8b128dc0f2d"

# Unique identifier for each deployment
deployment_id = "default"

# Admin password
admin_password = "password1"

# Admin username
admin_user = "admin"

# GEL primary URL
gel_url_primary = "http://primary.gel.example.com"

# GEL secondary URL
gel_url_secondary = "http://secondary.gel.example.com"

# GEL enterprise ID
gel_ent_id = "12345"

# GEL throughput in MB
gel_throughput_mb = 100

# GEL primary DNS
gel_dns_pri = "8.8.8.8"

# NTP primary server IP Address only
ntp_primary_server = "132.163.97.8"

# NTP time zone
ntp_tzone = "UTC"

# Local IP address
cc_local_ip = "10.0.1.2"

# Remote IP address
cc_remote_ip = "0.0.0.0"

# VM name
vm_name = "default-vm"

# Syslog Server IP for syslog host 1
hst1_ip = "1.2.3.4"

# Severity[0-7] for syslog host 1
hst1_severity = 7

# Facility[0-7] for syslog host 1
hst1_facility = 0

# Module for syslog host 1
hst1_module = "all"

# Port for syslog host 1
hst1_port = 514

# Syslog Server IP for syslog host 2
hst2_ip = "0.0.0.0"

# Severity for syslog host 2
hst2_severity = 7

# Facility for syslog host 2
hst2_facility = 0

# Module for syslog host 2
hst2_module = "all"

# Port for syslog host 2
hst2_port = 514
```

### 3. Initialize Terraform

Initialize your Terraform working directory, which will download the necessary provider plugins and set up the backend.

```sh
terraform init
```

### 4. Plan the Deployment

Before applying the changes, you can run the `terraform plan` command to see a preview of the actions that Terraform will take to deploy your infrastructure.

```sh
terraform plan
```

### 5. Apply the Configuration

Finally, apply the configuration to deploy the resources. Terraform will prompt you for confirmation before proceeding.

```sh
terraform apply
```

## Resources Created

- **VPC**: A virtual private cloud with a specified CIDR block.
- **Subnets**: Management, data, and server subnets.
- **Internet Gateway**: Enables internet access for the VPC.
- **Route Table**: Configured with routes to the internet gateway.
- **Security Group**: Allows traffic for specific ports and protocols.
- **Network Interfaces**: Attached to the subnets.
- **Elastic IP**: Allocated and associated with the management network interface.
- **EC2 Instance**: Configured with user data from a template file.

## User Data Template

The `userdata.tpl` file is used to configure the EC2 instance. 
It includes variables for admin credentials, GEL URLs, VM name, and syslog configuration. 
The template file is populated with values from `terraform.tfvars` during the deployment.

## Cleanup

To destroy the resources created by this Terraform configuration, run:

```sh
terraform destroy
```

## Notes

- Ensure that your AWS credentials are configured correctly.
- Review the security group rules and adjust as needed to match your security requirements.