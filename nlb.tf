resource "exoscale_nlb" "nlb_website" {
  zone = var.zone
  name = "nlb_website"
  description = "This is the Network Load Balancer for my website"
}