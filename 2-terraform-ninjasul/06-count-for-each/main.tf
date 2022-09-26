provider "aws" {
  region = "ap-northeast-2"
}

/*
 * No count / for_each
 */
resource "aws_iam_user" "user_1" {
  name = "user-1"
}

resource "aws_iam_user" "user_2" {
  name = "user-2"
}

resource "aws_iam_user" "user_3" {
  name = "user-3"
}

output "user_arns" {
  value = [
    aws_iam_user.user_1.arn,
    aws_iam_user.user_2.arn,
    aws_iam_user.user_3.arn,
  ]
}


/*
 * count - resource, data, module 에 모두 사용 가능함.
 */

resource "aws_iam_user" "count" {
  # count 는 resource 블록 body의 최상단에 선언하는 것이 convention 임.
  count = 10

  name = "count-user-${count.index}"
}

output "count_user_arns" {
  value = aws_iam_user.count.*.arn
}

/*
 * for_each
 */
resource "aws_iam_user" "for_each_set" {
  # toset 으로 set 이나 map을 생성할 수 있음.
  # set 의 경우에는 each.key, each.value가 모두 value를 나타냄.
  # map 의 경우에는 each.key 는 key, each.value 는 value를 나타냄.
  for_each = toset([
    "for-each-set-user-1",
    "for-each-set-user-2",
    "for-each-set-user-3",
  ])

  name = each.key
}

output "for_each_set_user_arns" {
  # keys(), values() 함수를 통해 key, value 값만 가져올 수 있음.
  value = values(aws_iam_user.for_each_set).*.arn
}

/*
* for_each_map
*/

resource "aws_iam_user" "for_each_map" {
  # key는 반드시 string 이어야 함.
  for_each = {
    alice = {
      level   = "low"
      manager = "posquit0"
    }
    bob = {
      level   = "mid"
      manager = "posquit0"
    }
    john = {
      level   = "high"
      manager = "steve"
    }
  }

  name = each.key
  tags = each.value
}

output "for_each_map_user_arns" {
  value = values(aws_iam_user.for_each_map).*.arn
}

