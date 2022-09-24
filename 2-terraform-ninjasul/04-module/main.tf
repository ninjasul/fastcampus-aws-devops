provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source  = "tedilabs/network/aws//modules/vpc"
  version = "0.24.0"

  name       = "fastcampus"
  cidr_block = "10.0.0.0/16"

  internet_gateway_enabled = true

  dns_hostnames_enabled = true
  dns_support_enabled   = true

  tags = {}
}

module "subnet_group__public" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  # 다른 모듈을 변수로 참조할 때는 ${module."모듈이름"."해당모듈의 output 변수"} 와 같은 형태로 참조가 가능함
  name   = "${module.vpc.name}-public"
  vpc_id = module.vpc.id

  # public subnet 이므로 해당 subnet 상의 EC2 인스턴스에는 public ip 를 할당하도록 설정
  map_public_ip_on_launch = true

  subnets = {
    "${module.vpc.name}-public-001/az1" = {
      cidr_block           = "10.0.0.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${module.vpc.name}-public-001/az2" = {
      cidr_block           = "10.0.1.0/24"
      availability_zone_id = "apne2-az2"
    }
  }

  tags = {}
}

module "subnet_group__private" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  name   = "${module.vpc.name}-private"
  vpc_id = module.vpc.id

  map_public_ip_on_launch = false

  subnets = {
    "${module.vpc.name}-private-001/az1" = {
      cidr_block           = "10.0.10.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${module.vpc.name}-private-001/az2" = {
      cidr_block           = "10.0.11.0/24"
      availability_zone_id = "apne2-az2"
    }
  }

  tags = {}
}

module "route_table__public" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name   = "${module.vpc.name}-public"
  vpc_id = module.vpc.id

  subnets = module.subnet_group__public.ids

  ipv4_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.vpc.internet_gateway_id
    },
  ]

  tags = {}
}

# 대개 실무 시에는 private route table 에 outgoing 통신만 가능한 장비인 NAT-gateway 나 NAT-instance 와 연결함.
# 하지만 NAT-gateway 나 NAT-instance가 유료이므로 이 실습에서는 아예 인터넷 통신이 안되도록 설정.
module "route_table__private" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name   = "${module.vpc.name}-private"
  vpc_id = module.vpc.id

  subnets = module.subnet_group__private.ids

  ipv4_routes = []

  tags = {}
}
