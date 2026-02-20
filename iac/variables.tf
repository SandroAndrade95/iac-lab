variable "location" {
  default = "East US 2"
}

variable "my_ip" {
  description = "Your public IP for SSH"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
  default     = "5c32571a-bb02-413d-9349-fa99ce5ba596"  
}