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

resource "aws_iam_group" "developer" {
  name = "developer"
}

resource "aws_iam_group" "employee" {
  name = "employee"
}

output "groups" {
  value = [
    aws_iam_group.developer,
    aws_iam_group.employee,
  ]
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
  groups = each.value.is_developer ? [aws_iam_group.developer.name, aws_iam_group.employee.name] : [aws_iam_group.employee.name]
}

# if user.is_developer 필터를 통해 개발자만 추출
locals {
  developers = [
  for user in var.users :
  user
  if user.is_developer
  ]
}

resource "aws_iam_user_policy_attachment" "developer" {
  for_each = {
  for user in local.developers :
  user.name => user
  }

  user       = each.key
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  # aws_iam_user.this 가 있어야만 aws_iam_user_policy_attachment 를 생성할 수 있음.
  depends_on = [
    aws_iam_user.this
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
