terraform {
  backend "s3" {
    bucket  = "terraform-remote-state-bens-epa"
    region  = "us-east-1"
    encrypt = true

  }
}