#####################################
 #  Variable
#####################################

variable "vpc_cidr_block" {
    type = string
    description = "cidr block for vpc"
    default = "10.0.0.0/16"
  
}

variable "vpc_subnets" {
    type = list(string)
    description = "subnet list of both AZ"
    default = ["10.0.0.0/24","10.0.1.0/24"]  
}

variable "enable_dns_hostname" {
    type = bool
    description = "enable DNS hostname in vpc"
    default = true
  
}
variable "map_public_ip_on_launch" {
    type = bool
    description = "assign public ip to EC2 machines"
    default = true
  
}

variable "aws_region" {
    type = string
    description = "aws region name"
    default = "ap-south-1"
  
}

variable "ec2_type" {
    type = string
    description = "ec2 machine type"
    default = "t2.micro"
  
}

variable "aws_s3_bucket" {
    type = string
    description = "s3 bucket name"
    default = "mitanshs3bucket"
  
}
