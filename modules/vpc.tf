locals {
  cluster_name = var.cluster_name
}

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = var.vpc_name
        Env = var.env
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = var.igw_name
      Env = var.env
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    }
    depends_on = [ aws_vpc.vpc ]
}

resource "aws_subnet" "public_subnet" {
    count = var.pub_subnet_count
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.pub_sub_cidr_block, count.index)
    availability_zone = element(var.az_list, count.index)
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.pub_sub_name}-${count.index + 1}"
        Env = var.env
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
        "kubernetes.io/role/elb" = 1
    }
    depends_on = [ aws_vpc.vpc ]
}

resource "aws_subnet" "private_subnet" {
    count = var.priv_subnet_count
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.priv_sub_cidr_block, count.index)
    availability_zone = element(var.az_list, count.index)
    map_public_ip_on_launch = false

    tags = {
        Name = "${var.priv_sub_name}-${count.index + 1}"
        Env = var.env
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
        "kubernetes.io/role/elb" = 1
    }
    depends_on = [ aws_vpc.vpc ]
}

resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id   
    }
    
    tags = {
        Name = var.pub_rt_name
        Env = var.env
    }
    depends_on = [ aws_vpc.vpc ]
}

resource "aws_route_table_association" "pub-rt-association" {
    count = var.pub_subnet_count
    route_table_id = aws_route_table.public-rt.id
    subnet_id = aws_subnet.public_subnet[count.index].id

    depends_on = [ aws_vpc.vpc,
    aws_subnet.public_subnet ]
}

resource "aws_eip" "ngw-eip" {
    domain = "vpc"
    
    tags = {
        Name = var.ngw_eip_name
        Env = var.env
    }
    depends_on = [ aws_vpc.vpc ]
}

resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.ngw-eip.id
    subnet_id = aws_subnet.private_subnet[0].id

    tags = {
        Name = var.nat_gw_name
        Env = var.env
    }
    depends_on = [ aws_vpc.vpc, aws_eip.ngw-eip ]
}

resource "aws_route_table" "priv-rt" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.ngw.id
    }
    
    tags = {
        Name = var.priv_rt_name
        Env = var.env
    }
    depends_on = [ aws_vpc.vpc ]
  
}

resource "aws_route_table_association" "priv-rt-association" {
    count = var.priv_subnet_count
    route_table_id = aws_route_table.priv-rt.id
    subnet_id = aws_subnet.private_subnet[count.index].id

    depends_on = [ aws_vpc.vpc,
    aws_subnet.private_subnet ]
}

resource "aws_security_group" "eks-cluster-sg" {
    name = var.cluster_name
    description = "Allow 443 from jump server only!"
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"] //Replace it with the IP of your Jump server
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = var.cluster_sg_name
        Env = var.env
    }
  
}