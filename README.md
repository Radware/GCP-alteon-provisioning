# GCP Alteon ADC Deployment with Terraform# GCP Alteon ADC Deployment with Terraform

This Terraform project deploys an Alteon instance in GCP with management, data, and server subnets, security groups, network interfaces, and an instance configured with specific user data.

This Terraform project deploys a Radware Alteon Application Delivery Controller (ADC) instance in Google Cloud Platform with management, data, and server network interfaces, security groups, and automated configuration through userdata.

## Prerequisites

## 📋 Prerequisites

- GCP CLI (gcloud) installed on your local machine: Ensure that you have the gcloud CLI installed and configured with your GCP credentials.

Before you begin, ensure you have the following:- Terraform installed: Make sure Terraform is installed on your local machine.



- **GCP Account** with appropriate permissions to create compute instances, networks, and firewalls### Installing GCP CLI (gcloud)

- **GCP CLI (gcloud)** installed and configured

- **Terraform** installed (version >= 1.0)To install the gcloud CLI, follow these steps:

- **GCP Project** with billing enabled

1. **Download and install the Google Cloud SDK**

### Installing GCP CLI (gcloud)

   For Windows, download the installer from [Google Cloud SDK Installer](https://cloud.google.com/sdk/docs/install).

To install the gcloud CLI, follow these steps:

   For macOS, you can use Homebrew:

**For Windows:**

```powershell   ```sh

# Download and install the Google Cloud SDK from:   brew install --cask google-cloud-sdk

# https://cloud.google.com/sdk/docs/install   ```

```

   For Linux, you can use a package manager like `apt` for Debian-based distributions:

**For macOS:**

```sh   ```sh

brew install --cask google-cloud-sdk   sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates gnupg

```   echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

   sudo apt-get update && sudo apt-get install -y google-cloud-sdk

**For Linux (Debian/Ubuntu):**   ```

```sh

sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates gnupg2. **Initialize the GCP CLI**

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

sudo apt-get update && sudo apt-get install -y google-cloud-sdk   After installation, initialize the gcloud CLI by running:

```

   ```sh

### Initialize and Authenticate GCP CLI   gcloud init

   ```

```sh   Follow the prompts to configure your GCP project and authenticate your credentials.

# Initialize the gcloud CLI

gcloud init

### 2. Configure Variables

# Authenticate your account

gcloud auth application-default loginCopy the example `terraform.tfvars.example` file to `terraform.tfvars`:



# Set your default project```sh

gcloud config set project YOUR_PROJECT_IDcp terraform.tfvars.example terraform.tfvars

``````



## 🚀 Quick StartEdit the `terraform.tfvars` file to customize the values according to your environment:



### 1. Clone the Repository```plaintext

# GCP project ID

```shgcp_project = "radware-alteon"

git clone https://github.com/Radware/GCP-alteon-provisioning.git

cd GCP-alteon-provisioning# GCP region to deploy the resources

```region = "us-central1"



### 2. Configure Variables# CIDR block for the VPC

vpc_cidr = "10.0.0.0/16"

Copy the example terraform.tfvars file and customize it:

# List of CIDR blocks for the subnets, should be /24

```shsubnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

cp terraform.tfvars.example terraform.tfvars

```# IP interface for client side (needs to be within the relevant CIDR block. x.x.x.1 is reserved for GCP default gateway - do not use it)

adc_clients_private_ip = "10.0.2.2"

Edit `terraform.tfvars` and update the following **required** values:

# IP interface for server side (needs to be within the relevant CIDR block. x.x.x.1 is reserved for GCP default gateway - do not use it)

```hcladc_servers_private_ip = "10.0.3.2"

# REQUIRED: Replace with your GCP project ID

gcp_project = "your-gcp-project-id"# Proxy IP for server side

adc_servers_private_ip_pip = "10.0.3.3"

# REQUIRED: Set a secure admin password

admin_password = "YourSecurePassword123!"# Availability zone for the subnets

zone = "us-central1-a"

# OPTIONAL: Customize other values as needed

region = "us-central1"# Instance type

zone = "us-central1-a"instance_type = "e2-highcpu-4"

deployment_id = "prod"  # or "dev", "staging", etc.

```# Machine Image for the GCP instance - Using public Radware Alteon image from GCP Marketplace

ami_id = "projects/radware-public/global/images/radware-alteon-va-33-5-11-0"

### 3. Initialize Terraform

# Unique identifier for each deployment

```shdeployment_id = "default"

terraform init

```# Admin password

admin_password = "radware123"

### 4. Plan the Deployment

# Admin username

Preview the resources that will be created:admin_user = "admin"



```sh# Is GEL enabled for this deployment

terraform plangel_enabled = false

```

# GEL primary URL

### 5. Deploy the Infrastructuregel_url_primary = "http://primary.gel.example.com"



```sh# GEL secondary URL

terraform applygel_url_secondary = "http://secondary.gel.example.com"

```

# GEL enterprise ID

Type `yes` when prompted to proceed with the deployment.gel_ent_id = "12345"



### 6. Access Your Alteon Instance# GEL throughput in MB

gel_throughput_mb = 100

After deployment completes, Terraform will output the connection information:

# GEL primary DNS

```gel_dns_pri = "8.8.8.8"

Outputs:

# NTP primary server IP Address only

adc_clients_private_ip = "10.0.2.2"ntp_primary_server = "132.163.97.8"

adc_mgmt_external_ip = "34.136.XX.XX"

adc_mgmt_private_ip = "10.0.1.2"# NTP time zone

adc_servers_private_ip = "10.0.3.2"ntp_tzone = "UTC"

```

# Local IP address

**Access the Alteon Web Interface:**cc_local_ip = "10.0.1.2"

- URL: `https://[adc_mgmt_external_ip]`

- Username: `admin` (or your configured `admin_user`)# Remote IP address

- Password: Your configured `admin_password`cc_remote_ip = "0.0.0.0"



**SSH Access:**# VM name

```shvm_name = "default-vm"

ssh admin@[adc_mgmt_external_ip]

```# Syslog Server IP for syslog host 1

hst1_ip = "1.2.3.4"

## 📦 Resources Created

# Severity[0-7] for syslog host 1

This deployment creates the following GCP resources:hst1_severity = 7



- **3 VPC Networks:**# Facility[0-7] for syslog host 1

  - Management VPChst1_facility = 0

  - Data/Client VPC

  - Server VPC# Module for syslog host 1

hst1_module = "all"

- **3 Subnets:**

  - Management subnet (`10.0.1.0/24`)# Port for syslog host 1

  - Data subnet (`10.0.2.0/24`)hst1_port = 514

  - Server subnet (`10.0.3.0/24`)

# Syslog Server IP for syslog host 2

- **3 Firewall Rules:**hst2_ip = "0.0.0.0"

  - Management firewall (ports: 22, 443, 2222, 3121, 8443, ICMP)

  - Data firewall (ports: 22, 443, 2222, 3121, 8443, ICMP)# Severity for syslog host 2

  - Server firewall (ports: 22, 443, 2222, 3121, 8443, ICMP)hst2_severity = 7



- **1 Alteon ADC Instance:**# Facility for syslog host 2

  - Machine type: `e2-highcpu-4` (customizable)hst2_facility = 0

  - Image: Public Radware Alteon VA from GCP Marketplace

  - 3 network interfaces (management, data, server)# Module for syslog host 2

  - External IP on management interfacehst2_module = "all"

  - Automated configuration via userdata

# Port for syslog host 2

## 🔧 Configurationhst2_port

```

### Key Configuration Files

### 3. Initialize Terraform

- **`main.tf`** - Main Terraform configuration defining all resources

- **`variables.tf`** - Variable definitions with defaultsInitialize your Terraform working directory, which will download the necessary provider plugins and set up the backend.

- **`versions.tf`** - Terraform and provider version requirements

- **`userdata.tpl`** - Alteon configuration template (JSON format)```sh

- **`terraform.tfvars`** - Your customized values (create from example)terraform init

```

### Important Variables

### 4. Plan the Deployment

| Variable | Description | Default | Required |

|----------|-------------|---------|----------|Before applying the changes, you can run the `terraform plan` command to see a preview of the actions that Terraform will take to deploy your infrastructure.

| `gcp_project` | Your GCP project ID | - | ✅ Yes |

| `admin_password` | Admin password for Alteon | `ChangeMe123!` | ✅ Yes |```sh

| `region` | GCP region | `us-central1` | No |terraform plan

| `zone` | GCP zone | `us-central1-a` | No |```

| `deployment_id` | Unique identifier for deployment | `default` | No |

| `instance_type` | GCP machine type | `e2-highcpu-4` | No |### 5. Apply the Configuration

| `ami_id` | Alteon image (from GCP Marketplace) | `projects/radware-public/global/images/radware-alteon-va` | No |

Finally, apply the configuration to deploy the resources. Terraform will prompt you for confirmation before proceeding.

### Network Configuration

```sh

The deployment creates three separate networks with pre-configured IP addresses:terraform apply

```

- **Management Interface:** `10.0.1.2` (external IP assigned)

- **Data/Client Interface:** `10.0.2.2`## Resources Created

- **Server Interface:** `10.0.3.2`

- **Proxy IP (PIP):** `10.0.3.3`- **VPC**: A virtual private cloud with a specified CIDR block.

- **Subnets**: Management, data, and server subnets.

> **Note:** IP addresses ending in `.1` are reserved by GCP as default gateways.- **Internet Gateway**: Enables internet access for the VPC.

- **Route Table**: Configured with routes to the internet gateway.

### Security Considerations- **Security Group**: Allows traffic for specific ports and protocols.

- **Network Interfaces**: Attached to the subnets.

⚠️ **Important Security Notes:**- **Elastic IP**: Allocated and associated with the management network interface.

- **EC2 Instance**: Configured with user data from a template file.

1. **Change Default Password:** Always change the default `admin_password` in `terraform.tfvars`

2. **Restrict Firewall Rules:** By default, firewalls allow traffic from `0.0.0.0/0`. Restrict `security_source_IP_ranges_*` variables to your specific IP ranges## User Data Template

3. **Sensitive Data:** Never commit `terraform.tfvars` to version control (it's in `.gitignore`)

4. **Terraform State:** Contains sensitive data - use remote state storage (GCS bucket) for productionThe `userdata.tpl` file is used to configure the GCP instance. 

It includes variables for admin credentials, GEL URLs, VM name, and syslog configuration. 

### Userdata ConfigurationThe template file is populated with values from `terraform.tfvars` during the deployment.



The Alteon instance is automatically configured at first boot using the `userdata.tpl` template. This includes:## Cleanup



- Admin credentialsTo destroy the resources created by this Terraform configuration, run:

- NTP configuration

- SNMP settings```sh

- Network interface configuration (IPs, VLANs)terraform destroy

- Proxy IP (PIP) configuration```

- Syslog host configuration

- GEL (Global Elastic Load Balancer) settings (if enabled)## Notes



## 🧹 Cleanup- Ensure that your GCP credentials are configured correctly.

- Review the firewall rules and adjust as needed to match your security requirements.

To destroy all resources created by this deployment:

```sh
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## 🔄 Updating the Deployment

To update the Alteon configuration or infrastructure:

1. Modify the appropriate files (`terraform.tfvars`, `userdata.tpl`, etc.)
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes

> **Note:** Changing userdata requires recreating the instance, as Alteon reads configuration only during first boot.

## 📝 Customization Examples

### Change Region/Zone

```hcl
region = "europe-west1"
zone = "europe-west1-b"
```

### Use Different Machine Type

```hcl
instance_type = "n1-standard-4"
```

### Restrict Firewall Access

```hcl
# Allow only from your office IP
security_source_IP_ranges_mgmt = ["203.0.113.0/24"]
security_source_IP_ranges_data = ["203.0.113.0/24"]
security_source_IP_ranges_servers = ["10.0.0.0/8"]
```

### Enable GEL (Global Elastic Load Balancer)

```hcl
gel_enabled = true
gel_url_primary = "https://your-gel-primary.example.com"
gel_url_secondary = "https://your-gel-secondary.example.com"
gel_ent_id = "your-enterprise-id"
```

## 🐛 Troubleshooting

### Authentication Errors

If you encounter OAuth2 errors:
```sh
gcloud auth application-default login
```

### Instance Not Configured

If the Alteon instance doesn't have the expected configuration:
1. Check that IPs in `terraform.tfvars` match the subnet CIDRs
2. Verify the instance metadata: `gcloud compute instances describe adc-instance-[deployment_id] --zone=[zone]`
3. The configuration is applied only on first boot - changes require instance recreation

### Permission Denied

Ensure your GCP account has the following roles:
- Compute Admin
- Service Account User
- Or a custom role with equivalent permissions

## 📚 Additional Resources

- [Radware Alteon Documentation](https://www.radware.com/products/alteon/)
- [GCP Marketplace - Radware Alteon VA](https://console.cloud.google.com/marketplace/product/radware-public/radware-alteon-va)
- [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## 🤝 Support

For Radware Alteon product support, please contact Radware Support.

For issues related to this Terraform deployment, please open an issue in the GitHub repository.

## 📄 License

This project is provided as-is for deploying Radware Alteon on GCP.

---

**Note:** The Radware Alteon image is publicly available on the GCP Marketplace at `projects/radware-public/global/images/radware-alteon-va`. All customers use the same image path regardless of their GCP project.
