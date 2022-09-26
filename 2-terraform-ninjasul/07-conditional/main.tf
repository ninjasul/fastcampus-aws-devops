provider "aws" {
  region = "ap-northeast-2"
}


/*
 * Conditional Expression
 * Condtion ? If_True : If_False
 */
variable "is_john" {
  type = bool
  default = true
}

# terraform apply -var="is_john=false"
# 명령어 로 테스트 해 볼 것.
locals {
  message = var.is_john ? "Hello John!" : "Hello!"
}

output "message" {
  value = local.message
}


/*
 * Count Trick for Conditional Resource
 */
variable "internet_gateway_enabled" {
  type = bool
  default = true
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

/*
  var.internet_gateway_enabled 값에 따라 count 를 1 또는 0으로 부여하여
  생성여부를 optional 하게 설정할 수 있음.
  terraform apply 와
  terraform apply -var="internet_gateway_enabled=false" 를 번갈아 실행하며 결과를 비교해 볼 것.
*/
resource "aws_internet_gateway" "this" {
  count = var.internet_gateway_enabled ? 1 : 0

  vpc_id = aws_vpc.this.id
}
