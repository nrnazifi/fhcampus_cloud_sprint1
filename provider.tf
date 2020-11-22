terraform {
  required_providers {
    exoscale = {
      source  = "terraform-providers/exoscale"
    }
  }
}

//noinspection HILConvertToHCL
provider "exoscale" {
  key = var.exoscale_key
  secret = var.exoscale_secret
}
