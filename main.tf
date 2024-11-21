provider "aws" {
  region = "eu-central-1"
}

variable "AMI_ID" {
  type = string
  default = ""
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key-pair"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "app_server" {
  ami           = var.AMI_ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    cd /home/ubuntu/
    sudo docker-compose up -d
  EOF

  tags = {
    Name = "AWS_TERRAFORM_TEST"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "security"
  description = "Allow 80 port"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
