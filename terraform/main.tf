// https://registry.terraform.io/providers/hashicorp/aws/latest/docs

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "minecraft_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "minecraft-vpc"
  }
}

# Internet Gateway and Public Route
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.minecraft_vpc.id
  tags = { Name = "minecraft-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.minecraft_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "minecraft-public-rt" }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.minecraft_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Subnet
resource "aws_subnet" "minecraft_subnet" {
  vpc_id                  = aws_vpc.minecraft_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "minecraft-subnet" }
}

# Security Group (allow SSH and Minecraft port)
resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-sg"
  description = "Allow SSH and Minecraft"
  vpc_id      = aws_vpc.minecraft_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "minecraft-sg" }
}

# EC2 Instance
resource "aws_instance" "minecraft_server" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.minecraft_subnet.id
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = var.key_pair_name

  tags = { Name = "acme-minecraft-server" }
}

# Output the public IP so you can put it in the inventory hosts file
output "minecraft_public_ip" {
  description = "Public IP of the Minecraft server"
  value       = aws_instance.minecraft_server.public_ip
}
