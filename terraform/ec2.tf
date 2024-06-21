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
  user_data                   = <<-EOF
              sudo apt-get update -y
              sudo apt-get install -y nodejs npm git
              sudo npm install -g pm2
              sudo npm install -g strapi@latest
              sudo mkdir -p /srv/strapi 
              sudo chown ubuntu:ubuntu /srv/strapi
             # "cd /srv/strapi",
              if [ ! -d /srv/strapi ]; then sudo git clone https://github.com/haripriya2413/Strapi-CICD /srv/strapi; else cd /srv/strapi && sudo git pull origin main; fi",
              cd /srv/strapi
            
                                EOF



  tags = {
    Name = "StrapiInstance-${random_id.this.hex}"
  }



 # security_groups = [aws_security_group.strapi-sg.name]
}





