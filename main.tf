provider "aws" {
  region = "eu-central-1"
}

variable "AMI_ID" {
  type = string
  default = ""
}

variable "private_key_path" {
  type    = string
  default = "/home/ubuntu/.ssh/id_rsa"
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key-pair"
  public_key = file("${var.private_key_path}.pub")  # Публічний ключ, що створений на кроці 1
}

resource "aws_instance" "app_server" {
  ami           = var.AMI_ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_key.key_name

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
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

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
