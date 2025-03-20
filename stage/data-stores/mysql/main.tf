provider "aws" {
  region = "ap-northeast-1"
}

# TerraformのstateファイルをS3に保存する
terraform {
  backend "s3" {
    key            = "stage/data-stores/mysql/terraform.tfstate"
    bucket         = "terraform-up-and-running-state-20250309"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["default-vpc"]
  }
}

data "aws_security_group" "instance" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnets" "subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

resource "aws_db_subnet_group" "example" {
  name        = "example"
  description = "Subnet group for example database"
  subnet_ids  = data.aws_subnets.subnet.ids
}

resource "aws_db_instance" "example" {
  identifier_prefix      = "terraform-up-and-running"
  engine                 = "mysql"
  allocated_storage      = 10
  instance_class         = "db.t3.micro"
  skip_final_snapshot    = true
  db_name                = "example_database"
  vpc_security_group_ids = [data.aws_security_group.instance.id]
  db_subnet_group_name   = aws_db_subnet_group.example.name
  username               = var.db_username
  password               = var.db_password
}