provider "aws" {
  region = "ap-northeast-1"
}

# TerraformのstateファイルをS3に保存する
terraform {
  backend "s3" {
    key            = "prod/services/webserver-cluster/terraform.tfstate"
    bucket         = "terraform-up-and-running-state-20250309"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name           = "webserver-prod"
  db_remote_state_bucket = "terraform-up-and-running-state-20250309"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "m4.large"
  min_size      = 3
  max_size      = 10
  env_name      = "prod"
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 3
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *" # 9am UTC is 6pm JST

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 3
  max_size              = 10
  desired_capacity      = 3
  recurrence            = "0 17 * * *" # 5pm UTC is 12am JST

  autoscaling_group_name = module.webserver_cluster.asg_name
}

output "asg_name" {
  value       = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balancer"
}
