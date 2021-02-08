
resource "aws_elb" "example" {
  name               = var.cluster_name
  #subnets            = [aws.subnet.id]
  #availability_zones = data.aws_availability_zones.all.names
  availability_zones = ["eu-west-1a"]
  security_groups    = [aws_security_group.elb.id]

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

/*

resource "aws_elb" "example" {
  name               = var.cluster_name

  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  access_logs {
    bucket        = "foo"
    bucket_prefix = "bar"
    interval      = 60
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    #ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
    ssl_certificate_id = "arn:aws:acm:eu-west-1:735669335807:certificate/1f2e098b-03d0-498b-8560-ef9d41acb051"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.foo.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    Name = "foobar-terraform-elb"
  }
}
*/
