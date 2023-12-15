data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [module.module_security_group.id]

  tags = {
    Name = "HelloWorld"
  }
}

module "module_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  
  vpc_id = aws_vpc.blog_vpc.id

  name                = "blog_module_sg"
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

data "aws_vpc" "blog_vpc" {
  default = true
}

resource "aws_security_group" "blog_sg" {
  name        = "blog_sg"
  description = "Allow http & https in. Allow everything out."

  vpc_id      = data.aws_vpc.blog_vpc.id
}

resource "aws_security_group_rule" "http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog_sg.id
}

resource "aws_security_group_rule" "https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog_sg.id
}

resource "aws_security_group_rule" "everything_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog_sg.id
}
