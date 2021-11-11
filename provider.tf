provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = var.keyid
  secret_key = var.seckey
}
