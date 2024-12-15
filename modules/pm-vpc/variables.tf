variable "env" {
  description = "environment variable"
  type = string
}

variable "vpc_name" {
  description = "name of the vpc"
  type = string
}

variable "cidr" {
  description = "CIDR block"
  type = string
}

variable "azs" {
  description = "avaibality zones"
  type = list(string)
}

variable "private_subnets" {
  description = "private subnets"
  type = list(string)
}

variable "public_subnets" {
  description = "public subnets"
  type = list(string)
}

variable "enable_nat_gateway" {
  description = "enable NAT Gateway"
  type = bool
}

variable "enable_vpn_gateway" {
  description = "enable_vpn_gateway"
  type = bool
}
