provider "aws" {
  region = "us-east-1"
}

# 1. Grab 2 Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnet in AZ 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0] 
}

# Subnet in AZ 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1] 
}

# 2. Auto-scaling adjusts capacity (2-4 instances)
resource "aws_autoscaling_group" "app_asg" {
  name                 = "react-app-asg"
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  
  launch_template {
    id      = "lt-placeholder123" 
    version = "$Latest"
  }
}

# 3. Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}