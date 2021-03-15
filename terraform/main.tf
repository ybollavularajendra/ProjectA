#terraform provider config

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-east-1"
}

#Terraform Backend s3 config

terraform {
  backend "s3" {
    bucket = "backends3test"
    key    = "terraformf/key"
    region = "us-east-1"
  }
}


# 1. Create vpc

resource "aws_vpc" "test_vpc" {
  cidr_block = var.VPC_ID

   tags = {
    Name = "dev-vpc"
  }
}


#2. Create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test"
  }
}

#3. Create Custom Route Table

resource "aws_route_table" "r_table" {
   vpc_id = aws_vpc.test_vpc.id
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
   }
   route {
     ipv6_cidr_block = "::/0"
     gateway_id      = aws_internet_gateway.gw.id
   }
   tags = {
     Name = "test"
   }
 }

#4. Create a Subnet

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = var.subnet-a
  availability_zone = "us-east-1a"

  tags = {
    Name = "test_subnet_1"
  }
}

#5. Associate subnet with Route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.r_table.id
}


#6. Create Security Group to allow ports for communication

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
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
    Name = "sg-test-basic"
  }
}

#7. Create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "test" {
  subnet_id       = aws_subnet.subnet-1.id
  security_groups = [aws_security_group.allow_traffic.id]

}


#8. Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "test" {
  vpc = true
  network_interface         = aws_network_interface.test.id
  associate_with_private_ip = var.private-ip
  depends_on                = [aws_internet_gateway.gw]
}



#9. Create an EC2 instance

resource "aws_instance" "test_instance" {
  ami           = var.ami-id
  instance_type = "t2.micro"
  network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.test.id
  }
  tags = {
    Name = "testInstance"
  }
}