terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "fast_api" {
  instance_type = "t2.micro"
  ami = "ami-0557a15b87f6559cf"
}