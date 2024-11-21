provider "aws" {
  region = "eu-central-1"
}

variable "AMI_ID" {
  type = string
  default = ""
}

data "aws_security_group" "existing_sg" {
  name = "security"
}

resource "aws_instance" "app_server" {
  ami           = var.AMI_ID
  instance_type = "t2.micro"

  security_groups = length(data.aws_security_group.existing_sg.id) > 0 ? [data.aws_security_group.existing_sg.name] : [aws_security_group.web_sg.name]

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
  count       = length(data.aws_security_group.existing_sg.id) > 0 ? 0 : 1
  name        = "security"
  description = "Allow HTTP and SSH traffic"

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
