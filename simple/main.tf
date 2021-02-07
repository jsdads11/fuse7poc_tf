# simple example -> move to modules in next phase

# run me=: curl http://terraform-asg-example-123.us-east-2.elb.amazonaws.com
# -> Hello, World

provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "all" {}


resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id
  availability_zones   = data.aws_availability_zones.all.names
  
  min_size = 2
  max_size = 10  

  load_balancers    = [aws_elb.example.name]
  health_check_type = "ELB"

tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}


resource "aws_launch_configuration" "example" {
  image_id        = "ami-0aef57767f5404a3c"      # Ubunto/busybox
  #image_id        = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  user_data = <<-EOF
     #!/bin/bash
     echo "Hello, World" > index.html
     nohup busybox httpd -f -p "${var.server_port}" &
     EOF  
  lifecycle {
    create_before_destroy = true
 }
}


resource "aws_instance" "example" {
  #ami          = "ami-032e5b6af8a711f30"
  ami           = "ami-0aef57767f5404a3c"      # Ubunto/busybox
  instance_type = "t2.micro"
  key_name      = "ej-digital-sandbox-keypair-poc"

  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" 8080 &
              EOF
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = ["217.44.197.50/32"]
  }
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP of the web server"
}







resource "aws_security_group" "elb" {
  name = "terraform-example-elb"  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  # Inbound HTTP from anywhere

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "example" {
  name               = "terraform-asg-example"
  availability_zones = data.aws_availability_zones.all.names  

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }


# This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

