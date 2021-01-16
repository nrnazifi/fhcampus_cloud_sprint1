resource "exoscale_compute" "monitoring" {
  zone         = var.zone
  display_name = "monitoring"
  template_id  = data.exoscale_compute_template.ubuntu.id
  size         = "Micro"
  disk_size    = 10
  key_pair     = ""
  
  affinity_groups = []
  security_groups = [exoscale_security_group.monitoring_sg.name]

  user_data = templatefile("userdata-monitor-server.sh.tbl" , {
	exoscale_key = var.exoscale_key
    exoscale_secret = var.exoscale_secret
    exoscale_zone = var.zone
	target_port = var.target_port
	listen_port = var.listen_port
    instance_pool_id = exoscale_instance_pool.webapp.id
	prometheus_yml = file("prometheus.yml")
	grafana_dashboards_yml = file("grafana_dashboards.yml")
	grafana_datasources_yml = file("grafana_datasources.yml")
	grafana_notifications_yml = file("grafana_notifications.yml")
	grafana_dashboard_json = file("grafana_dashboard.json")
  })
}