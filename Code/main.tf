provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "automated_server" {
  ami           = "ami-04e601abe3e1a910f" 
  instance_type = "t3.micro"

# THE DEVOPS BRIDGE: this runs automatically on first boot
user_data = <<-EOF
	#!/bin/bash
	# 1. Update the server and install Docker
	sudo apt-get update -y
	sudo apt-get install docker.io -y
	sudo systemctl start docker
	sudo systemctl enable docker

	#2. Pull your secure image from Docker Hub and run it!
	sudo docker run -d -p 80:8080 guchuu2115/my-first-app:lastest
	EOF

  tags = {
    Name = "Automated-Terraform-Server"
  }
}
