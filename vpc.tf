############
## VPC
############
resource "aws_vpc" "kubernetes" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
}


############
## subnet
############
# Subnet (public)
resource "aws_subnet" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"
  cidr_block = "${var.vpc_cidr}"

}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.kubernetes.id}"
}
############
## Routing
############
resource "aws_route_table" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"

  # Default route through Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "kubernetes" {
  subnet_id = "${aws_subnet.kubernetes.id}"
  route_table_id = "${aws_route_table.kubernetes.id}"
}
