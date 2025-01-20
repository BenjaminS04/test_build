
resource "aws_instance" "ec2" {
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = "${var.each_key}-EC2InstanceProfile"
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    encrypted = "true"
  }

  user_data = <<-EOF
    #!/bin/bash

    
    # gets cloudwatch logging dependancies

    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    dpkg -i -E ./amazon-cloudwatch-agent.deb
    
    
    # unique instance user data

    ${var.additional_user_data} 

    EOF


  # forces instance to be remade if its user data changes
  user_data_replace_on_change = true


  lifecycle {
    # makes sure old resource stays live until new one is created to minimize down time
    create_before_destroy = true
  }


  # adds security group and subnet
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id

  tags = {
    # names instance
    Name = "${var.instance_name}"
  }
}