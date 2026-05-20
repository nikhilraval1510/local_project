# This tells Terraform to dynamically search the live AWS catalog for the region you are in
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # The official canonical AWS account ID for Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}



# 1. Define our main metropolis network block (Day 6)
resource "aws_vpc" "main_network" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Production-Metropolis"
  }
}

# 2. Carve out our Public Web Room floor (Day 6 & 7)
resource "aws_subnet" "web_room" {
  vpc_id     = aws_vpc.main_network.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public-Web-Floor"
  }
}

# 3. Deploy our Virtual Linux Server Container
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id # The Ubuntu Linux OS Engine Image
  instance_type = "t3.micro"             # Server size capacity (1 CPU Core, 1GB RAM)
  subnet_id     = aws_subnet.web_room.id  # Plugs this server directly into our floor

  tags = {
    Name = "Production-Web-01"
  }
}
