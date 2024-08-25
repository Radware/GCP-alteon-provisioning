provider "google" {
  # credentials = file("<YOUR-CREDENTIALS-FILE>.json")
  project     = var.gcp_project
  region      = var.region
}

# Creating separate VPCs for each network interface
resource "google_compute_network" "adc_mgmt_vpc" {
  name                    = "adc-mgmt-vpc-${var.deployment_id}"
  auto_create_subnetworks = false
}
resource "google_compute_network" "adc_data_vpc" {
  name                    = "adc-data-vpc-${var.deployment_id}"
  auto_create_subnetworks = false
}
resource "google_compute_network" "adc_servers_vpc" {
  name                    = "adc-servers-vpc-${var.deployment_id}"
  auto_create_subnetworks = false
}


# Creating subnets in each VPC
resource "google_compute_subnetwork" "adc_mgmt_subnet" {
  name          = "adc-mgmt-subnet-${var.deployment_id}"
  region        = var.region
  ip_cidr_range = var.subnet_cidrs[0]
  network       = google_compute_network.adc_mgmt_vpc.self_link
}
resource "google_compute_subnetwork" "adc_data_subnet" {
  name          = "adc-data-subnet-${var.deployment_id}"
  region        = var.region
  ip_cidr_range = var.subnet_cidrs[1]
  network       = google_compute_network.adc_data_vpc.self_link
}
resource "google_compute_subnetwork" "adc_servers_subnet" {
  name          = "adc-servers-subnet-${var.deployment_id}"
  region        = var.region
  ip_cidr_range = var.subnet_cidrs[2]
  network       = google_compute_network.adc_servers_vpc.self_link
}

#google cloud firewall to allow traffic via ports
resource "google_compute_firewall" "adc_alteon_mgmt_sg" {
  name    = "alteon-mgmt-sg-${var.deployment_id}"
  network = google_compute_network.adc_mgmt_vpc.name

  allow {
    protocol = "tcp"
    ports    = var.security_ports_mgmt
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = var.security_source_IP_ranges_mgmt
}
resource "google_compute_firewall" "adc_alteon_data_sg" {
  name    = "alteon-data-sg-${var.deployment_id}"
  network = google_compute_network.adc_data_vpc.name
  allow {
    protocol = "tcp"
    ports    = var.security_ports_data
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = var.security_source_IP_ranges_data
}
resource "google_compute_firewall" "adc_alteon_servers_sg" {
  name    = "alteon-servers-sg-${var.deployment_id}"
  network = google_compute_network.adc_servers_vpc.name
  allow {
    protocol = "tcp"
    ports    = var.security_ports_servers
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = var.security_source_IP_ranges_servers
}

# Instance configurations with network interfaces in separate VPCs
resource "google_compute_instance" "adc_instance" {
  boot_disk{
    auto_delete = true
    device_name = "adc-instance-${var.deployment_id}"

    initialize_params {
      image = var.ami_id
      size  = 12
      type  = "pd-balanced"
    }
    mode = "READ_WRITE"
  
  }

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = var.instance_type
  name         = "adc-instance-${var.deployment_id}"
  zone         = "${var.region}-${var.availability_zone}"

  network_interface {
    subnetwork = google_compute_subnetwork.adc_mgmt_subnet.name
    access_config {
      network_tier = "PREMIUM"
    }
    queue_count = 0
    stack_type  = "IPV4_ONLY"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.adc_data_subnet.name
    access_config {
      network_tier = "PREMIUM"
    }
    alias_ip_range {
      ip_cidr_range = "/32"
    }
    queue_count = 0
    stack_type  = "IPV4_ONLY"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.adc_servers_subnet.name
    alias_ip_range {
      ip_cidr_range = "/32"
    }
    queue_count = 0
    stack_type  = "IPV4_ONLY"
  }

  service_account {
    email  = "591546275183-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    #ssh-keys = "${var.admin_user}:${file(var.public_key_path)}"
    user-data = templatefile("${path.module}/userdata.tpl", {
      admin_user             = var.admin_user,
      admin_password         = var.admin_password,
      gel_url_primary        = var.gel_url_primary,
      gel_url_secondary      = var.gel_url_secondary,
      vm_name                = var.vm_name,
      gel_ent_id             = var.gel_ent_id,
      gel_throughput_mb      = var.gel_throughput_mb,
      gel_dns_pri            = var.gel_dns_pri,
      ntp_primary_server     = var.ntp_primary_server,
      ntp_tzone              = var.ntp_tzone,
      cc_local_ip            = var.cc_local_ip,
      cc_remote_ip           = var.cc_remote_ip,
      adc_clients_private_ip =  google_compute_instance.adc_instance.network_interface.1.network_ip, #"10.0.2.2"
      adc_servers_private_ip = google_compute_instance.adc_instance.network_interface.2.network_ip, #"10.0.3.2"
      adc_servers_private_ip_pip = cidrhost(google_compute_instance.adc_instance.network_interface.2.alias_ip_range[0].ip_cidr_range, 0), #"10.0.3.3"
      data_subnet_gateway    = google_compute_subnetwork.adc_data_subnet.gateway_address,
    
      #adc_clients_private_ip = var.adc_clients_private_ip,
      #adc_servers_private_ip = var.adc_servers_private_ip,
      #adc_servers_private_ip_pip = var.adc_servers_private_ip_pip,
      #data_subnet_gateway    = ,
      
      hst1_ip                = var.hst1_ip,
      hst1_severity          = var.hst1_severity,
      hst1_facility          = var.hst1_facility,
      hst1_module            = var.hst1_module,
      hst1_port              = var.hst1_port,
      hst2_ip                = var.hst2_ip,
      hst2_severity          = var.hst2_severity,
      hst2_facility          = var.hst2_facility,
      hst2_module            = var.hst2_module,
      hst2_port              = var.hst2_port,
      gel_enabled            = var.gel_enabled
    })
  }

  tags = ["adc-instance", "http", "https"]
}

output "adc_mgmt_private_ip" {
  value = google_compute_instance.adc_instance.network_interface[0].network_ip
}

output "adc_clients_private_ip" {
  value = google_compute_instance.adc_instance.network_interface[1].network_ip
}

output "adc_servers_private_ip" {
  value = google_compute_instance.adc_instance.network_interface[2].network_ip
}

output "adc_servers_private_ip_pip" {
  value = google_compute_instance.adc_instance.network_interface[2].alias_ip_range[0].ip_cidr_range
}

#output "deployment_message" {
#  description = "Deployment message for Compute Engine VM instance"
#  value = var.operation == "create" ? format("Alteon ADC has been deployed to Compute Engine %s in account %s with instance ID %s. Access it at https://%s. You can SSH into the instance using port 2222. It might take 15-20 minutes for Alteon ADC to load up the config. If the userdata that was passed to the TF template was not valid, the admin password that you defined will not work, and instead the admin password will be R@dware12345", var.region, data.aws_caller_identity.current.account_id, aws_instance.adc_instance.id, aws_eip.adc_eip.public_ip, aws_instance.adc_instance.id) : format("Alteon ADC in GCP %s is being destroyed.", var.region)
#}
