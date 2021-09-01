data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  user_data              = file("${path.module}/scripts/init.sh")
  key_name               = aws_key_pair.ec2.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]

  tags = {
    Name = "ansible-managed"
  }
}

resource "aws_key_pair" "ec2" {
  key_name   = "ansible-ec2-key"
  public_key = file("${path.module}/ec2.key.pub")
}

resource "aws_security_group" "ec2" {
  name        = "ansible-ec2-sgs"
  description = "allow ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "server" {
  zone_id = var.zone_id
  name    = "ansible.mlem-mlem.net"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.ec2.public_ip]
}

resource "aws_eip" "ec2" {
  instance = aws_instance.ec2.id
  vpc      = true
}
