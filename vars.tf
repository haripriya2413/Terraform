

# Defining Region
variable "aws_region" {
  default = "us-east-1"
}




# Defining AMI
variable "ami" {
  default = {
    us-east-1 = "ami-04b70fa74e45c3917"
  }
}


