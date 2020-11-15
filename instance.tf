data "template_file" "prometheus_config" {
  template = file("prometheus.yml")
}

resource "exoscale_compute" "prometheus" {
  zone         = var.zone
  display_name = "prometheus_server"
  template_id  = data.exoscale_compute_template.ubuntu.id
  size         = "Micro"
  disk_size    = 10
  key_pair     = ""
  security_groups = [exoscale_security_group.sg.name]

  user_data = <<EOPF

#!/bin/bash
set -e
apt update

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo mkdir /srv/prometheus
sudo touch /srv/prometheus/prometheus.yml
sudo touch /srv/prometheus/servicediscovery.json
sudo echo "${data.template_file.prometheus_config.rendered}" > /srv/prometheus/prometheus.yml

sudo docker run -d --net=host -v /srv/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml -v /srv/prometheus/servicediscovery.json:/service-discovery/servicediscovery.json prom/prometheus

EOPF
}