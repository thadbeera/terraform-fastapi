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
resource "aws_security_group" "http_and_ssh" {
  name = "http_and_ssh"
  description = "Allow HTTP and SSH traffic via Terraform"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "fast_api" {
  instance_type = "t2.micro"
  ami = "ami-0557a15b87f6559cf"
  security_groups = [aws_security_group.http_and_ssh.name] 
  user_data = <<EOF
    #! /bin/bash
    set -x
    sudo apt-get update
    sudo apt install -y python3-pip nginx
    sudo pip install "fastapi[all]"
    sudo pip install uvicorn
    sudo cd /tmp
    sudo git clone https://github.com/thadbeera/fast_api.git
    sudo cd fast_api
    latestip=$(curl -sL http://169.254.169.254/latest/meta-data/public-ipv4)
    cd fast_api
    pwd
    sudo sed -i "s/IPADDRESS/$latestip/g" fastapi_nginx
    sudo cp fastapi_nginx /etc/nginx/sites-enabled/
    sudo service nginx restart
    python3 -m uvicorn main:app
EOF
  tags = {
    Name = "fast_api"
  }
}
