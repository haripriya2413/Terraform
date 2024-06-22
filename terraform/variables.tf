
variable "region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-0e001c9271cf7f3b9"
}
variable "ec2_private_key" {
  description = "SSH private key for connecting to EC2 instance"
}
