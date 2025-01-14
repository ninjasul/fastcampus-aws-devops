/*
https://www.terraform.io/language/expressions/for
for-each, count 는 data, resource, module 에서 사용가능한 속성임.
반면, for는 expression 을 사용할 수 있는 모든 곳에서 사용가능함.
*/
terraform {
  # terraform cloud 에서 state 관리
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "ninjasul"

    workspaces {
      name = "tf-cloud-backend"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

/*
 * Groups
 */

resource "aws_iam_group" "this" {
  for_each = toset(["developer", "employee"])

  name = each.key
}

output "groups" {
  value = aws_iam_group.this
}


/*
 * Users
 */

variable "users" {
  type = list(any)
}

resource "aws_iam_user" "this" {
  for_each = {
  for user in var.users :
  user.name => user
  }

  name = each.key

  tags = {
    level = each.value.level
    role  = each.value.role
  }
}

resource "aws_iam_user_group_membership" "this" {
  for_each = {
  for user in var.users :
  user.name => user
  }

  user   = each.key
  groups = each.value.is_developer ? [aws_iam_group.this["developer"].name, aws_iam_group.this["employee"].name] : [aws_iam_group.this["employee"].name]
}

# if user.is_developer 필터를 통해 개발자만 추출
locals {
  developers = [
  for user in var.users :
  user
  if user.is_developer
  ]
}

output "developers" {
  value = local.developers
}

output "high_level_users" {
  value = [
  for user in var.users :
  user
  if user.level > 5
  ]
}
