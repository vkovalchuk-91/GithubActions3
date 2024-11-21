terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-central-1"
}

variable "AMI_ID" {
  type = string
  default = ""
}

data "aws_security_group" "existing_sg" {
  name = "default"
}

resource "aws_instance" "app_server" {
  ami           = var.AMI_ID
  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sleep 30
    cd /home/ubuntu/
    sudo docker compose up -d
  EOF

  tags = {
    Name = "AWS_TERRAFORM_TEST"
  }
}
