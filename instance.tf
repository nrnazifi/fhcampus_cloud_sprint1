data "template_file" "prometheus_yaml" {
  template = file("prometheus.yml")
}

data "template_file" "prometheus_targets" {
  template = file("servicediscovery.json")
}

resource "exoscale_compute" "prometheus" {
  zone         = var.zone
  display_name = "prometheus"
  template_id  = data.exoscale_compute_template.ubuntu.id
  size         = "Micro"
  disk_size    = 10
  key_pair     = ""
  
  affinity_groups = []
  security_groups = [exoscale_security_group.prometheus_sg.name]

  user_data = <<EOF
#!/bin/bash
set -e
apt update

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo touch /srv/prometheus.yml
sudo echo "${data.template_file.prometheus_yaml.rendered}" > /srv/prometheus.yml
sudo touch /srv/servicediscovery.json
sudo echo "${data.template_file.prometheus_targets.rendered}" > /srv/servicediscovery.json

sudo docker run -d --net=host -v /srv/prometheus.yml:/etc/prometheus/prometheus.yml -v /srv/servicediscovery.json:/service-discovery/servicediscovery.json prom/prometheus
EOF
}