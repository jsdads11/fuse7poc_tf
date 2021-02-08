# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE ALL THE RESOURCES TO DEPLOY AN APP IN AN AUTO SCALING GROUP WITH AN ELB
# This template runs a simple "Hello, World" web server in Auto Scaling Group (ASG) with an Elastic Load Balancer
# (ELB) in front of it to distribute traffic across the EC2 Instances in the ASG.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#.
#├── dev
#│   └── webserver-cluster
#│       ├── main.tf
#│       ├── terraform.tfstate
#│       └── terraform.tfstate.backup
#└── services
#    └── webserver-cluster
#        ├── autoscalinggroups.tf
#        ├── autoscalingpolicy.tf
#        ├── elbs.tf
#        ├── main.tf
#        ├── outputs.tf
#        ├── securitygroups.tf
#        └── variables.tf

# run me=: curl http://varname ... terraform-asg-example-123.us-east-2.elb.amazonaws.com
# -> Hello, World

# ---------------------------------------------------------------------------------------------------------------------
# GET THE LIST OF AVAILABILITY ZONES IN THE CURRENT REGION
# Every AWS accout has slightly different availability zones in each region. For example, one account might have
# us-east-1a, us-east-1b, and us-east-1c, while another will have us-east-1a, us-east-1b, and us-east-1d. This resource
# queries AWS to fetch the list for the current account and region.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "all" {}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAUNCH CONFIGURATION THAT DEFINES EACH EC2 INSTANCE IN THE ASG (AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0aef57767f5404a3c"      # Ubunto/busybox
  #image_id        = "ami-0c55b159cbfafe1f0"
  key_name        = var.my_key_name
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

