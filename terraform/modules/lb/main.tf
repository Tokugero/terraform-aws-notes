resource "aws_instance" "web" {
  for_each          = data.aws_subnet_ids.default.ids
  ami               = data.aws_ami.AL2.id
  instance_type     = "t3.micro"
  key_name          = "bastion"
  security_groups   = [ aws_security_group.allow_web.id ]

  subnet_id         = each.value
  
  tags = {
    Name            = "HelloWorld"
    function        = "web"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y nginx1.12",
      "sudo systemctl start nginx"
    ]

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
    }
  }
}

resource "aws_lb" "inbound" {
  name               = "inboundweb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = data.aws_subnet_ids.default.ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "web" {
  name               = "web"
  port               = 80
  protocol           = "HTTP"
  vpc_id             = data.aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "web" {
  for_each          = aws_instance.web
  target_group_arn  = aws_lb_target_group.web.arn
  target_id         = each.value.id
}

resource "aws_lb_listener" "web" {
  load_balancer_arn  = aws_lb.inbound.arn
  port                = 80
  protocol            = "HTTP"
  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.web.arn
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow inbound web traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "web"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "ssh"
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
