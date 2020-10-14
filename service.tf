resource "exoscale_nlb_service" "website_service" {
  zone             = exoscale_nlb.nlb_website.zone
  name             = "website_service"
  description      = "Website over HTTP"
  nlb_id           = exoscale_nlb.nlb_website.id
  instance_pool_id = exoscale_instance_pool.webapp.id
  protocol       = "tcp"
  port           = 80
  target_port    = 80
  strategy       = "round-robin"

  healthcheck {
    mode     = "http"
    port     = 80
    uri      = "/health"
    interval = 10
    timeout  = 10
    retries  = 1
  }
}