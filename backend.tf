terraform {
  backend "s3" {
    bucket = "soat-tfstate-bucket"
    key    = "database/terraform.tfstate"
    region = "us-east-1"
  }
}