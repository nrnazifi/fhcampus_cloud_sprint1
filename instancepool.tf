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

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo docker pull quay.io/janoszen/http-load-generator:latest
sudo docker run -d --rm -p 80:8080 quay.io/janoszen/http-load-generator

sudo docker run -d --net=host -v "/:/hostfs" prom/node-exporter --path.rootfs=/hostfs

EOF
}
# ref: example for docker run ... prom/node-exporter from https://devconnected.com/how-to-install-prometheus-with-docker-on-ubuntu-18-04/