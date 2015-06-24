#--------------------------------------------------------------
# Instance
#--------------------------------------------------------------
resource "aws_instance" "main" {
    # The connection block tells our provisioner how to
    # communicate with the resource (instance)
    connection {
      # The default username for our AMI
      user = "ubuntu"

      # The path to your keyfile
      key_file = "${var.key_path}"
    }
   
    instance_type = "t2.micro"

    # Trusty 14.04
    ami = "ami-2a734c42"

    # This will create 1 instances
    count = 1

    subnet_id = "${aws_subnet.main.id}"
    security_groups = ["${aws_security_group.allow_all.id}"]

    # Key name to SSH to
    key_name = "tuannh@office"

    # We run a remote provisioner on the instance after creating it.
    # In this case, we just install nginx and start it. By default,
    # this should be on port 80
    provisioner "remote-exec" {
      inline = [
          "sudo apt-get -y update",
          "sudo apt-get -y install nginx",
          "sudo service nginx start"
      ]
    }
}

#--------------------------------------------------------------
# Security Group
#--------------------------------------------------------------
resource "aws_security_group" "allow_all" {
  name = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from anywhere
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#--------------------------------------------------------------
# VPC
#--------------------------------------------------------------
resource "aws_vpc" "main" {
    cidr_block = "172.31.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_subnet" "main" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "172.31.0.0/20"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "r" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
}

resource "aws_main_route_table_association" "a" {
    vpc_id = "${aws_vpc.main.id}"
    route_table_id = "${aws_route_table.r.id}"
}

#--------------------------------------------------------------
# SSH key
#--------------------------------------------------------------
resource "aws_key_pair" "deployer" {
  key_name = "tuannh@office" 
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8c06+38FkBJPlnWIW3PPjeXhhaBpwM//qHAQdob43RjLdO9KvMCmhY05+MZ1Pn8w58Fv/wyrD83Hgfi48408tpgtP9I4iV9/7+gk3/DDpJuG6hTOB/fWZUIlV6WcMElLMz3gzAd5uvaOtpuIeDM2lOMYqIgmpkPtLKMSzsTbaFieuqFGHIONVhXE6Qzncmx/Y3kElfyyj3n1MVmrvx5f3alxajCH4gRkYFm2xjIAH9544kc9JbCHaorhY9n2F4ugoZIIvLKtsNwKAEbBEyxYKvKOZQEyyfDl+SI6d4lINmug+Na/8YRfE17uAIXa8ip8Y3FViLC/C/iQ+hXlX0833 tuannh@tuannh-office"
}
