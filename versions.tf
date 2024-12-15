#AWS Provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local ={
      source = "hashicorp/local"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  # This is the version of Terraform we will use
  required_version = ">= 1.9.8"

backend "s3" {
    bucket         = "iacremotestate"
    key            = "state"
    region         = "us-east-1"
    dynamodb_table = "Pasarmalanganremotestate"
  }
}
