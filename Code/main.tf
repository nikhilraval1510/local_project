provider "aws" {
  region = "eu-central-1"
}

# 1. THE FIREWALL (Security Group)
resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
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
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # THE DEVOPS BRIDGE: This runs automatically on first boot
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io -y
              sudo systemctl start docker
              sudo systemctl enable docker
              
              sudo docker run -d -p 80:8080 guchuu2115/my-first-app:latest
              EOF

  tags = {
    Name = "Automated-Terraform-Server"
  }
}
