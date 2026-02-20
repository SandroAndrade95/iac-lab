resource "azurerm_resource_group" "rg" {
  name     = "rg-trucking-01"
  location = var.location
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
