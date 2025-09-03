variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-0715c1897453cabd1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "my-key-pair"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  sensitive = true
}
