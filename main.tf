provider "aws" {
  region = "ap-northeast-1"
}

# TerraformのstateファイルをS3に保存する
terraform {
  backend "s3" {
    key = "workspace-example/terraform.tfstate"
  }
}

data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["default-vpc"]
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0a290015b99140cd1"
  instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
  subnet_id     = data.aws_subnets.default.ids[0]
}