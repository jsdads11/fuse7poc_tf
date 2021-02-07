# modularised version  -> move to modules in next phase

# run me=: curl http://varname ... terraform-asg-example-123.us-east-2.elb.amazonaws.com
# -> Hello, World


data "aws_availability_zones" "all" {}


resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id
  availability_zones   = data.aws_availability_zones.all.names
  
  min_size = var.min_size
  max_size = var.max_size

  load_balancers    = [aws_elb.example.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}


resource "aws_launch_configuration" "example" {
  image_id        = "ami-0aef57767f5404a3c"      # Ubunto/busybox
  #image_id        = "ami-0c55b159cbfafe1f0"
  instance_type   = var.instance_type
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


resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

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


resource "aws_elb" "example" {
  name               = var.cluster_name
  security_groups    = [aws_security_group.elb.id] 
  subnets            = ["subnet-f9bf2ca3"]
  #availability_zones = data.aws_availability_zones.all.names  

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

# This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}


resource "aws_security_group" "elb" {
  #name = "terraform-example-elb"  # Allow all outbound
  name = "${var.cluster_name}-elb"  # Allow all outbound

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  # Inbound HTTP from anywhere

  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

