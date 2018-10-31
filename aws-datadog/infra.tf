# Chose AWS provider
provider "aws" {
	region = "${var.AWS_REGION}"
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
	}

# Create a VPC
resource "aws_vpc" "cloudapp" {
    cidr_block = "10.0.0.0/26"
    enable_dns_hostnames = true
    tags {
        Name = "cloudapp"
    }
}

# Create an IG and attach it to the VPC
resource "aws_internet_gateway" "cloudapp" {
    vpc_id = "${aws_vpc.cloudapp.id}"
    tags {
        Name = "cloudapp"
    }
}

# Create a subnet in the cloudapp VPC
resource "aws_subnet" "cloudapp" {
    vpc_id = "${aws_vpc.cloudapp.id}"
    cidr_block = "10.0.0.0/28"
    map_public_ip_on_launch = true
    tags {
        Name = "cloudapp"
    }
}

# Grant internet access to the VPC
resource "aws_route" "cloudapp" {
    route_table_id  = "${aws_vpc.cloudapp.main_route_table_id}"
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id  = "${aws_internet_gateway.cloudapp.id}"
}

# Create security group for elb
resource "aws_security_group" "cloudappelb" {
    name = "cloudappelb"
    description = "Security group for cloudapp elb"
    vpc_id = "${aws_vpc.cloudapp.id}"
    tags {
        Name = "cloudapp"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create the default security group
resource "aws_security_group" "cloudapp" {
    name        = "cloudappsg"
    description = "Default security group for cloudapp"
    vpc_id      = "${aws_vpc.cloudapp.id}"
    tags {
        Name = "cloudapp"
    }

  # Grant HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grant outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create cloudapp elb
resource "aws_elb" "cloudappelb" {
  name = "cloudappelb"
  subnets         = ["${aws_subnet.cloudapp.id}"]
  security_groups = ["${aws_security_group.cloudappelb.id}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

# Pointer to the userdata script
data "template_file" "user_data" {
	template = "${file("userdata.sh")}"
}

# Create a launch template
resource "aws_launch_template" "cloudapp" {
	name_prefix = "cloudapp"
	image_id = "${lookup(var.AMI, var.AWS_REGION)}"
	instance_type = "t2.micro"
	key_name = "${var.AWS_KEY_PAIR}"
	vpc_security_group_ids = ["${aws_security_group.cloudapp.id}"]
	user_data = "${base64encode(data.template_file.user_data.template)}"
	tags {
			Name = "cloudapp"
	}
}

# Create an Autoscaling group
resource "aws_autoscaling_group" "cloudapp" {
  vpc_zone_identifier = ["${aws_subnet.cloudapp.id}"]
  desired_capacity = 2
  max_size = 2
  min_size = 2
  load_balancers = ["${aws_elb.cloudappelb.name}"]
  launch_template = {
      id = "${aws_launch_template.cloudapp.id}"
      version = "$$Latest"
  }
  tags = [
      {
      key                 = "Name"
      value               = "cloudapp"
      propagate_at_launch = true
      }
  ]
}
