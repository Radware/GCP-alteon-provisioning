# GCP Alteon ADC Deployment with Terraform
This Terraform project deploys an Alteon instance in GCP with management, data, and server subnets, security groups, network interfaces, and an instance configured with specific user data.

## Prerequisites

- GCP CLI (gcloud) installed on your local machine: Ensure that you have the gcloud CLI installed and configured with your GCP credentials.
- Terraform installed: Make sure Terraform is installed on your local machine.

### Installing GCP CLI (gcloud)

To install the gcloud CLI, follow these steps:

1. **Download and install the Google Cloud SDK**

   For Windows, download the installer from [Google Cloud SDK Installer](https://cloud.google.com/sdk/docs/install).

   For macOS, you can use Homebrew:

   ```sh
   brew install --cask google-cloud-sdk
   ```

   For Linux, you can use a package manager like `apt` for Debian-based distributions:

   ```sh
   sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates gnupg
   echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
   sudo apt-get update && sudo apt-get install -y google-cloud-sdk
   ```

2. **Initialize the GCP CLI**

   After installation, initialize the gcloud CLI by running:

   ```sh
   gcloud init
   ```
   Follow the prompts to configure your GCP project and authenticate your credentials.


### 2. Configure Variables

Copy the example `terraform.tfvars.example` file to `terraform.tfvars`:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Edit the `terraform.tfvars` file to customize the values according to your environment:

```plaintext
# GCP project ID
gcp_project = "radware-alteon"

# GCP region to deploy the resources
region = "us-central1"

# CIDR block for the VPC
vpc_cidr = "10.0.0.0/16"

# List of CIDR blocks for the subnets, should be /24
subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

# IP interface for client side (needs to be within the relevant CIDR block. x.x.x.1 is reserved for GCP default gateway - do not use it)
adc_clients_private_ip = "10.0.2.2"

# IP interface for server side (needs to be within the relevant CIDR block. x.x.x.1 is reserved for GCP default gateway - do not use it)
adc_servers_private_ip = "10.0.3.2"

# Proxy IP for server side
adc_servers_private_ip_pip = "10.0.3.3"

# Availability zone for the subnets
availability_zone = "us-central1-a"

# Instance type
instance_type = "e2-highcpu-4"

# Machine Image for the GCP instance
machine_image = "projects/radware-alteon/global/images/alteon-os-ubuntu18-5-ndebug-gcp"

# Unique identifier for each deployment
deployment_id = "default"

# Admin password
admin_password = "radware123"

# Admin username
admin_user = "admin"

# Is GEL enabled for this deployment
gel_enabled = false

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
hst2_port
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

The `userdata.tpl` file is used to configure the GCP instance. 
It includes variables for admin credentials, GEL URLs, VM name, and syslog configuration. 
The template file is populated with values from `terraform.tfvars` during the deployment.

## Cleanup

To destroy the resources created by this Terraform configuration, run:

```sh
terraform destroy
```

## Notes

- Ensure that your GCP credentials are configured correctly.
- Review the firewall rules and adjust as needed to match your security requirements.
