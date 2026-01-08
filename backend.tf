terraform {
  backend "s3" {
    bucket = "soat-ms-tfstate-bucket-1"
    key    = "database/terraform.tfstate"
    region = "us-east-1"
  }
}