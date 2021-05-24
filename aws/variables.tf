variable "aws_region" {}
variable "aws_availability_zone" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
data "aws_caller_identity" "current" {}

variable "container_definition_fn" {
  default = "containers.json"
}

variable "assume_role_policy_fn" {
  default = "ecs-assume-role-policy.json"
}

variable "role_policy_fn" {
  default = "ecs-task-execution-role-policy.json"
}

variable "opencart_awslogs_group" {
  default = "/ecs/opencart"
}

variable "mymysql_awslogs_group" {
  default = "/ecs/mymysql"
}

data "aws_ecr_image" "opencart_image" {
  repository_name = "opencart"
  image_tag       = "0.1"
}

data "aws_ecr_image" "mymysql_image" {
  repository_name = "mymysql"
  image_tag       = "0.1"
}
