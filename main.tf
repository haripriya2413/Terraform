resource "random_id" "this" {
  byte_length = 8
}

resource "tls_private_key" "strapi_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "strapi_keypair" {
  key_name   = "strapi-keypair-${random_id.this.hex}"
  public_key = tls_private_key.strapi_key.public_key_openssh
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group-${random_id.this.hex}"
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
  instance_type = "t2.medium"
  key_name      = aws_key_pair.strapi_keypair.key_name
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  tags = {
    Name = "StrapiInstance-${random_id.this.hex}"
  }

 provisioner "remote-exec" {
    inline = [
             "sudo apt-get update -y",
             "sudo apt-get install -y nodejs npm git",
              "sudo npm install -g pm2",
              "sudo npm install -g strapi@latest",
              "sudo mkdir -p /srv/strapi",
              "sudo chown ubuntu:ubuntu /srv/strapi",
             # "cd /srv/strapi",
              "if [ ! -d /srv/strapi ]; then sudo git clone https://github.com/haripriya2413/Strapi-CICD /srv/strapi; else cd /srv/strapi && sudo git pull origin main; fi",
              "cd /srv/strapi",
             

          # Install Strapi globally
          "sudo npm install strapi@beta -g",

          # Create a new Strapi project
          "strapi new priya-project --dbclient=sqlite",

          # Navigate to the new project directory
          "cd priya-project",

          # Start the Strapi application using pm2
          "pm2 start npm --name 'strapi' -- run develop"
             
  

            
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.strapi_key.private_key_pem
    host        = self.public_ip
  }
}

output "strapi_private_key" {
  value = tls_private_key.strapi_key.private_key_pem
  sensitive = true
}
