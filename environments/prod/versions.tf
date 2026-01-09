terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # O backend deve ser configurado aqui ou via CLI/arquivo separado
  backend "s3" {
    bucket = "soat-ms-tfstate-bucket-1"
    key    = "database/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}