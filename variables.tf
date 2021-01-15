variable "zone" {
  default = "at-vie-1"
}

variable "target_port" {
 default = "9100"
}

variable "listen_port" {
 default = "8090"
}

variable "exoscale_key" {
  description = "The Exoscale API key"
  type = string
}
variable "exoscale_secret" {
  description = "The Exoscale API secret"
  type = string
}

variable "admin_ip" {
  description = "Administrator IP address"
  type = string
  default = "0.0.0.0/0"
}