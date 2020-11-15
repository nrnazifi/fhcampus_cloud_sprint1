data "template_file" "prometheus_config" {
  template = file("prometheus.yml")
}

resource "exoscale_compute" "prometheus" {
  zone         = var.zone
  display_name = "prometheus"
  template_id  = data.exoscale_compute_template.ubuntu.id
  size         = "Micro"
  disk_size    = 10
  key_pair     = ""
  security_group_ids = [exoscale_security_group.sg.id]

  user_data = <<EOF

#!/bin/bash
set -e
apt update

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo touch /srv/prometheus.yml
sudo echo "${data.template_file.prometheus_config.rendered}" > /srv/prometheus.yml
sudo docker run -d --net=host -v /srv/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus

EOF
}