resource "random_id" "this" {
  byte_length = 8
}
resource "aws_security_group" "strapi_sg" {
  vpc_id      = aws_vpc.strapi_vpc.id
 # name        = "strapi-security-group-${random_id.this.hex}"
  description = "Security group for Strapi EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Strapi Security Group-${random_id.this.hex}"
  }
}

resource "aws_instance" "strapi_instance" {
  ami           = var.ami
  instance_type = "t2.small"
  key_name      = "devops"
  vpc_security_group_ids      = [aws_security_group.strapi-sg.id]
  subnet_id = aws_subnet.public_subnet1.id
  associate_public_ip_address = true


  tags = {
    Name = "StrapiInstance-${random_id.this.hex}"
  }


provisioner "remote-exec" {
    inline = [
             "sudo apt update - y",
             "curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh",
             "sudo bash -E nodesource_setup.sh",
             "sudo apt update && sudo apt install nodejs -y",
             "sudo npm install -g yarn && sudo npm install -g pm2",
              "sudo mkdir -p /srv/strapi",
              "sudo chown ubuntu:ubuntu /srv/strapi",
              "echo -e 'skip\n' | npx create-strapi-app simple-strapi --quickstart",                      
            
    ]
  }
 
  #security_groups = [aws_security_group.strapi-sg.name]
}





