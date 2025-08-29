terraform {
  cloud {
    organization = "Jlee7"
    workspaces {
      name = "TerraformWeek22WorkSpace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  tags = { Name = "2TierArchitecture" }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "public1" }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "public2" }
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = { Name = "private1" }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = { Name = "private2" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "InternetGateway2023" }
}

resource "aws_route_table" "Web_Tier" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0" gateway_id = aws_internet_gateway.gw.id }
  tags = { Name = "Web_Tier" }
}

resource "aws_route_table_association" "Web_tier1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.Web_Tier.id
}

resource "aws_route_table_association" "Web_tier2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.Web_Tier.id
}

resource "aws_eip" "nat_eip" { vpc = true }

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public2.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0" nat_gateway_id = aws_nat_gateway.gw.id }
  tags = { Name = "PrivateRoute" }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "albsg" {
  name        = "albsg"
  description = "security group for alb"
  vpc_id      = aws_vpc.main.id

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

resource "aws_security_group" "web_tier" {
  name        = "web_tier"
  description = "web and SSH allowed"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.albsg.id]
  }

  ingress {
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
}

resource "aws_security_group" "db_tier" {
  name        = "db_tier"
  description = "allow traffic from Web Tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_tier" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element([aws_subnet.public1.id, aws_subnet.public2.id], count.index)
  vpc_security_group_ids      = [aws_security_group.web_tier.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<html><body><h1>Hello World from Web Tier ${count.index + 1}!</h1></body></html>" > /var/www/html/index.html
  EOF

  tags = { Name = "web-tier-${count.index + 1}" }
}

resource "aws_lb" "myalb" {
  name               = "2TierApplicationLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
  security_groups    = [aws_security_group.albsg.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "projecttg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "tgattach" {
  count            = 2
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web_tier[count.index].id
  port             = 80
}

resource "aws_lb_listener" "listenerlb" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_db_subnet_group" "sub_4_db" {
  name       = "sub_4_db"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
  tags       = { Name = "My DB subnet group" }
}

resource "aws_db_instance" "the_db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.sub_4_db.name
  vpc_security_group_ids = [aws_security_group.db_tier.id]
  db_name                = "appdb"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
}
