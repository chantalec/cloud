output "ipaddress" {
  description = "ip address"
  value = google_compute_instance.myterra.network_interface.0.access_config.0.nat_ip
  }

