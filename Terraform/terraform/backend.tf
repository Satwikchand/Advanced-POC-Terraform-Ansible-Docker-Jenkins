terraform {
  backend "s3" {
    bucket         = "satwik-devops-terraform-state"
    key            = "platform/terraform.tfstate"
    region         = "us-east-2"

    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
