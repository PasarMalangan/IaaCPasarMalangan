variable "env" {
    description = "environment variable"
    type = string
}

variable "instance_type" {
  description = "Instance type"
  type = string
}

variable "ami_id" {
  description = "AMI ID of the instance"
  type = string
}

variable "key_name" {
  description = "key name of the instance"
  type = string
}


variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}