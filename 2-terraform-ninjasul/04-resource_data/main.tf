provider "aws" {
  region = "ap-northeast-2"
}

data "aws_ami" "ubuntu" {
  # 여러 개의 ami 중 가장 최신의 것을 가져옴.
  most_recent = true

  # name 필터를 통해 20.04 ubuntu ami 를 모두 가져옴.
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  # 가상화 타입이 hvm 인 것만 가져옴.
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # ubuntu 를 만든 Canonical 이 제작한 ami만 가져옴.
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  ami = data.aws_ami.ubuntu.image_id
  instance_type = "t2.micro"

  tags = {
    Name = "fastcampus-ubuntu"
  }
}
