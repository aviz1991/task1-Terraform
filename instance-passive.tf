resource "aws_network_interface" "passiveeth0" {
  provider    = aws.my_region
  description = "passive-port1"
  subnet_id   = aws_subnet.fortigate_public1_publicwan.id
  private_ips = [var.passiveport1]
}

resource "aws_network_interface" "passiveeth1" {
  provider          = aws.my_region
  description       = "passive-port2"
  subnet_id         = aws_subnet.fortigate_public2_ha.id
  private_ips       = [var.passiveport2]
  source_dest_check = false
}





resource "aws_network_interface_sg_attachment" "passivepublicattachment" {
  provider             = aws.my_region
  depends_on           = [aws_network_interface.passiveeth0]
  security_group_id    = aws_security_group.fortigate_allow.id
  network_interface_id = aws_network_interface.passiveeth0.id
}

resource "aws_network_interface_sg_attachment" "passivehasyncattachment" {
  provider             = aws.my_region
  depends_on           = [aws_network_interface.passiveeth1]
  security_group_id    = aws_security_group.fortigate_allow.id
  network_interface_id = aws_network_interface.passiveeth1.id
}


resource "aws_instance" "fgtpassive" {
  provider             = aws.my_region
  depends_on           = [aws_instance.fgtactive]
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
    network_interface_id = aws_network_interface.passiveeth0.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.passiveeth1.id
    device_index         = 1
  }
  tags = {
    Name = "FortiGateVM Passive"
  }
}

