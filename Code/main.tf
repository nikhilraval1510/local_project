provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "automated_server" {
  ami           = "ami-04e601abe3e1a910f" 
  instance_type = "t3.micro"

  tags = {
    Name = "Automated-Terraform-Server"
  }
}
