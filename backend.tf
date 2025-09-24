terraform {
  backend "s3" {
    bucket = "soat-tfstate-bucket"
    # bucket = "fiap-soat-tc-terraform"
    key    = "database/terraform.tfstate"
    region = "us-east-1"
  }
}