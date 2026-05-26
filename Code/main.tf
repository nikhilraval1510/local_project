provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "web_sg_v5" {
  name        = "allow_web_traffic_5"
  description = "Allow incoming HTTP traffic from the internet"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "automated_server" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t3.micro"
  
  vpc_security_group_ids = [aws_security_group.web_sg_v5.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io docker-compose -y
              sudo systemctl start docker
              sudo systemctl enable docker
              
              cat << 'COMPOSE' > /home/ubuntu/docker-compose.yml
              version: '3.8'
              services:
                web:
                  image: guchuu2115/my-first-app:latest
                  restart: always
                  ports:
                    - "80:8080"
                  depends_on:
                    - database
                database:
                  image: postgres:15-alpine
                  restart: always
                  environment:
                    POSTGRES_USER: admin
                    POSTGRES_PASSWORD: secretpassword
                    POSTGRES_DB: enterprise_data
              COMPOSE

              cd /home/ubuntu
              sudo docker-compose up -d
              EOF

  tags = {
    Name = "Automated-Terraform-Server"
  }
}
