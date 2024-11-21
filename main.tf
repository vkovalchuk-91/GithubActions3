provider "aws" {
  region = "eu-central-1"
}

variable "AMI_ID" {
  type = string
  default = ""
}

resource "aws_instance" "app_server" {
  ami           = var.AMI_ID
  instance_type = "t2.micro"

  provisioner "remote-exec" {
    inline = [
      "sudo docker-compose up -d"
    ]
  }

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
}
