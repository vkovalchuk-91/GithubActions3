packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "ami_prefix" {
  type    = string
  default = "Terraform_intro_part_1-packer-linux-aws"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "aws_access_key" {
  type    = string
  default = env("AWS_ACCESS_KEY_ID")
}

variable "aws_secret_key" {
  type    = string
  default = env("AWS_SECRET_ACCESS_KEY")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = var.instance_type
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  region        = var.region
  ssh_username  = var.ssh_username
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "./docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }
  
  provisioner "shell" {
    inline = [
      "mkdir -p /home/ubuntu/html"
    ]
  }

  provisioner "file" {
    source      = "./html/index.html"
    destination = "/home/ubuntu/html/index.html"
  }

  provisioner "shell" {
    script = "./docker.sh"
  }
}
