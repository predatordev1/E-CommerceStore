# VPC Creation

resource "aws_vpc" "e-commerce-vpc" {
  tags = {
    Name  = var.name
    Owner = var.owner
  }
  cidr_block = "10.0.0.0/24"
}

# Subnet Creation

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.e-commerce-vpc.id
  availability_zone = var.availability_zone
  cidr_block        = "10.0.0.0/25"
  tags = {
    Name  = var.name
    Owner = var.owner
  }
}

resource "aws_subnet" "private-subnet-e-commerce" {
  vpc_id            = aws_vpc.e-commerce-vpc.id
  availability_zone = var.availability_zone
  cidr_block        = "10.0.0.128/25"
  tags = {
    Name  = var.name
    Owner = var.owner
  }
}

resource "aws_internet_gateway" "e-commerce-igw" {
  tags = {
    Name  = var.name
    Owner = var.owner
  }
  vpc_id = aws_vpc.e-commerce-vpc.id
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.e-commerce-vpc.id
  tags = {
    Name  = "e-commerce-public-route-table"
    Owner = "Devendra"
  }
}

resource "aws_route" "e-commerce-route-public" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.e-commerce-igw.id
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.e-commerce-vpc.id
  tags = {
    Name  = "e-commerce-private-route-table"
    Owner = "Devendra"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

# Security Group Creation

resource "aws_security_group" "e-commerce-frontend-sg" {
  vpc_id = aws_vpc.e-commerce-vpc.id
  tags = {
    Name  = "e-commerce-frontend-sg"
    Owner = "Devendra"
  }
}

resource "aws_vpc_security_group_ingress_rule" "frontend-http" {
  security_group_id = aws_security_group.e-commerce-frontend-sg.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "frontend-https" {
  security_group_id = aws_security_group.e-commerce-frontend-sg.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "frontend-ssh" {
  security_group_id = aws_security_group.e-commerce-frontend-sg.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "frontend-traffic" {
  security_group_id = aws_security_group.e-commerce-frontend-sg.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  to_port           = 3000
}

resource "aws_vpc_security_group_egress_rule" "frontend-egress" {
  security_group_id = aws_security_group.e-commerce-frontend-sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

################# EC2 Instances Launch ###########
resource "aws_key_pair" "e-commerce_key" {
  key_name   = "e-commerce-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
resource "aws_instance" "e-commerce-webserver" {
  ami                         = "ami-05d2d839d4f73aafb"
  instance_type               = "t3.small"
  key_name                    = "e-commerce-key"
  vpc_security_group_ids      = [aws_security_group.e-commerce-frontend-sg.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  tags = {
    Name  = "e-commerce-webserver"
    Owner = "Devendra"
  }
  user_data = <<-EOF
        #!/bin/bash
        # Install Docker
        sudo apt-get update -y
        sudo apt-get install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
         sudo usermod -aG docker ubuntu

        # Pull all 5 images from DockerHub
        sudo docker pull dev8182/dockerfiles:order-service-v1.0
        sudo docker pull dev8182/dockerfiles:product-service-v1.0
        sudo docker pull dev8182/dockerfiles:user-service-v1.0
        sudo docker pull dev8182/dockerfiles:cart-service-v1.0
        sudo docker pull dev8182/dockerfiles:frontend-service-v1.0
			  sudo docker pull mongo:latest


        # Run containers on proper ports
			  sudo docker run -d --name cart-service -p 3003:3003 -e MONGODB_URI="mongodb://172.17.0.1:27017/ecommerce_carts" dev8182/dockerfiles:cart-service-v1.0
        sudo docker run -d --name mongo6 -p 27017:27017 mongo:latest
			  sudo docker run -d --name cart-service -p 3004:3004 -e MONGODB_URI="mongodb://172.17.0.1:27017/ecommerce_orders" dev8182/dockerfiles:order-service-v1.0
			  sudo docker run -d --name cart-service -p 3002:3002 -e MONGODB_URI="mongodb://172.17.0.1:27017/ecommerce_products" dev8182/dockerfiles:product-service-v1.0
			  sudo docker run -d --name cart-service -p 3001:3001 -e MONGODB_URI="mongodb://172.17.0.1:27017/ecommerce_users" dev8182/dockerfiles:user-service-v1.0
			  sudo docker run -d --name cart-service -p 3000:80 dev8182/dockerfiles:frontend-service-v1.0
  EOF                                                                                                             

}
