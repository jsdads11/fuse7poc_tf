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

