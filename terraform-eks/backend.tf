terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket         = "eks-prod-terraform-state"
    key            = "eks/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
