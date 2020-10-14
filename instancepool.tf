variable "zone" {
  default = "at-vie-1"
}

data "exoscale_compute_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 20.04 LTS 64-bit"
}

resource "exoscale_instance_pool" "webapp" {
  zone = var.zone
  name = "webapp"
  template_id = data.exoscale_compute_template.ubuntu.id
  size = 2
  service_offering = "micro"
  disk_size = 10
  description = "This is the production environment for my webapp"
  key_pair = ""
  security_group_ids = [exoscale_security_group.sg.id]

  timeouts {
    delete = "10m"
  }
  
    user_data = <<EOF
#!/bin/bash
set -e
apt update
apt install -y nginx
EOF
}