variable "akey" {}
variable "skey" {}


provider "aws" {
  region     = "eu-west-1"
  access_key = var.akey
  secret_key = var.skey
}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["aws-parallelcluster-2.6.1-centos7-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["247102896272"] 
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "sbn" {
  key_name   = "sbn-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "lpic" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.sbn.id

  tags = {
    Name = "lpic-2"
  }
}
