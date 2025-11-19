provider "google" {
  project = var.gcp_project
  region  = var.region
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

# Google Cloud firewall to allow traffic via ports
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

resource "google_compute_instance" "adc_instance" {
  name         = "adc-instance-${var.deployment_id}"
  machine_type = var.instance_type
  zone         = var.zone

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.ami_id
      size  = 12
      type  = "pd-balanced"
    }
  }

  labels = {
    environment = var.deployment_id
    managed_by  = "terraform"
    application = "alteon-adc"
    goog-ec-src = "vm_add-tf"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.adc_mgmt_subnet.name
    network_ip = var.cc_local_ip

    # Adding external IP for management interface
    access_config {
      // Leaving this empty will assign an ephemeral external IP
      // To assign a static IP, specify `nat_ip = google_compute_address.static_ip.address`
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.adc_data_subnet.name
    network_ip = var.adc_clients_private_ip
  }

  network_interface {
    subnetwork = google_compute_subnetwork.adc_servers_subnet.name
    network_ip = var.adc_servers_private_ip
    # If alias IPs are needed, uncomment and define appropriately:
    # alias_ip_range {
    #   ip_cidr_range = "10.0.3.0/24"  # Adjust as needed
    # }
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  service_account {
    email  = var.service_account_email != "" ? var.service_account_email : null
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    user-data = local.rendered_userdata
  }

  tags = ["adc-instance"]

  lifecycle {
    ignore_changes = [
      scheduling,
    ]
  }
}

# Render the userdata.tpl template with the variables using native templatefile function
locals {
  rendered_userdata = templatefile("${path.module}/userdata.tpl", {
    admin_user                 = var.admin_user
    admin_password             = var.admin_password
    gel_enabled                = var.gel_enabled
    gel_url_primary            = var.gel_url_primary
    gel_url_secondary          = var.gel_url_secondary
    vm_name                    = var.vm_name
    gel_ent_id                 = var.gel_ent_id
    gel_throughput_mb          = var.gel_throughput_mb
    gel_dns_pri                = var.gel_dns_pri
    ntp_primary_server         = var.ntp_primary_server
    ntp_tzone                  = var.ntp_tzone
    cc_local_ip                = var.cc_local_ip
    cc_remote_ip               = var.cc_remote_ip
    adc_clients_private_ip     = var.adc_clients_private_ip
    adc_servers_private_ip     = var.adc_servers_private_ip
    adc_servers_private_ip_pip = var.adc_servers_private_ip_pip
    hst1_ip                    = var.hst1_ip
    hst1_severity              = var.hst1_severity
    hst1_facility              = var.hst1_facility
    hst1_module                = var.hst1_module
    hst1_port                  = var.hst1_port
    hst2_ip                    = var.hst2_ip
    hst2_severity              = var.hst2_severity
    hst2_facility              = var.hst2_facility
    hst2_module                = var.hst2_module
    hst2_port                  = var.hst2_port
  })
}

resource "local_file" "userdata_file" {
  content  = local.rendered_userdata
  filename = "${path.module}/rendered_userdata.tpl"
}

# Outputs for IP addresses
output "adc_mgmt_private_ip" {
  value = google_compute_instance.adc_instance.network_interface[0].network_ip
}

output "adc_clients_private_ip" {
  value = google_compute_instance.adc_instance.network_interface[1].network_ip
}

output "adc_servers_private_ip" {
  value = google_compute_instance.adc_instance.network_interface[2].network_ip
}

output "adc_mgmt_external_ip" {
  value = google_compute_instance.adc_instance.network_interface[0].access_config[0].nat_ip
}