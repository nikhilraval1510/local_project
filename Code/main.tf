provider "aws" {
  region = "eu-central-1"
}

# 1. WEB SECURITY GROUP (Allows Internet access to the Web Server)
resource "aws_security_group" "web_sg_prod" {
  name        = "allow_web_traffic_prod"
  description = "Allow incoming HTTP traffic"

  ingress {
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

# 2. DATABASE SECURITY GROUP (The Vault)
# Notice this doesn't allow 0.0.0.0/0. It ONLY allows traffic from the Web Server!
resource "aws_security_group" "db_sg" {
  name        = "allow_db_traffic"
  description = "Allow traffic from web server to database"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg_prod.id] # The Magic Security Link
  }
}

# 3. THE MANAGED DATABASE (AWS RDS)
resource "aws_db_instance" "production_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  db_name                = "enterprise_data"
  username               = "admin"
  password               = "secretpassword"
  skip_final_snapshot    = true # Allows us to delete it easily later
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false # Hides the database from the public internet!
}

# 4. THE WEB SERVER
resource "aws_instance" "prod_web_server" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg_prod.id]

  # Notice we deleted the database container from docker-compose!
  # We are dynamically passing the RDS address into the Node.js container instead.
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
                  environment:
                    - DB_USER=admin
                    - DB_PASSWORD=secretpassword
                    - DB_NAME=enterprise_data
                    - DB_HOST=${aws_db_instance.production_db.address}
              COMPOSE

              cd /home/ubuntu
              sudo docker-compose up -d
              EOF

  tags = {
    Name = "Production-Web-Server"
  }
}
