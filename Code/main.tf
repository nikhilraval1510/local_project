provider "aws" {
  region = "eu-central-1"
}

# 1. THE FIREWALL (Security Group)
resource "aws_security_group" "web_sg_v2" {
  name        = "allow_web_traffic_v2"
  description = "Allow incoming HTTP traffic from the internet"

  # INBOUND RULES (Who can come in)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 0.0.0.0/0 means the entire internet
  }

  # OUTBOUND RULES (Who the server can talk to)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. THE SERVER (EC2 Instance)
resource "aws_instance" "automated_server" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t3.micro"
  
  # ATTACH THE FIREWALL TO THE SERVER
  vpc_security_group_ids = [aws_security_group.web_sg_v2.id]

  # THE DEVOPS BRIDGE: This runs automatically on first boot
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io -y
              sudo systemctl start docker
              sudo systemctl enable docker
              
              sudo docker run -d -p 80:8080 guchuu2115/my-first-app:latest
              EOF


# 3. THE CLOUD-INIT BOOT SCRIPT (Now with Docker Compose!)
  user_data = <<-EOF
              #!/bin/bash
              # Install Docker and Docker Compose
              sudo apt-get update -y
              sudo apt-get install docker.io docker-compose -y
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # Create the Production Docker Compose file on the server
              cat << 'COMPOSE' > /home/ubuntu/docker-compose.yml
              version: '3.8'
              services:
                web:
                  image: guchuu2115/my-first-app:latest
                  ports:
                    - "80:8080" # Map the internet to your app
                  depends_on:
                    - database
                database:
                  image: postgres:15-alpine
                  environment:
                    POSTGRES_USER: admin
                    POSTGRES_PASSWORD: secretpassword
                    POSTGRES_DB: enterprise_data
              COMPOSE

              # Launch the Multi-Tier Architecture
              cd /home/ubuntu
              sudo docker-compose up -d
              EOF
  tags = {
    Name = "Automated-Terraform-Server"
  }
}
