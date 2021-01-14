data "template_file" "prometheus_yaml" {
  template = file("prometheus.yml")
}

data "template_file" "grafana_dashboards_yml" {
  template = file("grafana_dashboards.yml")
}

data "template_file" "grafana_datasources_yml" {
  template = file("grafana_datasources.yml")
}

data "template_file" "grafana_notifications_yml" {
  template = file("grafana_notifications.yml")
}

resource "exoscale_compute" "monitoring" {
  zone         = var.zone
  display_name = "monitoring"
  template_id  = data.exoscale_compute_template.ubuntu.id
  size         = "Micro"
  disk_size    = 10
  key_pair     = exoscale_ssh_keypair.key.name
  
  affinity_groups = []
  security_groups = [exoscale_security_group.monitoring_sg.name]

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

# Create the network
docker network create monitoring

# Run service discovery
sudo docker pull nrnazifi/cloud-servicediscovery
sudo docker run \
	-dit --name service_discover \
	--network monitoring \
	-e EXOSCALE_KEY=${var.exoscale_key} \
	-e EXOSCALE_SECRET=${var.exoscale_secret} \
	-e TARGET_PORT=${var.target_port} \
	-e EXOSCALE_ZONE=${var.zone} \
	-e EXOSCALE_INSTANCEPOOL_ID=${exoscale_instance_pool.webapp.id} \
	-v /prometheus/targets.json:/srv/service-discovery/config.json \
	nrnazifi/cloud-servicediscovery

# Run prometheus
sudo docker run -d --name prometheus \
	--network monitoring -p 9090:9090 \
	-v /prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
	-v /prometheus/targets.json:/service-discovery/targets.json \
	prom/prometheus
    
# Create garfana files 
sudo mkdir -p /grafana
sudo touch /grafana/dashboard.json
sudo touch /grafana/dashboards.yml
sudo touch /grafana/datasources.yml
sudo touch /grafana/notifications.yml

sudo echo "${data.template_file.grafana_dashboards_yml.rendered}" > /grafana/dashboards.yml
sudo echo "${data.template_file.grafana_datasources_yml.rendered}" > /grafana/datasources.yml
sudo echo "${data.template_file.grafana_notifications_yml.rendered}" > /grafana/notifications.yml

sudo chown -R ubuntu:ubuntu /grafana

# Run garfana 
sudo docker run -d -p 3000:3000 --name=grafana \
	--network monitoring \
	-v /grafana/dashboards.yml:/etc/grafana/provisioning/dashboards/dashboards.yml \
	-v /grafana/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml \
	-v /grafana/notifications.yml:/etc/grafana/provisioning/notifiers/notifications.yml \
	grafana/grafana

EOF
}