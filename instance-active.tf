resource "aws_network_interface" "eth0" {
  provider    = aws.my_region
  description = "active-port1"
  subnet_id   = aws_subnet.fortigate_public1_publicwan.id
  private_ips = [var.activeport1, var.activeport1float]
}



resource "aws_network_interface" "eth1" {
  provider          = aws.my_region
  description       = "active-port2-hasync"
  subnet_id         = aws_subnet.fortigate_public2_ha.id
  private_ips       = [var.activeport2]
  source_dest_check = false
}




resource "aws_network_interface_sg_attachment" "publicattachment" {
  provider             = aws.my_region
  depends_on           = [aws_network_interface.eth0]
  security_group_id    = aws_security_group.fortigate_allow.id
  network_interface_id = aws_network_interface.eth0.id
}



resource "aws_network_interface_sg_attachment" "hasyncattachment" {
  provider             = aws.my_region
  depends_on           = [aws_network_interface.eth1]
  security_group_id    = aws_security_group.fortigate_allow.id
  network_interface_id = aws_network_interface.eth1.id
}


resource "aws_instance" "fgtactive" {
  provider             = aws.my_region
  ami                  = var.ami
  instance_type        = "t2.small"
  iam_instance_profile = "fortigate_aws"

  root_block_device {
    volume_type = "standard"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }

  network_interface {
    network_interface_id = aws_network_interface.eth0.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eth1.id
    device_index         = 1
  }

  tags = {
    Name = "Fortigate_Active"
  }
}

