terraform {
  backend "s3" {
    bucket = "terraform-cicd-github-actions-2026"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}
