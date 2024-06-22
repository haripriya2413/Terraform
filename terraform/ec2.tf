resource "random_id" "this" {
  byte_length = 8
}
resource "aws_security_group" "strapi-sg" {
  vpc_id      = aws_vpc.strapi_vpc.id
  description = "Security Group for Strapi Application"
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    from_port   = "1337"
    to_port     = "1337"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Strapi-SG"
  }

}

resource "aws_instance" "strapi_instance" {
  ami           = var.ami
  instance_type = "t2.small"
  key_name      = "devops"
  vpc_security_group_ids      = [aws_security_group.strapi-sg.id]
  subnet_id = aws_subnet.public_subnet1.id
  associate_public_ip_address = true
 
provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
    "sudo apt-get install -y nodejs",
    "sudo apt-get install -y npm",
    "sudo npm install pm2 -g",
    "if [ ! -d /srv/strapi ]; then sudo git clone https://github.com/haripriya2413/deploy-strapi /srv/strapi; else cd /srv/strapi && sudo git pull origin master; fi",
    "sudo chmod u+x /srv/strapi/generate_env_variables.sh*",
    "cd /srv/strapi",
    "sudo ./generate_env_variables.sh",
]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ec2_private_key
      host        = self.public_ip
    }
  }


                             

              
             
            
                            



  tags = {
    Name = "StrapiInstance-${random_id.this.hex}"
  }



 # security_groups = [aws_security_group.strapi-sg.name]
}





