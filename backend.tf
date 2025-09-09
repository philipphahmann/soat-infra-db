terraform {
  backend "s3" {
    bucket = "soat-infra-db-tfstate-bucket"
    key    = "database/terraform.tfstate"
    region = "us-east-1"
  }
}