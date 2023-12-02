# Local Values
locals {
  vpc_name                 = "lytx-vnet"
  vpc_name_second          = "lytx-vnet-second"
  public_subnet_name       = "lytx-public-subnet"
  public_subnet_name_second = "lytx-public-subnet-second"
  asg_security_group_name  = "lytx-asg-security-group"
  asg_security_group_name_second  = "lytx-asg-security-group-second"
  internet_gateway_name    = "lytx-gateway"
  internet_gateway_name_second = "lytx-gateway-second"
  public_route_table_name  = "lytx-route-table-name"
  public_route_table_name_second  = "lytx-route-table-name-second"
}



variable "aws_region" {
  description = "AWS region name"
  type        = string
  default     = "us-east-1"
  }

variable "aws_second_region" {
  description = "AWS region name second"
  type        = string
  default     = "eu-west-1"
  }


# VPC Variables
variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string   
  default     = "10.0.0.0/16"      #"10.0.1.0/24"                        # "10.0.0.0/16" 
}

variable "vpc_cidr_second" {
  description = "VPC cidr block second"
  type        = string   
  default     = "10.1.0.0/16"          #"10.0.0.0/16"  
}

variable "az_names" {
  type          = string
  default = "us-east-1a"
}

variable "az_names_second" {
  type          = string
  default = "eu-west-1a"               #"eu-west-1a"
}

variable "ami" {
  description = "ami id"
  type        = string
  default     = "ami-05c13eab67c5d8861"   #ami-05c13eab67c5d8861
}

variable "ami2" {
  description = "ami id second"
  type        = string
  default     = "ami-07355fe79b493752d"
}

variable "public_subnet_cidr" {
  description = "Public Subnet cidr block"
  type          = string
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr_second" {
  description = "Public Subnet cidr block second"
  type          = string
  default = "10.1.1.0/24"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t2.micro"  # "m5.large"  #"t2.micro"    # "t2.xlarge"  
}
