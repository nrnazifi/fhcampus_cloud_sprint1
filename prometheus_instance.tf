data "template_file" "prometheus_yaml" {
  template = file("prometheus.yml")
}

resource "exoscale_compute" "prometheus" {
  zone         = var.zone
  display_name = "prometheus"
  template_id  = data.exoscale_compute_template.ubuntu.id
  size         = "Micro"
  disk_size    = 10
  #key_pair     = exoscale_ssh_keypair.key.name
  
  affinity_groups = []
  security_groups = [exoscale_security_group.prometheus_sg.name]

  user_data = <<EOF
#!/bin/bash
set -e
apt update

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo mkdir -p /prometheus
sudo touch /prometheus/prometheus.yml
sudo touch /prometheus/targets.json
sudo echo "${data.template_file.prometheus_yaml.rendered}" > /prometheus/prometheus.yml
sudo chown -R ubuntu:ubuntu /prometheus

sudo docker pull nrnazifi/cloud-servicediscovery
sudo docker run \
  -dit \
  -e EXOSCALE_KEY=${var.exoscale_key} \
  -e EXOSCALE_SECRET=${var.exoscale_secret} \
  -e TARGET_PORT=${var.target_port} \
  -e EXOSCALE_ZONE=${var.zone} \
  -e EXOSCALE_INSTANCEPOOL_ID=${exoscale_instance_pool.webapp.id} \
  -v /prometheus/targets.json:/srv/service-discovery/config.json \
  nrnazifi/cloud-servicediscovery

sudo docker run -d --net=host \
  -v /prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v /prometheus/targets.json:/service-discovery/targets.json \
  prom/prometheus

EOF
}