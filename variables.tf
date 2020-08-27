variable "environment_name" {
  description = "Name to label environment with - Dev for example"
}

variable "VPC_CIDR" {
  description = "Customer VPC to contain all their EC2/RDS instances."
}

variable "PublicSubnet1" {
  description = "First public subnet for EC2 instances."
}

variable "PublicSubnet2" {
  description = "Second public subnet for EC2 instances."
}

variable "PrivateSubnet1" {
  description = "First private subnet for RDS instances."
}

variable "PrivateSubnet2" {
  description = "Second private subnet for RDS instances."
}

variable "region" {
  description = "AWS region (can be us-east-1)"
}

variable "dbuser" {
  description = "Database user name"
}

variable "dbpassword" {
  description = "Database user password (please make it a complex one!!)"
}

variable "dbversion" {
  description = "Database engine version"
}

variable "ssh_key" {
  description = "AWS EC2 SSH key name (needs to be created by user in console)"
}

variable "ssh_key_path" {
  description = "absolute path of .pem file given by AWS (/path_to_file/file.pem), keep in mind that this key will be the only ssh access to this server, so keep it in a safe place"
}

variable "odooversion" {
  description = "Odoo version to install (it can be 11.0 or 12.0 or 13.0)"
}

variable "rds_instance_type" {
  description = "RDS db instance type, use db.t2.micro to stay in free tier"
  default = "db.t2.micro"
}

variable "ec2_instance_type" {
  description = "EC2 instance type, use t2.micro to stay in free tier"
  default = "t2.micro"
}
