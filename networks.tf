# Creating the vpc for deploying the fortigate GW instances

resource "aws_vpc" "fortigate_vpc" {
  provider             = aws.my_region
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "fortigate_vpc"
  }
}

#Creating the data resource for getting the az's in the region
data "aws_availability_zones" "azs" {
  provider = aws.my_region
  state    = "available"

}

#Creating the 2 public and 2 private subnets in the created VPC

resource aws_subnet "fortigate_public1_publicwan" {
  provider          = aws.my_region
  vpc_id            = aws_vpc.fortigate_vpc.id
  cidr_block        = "192.168.100.0/26"
  availability_zone = data.aws_availability_zones.azs.names[0]
  tags = {
    "Name" = "fortigate_public1_publicwan"
  }

}



resource aws_subnet "fortigate_public2_ha" {
  provider          = aws.my_region
  vpc_id            = aws_vpc.fortigate_vpc.id
  cidr_block        = "192.168.100.64/26"
  availability_zone = data.aws_availability_zones.azs.names[0]
  tags = {
    "Name" = "fortigate_public2_ha"
  }

}


resource aws_subnet "fortigate_private1" {
  provider          = aws.my_region
  vpc_id            = aws_vpc.fortigate_vpc.id
  cidr_block        = "192.168.100.128/26"
  availability_zone = data.aws_availability_zones.azs.names[0]
  tags = {
    "Name" = "fortigate_private1"
  }

}

resource aws_subnet "fortigate_private2" {
  provider          = aws.my_region
  vpc_id            = aws_vpc.fortigate_vpc.id
  cidr_block        = "192.168.100.192/26"
  availability_zone = data.aws_availability_zones.azs.names[1]
  tags = {
    "Name" = "fortigate_private2"
  }

}



# Create the IGW and then attach it to the created VPC

resource aws_internet_gateway "FG_igw" {
  provider = aws.my_region
  vpc_id   = aws_vpc.fortigate_vpc.id

}


# Create the elastic ips for the nat GW's

resource "aws_eip" "eip1" {
  provider = aws.my_region


}




# Create the NAT GW's for the private subnets

resource "aws_nat_gateway" "nat_gw_1" {
  provider      = aws.my_region
  subnet_id     = aws_subnet.fortigate_public1_publicwan.id
  allocation_id = aws_eip.eip1.id
  tags = {
    "Name" = "nat_gw_1"
  }


}




#Create the public route table

resource "aws_route_table" "FG_pub_rt" {
  provider = aws.my_region
  vpc_id   = aws_vpc.fortigate_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.FG_igw.id
  }
  tags = {
    "Name" = "FG_pub_rt"
  }

}

# Create the private route tables

resource "aws_route_table" "FG_priv1_rt" {
  provider = aws.my_region
  vpc_id   = aws_vpc.fortigate_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
  tags = {
    "Name" = "FG_priv1_rt"
  }

}

resource "aws_route_table" "FG_priv2_rt" {
  provider = aws.my_region
  vpc_id   = aws_vpc.fortigate_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
  tags = {
    "Name" = "FG_priv2_rt"
  }

}


#Associating the subnets with the private and public route tables


resource "aws_route_table_association" "associate_public_subnets_1" {
  provider       = aws.my_region
  route_table_id = aws_route_table.FG_pub_rt.id
  subnet_id      = aws_subnet.fortigate_public1_publicwan.id

}

resource "aws_route_table_association" "associate_public_subnets_2" {
  provider       = aws.my_region
  route_table_id = aws_route_table.FG_pub_rt.id
  subnet_id      = aws_subnet.fortigate_public2_ha.id

}

resource "aws_route_table_association" "associate_private_subnets_1" {
  provider       = aws.my_region
  route_table_id = aws_route_table.FG_priv1_rt.id
  subnet_id      = aws_subnet.fortigate_private1.id

}
resource "aws_route_table_association" "associate_private_subnets_2" {
  provider       = aws.my_region
  route_table_id = aws_route_table.FG_priv2_rt.id
  subnet_id      = aws_subnet.fortigate_private2.id

}



#Creating a SG for attaching it to the fortigate Firewalls instances

resource "aws_security_group" "fortigate_allow" {
  provider = aws.my_region
  vpc_id   = aws_vpc.fortigate_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "fortigate_SG"
  }
}



resource "aws_eip" "ClusterPublicIP" {
  provider                  = aws.my_region
  depends_on                = [aws_instance.fgtactive]
  vpc                       = true
  network_interface         = aws_network_interface.eth0.id
  associate_with_private_ip = var.activeport1float
}




resource "aws_eip" "PassivePublicIP" {
  provider                  = aws.my_region
  depends_on                = [aws_instance.fgtpassive]
  vpc                       = true
  network_interface         = aws_network_interface.passiveeth0.id
  associate_with_private_ip = var.passiveport1
}


